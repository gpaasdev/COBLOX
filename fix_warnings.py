import re
import os

def process_file(filepath):
    with open(filepath, 'r') as f:
        lines = f.readlines()
        
    new_lines = []
    for i, line in enumerate(lines):
        # Unused game:GetService or require
        if re.search(r'^local\s+\w+\s*=\s*(game:GetService|require)\(', line):
            # We don't know if it's unused, but we can't easily parse. 
            pass
            
    # We will just allow some rules in selene.toml
