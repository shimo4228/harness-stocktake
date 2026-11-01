# Harness stocktake 2026-11-01 — examples/sample-harness

- **date:** 2026-11-01
- **base:** `6fcfad3b75818d2d2d87ef51bfec78e3deb1ce28`

| Group | Count |
|---|---|
| Retire | 6 |
| Merge / demote | 1 |
| Improve / update | 15 |
| Keep | 7 |
| **Total** | **29** |

To override an item, edit its `decision` cell (blank = accept; or `skip`, `Keep`, another verdict word, or a note). Then approve in chat.

## Sources

### hooks — 3 targets: Retire 2 · Improve 1 · Keep 0


Keep: 0

### docs (context-sync) — 5 items: Update 4 · Keep 1


Keep: 1 (docs/adr/0001-in-memory-store.md)

### agents — 1 target · Dissolve 1 · Keep 0

Scope: .claude/agents/*.md (1 file, 0 unreadable). Total description words: 10. Usage: n/a (project mode).


Keep: 0

### distill — 5 items (Revise 1 · Already Covered 1 · Too Specific 3 · Keep 0)


Keep: 0

### Skills (.claude/skills, 4 scanned) — Update 1 · Merge 1 · Improve 2 · Keep 0


Keep: 0. Usage evidence: n/a (project mode). Residency cost: not measured. Phase 0: no symlinked (external) skill dirs; no ledger (dry run).

### assets (repo-asset-stocktake) — 10 items: Retire 2 · Update 6 · Merge 0 · Keep 2

Scope: whole repo (project mode, dry run); skills/rules/agents/hooks judged here only for dead reference edges.


Keep: 2 (.claude/hooks/format.sh, docs/adr/0001-in-memory-store.md)

### rules — 1 target: Retire 1 · Keep 0

Scan: 1 file (.claude/rules/style.md), 6 lines. Integrity: no skill pointers, no relative links, no rules/README.md. This harness states no header convention, so none was checked.


Keep: 0

## Collisions

- docs-01 × docs-02 × docs-03 × distill-01 (same-target): `CLAUDE.md`
- agents-01 × assets-05 (same-target): `.claude/agents/reviewer.md`
- skills-01 × assets-03 (same-target): `.claude/skills/deploy/SKILL.md`
- assets-07 × rules-01 (same-target): `.claude/rules/style.md`
- hooks-01 × assets-02 (duplicate): Both delete the Bash → check-secrets.sh block (settings.json:8-11); applying hooks-01 settles assets-02. — hooks-01 wins
- hooks-01 × hooks-03 (same-file): Both edit .claude/settings.json on different lines (8-11 vs 6); compatible, apply in one commit.
- rules-01 × assets-07 (incompatible): rules-01 deletes style.md; assets-07 rewrites its line 6 (black → ruff). Deleting the file removes the contradiction too. — rules-01 wins
- rules-01 × docs-03 (incompatible): docs-03 keeps style.md as the only copy and points CLAUDE.md at it; rules-01 deletes style.md and keeps CLAUDE.md as the copy. — rules-01 wins
- agents-01 × assets-05 (incompatible): assets-05 edits reviewer.md:9; agents-01 dissolves the file, which drops the bad pointer with it. — agents-01 wins
- skills-01 × assets-03 (incompatible): skills-01 repairs the deploy skill, assets-03 retires it; depends on whether a staging deploy still exists — author to settle. — skills-01 wins
- docs-01 × distill-01 (same-fact): Both act on CLAUDE.md:8 (make e2e). docs-01 deletes the line; distill-01 offers three fixes. Pick one; whichever is chosen, skills-01 must make deploy step 1 match.
- docs-01 × skills-01 (dependency): deploy SKILL.md:6 runs `make e2e`; skills-01's replacement command must match what CLAUDE.md:8 ends up saying.

## Retire

| order | id | verdict | target | reason | change | conflicts | decision |
|---|---|---|---|---|---|---|---|
| 1 | hooks-01 | Retire (alt: Improve) | .claude/hooks/check-secrets.sh | The PostToolUse Bash entry in .claude/settings.json calls .claude/hooks/check-secrets.sh, which does not exist in the repo, so the wiring is dangling: every Bash tool call runs `bash` on a missing file and gets a non-zero exit (a hook error) instead of any secret check. No other file names the script, so there is nothing to recover; remove the dead wiring (or, as the alternative, write and test the script if a secret check is actually wanted). | Delete the second PostToolUse element in .claude/settings.json (lines 8-11, the `{"matcher": "Bash", "hooks": [{... check-secrets.sh}]}` object) and the trailing comma after the Edit\|Write element on line 7. Alternative (Improve): add .claude/hooks/check-secrets.sh that reads tool_input/tool_response from stdin with jq and quotes every value, plus a test. | assets-02, hooks-03 | |
| 2 | hooks-02 | Retire (alt: Improve) | .claude/hooks/notify-done.sh (1 files, 1 items bundled: assets-01) | notify-done.sh is an orphan: its header says it notifies "when a session stops", but .claude/settings.json wires no Stop event and no command calls the script, so it never runs. It is also macOS-only (osascript) in a shared repo config; delete it, or, as the alternative, wire it under Stop if the team wants it. | git rm .claude/hooks/notify-done.sh. Alternative (Improve): add `"Stop": [{"hooks": [{"type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/notify-done.sh"}]}]` to .claude/settings.json and guard the script with `command -v osascript >/dev/null \|\| exit 0`. | — | |
| 3 | agents-01 | Dissolve (alt: Update; Retire) | .claude/agents/reviewer.md | The repo's skills .claude/skills/code-review and .claude/skills/pr-review already do diff-for-bugs review, and Claude Code ships its own /code-review, which runs its reviewers in fresh subagents, so this 2-line agent adds nothing they lack. It also has three defects: it pins the retired model claude-3-opus-20240229, it reads docs/architecture.md, which does not exist, and its frontmatter name (code-reviewer) does not match its filename (reviewer). Its 'Use PROACTIVELY after every change' description still pulls delegation in every session. Delete it and record why in docs/adr/. If the author wants a separate reviewer subagent, Update instead: set an alias model, drop the dead reference, and fix the name. | git rm .claude/agents/reviewer.md; add an ADR under docs/adr/ (e.g. 0002-dissolve-reviewer-agent.md): Context = a 2-line reviewer agent with a retired model and a dead doc reference, duplicating the code-review and pr-review skills and the bundled /code-review; Decision = delete it and review through the code-review skill. Alternative (Update): `name: reviewer` (or rename the file to code-reviewer.md); `model: opus` (or inherit); description → 'Reviews a diff for bugs in a fresh context. Use after a non-trivial change when an independent review is wanted; not for style (black and the format hook own that) or for PR prep (use pr-review).'; body L8 → 'Review every file in the diff and report every bug you find with file:line; the caller filters.'; drop L9 until docs/architecture.md exists. | assets-05 | |
| 5 | assets-03 | Retire (alt: Update) | .claude/skills/deploy/SKILL.md | Retire — the deploy runbook's two executable steps both point at things that do not exist: `make e2e` has no Makefile target (only `test` and `lint`) and `scripts/deploy.sh` is absent from the repo, so every local reference is dead and following it fails at step 1. | Soft-delete the skill (rename dir to `.claude/skills/deploy.disabled` / move to repo-local trash). Alternative Update: if deployment still exists elsewhere, rewrite the steps against the real commands (pending for the author). | skills-01 | |
| 6 | rules-01 | Retire (alt: Dissolve (line 6 is absorbed by the PostToolUse format hook)) | .claude/rules/style.md | Every line of this 4-rule file is redundant or wrong: lines 3-5 (type hints, f-strings, 40-line functions) repeat CLAUDE.md lines 13, 14, 20 and 21 word for word, and CLAUDE.md is also loaded every session. Line 6 says to format with black, but the format hook it points to runs `ruff format`. CLAUDE.md already covers the style need, and the PostToolUse hook (.claude/settings.json:5-6 -> .claude/hooks/format.sh) covers formatting with no instruction needed, so delete the file. | Delete .claude/rules/style.md (whole file, 6 lines): --- a/.claude/rules/style.md +++ /dev/null @@ -1,6 +0,0 @@ -# Style - -- Use type hints everywhere. -- Prefer f-strings over `%` formatting. -- Keep functions under 40 lines. -- Format Python with black before committing (the format hook does this for you). | assets-07, docs-03 | |

## Merge / demote

| order | id | verdict | target | reason | change | conflicts | decision |
|---|---|---|---|---|---|---|---|
| 7 | skills-02 | Merge into .claude/skills/code-review/SKILL.md (alt: Retire both project review skills in favour of the Claude Code bundled /code-review (see skills-03)) | .claude/skills/pr-review/SKILL.md | ABSORBABLE_OVERLAP with code-review: same trigger (review the current branch's diff for bugs), same command (`git diff main...HEAD`), same output (findings with file:line). Unique residue to move into code-review: the 'unclear names' check and the 'before opening a PR' trigger wording. | Move the 'unclear names' check (pr-review SKILL.md:6) and the 'before opening a PR' trigger into code-review, then delete .claude/skills/pr-review/. | — | |

## Improve / update

| order | id | verdict | target | reason | change | conflicts | decision |
|---|---|---|---|---|---|---|---|
| 8 | hooks-03 | Improve | .claude/hooks/format.sh | format.sh is wired on PostToolUse Edit\|Write and quotes the file path safely, but it has no test, it depends on ruff and jq that nothing in the repo declares (Makefile uses unittest and pyflakes only), it silences all ruff output so a missing ruff fails invisibly, and the command uses a cwd-relative path that breaks when Claude's cwd is not the repo root. rules/style.md:6 also describes this hook as formatting with black, which contradicts the ruff call it actually makes. | In .claude/settings.json:6 change the command to `bash "$CLAUDE_PROJECT_DIR"/.claude/hooks/format.sh`. In format.sh add `command -v ruff >/dev/null \|\| { echo 'format.sh: ruff not installed' >&2; exit 0; }` before line 4 and drop `2>&1` so ruff errors reach stderr. Add a small test (e.g. tests/test_format_hook.sh or a bats file) that pipes `{"tool_input":{"file_path":"x.py"}}` and a non-.py path into the script. Reconcile .claude/rules/style.md:6 to say ruff (rules-source item). | hooks-01 | |
| 9 | docs-01 | Update | CLAUDE.md (1 files, 1 items bundled: assets-04) | CLAUDE.md lists `make e2e` as a command to run before every release, but the Makefile has no e2e target, so any session following it hits 'No rule to make target'. The command line is stale and should be removed (or re-added only once an e2e target exists). | CLAUDE.md, ## Commands: delete line 8 `- \`make e2e\` — end-to-end tests against a local server (run before every release)`. | distill-01, docs-02, docs-03, skills-01 | |
| 10 | docs-02 | Update (alt: Create) | CLAUDE.md | CLAUDE.md points to `docs/architecture.md` for the architecture overview, but that file does not exist. The project is a single 10-line module, so the module layout is derivable from the code; the dangling pointer should be removed rather than a file-level architecture doc created. | CLAUDE.md, ## Conventions: delete line 15 `- Architecture overview: see \`docs/architecture.md\`.` (Alternative `Create`: write docs/architecture.md — not recommended, it would be a hand-written module map of derivable structure.) | distill-01, docs-01, docs-03 | |
| 11 | docs-03 | Update | CLAUDE.md | CLAUDE.md repeats the same style instructions twice within itself and a third time in `.claude/rules/style.md`, so every session loads them redundantly and future edits must be made in up to three places. The rule file is the single home for style; CLAUDE.md should keep only the instruction the rule does not carry (PR-only workflow). | CLAUDE.md: delete lines 13-14 (functions under 40 lines; type hints) and lines 20-21 (type hints; f-strings); replace the ## Style section with one line `- Code style: see \`.claude/rules/style.md\`.`; move line 22 (PR workflow) under ## Conventions next to the ADR pointer. Resulting ## Conventions: ADR pointer, PR workflow, style pointer. **Phase 2:** Since rules-01 retires .claude/rules/style.md, keep the style lines in CLAUDE.md and only delete the duplicate 'Use type hints everywhere' (line 20); add no pointer to style.md. | distill-01, docs-01, docs-02, rules-01 | |
| 12 | docs-04 | Update | README.md (1 files, 1 items bundled: assets-06) | README describes things this repo does not contain: a `bench/time-to-first-item.sh` script and a `dot-claude/` directory (lines 5-7), and an 'HTTP service' (line 3) where the only code is an in-memory dict with an add() function and no HTTP layer. This is flagged for the README owner, not edited by context-sync; the repo has no README skill, so the author decides the wording. | Flag for the author (README owner): README.md lines 5-7 — remove the paragraph about `bench/time-to-first-item.sh` / `dot-claude/` (it describes the bench fixture's origin, not this project), or move it to wherever the bench lives. README.md line 3 — either reword 'HTTP service' to 'in-memory note store (prototype; see docs/adr/0001-in-memory-store.md)' or keep it if an HTTP layer is planned. | — | |
| 13 | distill-01 | Revise (alt: Add an `e2e` target to the Makefile and keep the line as is; Already Covered (if the e2e target is being added elsewhere)) | CLAUDE.md | The release gate the deploy skill relies on (`make e2e` before every release) is already resident in CLAUDE.md, but the fact it states is false: the Makefile has no `e2e` target, so the resident rule points at a command that cannot run. Confidence: high. | In CLAUDE.md under `## Commands`, replace - `make e2e` — end-to-end tests against a local server (run before every release) with either (a) the same line once a `make e2e` target exists in the Makefile, or (b) the real end-to-end command if it lives elsewhere, or (c) remove the line and change skill: `deploy` step 1 to `make test` if no e2e suite exists. Author picks; wording stays pending until chosen. | docs-01, docs-02, docs-03 | |
| 14 | skills-01 | Update (alt: Retire (if notes-api has no staging deploy any more: nothing in the repo or its history deploys it)) | .claude/skills/deploy/SKILL.md | Both commands the skill runs are dangling: the Makefile has no `e2e` target and `scripts/deploy.sh` does not exist in the tree or in git history, so step 1 fails at once and step 2 has nothing to run. Step 3 ('post to the team channel') names no channel or tool. Restore the real deploy entry points, or Retire the skill if staging deploy is gone. | {'engine': 'skill-creator', 'target': '.claude/skills/deploy/SKILL.md', 'sections': ['steps 1-3'], 'no_answers': ['Currency: replace `make e2e` with a target that exists (or add the target to the Makefile)', 'Currency: point step 2 at the real deploy command, or drop it if deploy is not scripted', 'Actionability: name the channel and the tool used to post, and where the notes come from (CHANGELOG.md from release-notes)'], 'precondition': 'author confirms staging deploy still exists; otherwise apply the Retire alternative (delete the skill directory)'} | assets-03, docs-01 | |
| 15 | skills-03 | Improve (alt: Retire: the Claude Code bundled `code-review` skill already reviews the current diff for correctness bugs; keep only if the `make test` step is wanted as project residue) | .claude/skills/code-review/SKILL.md | Survivor of the pr-review merge (skills-02), but its name collides with Claude Code's bundled `code-review` skill, so which one loads for /code-review is ambiguous. Rename it (e.g. `branch-review`) or retire it in favour of the bundled one, and absorb pr-review's 'unclear names' check. | {'engine': 'skill-creator', 'target': '.claude/skills/code-review/SKILL.md', 'sections': ['frontmatter name/description', 'body'], 'no_answers': ['Scope fit / uniqueness: rename away from the bundled `code-review` name and mention the pre-PR trigger', "Merge residue: add the 'unclear names' check from pr-review"]} | — | |
| 16 | skills-04 | Improve | .claude/skills/release-notes/SKILL.md | Step 1 `git describe --tags --abbrev=0` fails in this repo, which has no tags, and nothing says what to do then. Step 2 'group the commits by type' assumes a commit-type convention the repo does not have (one commit, 'sample'). Add a no-tag fallback (all history or the root commit) and say how commits are grouped. | {'engine': 'skill-creator', 'target': '.claude/skills/release-notes/SKILL.md', 'sections': ['steps 1-2'], 'no_answers': ['Currency: fallback when there is no tag (range from the root commit)', 'Actionability: state the grouping rule (e.g. by conventional-commit prefix, else by area)']} | — | |
| 17 | assets-02 | Update (alt: Keep) | .claude/settings.json | Update — `.claude/settings.json:10` wires a PostToolUse `Bash` hook to `bash .claude/hooks/check-secrets.sh`, but that script does not exist in the repo, so the entry fires on every Bash call and runs a missing file; remove the entry or restore the script. | Delete the second PostToolUse matcher block (`"matcher": "Bash"` → `check-secrets.sh`) from `.claude/settings.json`, leaving the Edit\|Write → format.sh entry; or, if a secrets check is intended, add the script (content not guessable — pending for the author). | hooks-01 | |
| 19 | assets-05 | Update | .claude/agents/reviewer.md | Update — the reviewer agent's first instruction is to read `docs/architecture.md` (reviewer.md:9), a file that does not exist in the repo; drop or repoint the line. | Delete line 9 (`Read docs/architecture.md first…`), or point it at `src/notes.py` / CLAUDE.md for the module layout. (Model id and prompt style are left to the agents source.) | agents-01 | |
| 21 | assets-07 | Update | .claude/rules/style.md | Update — style.md:6 says to format with black and that "the format hook does this for you", but the only format hook (`.claude/hooks/format.sh:4`) runs `ruff format`, and black appears nowhere else in the repo; change the line to ruff. | style.md:6 → `- Python is formatted with ruff (the format hook runs \`ruff format\` on every edited .py file).` Rule residency/redundancy is left to the rules source. | rules-01 | |
| 22 | assets-08 | Update (alt: Keep) | Makefile | Update — `make test` (Makefile:3) runs `unittest discover -s src`, but the repo holds no test files, so the gate README and CLAUDE.md tell people to run before pushing checks nothing (and under Python 3.12 unittest exits 5 when no tests run — 未確認, not executed); add tests or point discovery at a real tests dir. | Pending for the author: add a test module (e.g. `src/test_notes.py`) or a `tests/` dir and change the discover path; not a mechanical fix. The `lint` target (pyflakes) is fine. | — | |

## Keep (7)

<details>

| order | id | verdict | target | reason |
|---|---|---|---|---|
| 23 | docs-05 | Keep | docs/adr/0001-in-memory-store.md | ADR-0001 still matches the code: notes live in a module-level dict, and its revisit trigger (adding PostgreSQL) has not fired. |
| 24 | distill-02 | Already Covered | CLAUDE.md | The wiring that `main` is the base branch and work reaches it through a PR, which both review skills assume (`git diff main...HEAD`), is already resident in CLAUDE.md. |
| 25 | distill-03 | Too Specific | .claude/skills/deploy/SKILL.md | Deploying via `scripts/deploy.sh staging` and posting release notes to the team channel are deploy-task steps, not facts that must hold before any task starts, so they stay in skill: `deploy`. |
| 26 | distill-04 | Too Specific | .claude/skills/release-notes/SKILL.md | Release notes are drafted from tag-to-HEAD commits into `CHANGELOG.md`; this only matters while writing release notes, so it stays in skill: `release-notes`. |
| 27 | distill-05 | Too Specific | .claude/skills/code-review/SKILL.md | "Review a diff for bugs and missing tests and report each with file:line" recurs in two skills but is a general engineering practice the substrate already does, so it is not a rule candidate and stays at skill level. |
| 28 | assets-09 | Keep | .claude/hooks/format.sh | Keep — `format.sh` is wired as the PostToolUse Edit\|Write hook (settings.json:6) and formats edited .py files with ruff, matching the Python codebase. |
| 29 | assets-10 | Keep | docs/adr/0001-in-memory-store.md | Keep — ADR-0001 is reached via CLAUDE.md:16 (`docs/adr/`) and its decision (module-level dict store) still matches `src/notes.py:3`. |

</details>

## What the native checks cover

This report judges content (stale references, contradictions, configuration whose owner is gone, distillation into rules). Usage history and writing style are what Claude Code's native checks see: `/doctor` lists unused plugins, MCP servers and skills and slow hooks; `/doctor prompt-audit` flags writing aimed at older models (fixed numeric caps, heavy emphasis, mentions of tools that do not exist). The two do not overlap, so run both and read them side by side (this run ran neither).
