from typing import List
import platform
import json
import openai
from pydantic import BaseModel, Field
import tree_sitter as TreeSitter

import tree_sitter_cpp as _CPP
CPP_LANGUAGE = TreeSitter.Language(_CPP.language())

import libraryDetector
import Modules.MaskFilter.MaskFilterAnalyzer as mask_filt
import Modules.RTRBit.RTRBit as RTR_Check
import Modules.IDBitLength.IDAnalyzer as id_analyzer
import Modules.DataBytePacking.DataByte_Analyzer as data_byte_packing
import Modules.DataLength.dlc_analyzer as dlc_analyzer

from langchain_ollama import ChatOllama
from langchain_anthropic import ChatAnthropic
from langchain_core.prompts import ChatPromptTemplate
from langchain_deepseek import ChatDeepSeek
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_openai import ChatOpenAI

from dotenv import load_dotenv
import os

load_dotenv(dotenv_path="/Users/abrahamabdulkarim/Documents/StatiCAN/.env")
# print("API KEY:", os.getenv("API_KEY"))

class IssueSolution(BaseModel):
    issue_type: str = Field(description="Type of issue, e.g. Mask Filter")
    issue_number: int = Field(description="1-based issue number")
    issue_message: str = Field(description="Original issue message")
    solution: str = Field(description="Concrete fix for the issue")

SYSTEM_PROMPT = """
You are a code analysis assistant for CAN bus code.

The CAN Libraries you will be analysing are the following so maintain their syntax and semantics in your solutions:
- arduino_mcp2515

Your job is to generate solutions ONLY for explicitly provided issues.
Do not invent issues.
Do not solve anything that is not mentioned in the issue messages.
If there are no issues, return an empty list.

Rules:
- Use the example only as a style guide, not as content to copy.
- DO NOT COPY EXACT SOLUTIONS FROM THE EXAMPLE. The example is only to show how to format the solution, not what the solution should be.
- In the solution make sure all the variables used have corresponding definitions.
- Each issue must produce exactly one solution object.
- Keep the solution specific to the provided source code.
- Reference exact code lines or exact code snippets when possible.
- Do not include any commentary before or after the output.
- The issue messages may reference line numbers, but these are not guaranteed to be accurate. Always verify against the source code.
- Flags like 'CAN_RTR_FLAG' or 'CAN_SFF_FLAG' (or similar depending on the library) may be utilized and sometimes you may need to infer the intent of a code snippet to understand the issue before assuming changes need to be made.
- Focus on providing actionable solutions that directly address the issue messages.
"""
#IN YOUR SOLUTIONS, ALWAYS REFERENCE THE EXACT CODE AND REFERENCE THE PROPER SNIPPETS AND OBJECT NAMES.
HUMAN_PROMPT = """
Issue category: {issue_type}

Example problem and example solution format:
{example}

Current issue messages:
{messages}

Source code:
{source_code}
""" 

class IssueSolutionList(BaseModel):
    solutions: List[IssueSolution]

class IssueChecker():

    

    def __init__(self):  
        self.libraryAnalyzer = libraryDetector.LibraryDetector()
        self.mask_filt_analyzer = mask_filt.MaskAndFilter()
        self.rtr_check_analyzer = RTR_Check.RTRBitChecker()
        self.id_bit_length_analyzer = id_analyzer.IDBitLength()
        self.data_byte_packing_analyzer = data_byte_packing.DataBytePackingAnalyzer()
        self.data_length_analyzer = dlc_analyzer.DLCAnalyzer()
        self.llm = None
        self.chain = None

    outputStructure =   "Issue Type: (insert type here) \n"\
                        "Issue Number: (insert bug number here) \n"\
                        "Issue Messages: (insert issue message here) \n"\
                        "Solution: (insert solution here) \n"\
          
    

    files = {
        "mask_filt": "Src/aiExamples/mf_ex.txt",
        "rtr": "Src/aiExamples/rtr_ex.txt",
        "idLen": "Src/aiExamples/idbl_ex.txt",
        "dataPack": "Src/aiExamples/dbp_ex.txt",
        "dlc": "Src/aiExamples/dlc_ex.txt"
    }

    examples = {}

    try:
        for key, path in files.items():
            with open(path, "r") as f:
                examples[key] = f.read()

    except FileNotFoundError as e:
        print(f"Error: File not found -> {e.filename}")
    except Exception as e:
        print(f"An error occurred: {e}")

    def initAI(self, modelNum):
        model = ""
        if(modelNum == 0):
            self.llm = None
            return
        elif(modelNum == 1):
            model = "llama3"

            self.llm = ChatOllama(
                model= "llama3",
                temperature = 0.7,
                num_ctx = 8192,
                num_predict = 600,
                top_k = 30, 
                top_p = 0.9,
                repeat_penalty = 1.1,
                repeat_last_n= 128,
                seed = 42
                ).with_structured_output(IssueSolutionList)
            
        elif(modelNum == 2):
            model = "deepseek-chat"

            self.llm = ChatDeepSeek(
                model= "deepseek-chat",
                temperature = 0.7,
                api_key= os.getenv("API_KEY")
                ).with_structured_output(IssueSolutionList)
            
        elif(modelNum == 3):
            model = "gpt-4o"

            self.llm = ChatOpenAI(
                model= "gpt-4o",
                temperature = 0.7,
                api_key= os.getenv("API_KEY")
                ).with_structured_output(IssueSolutionList)

        elif(modelNum == 4):
            model = "claude-3-7-sonnet-latest"

            self.llm = ChatAnthropic(
                model= "claude-3-7-sonnet-latest",
                temperature = 0.7,
                api_key= os.getenv("API_KEY")
                ).with_structured_output(IssueSolutionList)
            
        elif(modelNum == 5):
            model = "gemini-2.0-pro"

            self.llm = ChatGoogleGenerativeAI(
                model= "gemini-2.0-pro",
                temperature = 0.7,
                api_key= os.getenv("API_KEY")
            ).with_structured_output(IssueSolutionList)

        

        

        

        
        
        prompt = ChatPromptTemplate.from_messages([
        ("system", SYSTEM_PROMPT),
        ("human", HUMAN_PROMPT)
        ])

        self.chain = prompt | self.llm
        

    def render_solution(self, item: IssueSolution) -> str:
        return (
            f"Issue Type: {item.issue_type}\n"
            f"Issue Number: {item.issue_number}\n"
            f"Issue Messages: {item.issue_message}\n"
            f"Solution: {item.solution}\n"
        )
    
    def grabIssues(self, dataStream):
        AI_solutions = {}
        for type in ["mask_filt", "rtr", "idLen", "dataPack", "dlc"]:
            current = dataStream[type]
            for out in current:
                if out.endswith("_issues") and current[out] > 0:
                    solution = {}
                    for text in dataStream[type][out[:-6] + "messages"]:
                        solution[text] = {"cached": False, "answer": ""}
                    AI_solutions[type] = {"hasIssues":True, "solution":solution}
                    continue
                elif out.endswith("_issues") and current[out] == 0: 
                    AI_solutions[type] = {"hasIssues":False, "solution":{}}
                    continue
        return AI_solutions

    def llmSolveSingle(self, issue_type, message, source_code):
        
        solutionArray = []
        aiEnabled = True
        if(self.llm == None):
            aiEnabled = False
            return solutionArray

        exampleString = self.examples.get(issue_type)

        result = self.chain.invoke({
            "issue_type": issue_type,
            "example": exampleString,
            "messages": message,
            "source_code": source_code,
        })
        for item in result.solutions:
            solutionArray.append(self.render_solution(item))
            print(self.render_solution(item))
        
        return solutionArray[0]
    
    def llmSolve(self, dataStream, sourceCode):
        
        solutionArray = []
        aiEnabled = True
        if(self.llm == None):
            aiEnabled = False
            return solutionArray, aiEnabled

        print(os.getenv("API_KEY"))

        for type in ["mask_filt", "rtr", "idLen", "dataPack", "dlc"]:
            current = dataStream[type]
            issuesFound = False
            exampleString = self.examples.get(type)

            for out in current:
                if out.endswith("_issues") and current[out] > 0:
                    issuesFound = True
                    continue
                if out.endswith("_messages") and issuesFound:
                    messages  = current[out]
                    result = self.chain.invoke({
                        "issue_type": type,
                        "example": exampleString,
                        "messages": messages,
                        "source_code": sourceCode,
                    })
                    for item in result.solutions:
                        solutionArray.append(self.render_solution(item))
                        print(self.render_solution(item))
                if out.endswith("_messages") and not issuesFound:
                    print(f"No solution necessary for {type}.")
        return solutionArray, aiEnabled
            
    
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

        # Library only detectable from files recieving data via masks/filters
        # TODO: add library check for sending files in different module
        maskIssuesFound, maskIssueMessages, maskIssueLineNums = self.mask_filt_analyzer.checkMaskFilter(RootCursor, self.libraryAnalyzer)
        issuesFound += maskIssuesFound
        dataStream["mask_filt"] = {"mf_issues":maskIssuesFound, "mf_messages":maskIssueMessages, "mf_lineNums": maskIssueLineNums}

        rtrIssuesFound, rtrIssueMessages, rtrLineNums = self.rtr_check_analyzer.checkRTRmode(RootCursor, self.libraryAnalyzer)
        issuesFound += rtrIssuesFound
        dataStream["rtr"] = {"rtr_issues":rtrIssuesFound, "rtr_messages":rtrIssueMessages, "rtr_lineNums":rtrLineNums}

        idLenIssuesFound, idLenIssueMessages, idLineNums = self.id_bit_length_analyzer.checkIDBitLength(RootCursor)
        issuesFound += idLenIssuesFound
        dataStream["idLen"] = {"idLen_issues":idLenIssuesFound, "idLen_messages":idLenIssueMessages, "idLen_lineNums": idLineNums}

        dataPackIssuesFound, dataPackIssueMessages, dataPackLineNums = self.data_byte_packing_analyzer.checkDataPack(RootCursor)
        issuesFound += dataPackIssuesFound
        dataStream["dataPack"] = {
            "dataPack_issues":dataPackIssuesFound,
            "dataPack_messages":dataPackIssueMessages,
            "dataPack_lineNums": dataPackLineNums
        }

        dlcIssuesFound, dlcIssueMessages = self.data_length_analyzer.checkDLC(RootCursor)
        issuesFound += dlcIssuesFound
        dataStream["dlc"] = {"dlc_issues":dlcIssuesFound, "dlc_messages":dlcIssueMessages}

        dataStream["totalIssues"] = issuesFound
        
        self.libraryAnalyzer.detectLibrary(RootCursor)
        library = self.libraryAnalyzer.libraryDescriptor
        
        return issuesFound, dataStream, sourceCode, library


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


