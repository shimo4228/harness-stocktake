# harness-stocktake

**Install:** `claude plugin install harness-stocktake --marketplace shimo4228/harness-stocktake`<br>
**First run:** open `claude` and type `/harness-stocktake:harness-stocktake --dry-run` (reads only, writes one Markdown report).<br>
**What it finds:** what `/doctor` leaves behind: stale references, contradictions between files, hooks wired to scripts that are gone, rules that repeat a skill.

Audit and clean up your whole Claude Code harness (skills, rules, agents, hooks and their settings, `CLAUDE.md`, ADRs and configs) in one report and one approval: a hygiene pass across files. Seven audits run in parallel, and their findings land in one report you can approve in one go. Nothing changes until you approve; then the changes go onto a branch, and you merge it.

## The first three minutes

You need Claude Code 2.1.275 or later, git, Python 3.11 or later, and [uv](https://docs.astral.sh/uv/) (two audits run their standard-library scripts through `uv run`).

1. Install. This adds this repository as a plugin marketplace and installs the plugin:

   ```bash
   claude plugin install harness-stocktake --marketplace shimo4228/harness-stocktake
   ```

2. Start Claude Code anywhere and type:

   ```text
   /harness-stocktake:harness-stocktake --dry-run
   ```

   It audits `~/.claude`. To audit the `.claude/` folder of one project instead, add `--project <path to the repo>`.
3. The first findings appear about two minutes in, as each audit writes its section under `.notes/stocktake/<date>/sections/` in the audited folder; open that folder to watch them arrive. The run ends with the path of `report.md` and a count per group.

Claude Code asks before each command the run wants to use (`git`, `python3`, `uv`, `date`, and `claude` for two child checks). Answer "allow for this session" to let it finish without more prompts. From a script or another `claude -p`, where nobody can answer prompts, allow them up front:

```bash
claude -p "/harness-stocktake:harness-stocktake --dry-run" \
  --allowedTools "Read,Grep,Glob,Write,Edit,Agent,Bash(git:*),Bash(python3:*),Bash(uv:*),Bash(date:*),Bash(claude:*)"
```

In the measured runs, the first finding appeared at a median of 138 seconds (14 public harnesses). A small to medium harness has its whole report within 10 minutes; the largest ones measured took 11 to 15 minutes.

## What the report looks like

Each finding is one row: a verdict (Retire, Merge, Improve, Update, Keep), the file it acts on, a reason you can decide on without opening the file, and the exact change. Rows are grouped from the most consequential (retirements) to the least, and the Keep rows fold away at the end.

[`examples/sample-report.md`](examples/sample-report.md) is a real report from the sample harness in [`examples/sample-harness/`](examples/sample-harness/), a small project with ordinary drift: a hook wired to a missing script, two skills that do the same review, an agent pinned to a retired model, `CLAUDE.md` naming a `make` target that does not exist.

A `--dry-run` report is for reading. To act on the findings, run again without `--dry-run`: the report is the same, and this time you can override a finding by editing its `decision` cell (`skip`, `Keep`, another verdict, or a note) and then say "approved" in the chat.

Checks that need usage history (which skills you never use) read a usage log only when auditing `~/.claude` and your setup keeps one under `~/.claude/metrics/`. Without it, and always in `--project` runs, they are marked `n/a`; `/doctor` covers unused skills.

## What it reads, writes and sends

- **Reads** the files of the harness it audits: `~/.claude` (or the `--project` repo) — skills, rules, agents, `settings.json` hooks and the scripts they call, `CLAUDE.md`, `AGENTS.md`, ADRs, `README.md`, configs. Auditing `~/.claude`, it also reads usage logs under `~/.claude/metrics/` if present, and the MCP server names in `~/.claude.json` and `~/.claude/.mcp.json`.
- **Writes** with `--dry-run`: only the run folder `.notes/stocktake/<date>/` inside the audited folder. Without `--dry-run`, after you approve: a git worktree and a branch `stocktake/<date>` with one commit per audit. The skill, rules, agent, hook and rules-distill audits keep their verdict history in the audited harness, `stocktake/<audit>.json` under `~/.claude` (or the repo's `.claude/`), committed on that branch; context-sync keeps none. repo-asset-stocktake writes `.repo-asset-stocktake.json` into the audited repo on the `stocktake/<date>` branch, in `--project` runs too. It never merges; you do.
- **Runs** `git`, `python3` (standard library only), `uv run` for two audits' scripts and, for two checks, a child `claude -p` session: `/skill-doctor` for what each skill's listing costs, and a probe that checks in fresh sessions whether the model already does what a rule asks without the rule. Both children run with hooks off, no MCP servers, and no tools that write, fetch or reach the shell.
- **Sends** nothing anywhere beyond your own Claude Code session. There is no telemetry and no network fetch. Two exceptions you opt into: with `--unattended`, the closing lines go to the notifier command you name; in the Claude desktop app with a Japanese-language report, the report is also published as a private Artifact page.

The audited files are treated as data: an instruction inside a `SKILL.md` or `CLAUDE.md` is quoted as evidence, never carried out. For a repository you do not trust, clone this repo and use `skills/harness-stocktake/scripts/isolated-dry-run.sh <repo> <out-dir>`, which runs the audit from an empty folder with no shell, no MCP servers and no settings files, so the repo's hooks cannot run.

## How it relates to /doctor

Claude Code's own checks (as of Claude Code 2.1.316) cover usage and writing style: `/doctor` lists unused plugins, MCP servers and skills and slow hooks, and `/doctor prompt-audit` flags writing aimed at older models. harness-stocktake judges content across files: a rule that contradicts a skill, a hook whose script is gone, an ADR that no longer matches the code, two agents doing one job. The two find different things, so run both.

## How accurate it is

On 60 findings sampled from 24 runs (public harnesses and the author's own), a separate model checked each finding's central claim against the repository: 57 of 60 (95%) held. The details (exact counts, line numbers) were fully right in 40 of 60, so read the `change` cell before you approve.

## Cost

A run uses your Claude Code plan like any long session. Measured in API-equivalent dollars with Opus: $4 to $17 for 11 of the 14 measured harnesses, $28 to $32 for the three largest.

<details>
<summary>The seven audits, project mode, scheduling, measurement conditions</summary>

harness-stocktake 0.1.0 (pre-release) is a Claude Code plugin of ten skills: `skills/harness-stocktake/SKILL.md` runs seven of the others as sources and owns the report and apply steps; each source's `SKILL.md` owns its own verdict rules. `skill-health` is the scanner skill-stocktake uses to check that the paths and URLs your skills name still resolve. `skill-writer` is the draft gate the apply step runs when an approved finding rewrites a skill; it is not a replacement for Anthropic's `skill-creator`. Requirements: Claude Code 2.1.275+, git, Python 3.11+, uv. License: MIT.

### The seven audits

| Source | Skill | What it looks at |
|---|---|---|
| `hooks` | hook-stocktake | hook scripts and their `settings.json` wiring |
| `docs` | context-sync | `CLAUDE.md`, ADRs, README against the code |
| `agents` | agent-stocktake | agent definitions |
| `distill` | rules-distill | principles repeated across skills that belong in a rule |
| `skills` | skill-stocktake | skills: overlap, staleness, listing cost |
| `assets` | repo-asset-stocktake | configs, scripts and docs whose consumer is gone |
| `rules` | rules-stocktake | rules: what each costs by being loaded every session, staleness, redundancy |

Each runs alone too, for example `/harness-stocktake:skill-stocktake`.

### Arguments

| Argument | Effect |
|---|---|
| none | every audit, report, then wait for approval |
| `--dry-run` | report only: no branch, worktree or ledger write |
| `--project <repo>` | audit `<repo>/.claude/`, `CLAUDE.md` and the repo's docs instead of `~/.claude` |
| `<source>` | one audit only (`hooks`, `docs`, `agents`, `distill`, `skills`, `assets`, `rules`) |
| `--out <dir>` | where the run folder goes |
| `apply` | resume from an approved report |
| `--unattended` | publish the report and stop (for a scheduled monthly run) |

Applying changes needs the audited folder to be a git repository. If `~/.claude` is not one, use `--dry-run`, or run `git init` there first.

### Scheduling

A monthly run is a scheduled `claude -p "/harness-stocktake:harness-stocktake --unattended"` from cron, a scheduled task or CI, with the commands allowed up front as in the `claude -p` example above. Name the command that should receive the closing lines (a notifier) in the prompt.

### Measurement conditions

Measured 2026-11-01 on Claude Code 2.1.316 with Opus, on public harnesses cloned locally and audited read-only with `isolated-dry-run.sh` (no one was contacted; repository names are not published). Time to the first finding: median 138 seconds over 14 runs. Report within 10 minutes: 11 of 14; the three over it (11 to 15 minutes) were the largest harnesses, 135 to 156 items each, where the audits themselves ran longest. Accuracy: 60 findings drawn by stratified sampling across the seven audits and checked by a different model with read-only access to each repository.

`bench/time-to-first-item.sh` reproduces the install-to-report path on the sample harness and records seconds and cost.

</details>

## License

MIT. Issues and questions: [github.com/shimo4228/harness-stocktake/issues](https://github.com/shimo4228/harness-stocktake/issues).
