#!/usr/bin/env python3
# WHY: p13's string matching can't see shell structure (ERR-018 class).
# bashlex AST gives real command/redirect/write-target extraction.
# Output: {"ok":true,"commands":[...],"writes":[...]} or {"ok":false}.
import sys, json, os.path
import bashlex

WRITE_VERBS = {"rm", "cp", "mv", "install", "dd", "tee", "truncate",
               "touch", "patch", "nano", "vim", "vi", "code", "sed"}
ROOT = sys.argv[1] if len(sys.argv) > 1 else os.getcwd()
WORK = sys.argv[2] if len(sys.argv) > 2 and sys.argv[2] else ROOT
GIT_WRITE_SUBS = {"checkout", "restore", "apply", "clean", "am", "reset", "commit-tree"}
MAX_DEPTH = 6

def walk(node, depth=0):
    """Iterate all AST nodes including nested command subs."""
    if depth > MAX_DEPTH:
        return
    yield node
    for part in getattr(node, "parts", []) or []:
        yield from walk(part, depth + 1)
    for sub in getattr(node, "list", []) or []:
        yield from walk(sub, depth + 1)
    for cs in [getattr(node, "command", None)]:
        if cs is not None and cs is not node:
            yield from walk(cs, depth + 1)

def words_of(node):
    return [p.word for p in getattr(node, "parts", [])
            if getattr(p, "kind", "") == "word"]

def analyze(text, depth=0):
    cmds, writes, cds = [], set(), []
    # bashlex strips \ inside quoted strings — "C:\governance-dev\policies\x"
    # becomes a slashless C:governance-devpoliciesx that defeats seg_match.
    # Parse both raw and backslash-normalized text, union the results.
    trees = []
    for t in {text, text.replace("\\", "/")}:
        try:
            trees += bashlex.parse(t)
        except Exception:
            pass
    if not trees:
        return None
    for tree in trees:
        for n in walk(tree):
            if n.kind == "command":
                ws = words_of(n)
                if not ws:
                    continue
                verb = os.path.basename(ws[0])
                if verb.endswith(".exe"):
                    verb = verb[:-4]
                cmds.append(verb)
                rest = ws[1:]
                if verb == "cd" and rest:
                    cds.append(rest[0])
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
                elif verb == "cp":
                    nf = [w for w in rest if not w.startswith("-")]
                    if nf:
                        writes.add(nf[-1])
                elif verb == "mv":
                    writes |= {w for w in rest if not w.startswith("-")}
                elif verb == "find" and any(f in rest for f in ("-exec", "-execdir", "-ok")):
                    for f in ("-exec", "-execdir", "-ok"):
                        if f in rest:
                            i = rest.index(f)
                            inner = [w for w in rest[i + 1:] if w not in {";", "\\;", "+"}]
                            if inner:
                                cmds.append(os.path.basename(inner[0]))
                                writes |= {w for w in inner[1:] if not w.startswith("-")}
                            break
                elif verb == "xargs":
                    nf = [w for w in rest if not w.startswith("-") and "=" not in w]
                    if nf:
                        cmds.append(os.path.basename(nf[0]))
                        writes |= set(nf[1:])
                elif verb in WRITE_VERBS - {"sed", "cp", "mv"}:
                    writes |= {w for w in rest if not w.startswith("-")}
            elif n.kind == "redirect" and n.type in {">", ">>", "&>", "&>>", ">&", "<>"}:
                out = getattr(n, "output", None)
                if out and getattr(out, "kind", "") == "word":
                    writes.add(out.word)
    out = set()
    for w in writes:
        if os.path.isabs(w):
            out.add(w)
        else:
            out.add(os.path.normpath(os.path.join(WORK, w)))
            for cd in cds:
                out.add(os.path.normpath(os.path.join(WORK, cd, w)))
    return cmds, out

if __name__ == "__main__":
    try:
        text = sys.stdin.read()
        res = analyze(text)
        if res is None:
            print('{"ok":false}')
        else:
            print(json.dumps({"ok": True, "commands": res[0], "writes": sorted(res[1])}))
    except Exception:
        print('{"ok":false}')
