---
name: code-review
description: Review the diff of the current branch for bugs and missing tests.
---

Read `git diff main...HEAD`. List each bug or missing test with its file:line.
Then run `make test` and report failures.
