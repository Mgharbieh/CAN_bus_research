from Modules.libFlags import LibFlags as LibFlag

class LibraryDetector():
    
    
    
    def __init__(self):
        self.libraryDescriptor = "Unknown"
        self.maskDescriptor = LibFlag.UNKOWN
        self.filtDescriptor = LibFlag.UNKOWN
        self.sendDescriptor = LibFlag.UNKOWN
        self.recvDescriptor = LibFlag.UNKOWN
        self.sendArgLength = -1
        self.recvArgLength = -1
    
    def detectLibrary(self):
        if(((self.maskDescriptor & LibFlag.SEEED_ARDUINO_CAN) and 
           (self.filtDescriptor & LibFlag.SEEED_ARDUINO_CAN) and
           (self.sendDescriptor & LibFlag.SEEED_ARDUINO_CAN)) or
           (self.recvDescriptor & LibFlag.SEEED_ARDUINO_CAN)):
            self.libraryDescriptor = "Seeed_Arduino_CAN"
        elif(((self.maskDescriptor & LibFlag.arduino_mcp_2515) and
             (self.filtDescriptor & LibFlag.arduino_mcp_2515) and
             (self.sendDescriptor & LibFlag.arduino_mcp_2515)) or
             (self.recvDescriptor & LibFlag.arduino_mcp_2515)):
            self.libraryDescriptor = "arduino-mcp2515"
        elif(((self.maskDescriptor & LibFlag.SEEED_ARDUINO_CAN) and
             (self.filtDescriptor & LibFlag.SEEED_ARDUINO_CAN) and
             (self.sendDescriptor & LibFlag.MCP_CAN_lib)) or
             (self.recvDescriptor & LibFlag.MCP_CAN_lib)):
            self.libraryDescriptor = "MCP_CAN_lib"
        elif((self.maskDescriptor & LibFlag.CAN_Library) and
             (self.filtDescriptor & LibFlag.arduino_mcp_2515) and
             (self.sendDescriptor == LibFlag.UNKOWN)):
            self.libraryDescriptor = "CAN_Library"
            
        
        
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
