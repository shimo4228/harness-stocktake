# Harness stocktake 2026-11-02 — examples/sample-harness

- **date:** 2026-11-02
- **base:** `dc1ab8234b46445ab7e1b635b8a17039bd2467e2`

| Group | Count |
|---|---|
| Retire | 5 |
| Merge / demote | 1 |
| Improve / update | 12 |
| Keep | 10 |
| **Total** | **28** |

To override an item, edit its `decision` cell (blank = accept; or `skip`, `Keep`, another verdict word, or a note). Then approve in chat.

## Sources

### hooks — 3 items: Retire 2 · Improve 1 · Keep 0

Hooks found 3 (2 scripts on disk, 1 dangling command), wired 1, orphaned 1, dangling 1; no hook tests in the repo (—). No ledger exists yet (`.claude/stocktake/hook-stocktake.json`).


Keep: 0

### docs — Update 4 · Keep 1


Keep: 1 (docs/adr/0001-in-memory-store.md)

### agents — 1 target · Dissolve 1 · Keep 0

Scan: 1 agent definition, 0 unreadable, 10 description words loaded into every session, usage n/a (project mode), no ledger yet.

| Agent | Desc words | Body lines | Usage 90d | Verdict | Reason |
|---|---|---|---|---|---|
| code-reviewer (reviewer.md) | 10 | 2 | — | Dissolve | Built-in `/code-review` and the project's `code-review` / `pr-review` skills already cover diff review |


Keep: 0

Description words: 10 in total, with no previous audit to compare against.

### distill (rules-distill) — Revise 2 · Already Covered 2 · Too Specific 3

Inventory: 4 skills, 1 rule file (`.claude/rules/style.md`, 1 heading) + `CLAUDE.md`; no ledger at `.claude/stocktake/rules-distill.json` (dry run, none written). No new resident candidate passed tests 1–3.


Keep group (Already Covered / Too Specific): 5

### skills — 4 items: Update 1 · Merge 1 · Improve 1 · Keep 1

Scanned `.claude/skills/*/SKILL.md` (4 skills). There are no symlinks, no dangling skill-name references and no URLs. No ledger exists at `.claude/stocktake/skill-stocktake.json`, so there is nothing to clean up. Usage and residency cost are `n/a` in project mode.


Keep: 1 (pr-review, the merge target)

### assets — repo-asset-stocktake (7 assets: Retire 1 · Update 3 · Merge 0 · Keep 3)


Keep: 3 (`.claude/hooks/format.sh`, `Makefile`, `docs/adr/0001-in-memory-store.md`).

No ledger (`.repo-asset-stocktake.json`) was present, so this run has no delta. Skills, rules and CLAUDE.md belong to the sibling sources.

### rules — 1 target (Retire 1, Keep 0)

Scan: 1 rule file, 6 lines in total, 0 integrity failures. No ledger exists (`.claude/stocktake/rules-stocktake.json`), so this is a first run and there is no line-count delta to compare against.


Keep: 0

## Collisions

- hooks-01 × assets-01 (same-target): `.claude/settings.json`
- docs-02 × docs-03 × distill-02 (same-target): `CLAUDE.md`
- agents-01 × assets-03 (same-target): `.claude/agents/reviewer.md`
- distill-01 × rules-01 (same-target): `.claude/rules/style.md`
- rules-01 × docs-03 (pointer): docs-03 replaces the CLAUDE.md style bullets with a pointer to .claude/rules/style.md, which rules-01 deletes; with rules-01 applied, docs-03 keeps the bullets in CLAUDE.md and only drops the duplicate 'Use type hints everywhere.' line — rules-01 wins
- rules-01 × distill-01 (same-file): distill-01 fixes style.md:6 (black -> ruff); rules-01 deletes the whole file, which removes the stale line too. distill-01 applies only if rules-01 is overridden to Keep/Improve — rules-01 wins
- agents-01 × assets-03 (same-file): assets-03 edits reviewer.md (dead docs/architecture.md pointer, retired model pin); agents-01 deletes the file, which makes those edits moot — agents-01 wins
- hooks-01 × assets-01 (same-file): same fact (settings.json:8-11 calls the missing check-secrets.sh) and the same removal; applying hooks-01 resolves assets-01 — hooks-01 wins
- distill-02 × skills-01 (pointer): both rest on the missing `make e2e` target; the choice made for distill-02 (add an e2e target, or make `make test` the release gate) decides deploy step 1 in skills-01
- docs-02 × docs-03 (same-file): both diffs touch CLAUDE.md:15 (the docs/architecture.md pointer); apply docs-02 first and drop that line from docs-03's context

## Retire

| order | id | verdict | target | reason | change | conflicts | decision |
|---|---|---|---|---|---|---|---|
| 1 | hooks-01 | Retire (alt: Improve (write the missing .claude/hooks/check-secrets.sh instead of removing the wiring)) | .claude/settings.json | The PostToolUse/Bash entry calls `bash .claude/hooks/check-secrets.sh`, a script that does not exist and never existed in git history, so the hook is broken on every Bash call and checks nothing. No test, README row, skill or rule describes what it was meant to check, so there is no spec to rebuild it from; retire the dangling entry, and only choose the Improve alternative if the author wants a secrets check and will write it. | Delete the second PostToolUse entry (`{"matcher": "Bash", "hooks": [{"type": "command", "command": "bash .claude/hooks/check-secrets.sh"}]}`, settings.json:8-11) and the preceding comma, leaving only the Edit\|Write → format.sh entry. | assets-01 | |
| 2 | hooks-02 | Retire (alt: Improve (wire it to a Stop event in .claude/settings.json if the author still wants the notification)) | .claude/hooks/notify-done.sh (1 files, 1 items bundled: assets-02) | notify-done.sh is an orphan: its header says it notifies "when a session stops", but settings.json has no Stop event and no command calls it, so it never runs. It is also macOS-only (`osascript`) inside a shared project harness, which argues against wiring it at project level rather than in a personal settings.local.json or ~/.claude. | Delete .claude/hooks/notify-done.sh (no settings.json, test or README entry to remove). | — | |
| 3 | agents-01 | Dissolve (alt: Retire (on defects alone: pinned retired model, dangling doc reference, name/filename mismatch). Improve, only if a fresh-context read-only reviewer is wanted as a separate agent: set `model: opus` (alias), name it `reviewer` to match the file, drop the ALWAYS/NEVER line, remove the missing-doc read, and scope the description ("use for a fresh-context review of a finished diff; not for one-line edits").) | .claude/agents/reviewer.md | The diff-review job of agent `code-reviewer` is already covered by the built-in `/code-review` skill and by the project's own `code-review` and `pr-review` skills, and its two-line body adds nothing they lack. It is also broken as written. It pins `claude-3-opus-20240229`, a model Anthropic has retired, so the agent probably cannot run. It tells the agent to read `docs/architecture.md`, a file the repo does not have. Its description ("Use PROACTIVELY after every change") pushes delegation after every edit and never says when not to delegate, so its residency cost buys over-firing. Review is a fresh-context role and could justify a subagent, but `/code-review` already starts reviewer subagents for that. Delete the file and record why in an ADR under `docs/adr/`. | Delete .claude/agents/reviewer.md. Record why in a new ADR under docs/adr/ (absorbed by built-in /code-review and the project's code-review / pr-review skills, and the agent pinned a retired model). Overlap between the code-review and pr-review skills is skill-stocktake's call. The dangling docs/architecture.md reference in CLAUDE.md:15 is context-sync's call. | assets-03 | |
| 5 | rules-01 | Retire (alt: Dissolve (line 6 is absorbed by the PostToolUse format hook); Improve (s/black/ruff format/ on line 6 — but lines 3–5 would still duplicate CLAUDE.md)) | .claude/rules/style.md | Nothing in this 6-line rule is both unique and correct: three of its four bullets (type hints, f-strings, functions under 40 lines) are copied word for word in CLAUDE.md, which is also loaded every session. The fourth bullet is stale: it says to format with black, but the format hook it cites runs `ruff format`, and that hook already runs after every Edit/Write, so the instruction adds nothing. Its replacements are CLAUDE.md §Conventions/§Style and .claude/hooks/format.sh. | Delete .claude/rules/style.md (6 lines, the whole rules corpus). No README table to sync (there is no rules/README.md). Create the ledger <repo>/.claude/stocktake/rules-stocktake.json recording the Retire, with total_lines 0. | distill-01, docs-03 | |

## Merge / demote

| order | id | verdict | target | reason | change | conflicts | decision |
|---|---|---|---|---|---|---|---|
| 6 | skills-02 | Merge (alt: Retire both code-review and pr-review in favour of the built-in Claude Code `/code-review` skill, keeping only the `make test` step as a CLAUDE.md note; Merge the other way (pr-review into code-review) — not preferred because of the name collision below) | .claude/skills/code-review/SKILL.md | Merge into pr-review. code-review and pr-review serve the same user intent, trigger and job (ABSORBABLE_OVERLAP): both read `git diff main...HEAD`, look for bugs and missing tests, and report file:line. Maintaining both adds selection cost (two near-identical descriptions compete for the same request) and drift cost. The only unique residue is the last line, "Then run `make test` and report failures" (`make test` is a real Makefile target). The name `code-review` also collides with the built-in Claude Code `/code-review` skill, so folding into pr-review removes an ambiguous name. | Move code-review/SKILL.md:7 ("Then run `make test` and report failures.") into pr-review/SKILL.md as a final step, then delete .claude/skills/code-review/. **Phase 2:** pr-review becomes the only project review skill; the name `code-review` then resolves only to the built-in /code-review | — | |

## Improve / update

| order | id | verdict | target | reason | change | conflicts | decision |
|---|---|---|---|---|---|---|---|
| 7 | hooks-03 | Improve (alt: Keep) | .claude/hooks/format.sh | format.sh is wired (PostToolUse Edit\|Write), quotes the path and keeps its logic in the script, but it depends on `ruff`, which the repo declares nowhere (Makefile lint uses pyflakes, no pyproject/requirements), and it discards all output and always exits 0, so on a machine without ruff it silently does nothing. Fix: surface a missing ruff to stderr (still exit 0) and declare ruff as a dev dependency, or drop the hook if the project does not intend to use ruff. | In .claude/hooks/format.sh replace line 4 with: `if [[ $file == *.py ]]; then command -v ruff >/dev/null \|\| { echo "format.sh: ruff not installed; skipped $file" >&2; exit 0; }; ruff format "$file" >/dev/null 2>&1; fi` — and add ruff to the project's dev dependencies (or a `make fmt` target) so the formatter the hook assumes is declared. | — | |
| 9 | docs-02 | Update (alt: Create a short concept-level `docs/architecture.md`. That isn't recommended: the code is one 9-line module, and a hand-written module map just mirrors code that can be read directly) | CLAUDE.md | CLAUDE.md:15 points to `docs/architecture.md` as the architecture overview, but no such file exists, so the pointer leads nowhere. For a single-module service the code itself (`src/notes.py`, already named at CLAUDE.md:3) is the layout. | --- a/CLAUDE.md +++ b/CLAUDE.md @@ -13,4 +13,3 @@  - Keep functions under 40 lines.  - Use type hints everywhere. -- Architecture overview: see `docs/architecture.md`.  - Decisions are recorded in `docs/adr/`. | distill-02, docs-03 | |
| 10 | docs-03 | Update | CLAUDE.md | Three style directives in CLAUDE.md copy `.claude/rules/style.md` word for word, and `Use type hints everywhere.` appears twice inside CLAUDE.md itself. Each copy costs context tokens in every session and gives the rule two owners that can drift apart. The rule file should be the single owner. | --- a/CLAUDE.md +++ b/CLAUDE.md @@ -11,12 +11,9 @@  ## Conventions   -- Keep functions under 40 lines. -- Use type hints everywhere. +- Code style (type hints, f-strings, function length, black): `.claude/rules/style.md`.  - Architecture overview: see `docs/architecture.md`.  - Decisions are recorded in `docs/adr/`.   -## Style +## Workflow   -- Use type hints everywhere. -- Prefer f-strings over `%` formatting.  - Never commit directly to main; open a PR. **Phase 2:** Because rules-01 retires .claude/rules/style.md: do not add the pointer line; keep the Conventions bullets in CLAUDE.md, delete the second 'Use type hints everywhere.' (CLAUDE.md:20), and keep 'Never commit directly to main' under Workflow | distill-02, docs-02, rules-01 | |
| 11 | docs-04 | Update | README.md (1 files, 1 items bundled: assets-04) | README.md:5-7 describes `bench/time-to-first-item.sh` and a `dot-claude/` directory, and neither exists in this repo, so the README points readers at files they can't find. This is flagged for the README owner, not edited by context-sync, and the repo has no README skill of its own. | Flag for the README owner (no edit by context-sync). README.md:5-7: delete the paragraph that starts `This directory is a sample harness for harness-stocktake`, or rewrite it so it doesn't name `bench/time-to-first-item.sh` / `dot-claude/`, which live outside this repo. | — | |
| 12 | distill-01 | Revise (alt: Delete the line: the PostToolUse hook already formats every edited .py file, so the resident sentence adds nothing once corrected (rules-stocktake's call)) | .claude/rules/style.md | The rule names the wrong formatter: style.md says Python is formatted with black by the format hook, but the hook actually runs `ruff format`, so the always-loaded rule plants a false wiring fact (agent may run or install black, producing formatting that the hook then rewrites). Confidence: high — both files read. | In .claude/rules/style.md replace line 6 - Format Python with black before committing (the format hook does this for you). with - Python files are formatted with `ruff format` automatically by the PostToolUse hook on Edit/Write (`.claude/hooks/format.sh`); do not run black. | rules-01 | |
| 13 | distill-02 | Revise (alt: Add an `e2e` target to the Makefile instead (code change, outside this source's scope); Hand to context-sync, which owns CLAUDE.md-vs-code staleness) | CLAUDE.md (1 files, 1 items bundled: docs-01) | The principle the deploy skill relies on — run end-to-end tests before every release and stop on failure — is already resident in CLAUDE.md, but the command it names, `make e2e`, does not exist in the Makefile, so both the rule and the deploy skill direct the agent to a target that fails. Confidence: high that the target is missing; the right fix (add the target vs. reword the rule) is the author's decision. | Either (a) add an `e2e` target to the Makefile and keep CLAUDE.md:8 as is, or (b) if no e2e suite exists, replace CLAUDE.md:8 with: - No end-to-end suite yet; `make test` is the release gate (run before every release). and update skill: `deploy` step 1 to match. | docs-02, docs-03, skills-01 | |
| 14 | skills-01 | Update (alt: Retire — if no deploy script or staging server exists outside this repo (ADR-0001 describes an in-memory prototype), the workflow premise itself is gone; nothing else in the repo covers deploying) | .claude/skills/deploy/SKILL.md | Neither command the skill runs exists: the Makefile defines only `test` and `lint` (no `e2e` target), and there is no `scripts/` directory or `deploy.sh` anywhere in the repo, so step 1 fails immediately and step 2 can never run. Step 3 ("Post the release notes to the team channel") names no channel or mechanism and no producing skill. Currency No; Actionability No for steps 2–3. The job (a gated staging deploy) is not covered by any other asset, so the dead pointers are an Update, not a Retire — unless the author confirms there is no deploy path at all. | skill-writer intent packet — target: .claude/skills/deploy/SKILL.md. Fix: (1) step 1 — point at a test command that exists (`make test`) or add the `e2e` Makefile target first; author to decide which; (2) step 2 — replace `scripts/deploy.sh staging` with the real deploy command/path, or Retire the skill if none exists; (3) step 3 — name the channel and the mechanism, and say the notes come from the release-notes skill output (CHANGELOG.md), or drop the step. No list: Currency (make e2e, scripts/deploy.sh), Actionability (step 3). Leave the description as is. | distill-02 | |
| 15 | skills-03 | Improve | .claude/skills/release-notes/SKILL.md | Step 1 assumes a tag exists, but the repo has no tags, so `git describe --tags --abbrev=0` returns no tag and step 2's `git log <tag>..HEAD` has no range; the skill has no fallback for the first release. The rest is actionable and unique: "group the commits by type" and writing to CHANGELOG.md is a real, standalone job no other asset covers. | skill-writer intent packet — target: .claude/skills/release-notes/SKILL.md. Fix steps 1–2: when `git describe --tags --abbrev=0` finds no tag, use the full history (`git log --oneline`) and say so in the notes heading. No list: Currency/Actionability (no-tag case). Leave step 3 and the description unchanged. | — | |
| 16 | assets-01 | Update (alt: Restore a real .claude/hooks/check-secrets.sh instead of deleting the entry, if secret-scanning on Bash output is still wanted) | .claude/settings.json | Update — the PostToolUse hook for matcher `Bash` runs `bash .claude/hooks/check-secrets.sh`, but that script does not exist in the repo, so the hook fires on every Bash call and does no checking at all. The secret check it promises is not happening. The Edit\|Write → format.sh entry is fine. | Remove the `{"matcher": "Bash", ...check-secrets.sh}` entry (settings.json:8-11), or restore the script if a secret check is wanted. | hooks-01 | |
| 17 | assets-03 | Update | .claude/agents/reviewer.md | Update — the `code-reviewer` agent tells itself to read `docs/architecture.md` first, but that file does not exist, so every invocation starts by looking for a missing doc. Its `model:` pin is `claude-3-opus-20240229`, a Claude 3 model that has been retired. Fix the doc reference and drop or refresh the model pin. | Remove line 9, or point it at the module layout that does exist (src/notes.py, see CLAUDE.md:3). Remove `model:` so the agent inherits the session model, or set a current model id. | agents-01 | |

## Keep (10)

<details>

| order | id | verdict | target | reason |
|---|---|---|---|---|
| 19 | docs-05 | Keep | docs/adr/0001-in-memory-store.md | ADR-0001 still matches the code: notes are kept in a module-level dict, and its revisit trigger (adding PostgreSQL) hasn't fired, so it correctly reads as current. |
| 20 | distill-03 | Already Covered | .claude/skills/code-review/SKILL.md | The fact that `make test` is this repo's unit-test command, used by skill code-review, is already resident in CLAUDE.md's Commands section. |
| 21 | distill-04 | Already Covered | .claude/skills/pr-review/SKILL.md | Both review skills diff against `main`, implying `main` is the trunk; that fact is already resident in CLAUDE.md's Style section. |
| 22 | distill-05 | Too Specific | .claude/skills/code-review/SKILL.md | "Review the diff for bugs and missing tests, report each with file:line" is a procedure and a general review habit the substrate already has, so it fails tests 1–3 and stays in the skills despite recurring in two. |
| 23 | distill-06 | Too Specific | .claude/skills/release-notes/SKILL.md | Writing release notes from commits since the last tag into `CHANGELOG.md` is a procedure used only when drafting release notes, so it belongs in skill release-notes, not in residency. |
| 24 | distill-07 | Too Specific | .claude/skills/deploy/SKILL.md | Deploying to staging with `scripts/deploy.sh staging` and posting notes to the team channel are deploy-only steps, so they stay in skill deploy rather than becoming resident rules. |
| 25 | skills-04 | Keep | .claude/skills/pr-review/SKILL.md | Keep as the merge target for code-review (skills-02). |
| 26 | assets-05 | Keep | .claude/hooks/format.sh | Keep — format.sh is wired as the PostToolUse hook for Edit\|Write in .claude/settings.json:5-6, and it still does what it says: it runs `ruff format` on edited .py files. |
| 27 | assets-06 | Keep | Makefile | Keep — the Makefile is the repo's command surface. |
| 28 | assets-07 | Keep | docs/adr/0001-in-memory-store.md | Keep — ADR-0001 is reached through CLAUDE.md:16 ('Decisions are recorded in `docs/adr/`'), and its decision still matches the code: notes live in a module-level dict and no database has been added. |

</details>

## What the native checks cover

This report judges content (stale references, contradictions, configuration whose owner is gone, distillation into rules). Usage history and writing style are what Claude Code's native checks see: `/doctor` lists unused plugins, MCP servers and skills and slow hooks; `/doctor prompt-audit` flags writing aimed at older models (fixed numeric caps, heavy emphasis, mentions of tools that do not exist). The two do not overlap, so run both and read them side by side (this run ran neither).
