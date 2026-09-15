import subprocess
import os

def get_staged_deleted_scripts():
    """Get all .sh files that are staged for deletion"""
    result = subprocess.run(['git', 'diff', '--cached', '--name-status'],
                            capture_output=True, text=True, check=True)
    deleted_scripts = []

    for line in result.stdout.splitlines():
        status, file_path = line.strip().split('\t', 1)
        if status == 'D' and file_path.endswith('.sh'):
            deleted_scripts.append(file_path)
    return deleted_scripts

def search_with_ripgrep(script_name):
    """Use ripgrep (rg) to search for references to the script name"""
    try:
        result = subprocess.run(['rg', '--color', 'never', '--no-heading', '--line-number', script_name],
                                capture_output=True, text=True, check=False)
        lines = result.stdout.strip().splitlines()
        return [line for line in lines if line]  # filter empty
    except FileNotFoundError:
        print("Error: ripgrep (rg) is not installed or not in PATH.")
        return []

def main():
    repo_root = subprocess.run(['git', 'rev-parse', '--show-toplevel'],
                               capture_output=True, text=True, check=True).stdout.strip()
    os.chdir(repo_root)

    deleted_scripts = get_staged_deleted_scripts()
    if not deleted_scripts:
        print("No staged deletions of .sh files found.")
        return

    print("Checking for references to deleted scripts...\n")
    for script_path in deleted_scripts:
        script_name = os.path.basename(script_path)
        matches = search_with_ripgrep(script_name)

        if matches:
            print(f"⚠️  Script '{script_path}' is still referenced in:")
            for line in matches:
                print(f"   → {line}")
            print()
        else:
            print(f"✅ Script '{script_path}' has no references.\n")

if __name__ == "__main__":
    main()
