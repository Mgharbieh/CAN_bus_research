import tree_sitter as TreeSitter
from ..libFlags import LibFlags as flags

import tree_sitter_cpp as _CPP
CPP_LANGUAGE = TreeSitter.Language(_CPP.language())

class MaskAndFilter():
    def __init__(self):
        self.strList = []
        self.maskList = []
        self.setupFilterList = []
        self.loopFilterList = []
        self.lineNums = [] 
        self.libraryDescriptor = []

    def _reset(self):
        self.strList = []
        self.maskList = []
        self.setupFilterList = []
        self.loopFilterList = []
        self.lineNums = [] 
        self.libraryDescriptor = []

    #############################################################################
    def _maskSearch(self, root, lib):    
        maskQuery = '''
            (function_definition
                (function_declarator 
                    (identifier) @func_Decl
                        ;;(#eq? @func_Decl "setup")
                )
                (compound_statement
                    (expression_statement
                        (call_expression
                            (field_expression
                                (field_identifier) @fd_Name
                            )
                            arguments: (argument_list) @args
                            (#match? @fd_Name "[mM]ask")
                        )
                    )
                )
            )
            '''

        query = TreeSitter.Query(CPP_LANGUAGE, maskQuery)
        queryCursor = TreeSitter.QueryCursor(query)
        captures = queryCursor.captures(root)
        for cap in captures:
            if cap == 'args':
                argList = captures[cap]
                for args in argList:
                    for node in args.children:
                        if(node.type == "number_literal" and ('0x' in node.text.decode())):
                            self.maskList.append((node.text.decode(), node.start_point.row + 1))
                            
            if cap == 'fd_Name':
                fdNameList = captures[cap]
                for fd in fdNameList:
                    functionText = fd.text.decode()
                    if(functionText == "init_Mask"): 
                        lib.maskDescriptor = flags.SEEED_ARDUINO_CAN
                        break
                    elif(functionText == "setFilterMask"):
                        lib.maskDescriptor = flags.arduino_mcp_2515
                        break
                    elif(functionText == "setMask"):
                        lib.maskDescriptor = flags.CAN_Library
                        break
                    
    #############################################################################
    def _filterSetupSearch(self, root, lib):
        setupFilterQuery = '''
        (function_definition
            (function_declarator 
                (identifier) @func_Decl
                    ;;(#eq? @func_Decl "setup")
            )
            (compound_statement
                (expression_statement
                    (call_expression
                        (field_expression
                            (field_identifier) @fd_Name
                        )
                        arguments: (argument_list) @args
                        (#match? @fd_Name "[fF]ilt")
                        (#not-match? @fd_Name "[mM]ask")  
                    )
                )
            )
        )
        '''

        query = TreeSitter.Query(CPP_LANGUAGE, setupFilterQuery)
        queryCursor = TreeSitter.QueryCursor(query)
        captures = queryCursor.captures(root)
        for cap in captures:
            if cap == 'args':
                argList = captures[cap]
                for args in argList:
                    for node in args.children:
                        if(node.type == "number_literal" and ('0x' in node.text.decode())):
                            self.setupFilterList.append((node.text.decode(), node.start_point.row + 1))
            if cap == 'fd_Name':
                fdNameList = captures[cap]
                for fd in fdNameList:
                    functionText = fd.text.decode()
                    if(functionText == "init_Filt"): 
                        lib.filtDescriptor = flags.SEEED_ARDUINO_CAN
                        break
                    elif(functionText == "setFilter"):
                        lib.filtDescriptor = flags.arduino_mcp_2515
                        break
    #############################################################################
    def _loopFilterSearch(self, root, lib):

        HEX_CHARS = ['x', 'A', 'B', 'C', 'D', 'E', 'F']

        loopFilterQuery = '''
        (function_definition
            (function_declarator 
                (identifier) @func_Decl
                    (#not-eq? @func_Decl "setup")
            )
            body: (compound_statement 
                [(if_statement
                    (condition_clause
                        (binary_expression
                            (call_expression
                                function: (field_expression) @target_func
                                arguments: (argument_list) @args
                                    (#not-match? @target_func "check[rR]eceive")
                                    (#not-match? @target_func "mcp2515.sendMessage")
                            )
                        )
                    )
                )
                (if_statement
                    (compound_statement
                        (expression_statement
                            (call_expression
                                function: (field_expression) @target_func
                                arguments: (argument_list) @args
                            )
                        )
                    )
                )
                (expression_statement
                    (call_expression 
                        function: (field_expression) @target_func
                        arguments: (argument_list) @args
                    )
                )
                (declaration
                    (init_declarator
                        (call_expression 
                            function: (field_expression) @target_func
                            arguments: (argument_list) @args
                        )
                    )
                )]
            ) @function.body
        )

        (#match? @target_func "^[cC][aA][nN](\d*)\.$") 
        (#match? @target_func "^[mM][cC][pP]2515$")
        '''

        query = TreeSitter.Query(CPP_LANGUAGE, loopFilterQuery)
        queryCursor = TreeSitter.QueryCursor(query)
        captures = queryCursor.captures(root)
        loopText = ""
        loopTextStartLine = -1
        for cap in captures:
            if(cap == 'function.body'):
                for capID in captures[cap]:
                    tempText = capID.text.decode()
                    if("setFilt" in tempText):
                        continue
                    else:
                        loopText = tempText
                        loopTextStartLine =  capID.start_point.row + 1
            if(cap == 'target_func'):
                funcList = captures[cap]
                for funcIDX in range(0, len(funcList)):
                    functionText = funcList[funcIDX].text.decode()
                    if("readMsgBuf" in functionText):
                        if(captures["args"][funcIDX].named_child_count == 2):
                            lib.recvDescriptor = flags.SEEED_ARDUINO_CAN
                            lib.recvArgLength = 2
                            break
                        elif(captures["args"][funcIDX].named_child_count == 3):
                            lib.recvDescriptor = flags.MCP_CAN_lib
                            lib.recvArgLength = 3
                            break
                    elif("readMessage" in functionText):
                        lib.recvDescriptor = flags.arduino_mcp_2515
                        lib.recvArgLength = 2
                        break

        loopText = loopText.splitlines()
        for line_idx in range(0, len(loopText)):
            line = loopText[line_idx]
            if(('if' in line) or ('case' in line)):
                if(('0x' in line) or ('if' in line and '==' in line)):
                    chars = list(line)
                    hexVal = ''
                    idx = 0
                    while(idx < len(chars)):
                        currentChar = chars[idx]
                        if((chars[idx] == '0') and (chars[idx+1] == 'x')):

                            hexVal += chars[idx]
                            hexVal += chars[idx+1]
                            idx += 2
                            continue
                        elif((len(hexVal) >= 2) and ((chars[idx].isdigit()) or (chars[idx].upper() in HEX_CHARS))):
                            hexVal += chars[idx]
                        else:
                            #if('0x' in hexVal[:2] and (len(hexVal) > 2 and len(hexVal) < 6)): #Only works for standard IDs now, will figure out extended later
                            if('0x' in hexVal[:2] ):
                                if((hexVal == '0x40000000') or (hexVal == '0x80000000')):
                                    hexVal = ''
                                    continue
                                elif(hexVal not in self.loopFilterList):
                                    self.loopFilterList.append((hexVal, loopTextStartLine + line_idx))
                                    hexVal = ''
                        idx += 1                    
    #############################################################################
    def _maskFilterCheck(self, root, libraryAnalyzer):

        self._maskSearch(root, libraryAnalyzer)
        self._filterSetupSearch(root, libraryAnalyzer)
        self._loopFilterSearch(root, libraryAnalyzer)
    
        maskSetupWarn = False
        maskWarn = False
        usageWarn = False
        unusedList = []

        excludedWarn = False
        excludeList = []

        returnList = []

        if(len(self.maskList) == 0 and len(self.setupFilterList) == 0 and len(self.loopFilterList) == 0):
            print("#"*100,'\n')
            print("No Mask/Filter usage found\n")
            returnList.append("No Mask/Filter usage found")
            print("#"*100,'\n')
            return 0, returnList
        elif(len(self.maskList) == 0 and len(self.setupFilterList) > 0):
            maskSetupWarn = True
        elif(len(self.maskList) == 0 and len(self.setupFilterList) == 0 and len(self.loopFilterList) > 0):
            print("#"*100,'\n')
            print("No filters were set during initialization, but address checking is being done.  Consider adding filters during initialization to optimize this code.\n")
            returnList.append("No filters were set during initialization, but address checking is being done.  Consider adding filters during initialization to optimize this code.")
            print("#"*100,'\n')
            return 0, returnList

        for filterPair in self.setupFilterList:
            filter = filterPair[0]
            for mask in self.maskList:
                if((int(mask[0], 16) & int(filter, 16)) != int(filter, 16)):
                    maskWarn = True
                    if(mask[1] not in self.lineNums):
                        self.lineNums.append(mask[1]) 
            
            if(len([el[0] for el in self.loopFilterList if el[0] == filter]) == 0):
                usageWarn = True
                unusedList.append(filter)
                if(filterPair[1] not in self.lineNums):
                    self.lineNums.append(filterPair[1])
        
        for filtPair in self.loopFilterList:
            filt = filtPair[0]
            
            if(len([el[0] for el in self.setupFilterList if el[0] == filt]) == 0):
                excludedWarn = True
                excludeList.append(filt)
                if(filtPair[1] not in self.lineNums):
                    self.lineNums.append(filtPair[1])

        issues = 0
        print("#"*100,'\n')
        if(maskSetupWarn):
            issues += 1
            print(f'Filters {self.setupFilterList} were set up during initialization but no masks were set!') if len(self.setupFilterList) > 1 else print(f'Filter {self.setupFilterList} was set up during initialization but no masks were set!')
            returnList.append(f'Filters {self.setupFilterList} were set up during initialization but no masks were set!') if len(self.setupFilterList) > 1 else returnList.append(f'Filter {self.setupFilterList} was set up during initialization but no masks were set!')
        if(maskWarn):   
            issues += 1
            print("Mask(s) set aren't applied across the full filter value. Is that intentional?")
            returnList.append("Mask(s) set aren't applied across the full filter value. Is that intentional?")
        if(usageWarn and (len(self.setupFilterList) > 1)):
            issues += 1
            print(unusedList, "were setup in the filter but never explicitly used.") if len(unusedList) > 1 else print(unusedList, "was setup in the filter but never explicitly used.")
            returnList.append(str(unusedList) + " were setup in the filter but never explicitly used.") if len(unusedList) > 1 else returnList.append(str(unusedList) + " was setup in the filter but never explicitly used.")
        else:
            usageWarn = False 
        if(excludedWarn):
            issues += 1
            print(excludeList, "were being checked but are excluded from the filter.") if len(excludeList) > 1 else print(excludeList, "was being checked but is excluded from the filter.")
            returnList.append(f"{excludeList} were being checked but are excluded from the filter.") if len(excludeList) > 1 else returnList.append(f"{excludeList} was being checked but is excluded from the filter.")

        if((not maskSetupWarn) and (not maskWarn) and (not usageWarn) and (not excludedWarn)):
            print("No Mask/Filter issues detected!")
            returnList.append("No Mask/Filter issues detected!")
        print()
        print("#"*100)
        return issues, returnList
    #############################################################################
    def checkMaskFilter(self, root, libraryAnalyzer):
        self._reset()
        totalIssues, messages = self._maskFilterCheck(root, libraryAnalyzer)
        return totalIssues, messages, self.lineNums