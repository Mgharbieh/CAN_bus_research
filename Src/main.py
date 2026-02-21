import sys
import ctypes
import IssueChecker 
import fileHandler

from PyQt6.QtCore import QObject, pyqtSignal, pyqtSlot, QRunnable, QThreadPool
from PyQt6.QtQml import QQmlApplicationEngine
from PyQt6.QtGui import QGuiApplication, QIcon
from PySide6.QtQuickControls2 import QQuickStyle

class WorkerSignals(QObject):
    analysisResult = pyqtSignal(int)
    fileResult = pyqtSignal(list, str)
    deleteResult = pyqtSignal(str)

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
            if(self.fileManager.check_file_exists(self.path.split('/')[-1][:-4] + '_ino.json')):
                return
            
            issueCount, data, code = self.checker.analyzeFile(self.path)
            fileName = self.path.split('/')[-1][:-4]
            fileData = {"data":data, "sourceCode":code, "path":self.path}
            if(self.fileManager.save_file(fileName + '_ino.json', fileData)):
                self.signals.analysisResult.emit(issueCount)
        except Exception as e:
            print(f"Error in worker: {e}")

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

    fileProcessed = pyqtSignal(int)
    fileLoaded = pyqtSignal(list, str)
    populateSavedFiles = pyqtSignal(str)
    configFileLoaded = pyqtSignal(int, int)
    fileDeleted = pyqtSignal(str)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.fileManager = fileHandler.FileHandler()
        self.checker = IssueChecker.IssueChecker()
        self.threadPool = QThreadPool()

    def loadConfiguration(self):
        config = self.fileManager.loadConfig()
        if config:
            self.configFileLoaded.emit(config["theme"], config["highContrast"])
            # Load other configuration settings as needed

    def updateConfiguration(self, key, value):
        self.fileManager.updateConfig(key, value)

    def populateSavedFileList(self):
        saved_files = self.fileManager.loadPreviousScans()
        if(type(saved_files) != list):
            self.populateSavedFiles.emit(saved_files)

    def analyzeFile(self, path):
        worker = AnalysisWorker(self.checker, self.fileManager,path)
        worker.signals.analysisResult.connect(self.fileProcessed.emit)
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

myappid = 'statican.gui.v1' 
ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(myappid)
app = QGuiApplication(sys.argv)
interface = AnalysisInterface()

app.setWindowIcon(QIcon("./ui/assets/statican.ico"))

QQuickStyle.setStyle("Material")
engine = QQmlApplicationEngine()
engine.rootContext().setContextProperty('ISSUE_CHECKER', interface)
engine.quit.connect(app.quit)
engine.load('./ui/Main.qml')
if not engine.rootObjects():
    sys.exit(-1)

interface.loadConfiguration()
interface.populateSavedFileList()
root_object = engine.rootObjects()[0]
root_object.scanFile.connect(interface.analyzeFile)
root_object.loadSelectedFile.connect(interface.loadFile)  
root_object.configUpdated.connect(interface.updateConfiguration)
root_object.deleteFile.connect(interface.deleteFile)
root_object.deleteAllFiles.connect(interface.deleteAllFiles)

sys.exit(app.exec())