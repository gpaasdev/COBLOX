import os
import re

def main():
    src_dir = "src"
    
    server_events = set()
    client_events = set()
    
    server_funcs = set()
    client_funcs = set()
    
    for root, _, filenames in os.walk(src_dir):
        for filename in filenames:
            if filename.endswith(".luau"):
                filepath = os.path.join(root, filename)
                with open(filepath, "r", encoding="utf-8") as f:
                    content = f.read()
                
                # Find GetRemoteEvent("NAME")
                events = re.findall(r'GetRemoteEvent\("([^"]+)"\)', content)
                funcs = re.findall(r'GetRemoteFunction\("([^"]+)"\)', content)
                
                if "Server" in filepath:
                    server_events.update(events)
                    server_funcs.update(funcs)
                else:
                    client_events.update(events)
                    client_funcs.update(funcs)
                    
                # Also check ClientRemotes.Get("NAME") in client
                if "Client" in filepath:
                    client_remotes = re.findall(r'ClientRemotes\.Get\("([^"]+)"\)', content)
                    client_events.update(client_remotes)
                    client_remote_funcs = re.findall(r'ClientRemotes\.GetFunction\("([^"]+)"\)', content)
                    client_funcs.update(client_remote_funcs)

    print("--- RemoteEvents ---")
    print("Server has:", server_events)
    print("Client expects:", client_events)
    print("Missing in Server:", client_events - server_events)
    print("Missing in Client:", server_events - client_events)
    
    print("\n--- RemoteFunctions ---")
    print("Server has:", server_funcs)
    print("Client expects:", client_funcs)
    print("Missing in Server:", client_funcs - server_funcs)
    print("Missing in Client:", server_funcs - client_funcs)

if __name__ == "__main__":
    main()
