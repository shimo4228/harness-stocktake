# Changelog

## 0.2.0 — 2026-11-02

- `--project <repo>` publishes the same report form as a run on `~/.claude`: an Artifact page when the session has the Artifact tool, Markdown otherwise. It no longer always writes Markdown.
- A Japanese Markdown report gives its override instructions in Japanese.
- The Artifact report page shows its text in English or Japanese, following the run's report language. It is no longer Japanese-only, so an English session gets the page too.
- The decision menu no longer lists `Keep` (or the recommended verdict) twice.
- `examples/` has a sample report in English and Japanese from fresh runs on the sample harness, and a picture of the report page in each language; the README shows them.
- `bench/time-to-first-item.sh --lang ja` runs the bench with a Japanese request.

## 0.1.0 — 2026-11-02

- First release: harness-stocktake and its seven source audits (skill-stocktake, rules-stocktake,
  agent-stocktake, hook-stocktake, rules-distill, context-sync, repo-asset-stocktake) as one plugin.
- `--dry-run` writes a Markdown report and changes nothing; `--project <repo>` audits a repository's `.claude/`.
- `examples/sample-harness/` and `bench/time-to-first-item.sh` reproduce the install-to-report path.
- Each audit's verdict history lives in the audited harness (`stocktake/<audit>.json`) and is committed on the `stocktake/<date>` branch with the changes.
- `skill-health` ships with the plugin, so skill-stocktake checks the paths and URLs your skills name instead of marking them `n/a`.
- `skill-writer` ships with the plugin: applying an approved finding that rewrites a skill runs its draft gate.
