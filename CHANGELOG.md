# Changelog

## 0.1.0 — unreleased

- First release: harness-stocktake and its seven source audits (skill-stocktake, rules-stocktake,
  agent-stocktake, hook-stocktake, rules-distill, context-sync, repo-asset-stocktake) as one plugin.
- `--dry-run` writes a Markdown report and changes nothing; `--project <repo>` audits a repository's `.claude/`.
- `examples/sample-harness/` and `bench/time-to-first-item.sh` reproduce the install-to-report path.
- Each audit's verdict history lives in the audited harness (`stocktake/<audit>.json`) and is committed on the `stocktake/<date>` branch with the changes.
- `skill-health` ships with the plugin, so skill-stocktake checks the paths and URLs your skills name instead of marking them `n/a`.
