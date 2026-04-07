import tree_sitter as TreeSitter
import tree_sitter_cpp as _CPP
CPP_LANGUAGE = TreeSitter.Language(_CPP.language())

class DataBytePackingAnalyzer:
    def __init__(self):
        self.buf_sizes = {} #declared byte buffers like: byte stmp[8];
        self.dlc_values = {} #DLC values assigned to variables or frame fields ex. canMsg.can_dlc = 8 
        self.frame_bytes = {} #track max bytes written into frame.data[] ex.canMsg.data[8] is 9 bytes
        self.lineNums = []

    def _reset(self):
        self.buf_sizes = {}
        self.dlc_values = {}
        self.frame_bytes = {}
        self.lineNums = []

    #helpers
    def _cap(self, root, q: str):
        query = TreeSitter.Query(CPP_LANGUAGE, q)
        cursor = TreeSitter.QueryCursor(query)
        return cursor.captures(root)

    def _txt(self, node):
        if node is None:
            return ""
        return node.text.decode("utf-8", "ignore").strip()

    def _int(self, node):
        try:
            return int(self._txt(node), 0)
        except Exception:
            return None

    #queries
    #find declared data buffers (BYTES side), ex. byte stmp[8]; or uint8_t data[7];
    def _buf_decl_search(self, root):
        q = r"""
        (
          (declaration
            declarator: (init_declarator
              declarator: (array_declarator
                declarator: (identifier) @buf
                size: (number_literal) @n
              )
            )
          )
        )
        """
        caps = self._cap(root, q)
        for b, n in zip(caps.get("buf", []), caps.get("n", [])):
            name = self._txt(b)
            size = self._int(n)
            if name and size is not None:
                self.buf_sizes[name] = size
    #find DLC assignments (DLC side), ex. dlc = 8; or canMsg.can_dlc = 8;
    def _dlc_assign_search(self, root):
        q = r"""
        ;dlc can be assigned in 3 diff ways
        (
          (assignment_expression
            left: (identifier) @name
            right: (number_literal) @val        ;simple assignment
          )
        )

        (
          (declaration
            declarator: (init_declarator
              declarator: (identifier) @name2
              value: (number_literal) @val2     ;declaration with assignment
            )
          )
        )

        (
          (assignment_expression
            left: (field_expression
              argument: (identifier) @obj
              field: (field_identifier) @field
            )
            right: (number_literal) @val3       ;object field assignment
          )
          (#match? @field "^(can_dlc|length|dlc)$")
        )
        """
        caps = self._cap(root, q)

        #dlcVar = 8;
        for n, v in zip(caps.get("name", []), caps.get("val", [])):
            key = self._txt(n)
            val = self._int(v)
            if key and val is not None:
                self.dlc_values.setdefault(key, []).append((n.start_byte, val))

        #int dlcVar = 8;
        for n, v in zip(caps.get("name2", []), caps.get("val2", [])):
            key = self._txt(n)
            val = self._int(v)
            if key and val is not None:
                self.dlc_values.setdefault(key, []).append((n.start_byte, val))

        #canMsg.can_dlc = 8;  (and other dlc field names)
        for o, f, v in zip(caps.get("obj", []), caps.get("field", []), caps.get("val3", [])):
            obj = self._txt(o)
            field = self._txt(f)
            val = self._int(v)
            if obj and field and val is not None:
                self.dlc_values.setdefault(f"{obj}.{field}", []).append((o.start_byte, val))

        #keep assignments sorted so "latest before call" works
        for k in self.dlc_values:
            self.dlc_values[k].sort(key=lambda x: x[0])
    #finds max bytes written into frame.data[] (BYTES side)
    def _frame_bytes_search(self, root):
        #frame.data[idx] 
        q1 = r"""
        (
          (assignment_expression
            left: (subscript_expression
              argument: (field_expression
                argument: (identifier) @frame
                field: (field_identifier) @field
              )
              (subscript_argument_list (number_literal) @idx)
            )
            right: (_)
          ) @hit
          (#match? @field "^data$")
        )
        """
        caps1 = self._cap(root, q1)

        hits = caps1.get("hit", [])
        frames = caps1.get("frame", [])
        idxs = caps1.get("idx", [])
        #max index written to frame.data[] and adds 1 for byte count
        for k in range(min(len(hits), len(frames), len(idxs))):
            frame = self._txt(frames[k])
            i = self._int(idxs[k])
            if frame and i is not None:
                self.frame_bytes[frame] = max(self.frame_bytes.get(frame, 0), i + 1)

        #memcpy(frame.data, src, size)
        q2 = r"""
        (
          (call_expression
            function: (identifier) @fn
            arguments: (argument_list) @args
          ) @call
          (#match? @fn "^memcpy$")
        )
        """
        caps2 = self._cap(root, q2)
        for args_node in caps2.get("args", []):
            args = [c for c in args_node.children if c.type not in ("(", ")", ",")] #filter out non-argument nodes
            if len(args) < 3:
                continue

            dest = self._txt(args[0])
            src = self._txt(args[1])

            #only count memcpy writes into ".data"
            if not dest.endswith(".data"):
                continue

            frame = dest.split(".")[0].strip()
            #Size may be literal or based on a known buffer variable
            size = self._int(args[2])
            if size is None and src in self.buf_sizes:
                size = self.buf_sizes[src]

            if frame and size is not None:
                self.frame_bytes[frame] = max(self.frame_bytes.get(frame, 0), size)

    #find CAN send calls and their arguments (to get DLC and BYTES)
    def _can_calls(self, root):
        q = r"""
        (
          (call_expression
            function: (field_expression
              argument: (_) @obj
              field: (field_identifier) @method
            )
            arguments: (argument_list) @args
          ) @call
          (#match? @method "(?i)^(sendMsgBuf|sendMessage|write)$")
        )
        """
        caps = self._cap(root, q)
        return list(zip(caps.get("call", []), caps.get("args", [])))
    
    #resolve most recent DLC assignment before call position (should work in setup() and loop())
    def _resolve_dlc_before(self, key, call_pos):
        if key not in self.dlc_values:
            return None
        dlc = None
        for pos, val in self.dlc_values[key]:
            if pos <= call_pos:
                dlc = val
            else:
                break
        return dlc

    #compare DLC and BYTES and format output
    def _compare(self, call_txt, dlc, bytes_sent, assumed):
        suffix = " (Assumed DLC=8)" if assumed else ""
        if bytes_sent is None:
            # informational, not counted as an "issue"
            return f"{call_txt} DLC={dlc} BYTES=unknown.{suffix}", 0

        if dlc == bytes_sent:
            return f"{call_txt} DLC={dlc} matches BYTES={bytes_sent}. No issues found.{suffix}", 0
        if dlc < bytes_sent:
            return f"{call_txt}  DLC={dlc} < BYTES={bytes_sent}. (Overflow){suffix}", 1
        return f"{call_txt}  DLC={dlc} > BYTES={bytes_sent}. (Underflow){suffix}", 1

    #analyzes a single CAN send call and calls compare
    def _analyze_call(self, call_node, args_node):
        if call_node is None or args_node is None:
            return None, 0

        call_txt = self._txt(call_node)
        line_num = call_node.start_point.row + 1 if call_node is not None else None

        fn_node = call_node.child_by_field_name("function")
        fn_txt = self._txt(fn_node).lower() if fn_node is not None else call_txt.lower()

        args = [c for c in args_node.children if c.type not in ("(", ")", ",")] 

        #mcp2515.sendMessage(&canMsg)
        if "sendmessage" in fn_txt and len(args) >= 1:
            frame = self._txt(args[0]).lstrip("&").strip()

            dlc = (
                self._resolve_dlc_before(f"{frame}.can_dlc", call_node.start_byte)
                or self._resolve_dlc_before(f"{frame}.length", call_node.start_byte)
                or self._resolve_dlc_before(f"{frame}.dlc", call_node.start_byte)
            )

            assumed = False
            if dlc is None:
                dlc = 8
                assumed = True

            msg, inc = self._compare(call_txt, dlc, self.frame_bytes.get(frame), assumed)
            return msg, inc, line_num

        #CAN.write(frame)
        if "write" in fn_txt and len(args) == 1:
            frame = self._txt(args[0])

            dlc = (
                self._resolve_dlc_before(f"{frame}.length", call_node.start_byte)
                or self._resolve_dlc_before(f"{frame}.can_dlc", call_node.start_byte)
                or self._resolve_dlc_before(f"{frame}.dlc", call_node.start_byte)
            )

            assumed = False
            if dlc is None:
                dlc = 8
                assumed = True

            msg, inc = self._compare(call_txt, dlc, self.frame_bytes.get(frame), assumed)
            return msg, inc, line_num

        #sendMsgBuf(..., dlc, buf) or write(id,type,dlc,buf)
        if len(args) >= 2:
            dlc_node, buf_node, bytes_sent = None, None, None

            if "write" in fn_txt and len(args) >= 4:
                dlc_node, buf_node = args[2], args[3]
            elif "sendmsgbuf" in fn_txt and len(args) == 5:
                rtr_node = args[2]
                rtr_val = self._int(rtr_node)
                if rtr_val is None:
                    rtr_val = self._resolve_dlc_before(self._txt(rtr_node), call_node.start_byte)
                if rtr_val:
                    return None, 0, line_num
                dlc_node, buf_node = args[3], args[4]
            else:
                dlc_node, buf_node = args[-2], args[-1]

            buf = self._txt(buf_node)
            bytes_sent = self.buf_sizes.get(buf)

            dlc = self._int(dlc_node)
            if dlc is None:
                dlc = self._resolve_dlc_before(self._txt(dlc_node), call_node.start_byte)

            assumed = False
            if dlc is None:
                dlc = 8
                assumed = True

            msg, inc = self._compare(call_txt, dlc, bytes_sent, assumed)
            return msg, inc, line_num

        return None, 0, line_num
    def checkDataPack(self, root):
        self._buf_decl_search(root)
        self._dlc_assign_search(root)
        self._frame_bytes_search(root)

        messages = []
        issues = 0

        for call_node, args_node in self._can_calls(root):
            msg, inc, line_num = self._analyze_call(call_node, args_node)
            if msg:
                messages.append(msg)
                issues += inc
                if inc > 0 and line_num is not None and line_num not in self.lineNums:
                    self.lineNums.append(line_num)

        lineNums = self.lineNums.copy()
        self._reset()
        return issues, messages, lineNums