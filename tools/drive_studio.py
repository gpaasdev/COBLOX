#!/usr/bin/env python3
import subprocess
import json

def drive_studio():
    proc = subprocess.Popen(
        ["/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )
    
    # 1. Initialize
    init_request = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
            "protocolVersion": "2024-11-05",
            "capabilities": {},
            "clientInfo": {"name": "AntigravityQA", "version": "1.0.0"}
        }
    }
    proc.stdin.write(json.dumps(init_request) + "\n")
    proc.stdin.flush()
    proc.stdout.readline() # Read init response

    # 2. Call execute_luau to simulate player clicking Hatch Egg or walking to pad
    luau_script = """
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer or Players:GetPlayers()[1]
    if player then
        print("[AUTOMATED QA AGENT] Successfully connected to Studio Playtest!")
        print("[AUTOMATED QA AGENT] Active Player:", player.Name)
        
        -- Simulate Hatching Egg from Server/Client
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
        local hatchFunc = NetChannels.GetRemoteFunction("RequestHatch")
        
        local res = hatchFunc:InvokeServer("Egg_Basic")
        print("[AUTOMATED QA AGENT] Hatch Result:", res)
    end
    """
    
    call_request = {
        "jsonrpc": "2.0",
        "id": 2,
        "method": "tools/call",
        "params": {
            "name": "execute_luau",
            "arguments": {
                "script": luau_script
            }
        }
    }
    
    proc.stdin.write(json.dumps(call_request) + "\n")
    proc.stdin.flush()
    
    res = proc.stdout.readline()
    print("[Studio QA Result]:", res)
    proc.terminate()

if __name__ == "__main__":
    drive_studio()
