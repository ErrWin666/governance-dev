#!/usr/bin/env python3
# WHY: p13's string matching can't see shell structure (ERR-018 class).
# bashlex AST gives real command/redirect/write-target extraction.
# Output: {"ok":true,"commands":[...],"writes":[...]} or {"ok":false}.
import sys, json, os.path
import bashlex

WRITE_VERBS = {"rm", "cp", "mv", "install", "dd", "tee", "truncate",
               "touch", "patch", "nano", "vim", "vi", "code", "sed"}
GIT_WRITE_SUBS = {"checkout", "restore", "apply", "clean", "am", "reset", "commit-tree"}
MAX_DEPTH = 3

def walk(node, depth=0):
    """Iterate all AST nodes including nested command subs."""
    if depth > MAX_DEPTH:
        return
    yield node
    for part in getattr(node, "parts", []) or []:
        yield from walk(part, depth + 1)
    for sub in getattr(node, "list", []) or []:
        yield from walk(sub, depth + 1)

def words_of(node):
    return [p.word for p in getattr(node, "parts", [])
            if getattr(p, "kind", "") == "word"]

def analyze(text, depth=0):
    cmds, writes = [], set()
    try:
        trees = bashlex.parse(text)
    except Exception:
        return None
    for tree in trees:
        for n in walk(tree):
            if n.kind == "command":
                ws = words_of(n)
                if not ws:
                    continue
                verb = os.path.basename(ws[0])
                cmds.append(verb)
                rest = ws[1:]
                if verb in {"bash", "sh", "wsl"} and "-c" in rest and depth < MAX_DEPTH:
                    i = rest.index("-c")
                    if i + 1 < len(rest):
                        sub = analyze(rest[i + 1], depth + 1)
                        if sub:
                            cmds += sub[0]; writes |= sub[1]
                elif verb == "sed" and ("-i" in rest or "--in-place" in rest):
                    for w in rest:
                        if w.startswith("-") or w.startswith("s/") or w == "-i":
                            continue
                        writes.add(w)
                elif verb == "git" and rest and rest[0] in GIT_WRITE_SUBS:
                    writes |= {w for w in rest[1:] if not w.startswith("-")}
                elif verb in WRITE_VERBS - {"sed"}:
                    writes |= {w for w in rest if not w.startswith("-")}
            elif n.kind == "redirect" and n.type in {">", ">>", "&>"}:
                out = getattr(n, "output", None)
                if out and getattr(out, "kind", "") == "word":
                    writes.add(out.word)
    return cmds, writes

try:
    text = sys.stdin.read()
    res = analyze(text)
    if res is None:
        print('{"ok":false}')
    else:
        print(json.dumps({"ok": True, "commands": res[0], "writes": sorted(res[1])}))
except Exception:
    print('{"ok":false}')
