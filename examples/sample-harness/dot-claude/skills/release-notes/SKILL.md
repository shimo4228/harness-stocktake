---
name: release-notes
description: Draft release notes from the commits since the last tag.
---

1. `git describe --tags --abbrev=0` to find the last tag.
2. `git log <tag>..HEAD --oneline` and group the commits by type.
3. Write the notes to `CHANGELOG.md` under a new heading.
