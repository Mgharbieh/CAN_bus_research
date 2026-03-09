import platform
import json
import tree_sitter as TreeSitter

import tree_sitter_cpp as _CPP
CPP_LANGUAGE = TreeSitter.Language(_CPP.language())

import Modules.MaskFilter.MaskFilterAnalyzer as mask_filt
import Modules.RTRBit.RTRBit as RTR_Check
import Modules.IDBitLength.IDAnalyzer as id_analyzer
import Modules.DataBytePacking.DataByte_Analyzer as data_byte_packing
import Modules.DataLength.dlc_analyzer as dlc_analyzer

from langchain_ollama import ChatOllama as ai



class IssueChecker():

    def __init__(self):
        self.mask_filt_analyzer = mask_filt.MaskAndFilter()
        self.rtr_check_analyzer = RTR_Check.RTRBitChecker()
        self.id_bit_length_analyzer = id_analyzer.IDBitLength()
        self.data_byte_packing_analyzer = data_byte_packing.DataBytePackingAnalyzer()
        self.data_length_analyzer = dlc_analyzer.DLCAnalyzer()

    outputStructure =   "Issue Type: (insert type here) \n"\
                        "Issue Number: (insert bug number here) \n"\
                        "Issue Messages: (insert issue message here) \n"\
                        "Solution: (insert solution here) \n"\
                        
    mask_filt_example_test_arduino_mcp2515 = "[Source Code Problem Snippet: \n"\
    "    void setup() {\n\
        mcp2515.setFilterMask(MCP2515::MASK0, false, 0x7FF)\n\
        mcp2515.setFilter(MCP2515::RXF0, false, 0x640);\n\
        mcp2515.setFilter(MCP2515::RXF1, false, 0x641);\n\
        mcp2515.setFilterMask(MCP2515::MASK1, false, 0x3FF); \n\
        mcp2515.setFilter(MCP2515::RXF2, false, 0x080); \n\
        mcp2515.setFilter(MCP2515::RXF3, false, 0x081); \n\
        mcp2515.setFilter(MCP2515::RXF4, false, 0x082); \n\
        mcp2515.setFilter(MCP2515::RXF5, false, 0x083); \n\
    }\n\
    void loop() {\n\
    if (mcp2515.readMessage(&canMsg) == MCP2515::ERROR_OK) \n\
    { \n\
        switch(canMsg.can_id)\n\
        {\n\
            case (0x640):\n\
                break;\n\
            case (0x082):\n\
                break;\n\
            case (0x083):\n\
                break;\n\
            case (0x084):\n\
                break;\n\
            default:\n\
                break;\n\
        }\n\
        if(canMsg.can_id == 0x081)\n\
        {\n\
            continue;\n\
        }]\n" \
              \
    "    [Outputs for this example:\n  \
    {Mask(s) set aren't applied across the full filter value. Is that intentional?\n\
    ['0x641', '0x080'] were setup in the filter but never explicitly used.\n\
    ['0x084'] was being checked but is excluded from the filter.}]\n" \
    \
    "[Solutions for this example:\n\
                        Issue Type: Mask Filter \n\
                        Issue Number: 1 \n\
                        Issue Messages: Mask(s) set aren't applied across the full filter value. Is that intentional? \n\
                        Solution: Ensure that the mask value is set to cover the entire range of the filter value. For example, if the filter value is 0x7FF, the mask should also be set to 0x7FF to ensure that all bits are considered in the filtering process. Change line 'mcp2515.setFilterMask(MCP2515::MASK1, false, 0x3FF);' to 'mcp2515.setFilterMask(MCP2515::MASK1, false, 0x7FF);'\n\n"
    \
    "\
                        Issue Type: Mask Filter \n\
                        Issue Number: 2 \n\
                        Issue Messages: ['0x641', '0x080'] were setup in the filter but never explicitly used. \n\
                        Solution: Review the filter setup and ensure that all filters that are set up are being utilized in the code. If certain filters are not needed, consider removing them to simplify the code and reduce potential confusion. In this case, if '0x641' and '0x080' are not being used in the filtering process, you can remove the lines 'mcp2515.setFilter(MCP2515::RXF1, false, 0x641);' and 'mcp2515.setFilter(MCP2515::RXF2, false, 0x080);' from the setup function. \n\n]"\
    "\
                        Issue Type: Mask Filter \n\
                        Issue Number: 3 \n\
                        Issue Messages: ['0x084'] was being checked but is excluded from the filter. \n\
                        Solution: Ensure that the filter value is set to include the ID being checked. Add 'mcp2515.setFilter(MCP2515::RXF4, false, 0x084);'\n\n]"\
    
    
    def llmSolve(self, dataStream, sourceCode):
        llm = ai(model="llama3")
        for type in ["mask_filt", "rtr", "idLen", "dataPack", "dlc"]:
            current = dataStream[type]

            issuesFound = False
            for out in current:
                if out.endswith("_issues") and current[out] > 0:
                    issuesFound = True
                    continue
                if out.endswith("_messages") and issuesFound:
                    messages  = current[out]
                    #print(f"Messages for {type}: {messages}")
                    print(llm.invoke(f"Given the following CAN bus issues of type {type}: {messages}, and the source code: {sourceCode}, generate solutions to the bugs only when there is an issue explicitly described. If there is no issue say nothing. Refer to this example: {self.mask_filt_example_test_arduino_mcp2515} and follow the following structure for your responses: {self.outputStructure}").content)
                if out.endswith("_messages") and not issuesFound:
                    print(f"No solution necessary for {type}.")
            
    
    def analyzeFile(self, inputFile):
        dataStream = {}
        issuesFound = 0
        
        dataStream["file_name"] = inputFile.split('/')[-1]
        if(platform.system() == 'Windows'):
            with(open(inputFile[1:], 'r', encoding='utf-8') as inFile):
                sourceCode = inFile.read()
        else:
            with(open(inputFile, 'r', encoding='utf-8') as inFile):
                    sourceCode = inFile.read()
    
        parser = TreeSitter.Parser(CPP_LANGUAGE)
        tree = parser.parse(bytes(sourceCode, "utf8"))
        RootCursor = tree.root_node

        maskIssuesFound, maskIssueMessages = self.mask_filt_analyzer.checkMaskFilter(RootCursor)
        issuesFound += maskIssuesFound
        dataStream["mask_filt"] = {"mf_issues":maskIssuesFound, "mf_messages":maskIssueMessages}

        rtrIssuesFound, rtrIssueMessages = self.rtr_check_analyzer.checkRTRmode(RootCursor)
        issuesFound += rtrIssuesFound
        dataStream["rtr"] = {"rtr_issues":rtrIssuesFound, "rtr_messages":rtrIssueMessages}

        idLenIssuesFound, idLenIssueMessages = self.id_bit_length_analyzer.checkIDBitLength(RootCursor)
        issuesFound += idLenIssuesFound
        dataStream["idLen"] = {"idLen_issues":idLenIssuesFound, "idLen_messages":idLenIssueMessages}

        dataPackIssuesFound, dataPackIssueMessages = self.data_byte_packing_analyzer.checkDataPack(RootCursor)
        issuesFound += dataPackIssuesFound
        dataStream["dataPack"] = {"dataPack_issues":dataPackIssuesFound, "dataPack_messages":dataPackIssueMessages}

        dlcIssuesFound, dlcIssueMessages = self.data_length_analyzer.checkDLC(RootCursor)
        issuesFound += dlcIssuesFound
        dataStream["dlc"] = {"dlc_issues":dlcIssuesFound, "dlc_messages":dlcIssueMessages}

        dataStream["totalIssues"] = issuesFound
        return issuesFound, dataStream, sourceCode


'''
mask_filt_analyzer = mask_filt.MaskAndFilter()
rtr_check_analyzer = RTR_Check.RTRBitChecker()
id_bit_length_analyzer = id_analyzer.IDBitLength()
data_byte_packing_analyzer = data_byte_packing.DataBytePackingAnalyzer() 
data_length_analyzer = dlc_analyzer.DLCAnalyzer()

INPUT_FILE = argv[1]

### READ FILE AND BUILD TREE #####################################################################
##################################################################################################

with(open(INPUT_FILE, 'r', encoding='utf-8') as inFile):
    print("-"*100)
    print()
    print("Reading file: '", INPUT_FILE, "'\n", flush=True)
    sourceCode = inFile.read()

print("Analyzing file...\n", flush=True)

parser = TreeSitter.Parser(CPP_LANGUAGE)
tree = parser.parse(bytes(sourceCode, "utf8"))
RootCursor = tree.root_node

##################################################################################################

### ADD CHECKS HERE ##############################################################################

print("-"*100)
print("\nMASK AND FILTER CHECK: \n")
mask_filt_analyzer.checkMaskFilter(RootCursor)
print("-"*100)
print("\nRTR BIT CHECK: \n")
rtr_check_analyzer.checkRTRmode(RootCursor)
print("-"*100)
print("\nID BIT LENGTH CHECK: \n")
id_bit_length_analyzer.checkIDBitLength(RootCursor)
print("-"*100)
print("\nDATA BYTE PACKING CHECK: \n")
data_byte_packing_analyzer.checkDataPack(RootCursor)
print("-"*100)
print("-"*100)
print("\nDLC CHECK: \n")
data_length_analyzer.checkDLC(RootCursor)
##################################################################################################
'''


