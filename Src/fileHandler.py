import os
import json
import shutil
from pathlib import Path
from platformdirs import user_documents_dir

class AlreadyExistsError(Exception): # will implement later for better solution
    pass

class FileHandler: ### NEED TO ADD FUNCTION TO POPULATE LIST WITH SAVED FILES ###
    def __init__(self):
        self.current_file = {}
        self.config = {}
        self.root_dir = Path(user_documents_dir()) / "StatiCAN"
        self.save_dir = self.root_dir / "Saved_Files"
        self.alreadyExistsError = AlreadyExistsError

        print(f"Save directory: {self.save_dir}")
        if not os.path.exists(self.save_dir):
            print(str(self.save_dir) + " does not exist... creating...")
            self.save_dir.mkdir(parents=True, exist_ok=True)
        else:
            print(str(self.save_dir) + " exists.")

    def loadConfig(self):
        config_path = self.root_dir / "config.json"
        if os.path.exists(config_path):
            with open(config_path, 'r') as file:
                self.config = json.load(file)
                return self.config
        else:
            self.config = {
                "theme": 0,
                "highContrast": 0
            }
            with open(config_path, 'w') as file:
                json.dump(self.config, file, indent=4)
            return self.config

    def updateConfig(self, key, value):
        self.config[key] = value
        config_path = self.root_dir / "config.json"
        with open(config_path, 'w') as file:
            json.dump(self.config, file, indent=4)

    def loadPreviousScans(self):
        saved_files = []
        try:
            for file_name in os.listdir(self.save_dir):
                with open(self.save_dir / file_name, 'r') as file:
                    json_obj = json.load(file)
                    file_data = json_obj["data"]
                    saved_files.append({
                        "file_name": file_data["file_name"],
                        "totalIssues": file_data["totalIssues"]
                    })
            return json.dumps({"files":saved_files}) 
        except Exception as e:
            print(f"Error loading previous scans: {e}")
            return []

    def check_file_exists(self, name): # will add another condition to check if it was modified after last scan
        file_path = self.save_dir / name
        return os.path.exists(file_path)


    def load_file(self, name):
        try:
            path = self.save_dir / (name[:-4] + '_ino.json')
            with open(path, 'r') as file:
                self.current_file = json.load(file)

            sourceCode = self.current_file["sourceCode"].split('\n')
            data = self.current_file["data"]
            return sourceCode, json.dumps(data)
        except Exception as e:
            print(f"Error loading file: {e}")
            return None

    def save_file(self, name, data):
        path = self.save_dir / name
        try:
            with open(path, 'w') as file:
                json.dump(data, file, indent=4)
            return True
        except Exception as e:
            print(f"Error saving file: {e}")
            return False