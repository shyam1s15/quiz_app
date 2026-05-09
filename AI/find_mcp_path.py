import re

with open(r'C:\Users\LENOVO\AppData\Roaming\npm\node_modules\google-play-developer-mcp\dist\index.js', encoding='utf-8') as f:
    content = f.read()

# Look for key storage path patterns
patterns = [
    r'\.google-play[^\s"\']{0,60}',
    r'accounts[^\s"\']{0,60}\.json',
    r'keyFile[^\s"\']{0,60}',
    r'homedir[^\s"\']{0,60}',
    r'APPDATA[^\s"\']{0,60}',
]

for p in patterns:
    hits = re.findall(p, content)
    for h in set(hits):
        print(h)
