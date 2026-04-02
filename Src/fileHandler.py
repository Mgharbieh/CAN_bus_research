import os
import platform
import json
import dotenv 
from pathlib import Path
from platformdirs import user_documents_dir

class AlreadyExistsError(Exception): # will implement later for better solution
    pass

class FileHandler: ### NEED TO ADD FUNCTION TO POPULATE LIST WITH SAVED FILES ###
    def __init__(self):
        self.current_file = {}
        self.config = {}
        self.apiKey = ""
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
        env_path = self.root_dir / ".env"
        if os.path.exists(config_path):
            self.apiKey = dotenv.get_key(str(env_path), "API_KEY") 
            with open(config_path, 'r') as file:
                self.config = json.load(file)
                return self.config, self.apiKey
        else:
            self.config = {
                "theme": 0,
                "highContrast": 0,
                "aiAgent": 0
            }
            with open(config_path, 'w', encoding='utf-8') as file:
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
                file_path = self.save_dir / file_name
                print(f"Trying to open: {file_path}")

                if file_path.suffix.lower() != ".json":
                    continue

                with open(self.save_dir / file_name, 'r') as file:
                    json_obj = json.load(file)
                    file_data = json_obj["dataStream"]["data"]
                    saved_files.append({
                        "file_name": file_data["file_name"],
                        "totalIssues": file_data["totalIssues"]
                    })
            return json.dumps({"files":saved_files}) 
        except Exception as e:
            print(f"Error loading previous scans: {e}")
            return []
        
    def getFileData(self, name):
        file_path = self.save_dir / (name[:-4] + '_ino.json')
        if os.path.exists(file_path):
            with open(file_path, 'r') as file:
                json_obj = json.load(file)
                return json_obj
        else:
            print(f"File {file_path} does not exist.")
            return None

    def check_file_exists(self, name): # will add another condition to check if it was modified after last scan
        file_path = self.save_dir / (name[:-4] + '_ino.json')
        if(os.path.exists(file_path)):
            with open(file_path, 'r') as file:
                json_obj = json.load(file)
                lastEdited = json_obj["lastEdited"]
                currentLastEdited = self.get_last_modified_date(json_obj["path"])
                if(currentLastEdited < lastEdited):
                    return False, "replace"
            return True, "_"
        else:
            return False, "add"

    def get_last_modified_date(self, path):
        if(platform.system() == 'Windows'):
            return os.path.getmtime(path[1:])     
        else:
            return os.path.getmtime(path)

    def load_file(self, name):
        try:
            path = self.save_dir / (name[:-4] + '_ino.json')
            with open(path, 'r') as file:
                self.current_file = json.load(file)

            sourceCode = self.current_file["sourceCode"].split('\n')
            dataStream = self.current_file["dataStream"]
            return sourceCode, json.dumps(dataStream)
        except Exception as e:
            print(f"Error loading file: {e}")
            return None

    def update_api_key(self, agent, key):
        env_path = self.root_dir / ".env"
        success, _, self.apiKey = dotenv.set_key(str(env_path), agent, key)
        return success

    def save_file(self, name, data):
        path = self.save_dir / name
        try:
            with open(path, 'w') as file:
                json.dump(data, file, indent=4)
            return True
        except Exception as e:
            print(f"Error saving file: {e}")
            return False
        
    def delete_file(self, name):
        path = self.save_dir / (name[:-4] + '_ino.json')
        try:
            if os.path.exists(path):
                os.remove(path)
                return True
            else:
                print(f"File {path} does not exist.")
                return False
        except Exception as e:
            print(f"Error deleting file: {e}")
            return False
        
    def delete_all_files(self):
        try:
            for file_name in os.listdir(self.save_dir):
                file_path = self.save_dir / file_name
                if os.path.isfile(file_path):
                    os.remove(file_path)
            return True
        except Exception as e:
            print(f"Error deleting all files: {e}")
            return False