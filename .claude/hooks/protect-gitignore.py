#!/usr/bin/env python3
"""PreToolUse hook (Edit|Write|MultiEdit): block edits that stop .gitignore from ignoring .env files.

Denies the edit when the resulting .gitignore would
  - drop an env rule (.env, .env.*, *.env) that the current file has, or
  - add a negation that un-ignores env files (e.g. !.env, !.env.local); !.env.example is allowed.
"""
import json
import os
import re
import sys

PROTECTED = {".env", ".env.*", "*.env"}
ALLOWED_NEGATIONS = {"!.env.example"}
ENV_NEGATION = re.compile(r"^!\S*\.env(\b|\.|\*|$)")


def rules(text):
    return {ln.strip() for ln in text.splitlines() if ln.strip() and not ln.strip().startswith("#")}


def deny(reason):
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": f"Blocked: {reason}. .env files must stay ignored by git (project policy).",
    }}))
    sys.exit(0)


def main():
    data = json.load(sys.stdin)
    tool, inp = data.get("tool_name", ""), data.get("tool_input", {}) or {}
    path = inp.get("file_path", "")
    if os.path.basename(path) != ".gitignore":
        return

    try:
        with open(path, encoding="utf-8") as f:
            old = f.read()
    except FileNotFoundError:
        old = ""

    if tool == "Write":
        new = inp.get("content", "")
    else:
        edits = inp.get("edits") if tool == "MultiEdit" else [inp]
        new = old
        for e in edits or []:
            o, n = e.get("old_string", ""), e.get("new_string", "")
            new = new.replace(o, n) if e.get("replace_all") else new.replace(o, n, 1)

    before, after = rules(old), rules(new)
    removed = sorted((PROTECTED & before) - after)
    if removed:
        deny(f"edit removes env rule(s) from .gitignore: {', '.join(removed)}")
    unignored = sorted(r for r in after - before if ENV_NEGATION.match(r) and r not in ALLOWED_NEGATIONS)
    if unignored:
        deny(f"edit adds negation(s) that un-ignore env files: {', '.join(unignored)}")


if __name__ == "__main__":
    main()
