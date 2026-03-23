from Modules.libFlags import LibFlags as LibFlag
import tree_sitter as TreeSitter

import tree_sitter_cpp as _CPP
CPP_LANGUAGE = TreeSitter.Language(_CPP.language())

class LibraryDetector():
    
    def __init__(self):
        self.libraryDescriptor = "Unknown"
        self.maskDescriptor = LibFlag.UNKNOWN
        self.filtDescriptor = LibFlag.UNKNOWN
        self.sendDescriptor = LibFlag.UNKNOWN
        self.recvDescriptor = LibFlag.UNKNOWN
        self.sendArgLength = -1
        self.recvArgLength = -1

    def _sendFuncSearch(self, root):
        SEND_QUERY_1 = '''
        (call_expression
            function: (field_expression
                argument: (_) @object_name
                field: (field_identifier) @method_name
            )
            arguments: (argument_list
                (_) @arg_value
            ) @arg_list
            (#eq? @method_name "sendMsgBuf")
        ) @sendMsgBuf
        '''
        
        SEND_QUERY_2 = '''
        (call_expression
            function: (field_expression
                argument: (_) @object_name
                field: (field_identifier) @method_name
            )
            arguments: (argument_list
                (_) @arg_value
            ) @arg_list
            (#eq? @method_name "sendMessage")
        ) @sendMessage
        '''
        
        SEND_QUERY_3 = '''
        (call_expression
            function: (field_expression
                argument: (_) @object_name
                field: (field_identifier) @method_name
            )
            arguments: (argument_list
                (_) @arg_value
            ) @arg_list
            (#eq? @method_name "write")
        ) @writeFunc
        '''
        
        QUERY_LIST = [SEND_QUERY_1, SEND_QUERY_2, SEND_QUERY_3]
        for sendQuery in QUERY_LIST:
            query = TreeSitter.Query(CPP_LANGUAGE, sendQuery)
            queryCursor = TreeSitter.QueryCursor(query)
            captures = queryCursor.captures(root)
            if(len(captures) != 0):
                break 
        
        if(len(captures) > 0):
            for cap in captures:
                if(cap == "sendMsgBuf"):
                    pass #hardest one to detect due to several similarities
                elif(cap == "sendMessage"):
                    self.sendDescriptor = LibFlag.arduino_mcp_2515
             
        
        

    def strongGuess(self):
        if((self.maskDescriptor & LibFlag.SEEED_ARDUINO_CAN) and 
           (self.filtDescriptor & LibFlag.SEEED_ARDUINO_CAN) and
           (self.sendDescriptor & LibFlag.SEEED_ARDUINO_CAN) and
           (self.recvDescriptor & LibFlag.SEEED_ARDUINO_CAN)):
            self.libraryDescriptor = "Seeed_Arduino_CAN"
        elif((self.maskDescriptor & LibFlag.arduino_mcp_2515) and
             (self.filtDescriptor & LibFlag.arduino_mcp_2515) and
             (self.sendDescriptor & LibFlag.arduino_mcp_2515) and
             (self.recvDescriptor & LibFlag.arduino_mcp_2515)):
            self.libraryDescriptor = "arduino-mcp2515"
        elif((self.maskDescriptor & LibFlag.SEEED_ARDUINO_CAN) and
             (self.filtDescriptor & LibFlag.SEEED_ARDUINO_CAN) and
             (self.sendDescriptor & LibFlag.MCP_CAN_lib) and
             (self.recvDescriptor & LibFlag.MCP_CAN_lib)):
            self.libraryDescriptor = "MCP_CAN_lib"
        elif((self.maskDescriptor & LibFlag.CAN_Library) and
             (self.filtDescriptor & LibFlag.arduino_mcp_2515) and
             (self.sendDescriptor == LibFlag.UNKNOWN)):
            self.libraryDescriptor = "CAN_Library"
            
    def weakGuess(self):
        if((self.sendDescriptor & LibFlag.SEEED_ARDUINO_CAN) and
           (self.recvDescriptor & LibFlag.SEEED_ARDUINO_CAN)):
            self.libraryDescriptor = "Seeed_Arduino_CAN"
        elif((self.sendDescriptor & LibFlag.arduino_mcp_2515) and
             (self.recvDescriptor & LibFlag.arduino_mcp_2515)):
            self.libraryDescriptor = "arduino-mcp2515"
        elif((self.sendDescriptor & LibFlag.MCP_CAN_lib) and
             (self.recvDescriptor & LibFlag.MCP_CAN_lib)):
            self.libraryDescriptor = "MCP_CAN_lib"
        elif((self.recvDescriptor & LibFlag.UNKNOWN) and
             (self.filtDescriptor & LibFlag.arduino_mcp_2515)):
            self.libraryDescriptor = "CAN_Library"
            
    def detectLibrary(self, root):
        self._sendFuncSearch(root)
        
        if((self.maskDescriptor == LibFlag.UNKNOWN) and
           (self.filtDescriptor == LibFlag.UNKNOWN)):
            self.weakGuess()
        else:
            self.strongGuess()

        
        
'''
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
'''
