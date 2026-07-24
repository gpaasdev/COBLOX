#!/usr/bin/env python3
import subprocess
import json

def test_mcp():
    proc = subprocess.Popen(
        ["/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )
    
    init_request = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
            "protocolVersion": "2024-11-05",
            "capabilities": {},
            "clientInfo": {"name": "AntigravityIDE", "version": "1.0.0"}
        }
    }
    
    proc.stdin.write(json.dumps(init_request) + "\n")
    proc.stdin.flush()
    
    response = proc.stdout.readline()
    print("Init Response Length:", len(response))
    
    list_tools_request = {
        "jsonrpc": "2.0",
        "id": 2,
        "method": "tools/list",
        "params": {}
    }
    proc.stdin.write(json.dumps(list_tools_request) + "\n")
    proc.stdin.flush()
    
    tools_response = proc.stdout.readline()
    try:
        data = json.loads(tools_response)
        tools = data.get("result", {}).get("tools", [])
        print(f"[StudioMCP] Successfully connected! Found {len(tools)} tools.")
    except Exception as e:
        print("[StudioMCP] Tools response:", tools_response[:200])

    # Call get_studio_state
    call_request = {
        "jsonrpc": "2.0",
        "id": 3,
        "method": "tools/call",
        "params": {
            "name": "get_studio_state",
            "arguments": {}
        }
    }
    proc.stdin.write(json.dumps(call_request) + "\n")
    proc.stdin.flush()

    call_response = proc.stdout.readline()
    print("[StudioMCP] Studio State Response:", call_response)

    proc.terminate()

if __name__ == "__main__":
    test_mcp()
