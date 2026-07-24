import os
import re

def main():
    src_dir = "src"
    
    files = {}
    for root, _, filenames in os.walk(src_dir):
        for filename in filenames:
            if filename.endswith(".luau"):
                filepath = os.path.join(root, filename)
                with open(filepath, "r", encoding="utf-8") as f:
                    content = f.read()
                files[filepath] = content

    print("Analyzing %d Luau files..." % len(files))
    
    for filepath, content in files.items():
        # Let's search for basic syntax issues like missing "end"
        
        # Count words: "function", "do", "then", "if" (but "if" and "elseif" can be tricky),
        # Actually a better check is to use regex to find common patterns of missing paths
        
        # Check RemoteEvents mismatch
        # e.g. looking for "ClientRemotes" or "NetChannels" mismatch
        pass

    print("Checking for require(...) missing paths...")
    # Read RuntimeServer.server.luau
    if "src/Server/RuntimeServer.server.luau" in files:
        rs_content = files["src/Server/RuntimeServer.server.luau"]
        requires = re.findall(r'require\(([^)]+)\)', rs_content)
        for req in requires:
            if "ServerScriptService.Server.Services." in req:
                svc = req.split(".")[-1]
                svc_path = "src/Server/Services/" + svc + ".luau"
                if svc_path not in files:
                    print(f"FATAL: RuntimeServer requires {svc} but file {svc_path} does not exist!")

    # Read RuntimeClient.client.luau
    if "src/Client/RuntimeClient.client.luau" in files:
        rc_content = files["src/Client/RuntimeClient.client.luau"]
        requires = re.findall(r'require\(([^)]+)\)', rc_content)
        for req in requires:
            if "controllersFolder." in req:
                ctrl = req.split(".")[-1]
                ctrl_path = "src/Client/Controllers/" + ctrl + ".luau"
                if ctrl_path not in files:
                    print(f"FATAL: RuntimeClient requires {ctrl} but file {ctrl_path} does not exist!")

if __name__ == "__main__":
    main()
