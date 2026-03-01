import json
import os
import sys

def clean_settings(settings_path):
    try:
        if not os.path.exists(settings_path):
            print(f"Settings file not found: {settings_path}")
            return

        with open(settings_path, 'r') as f:
            data = json.load(f)

        if 'hooks' in data:
            print("Found 'hooks' in settings.json. Removing...")
            del data['hooks']
            
            # Create backup
            backup_path = settings_path + ".bak.clean"
            with open(backup_path, 'w') as f:
                json.dump(data, f, indent=2)
                
            # Write back
            with open(settings_path, 'w') as f:
                json.dump(data, f, indent=2)
            print("Successfully removed hooks from settings.json")
        else:
            print("No 'hooks' found in settings.json. Clean.")

    except Exception as e:
        print(f"Error cleaning settings.json: {e}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 clean_settings_json.py <path_to_settings.json>")
        sys.exit(1)
    
    clean_settings(sys.argv[1])
