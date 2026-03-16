import tree_sitter as TreeSitter

import tree_sitter_cpp as _CPP
CPP_LANGUAGE = TreeSitter.Language(_CPP.language())

class MaskAndFilter():
    def __init__(self):
        self.strList = []
        self.maskList = []
        self.setupFilterList = []
        self.loopFilterList = []
        self.libraryDescriptor = []

    def _reset(self):
        self.strList = []
        self.maskList = []
        self.setupFilterList = []
        self.loopFilterList = []
        self.libraryDescriptor = []

    #############################################################################
    def _maskSearch(self, root):    
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
                            self.maskList.append(node.text.decode())
            if cap == 'fd_Name':
                fdNameList = captures[cap]
                for fd in fdNameList:
                    functionText = fd.text.decode()
                    if(functionText == "init_Mask"): 
                        self.libraryDescriptor.append("Seeed_Arduino_CAN")
                        break
                    elif(functionText == "setFilterMask"):
                        self.libraryDescriptor.append("arduino-mcp2515")
                        break
                    elif(functionText == "setMask"):
                        self.libraryDescriptor.append("CAN_Library")
                        break
                    else:
                        self.libraryDescriptor.append("Unknown Library")
                        break
                    
    #############################################################################
    def _filterSetupSearch(self, root):
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
                            self.setupFilterList.append(node.text.decode())
            if cap == 'fd_Name':
                fdNameList = captures[cap]
                for fd in fdNameList:
                    functionText = fd.text.decode()
                    if(functionText == "init_Filt"): 
                        self.libraryDescriptor.append("Seeed_Arduino_CAN")
                        break
                    elif(functionText == "setFilter"):
                        self.libraryDescriptor.append("arduino-mcp2515")
                        break
                    else:
                        self.libraryDescriptor.append("Unknown Library")
                        break
    #############################################################################
    def _loopFilterSearch(self, root):

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
        for cap in captures:
            if(cap == 'function.body'):
                for capID in captures[cap]:
                    tempText = capID.text.decode()
                    if("setFilt" in tempText):
                        continue
                    else:
                        loopText = tempText
            if(cap == 'target_func'):
                funcList = captures[cap]
                for funcIDX in range(0, len(funcList)):
                    functionText = funcList[funcIDX].text.decode()
                    if("readMsgBuf" in functionText):
                        if(captures["args"][funcIDX].named_child_count == 2):
                            self.libraryDescriptor.append("Seeed_Arduino_CAN")
                            break
                        elif(captures["args"][funcIDX].named_child_count == 3):
                            self.libraryDescriptor.append("MCP_CAN_lib")
                            break
                    elif("readMessage" in functionText):
                        self.libraryDescriptor.append("arduino-mcp2515")
                        break

        loopText = loopText.splitlines()
        for line in loopText:
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
                                    self.loopFilterList.append(hexVal)
                                    hexVal = ''
                        idx += 1
                        
    #############################################################################
    def _libraryCheck(self):
        if(self.libraryDescriptor[0] == "Unkown Library"):
            return "Unkown"
  
        libraryGuess = ""
        if(len(self.libraryDescriptor) == 2):
            libraryGuess = "CAN_Library"
        elif(len(self.libraryDescriptor) == 3):
            maskDescriptor = self.libraryDescriptor[0]
            filterDescriptor = self.libraryDescriptor[1]
            messageDescriptor = self.libraryDescriptor[2]
            
            if(maskDescriptor == "Seeed_Arduino_CAN" and filterDescriptor == "Seeed_Arduino_CAN" and messageDescriptor == "Seeed_Arduino_CAN"):
                libraryGuess = "Seeed_Arduino_CAN" #Arduino_CAN_BUS_MCP2515 has same syntax, so this should be fine
            elif(maskDescriptor == "arduino-mcp2515" and filterDescriptor == "arduino-mcp2515" and messageDescriptor == "arduino-mcp2515"):
                libraryGuess = "arduino-mcp2515"
            elif(maskDescriptor == "Seeed_Arduino_CAN" and filterDescriptor == "Seeed_Arduino_CAN" and messageDescriptor == "MCP_CAN_lib"):
                libraryGuess = "MCP_CAN_lib"
            
        return libraryGuess
                            
    #############################################################################
    def _maskFilterCheck(self, root):

        self._maskSearch(root)
        self._filterSetupSearch(root)
        self._loopFilterSearch(root)
    
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

        for filter in self.setupFilterList:
            for mask in self.maskList:
                if((int(mask, 16) & int(filter, 16)) != int(filter, 16)):
                    maskWarn = True 


            
            if(filter not in self.loopFilterList):
                usageWarn = True
                unusedList.append(filter)
        
        for filt in self.loopFilterList:
            if(filt not in self.setupFilterList):
                excludedWarn = True
                excludeList.append(filt)

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
    def checkMaskFilter(self, root):
        self._reset()
        totalIssues, messages = self._maskFilterCheck(root)
        library = self._libraryCheck()
        return totalIssues, messages, library



