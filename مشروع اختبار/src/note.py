#!/usr/bin/env python3
import json
import sys
from datetime import datetime
from pathlib import Path

NOTES_FILE = Path(__file__).resolve().parent / "notes.json"


def load_notes():
    if not NOTES_FILE.exists():
        return []
    try:
        return json.loads(NOTES_FILE.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        print("خطأ: ملف notes.json تالف وغير قابل للقراءة.")
        sys.exit(2)


def save_notes(notes):
    NOTES_FILE.write_text(
        json.dumps(notes, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def cmd_add():
    text = sys.stdin.read().strip()
    if not text:
        print("خطأ: لا يمكن حفظ ملاحظة فارغة.")
        sys.exit(1)
    notes = load_notes()
    note = {
        "id": max((n["id"] for n in notes), default=0) + 1,
        "created": datetime.now().strftime("%Y-%m-%dT%H:%M:%S"),
        "text": text,
    }
    notes.append(note)
    save_notes(notes)
    print(f"تم حفظ الملاحظة رقم {note['id']}.")


def cmd_list():
    notes = load_notes()
    if not notes:
        print("لا توجد ملاحظات بعد.")
        return
    for n in notes:
        print(f"[{n['id']}] {n['created']}")
        print(n["text"])
        print()


def cmd_search(query):
    notes = load_notes()
    words = query.lower().split()
    hits = [n for n in notes if all(w in n["text"].lower() for w in words)]
    if not hits:
        print("لا توجد نتائج.")
        return
    for n in hits:
        print(f"[{n['id']}] {n['created']}")
        print(n["text"])
        print()


def main():
    sys.stdin.reconfigure(encoding="utf-8")
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")
    if len(sys.argv) < 2:
        print("الاستخدام: note add | note list | note search <كلمات>")
        sys.exit(1)
    cmd = sys.argv[1]
    if cmd == "add":
        cmd_add()
    elif cmd == "list":
        cmd_list()
    elif cmd == "search":
        cmd_search(" ".join(sys.argv[2:]))
    else:
        print(f"خطأ: أمر غير معروف '{cmd}'. الاستخدام: add | list | search")
        sys.exit(1)


if __name__ == "__main__":
    main()
