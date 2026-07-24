import re
import subprocess

def run_selene():
    result = subprocess.run(['selene', 'src/'], capture_output=True, text=True)
    return result.stderr

def fix_unused_variable(filepath, line_num, variable_name, line_content):
    with open(filepath, 'r') as f:
        lines = f.readlines()
    
    idx = line_num - 1
    line = lines[idx]
    
    # If it's a local service or require, just comment it out or remove it
    if re.search(r'local\s+' + variable_name + r'\s*=\s*(game:GetService|require)', line):
        lines[idx] = "-- " + line
    else:
        # It's a parameter or something, prefix with _
        # Be careful not to replace it everywhere
        pass
    
    with open(filepath, 'w') as f:
        f.writelines(lines)

def fix_multiple_statements(filepath, line_num, line_content):
    with open(filepath, 'r') as f:
        lines = f.readlines()
        
    idx = line_num - 1
    line = lines[idx]
    
    # Try to fix `if cond then action end`
    if re.search(r'if\s+(.*?)\s+then\s+(.*?)\s+end', line):
        m = re.search(r'(\s*)if\s+(.*?)\s+then\s+(.*?)\s+end', line)
        if m:
            indent = m.group(1)
            lines[idx] = f"{indent}if {m.group(2)} then\n{indent}    {m.group(3)}\n{indent}end\n"
    # Try to fix `function() action end`
    elif re.search(r'function\((.*?)\)\s+(.*?)\s+end', line):
        m = re.search(r'(\s*)(.*?)function\((.*?)\)\s+(.*?)\s+end(.*)', line)
        if m:
            lines[idx] = f"{m.group(1)}{m.group(2)}function({m.group(3)})\n{m.group(1)}    {m.group(4)}\n{m.group(1)}end{m.group(5)}\n"
            
    with open(filepath, 'w') as f:
        f.writelines(lines)

def main():
    pass

if __name__ == '__main__':
    main()
