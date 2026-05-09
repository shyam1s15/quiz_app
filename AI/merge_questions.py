"""
Fixes geography.json (Python code mixed in) and merges all 5 category
JSON files into assets/data/questions.json
"""
import json, re, sys, os

BASE = os.path.dirname(os.path.abspath(__file__))
OUT  = os.path.join(BASE, '..', 'assets', 'data', 'questions.json')

# ── helpers ────────────────────────────────────────────────────────────────

def load(path):
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)

def save(path, data):
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

# ── fix geography (contains Python source + JSON output) ───────────────────

def fix_geography():
    with open(os.path.join(BASE, 'geography.json'), 'r', encoding='utf-8') as f:
        raw = f.read()

    # The valid JSON is the LAST complete [...] block in the file.
    # Find every position that looks like the start of a JSON array of objects.
    matches = list(re.finditer(r'\[\s*\{\s*"id"\s*:', raw))
    if not matches:
        print("ERROR: Could not find valid JSON array in geography.json")
        sys.exit(1)

    json_str = raw[matches[-1].start():]
    # Trim any trailing Python/text after the closing bracket
    depth, end = 0, 0
    for i, ch in enumerate(json_str):
        if ch == '[': depth += 1
        elif ch == ']':
            depth -= 1
            if depth == 0:
                end = i + 1
                break

    questions = json.loads(json_str[:end])
    print(f"  Geography  : {len(questions)} questions extracted from mixed file")
    return questions

# ── fix current_affairs (has extra 'difficulty' field, some 3-option Qs) ──

def fix_current_affairs():
    data = load(os.path.join(BASE, 'current_affairs.json'))
    fixed = []
    skipped = 0
    for q in data:
        q.pop('difficulty', None)          # remove extra field
        if len(q.get('options', [])) != 4:
            skipped += 1
            continue                        # skip malformed questions
        if 'question' not in q:
            skipped += 1
            continue
        fixed.append(q)
    print(f"  Current Affairs: {len(fixed)} questions ({skipped} skipped — bad format)")
    return fixed

# ── load remaining categories ──────────────────────────────────────────────

def load_simple(filename, label):
    data = load(os.path.join(BASE, filename))
    print(f"  {label:<16}: {len(data)} questions")
    return data

# ── main ───────────────────────────────────────────────────────────────────

print("Loading category files …")
science        = load_simple('science_data.json',    'Science')
history        = load_simple('history_quiz_200.json','History')
geography      = fix_geography()
current_affairs= fix_current_affairs()
sports         = load_simple('sports_data.json',     'Sports')

# Validate each question has required fields
REQUIRED = {'category', 'question', 'options', 'correctIndex'}

def validate(questions, label):
    out, bad = [], 0
    for q in questions:
        if not REQUIRED.issubset(q.keys()):
            bad += 1; continue
        if len(q['options']) != 4:
            bad += 1; continue
        ci = q['correctIndex']
        if not (0 <= ci <= 3):
            bad += 1; continue
        out.append(q)
    if bad:
        print(f"  WARN  {label}: {bad} questions removed (missing fields / bad correctIndex)")
    return out

science         = validate(science,         'Science')
history         = validate(history,         'History')
geography       = validate(geography,       'Geography')
current_affairs = validate(current_affairs, 'Current Affairs')
sports          = validate(sports,          'Sports')

# Merge + reassign sequential IDs
all_q = []
new_id = 1
for bucket in [science, history, geography, current_affairs, sports]:
    for q in bucket:
        q['id'] = new_id
        new_id += 1
        all_q.append(q)

print(f"\nMerge summary:")
for cat in ['Science', 'History', 'Geography', 'Current Affairs', 'Sports']:
    n = sum(1 for q in all_q if q.get('category') == cat)
    print(f"  {cat:<18}: {n}")
print(f"  {'TOTAL':<18}: {len(all_q)}")

save(OUT, all_q)
print(f"\nOK  Saved -> {os.path.normpath(OUT)}")
