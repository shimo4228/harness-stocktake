---
name: pr-review
description: Review the current branch's diff for bugs before opening a PR.
---

Run `git diff main...HEAD`. For each file, look for bugs, missing tests and unclear names.
Report findings as a list with file:line.
