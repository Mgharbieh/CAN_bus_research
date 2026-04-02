import sys
import ctypes
import IssueChecker 
import fileHandler

from PyQt6.QtCore import Qt, QObject, QUrl, pyqtSignal, pyqtSlot, QRunnable, QThreadPool 
from PyQt6.QtQml import QQmlApplicationEngine
from PyQt6.QtGui import QGuiApplication, QIcon
from PyQt6.QtQuick import QQuickView
from PySide6.QtQuickControls2 import QQuickStyle

class WorkerSignals(QObject):
    analysisResult = pyqtSignal(int)
    fileResult = pyqtSignal(list, str)
    deleteResult = pyqtSignal(str)
    statusMessage = pyqtSignal(bool)
    solutionResult = pyqtSignal(str)

class AnalysisWorker(QRunnable):
    def __init__(self, checker, fileManager, path):
        super().__init__()
        self.checker = checker
        self.fileManager = fileManager
        self.path = path
        self.signals = WorkerSignals()

    @pyqtSlot()
    def run(self):
        try:
            issueCount, data, code, lib = self.checker.analyzeFile(self.path)
            print("")
            #self.signals.statusMessage.emit(True)
            #self.checker.llmSolveSingle("mask_filt", "Example issue message for mask filter issue.", "Example source code snippet related to mask filter issue.")
            #solutions, aiEnabled = self.checker.llmSolve(data, code)
            #self.signals.statusMessage.emit(False)
            aiStream = self.checker.grabIssues(data)
            fileName = self.path.split('/')[-1][:-4]
            lastModified = self.fileManager.get_last_modified_date(self.path)  
            fileData = {"library":lib, "dataStream":{"data":data,"AI_solutions": aiStream}, "sourceCode":code, "path":self.path, "lastEdited": lastModified}
            if(self.fileManager.save_file(fileName + '_ino.json', fileData)):
               self.signals.analysisResult.emit(issueCount)
        except Exception as e:
            print(f"Error in worker: {e}")

class AISolutionWorker(QRunnable):
    def __init__(self, checker, fileManager, issueType, issueMessage, code, name):
        super().__init__()
        self.checker = checker
        self.fileManager = fileManager
        self.issueType = issueType
        self.issueMessage = issueMessage
        self.code = code
        self.fileName = name
        self.signals = WorkerSignals()

    @pyqtSlot()
    def run(self):
        try:
            json_obj = self.fileManager.getFileData(self.fileName)
            solution = self.checker.llmSolveSingle(self.issueType, self.issueMessage, self.code)
            json_obj["dataStream"]["AI_solutions"][self.issueType]["cached"] = True
            json_obj["dataStream"]["AI_solutions"][self.issueType]["solution"] = solution
            if(self.fileManager.save_file(self.fileName[:-4] + '_ino.json', json_obj)):
                self.signals.solutionResult.emit(solution)
        except Exception as e:
            print(f"Error in AI Solution worker: {e}")

class LoaderWorker(QRunnable):
    def __init__(self, fileManager, fileName):
        super().__init__()
        self.fileManager = fileManager
        self.name = fileName
        self.signals = WorkerSignals()

    @pyqtSlot()
    def run(self):
        try:
            code, fileData = self.fileManager.load_file(self.name)
            if fileData:
                self.signals.fileResult.emit(code, fileData)
        except Exception as e:
            print(f"Error in worker: {e}")

class DeleteWorker(QRunnable):
    def __init__(self, fileManager, fileName):
        super().__init__()
        self.fileManager = fileManager
        self.name = fileName
        self.signals = WorkerSignals()

    @pyqtSlot()
    def run(self):
        try:
            if self.fileManager.delete_file(self.name):
                self.signals.deleteResult.emit(self.name)
        except Exception as e:
            print(f"Error in worker: {e}")

class DeleteAllWorker(QRunnable):
    def __init__(self, fileManager):
        super().__init__()
        self.fileManager = fileManager
        self.signals = WorkerSignals()

    @pyqtSlot()
    def run(self):
        try:
            if self.fileManager.delete_all_files():
                self.signals.deleteResult.emit("allDeleted")
        except Exception as e:
            print(f"Error in worker: {e}")

class AnalysisInterface(QObject):

    fileExists = pyqtSignal(bool, str)
    fileProcessed = pyqtSignal(int)
    statusMessage = pyqtSignal(bool)
    fileLoaded = pyqtSignal(list, str)
    populateSavedFiles = pyqtSignal(str)
    configFileLoaded = pyqtSignal(int, int, int, str)
    fileDeleted = pyqtSignal(str)
    solutionGenerated = pyqtSignal(str)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.fileManager = fileHandler.FileHandler()
        self.checker = IssueChecker.IssueChecker()
        self.threadPool = QThreadPool()
        

    def loadConfiguration(self):
        config, apiKey = self.fileManager.loadConfig()
        if config:
            self.configFileLoaded.emit(
                config.get("theme", 0),
                config.get("highContrast", 0),
                config.get("aiAgent", 0),
                apiKey or ""
            )

            self.checker.initAI(config.get("aiAgent", 0))
    
    def updateConfiguration(self, key, value):
        self.fileManager.updateConfig(key, value)

    def saveAPIKey(self, agent, key):
        self.fileManager.update_api_key(agent, key)

    def populateSavedFileList(self):
        saved_files = self.fileManager.loadPreviousScans()
        if(type(saved_files) != list):
            self.populateSavedFiles.emit(saved_files)

    def checkFileExists(self, path):    
        exists, mode = self.fileManager.check_file_exists(path)
        print(exists)
        self.fileExists.emit(exists, mode)
        
    def analyzeFile(self, path):
        worker = AnalysisWorker(self.checker, self.fileManager,path)
        worker.signals.statusMessage.connect(self.statusMessage.emit)
        worker.signals.analysisResult.connect(self.fileProcessed.emit)
        self.threadPool.start(worker)

    def analyzeFileWithAI(self, type, message, code, name):  
        worker = AISolutionWorker(self.checker, self.fileManager, type, message, code, name)
        worker.signals.solutionResult.connect(self.solutionGenerated.emit)
        self.threadPool.start(worker)

    def loadFile(self, name):
        worker = LoaderWorker(self.fileManager, name)
        worker.signals.fileResult.connect(self.fileLoaded.emit)
        self.threadPool.start(worker)

    def deleteFile(self, name):
        worker = DeleteWorker(self.fileManager, name)
        worker.signals.deleteResult.connect(self.fileDeleted.emit)
        self.threadPool.start(worker)
    
    def deleteAllFiles(self):
        worker = DeleteAllWorker(self.fileManager)
        worker.signals.deleteResult.connect(self.fileDeleted.emit)
        self.threadPool.start(worker)

app = QGuiApplication(sys.argv)
splash = QQuickView(QUrl.fromLocalFile("./Src/ui/SplashScreen.qml"))
splash.setFlags(Qt.WindowType.SplashScreen | Qt.WindowType.WindowStaysOnTopHint)
splash.setColor(Qt.GlobalColor.transparent)
splash.show()
app.processEvents()

#myappid = 'statican.gui.v1' 
#ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(myappid)
app.setWindowIcon(QIcon("./Src/ui/assets/statican.ico"))
interface = AnalysisInterface()

QQuickStyle.setStyle("Material")
engine = QQmlApplicationEngine()
engine.rootContext().setContextProperty('ISSUE_CHECKER', interface)
engine.quit.connect(app.quit)
engine.load('./Src/ui/Main.qml')
if not engine.rootObjects():
    sys.exit(-1)

interface.loadConfiguration()
interface.populateSavedFileList()
root_object = engine.rootObjects()[0]
root_object.checkFileExists.connect(interface.checkFileExists)
root_object.scanFile.connect(interface.analyzeFile)
root_object.loadSelectedFile.connect(interface.loadFile)  
root_object.configUpdated.connect(interface.updateConfiguration)
root_object.deleteFile.connect(interface.deleteFile)
root_object.deleteAllFiles.connect(interface.deleteAllFiles)
root_object.storeAPIKey.connect(interface.saveAPIKey)
root_object.generateSolution.connect(interface.analyzeFileWithAI)
 
splash.close()
sys.exit(app.exec())