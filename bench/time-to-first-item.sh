#!/usr/bin/env bash
# time-to-first-item.sh — install harness-stocktake the way the README says, run its --dry-run on
# the sample harness, and record how long the first finding and the report take and what it costs.
#
# Usage: bench/time-to-first-item.sh [--source <marketplace source>] [--model <alias>]
#                                    [--timeout <seconds>] [--out <dir>] [--lang en|ja]
#
#   --source   what `claude plugin install --marketplace` gets (default: shimo4228/harness-stocktake;
#              a local path tests an unpushed checkout)
#   --model    model of the audit run (default: opus)
#   --timeout  cap on the audit run in seconds (default: 1200)
#   --lang     report language (default: en). ja adds a Japanese request to the command, since the
#              skill writes in the language the operator writes in
#   --out      new or empty directory for the results, outside any git work tree so no CLAUDE.md
#              above it loads (default: a new mktemp directory)
#
# Writes into <out>:
#   cfg/          a throwaway CLAUDE_CONFIG_DIR the plugin is installed into (step 1)
#   target/       the sample harness as a git repo (examples/sample-harness, dot-claude/ -> .claude/)
#   run/          the report: items-<source>.json, sections/<source>.md, crosscheck.json, report.md
#   timeline.tsv  <seconds since the audit started>\t<path> for each file that appears under run/,
#                 then END rc=<exit>
#   install.txt   the install command's output and its seconds
#   result.json   claude -p --output-format json (total_cost_usd, duration_ms, modelUsage)
#   summary.tsv   one row: install_s first_section_s first_finding_s report_s total_cost_usd items non_keep
#
# Why the audit run does not use cfg/: a throwaway config dir has no login, and a subscription login
# cannot be copied into one safely. The audit runs with the operator's own login and loads the
# installed copy from cfg/ with --plugin-dir, with the operator's hooks, CLAUDE.md, memory, MCP
# servers and user settings switched off, and with --project pointing at target/ so it never reads
# the operator's own ~/.claude. The operator's skills stay listed (no flag removes them); the
# command names the plugin's namespace, so the plugin's skill is the one that runs.
set -euo pipefail

die() { printf 'time-to-first-item: %s\n' "$*" >&2; exit 2; }

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
source_arg=shimo4228/harness-stocktake
model=opus
limit=1200
out=""
lang=en
while [[ $# -gt 0 ]]; do
  case $1 in
    --source) [[ $# -ge 2 ]] || die "--source needs a value"; source_arg=$2; shift 2 ;;
    --model) [[ $# -ge 2 ]] || die "--model needs a value"; model=$2; shift 2 ;;
    --timeout) [[ $# -ge 2 && $2 =~ ^[0-9]+$ ]] || die "--timeout needs seconds"; limit=$2; shift 2 ;;
    --out) [[ $# -ge 2 ]] || die "--out needs a value"; out=$2; shift 2 ;;
    --lang) [[ $# -ge 2 && $2 =~ ^(en|ja)$ ]] || die "--lang is en or ja"; lang=$2; shift 2 ;;
    *) die "unknown argument: $1" ;;
  esac
done
[[ -n $out ]] || out=$(mktemp -d)
[[ ! -e $out || -z $(ls -A -- "$out") ]] || die "out-dir is not empty: $out"
mkdir -p -- "$out"
out=$(cd -- "$out" && pwd -P)
timeout_bin=$(command -v timeout || command -v gtimeout || true)
[[ -n $timeout_bin ]] || die "timeout (or gtimeout from coreutils) is required"
command -v claude >/dev/null || die "claude is not on PATH"

# Step 1 — install, exactly as the README's first line, into a throwaway config dir.
mkdir -p -- "$out/cfg"
t0=$(date +%s)
CLAUDE_CONFIG_DIR=$out/cfg claude plugin install harness-stocktake --marketplace "$source_arg" \
  >"$out/install.txt" 2>&1 || { cat "$out/install.txt" >&2; die "install failed"; }
install_s=$(($(date +%s) - t0))
printf 'seconds=%s\n' "$install_s" >>"$out/install.txt"
manifest=$(find "$out/cfg/plugins/cache" -path '*/.claude-plugin/plugin.json' -print 2>/dev/null |
  while IFS= read -r m; do grep -q '"name": *"harness-stocktake"' "$m" && { echo "$m"; break; }; done)
[[ -n $manifest ]] || die "installed plugin not found under $out/cfg/plugins/cache"
plugin_dir=$(dirname -- "$(dirname -- "$manifest")")

# Step 2 — the sample harness as a repository of its own.
cp -R -- "$repo/examples/sample-harness" "$out/target"
mv -- "$out/target/dot-claude" "$out/target/.claude"
git -C "$out/target" init -q -b main
git -C "$out/target" -c user.name=bench -c user.email=bench@example.invalid add -A
git -C "$out/target" -c user.name=bench -c user.email=bench@example.invalid commit -q -m sample

# Step 3 — the audit, timed by a poller outside the run.
mkdir -p -- "$out/run" "$out/cwd"
settings=$(printf '{"disableAllHooks":true,"autoMemoryEnabled":false,"claudeMdExcludes":["%s/.claude/**"]}' "$HOME")
start=$(date +%s)
: >"$out/timeline.tsv"
(
  seen=" "
  while :; do
    while IFS= read -r f; do
      case $seen in *" $f "*) continue ;; esac
      seen="$seen$f "
      printf '%s\t%s\n' "$(($(date +%s) - start))" "$f" >>"$out/timeline.tsv"
    done < <(cd "$out/run" && find . -type f | sed 's|^\./||' | sort)
    sleep 2
  done
) &
poller=$!
trap 'kill "$poller" 2>/dev/null || true' EXIT

request="/harness-stocktake:harness-stocktake --project $out/target --dry-run --out $out/run"
[[ $lang == ja ]] && request="$request 日本語でレポートを書いてください。"
rc=0
(
  cd "$out/cwd" && "$timeout_bin" "$limit" claude -p \
    "$request" \
    --plugin-dir "$plugin_dir" \
    --model "$model" \
    --setting-sources local \
    --strict-mcp-config \
    --settings "$settings" \
    --add-dir "$out/target" --add-dir "$out/run" \
    --allowedTools "Read,Grep,Glob,Write,Edit,Agent,Bash(git:*),Bash(python3:*),Bash(uv:*),Bash(date:*),Bash(ls:*),Bash(mkdir:*)" \
    --no-session-persistence \
    --output-format json
) >"$out/result.json" 2>"$out/stderr.txt" || rc=$?
sleep 3
kill "$poller" 2>/dev/null || true
wait "$poller" 2>/dev/null || true
printf '%s\tEND rc=%s\n' "$(($(date +%s) - start))" "$rc" >>"$out/timeline.tsv"

# Summary: the first section, the first section with a non-Keep line, the report.
python3 -I - "$out" "$install_s" <<'PYEOF'
import json, re, sys
from pathlib import Path
out, install_s = Path(sys.argv[1]), sys.argv[2]
seen = {}
for line in (out / "timeline.tsv").read_text().splitlines():
    sec, _, path = line.partition("\t")
    if not path.startswith("END"):
        seen.setdefault(path, int(sec))
sections = {p: s for p, s in seen.items() if p.startswith("sections/")}
keep = re.compile(r"^- (Keep|Out of scope|Already Covered|Too Specific)\b", re.I)
finding = [s for p, s in sections.items()
           if any(l.startswith("- ") and " · " in l and not keep.match(l)
                  for l in (out / "run" / p).read_text(errors="replace").splitlines())]
items = []
p = out / "run" / "items-all.json"
if p.is_file():
    items = json.loads(p.read_text())
non_keep = [i for i in items if not keep.match("- " + str(i.get("verdict", "")))]
try:
    cost = json.loads((out / "result.json").read_text()).get("total_cost_usd", "")
except ValueError:
    cost = ""
row = [install_s, min(sections.values(), default=""), min(finding, default=""),
       seen.get("report.md", ""), cost, len(items), len(non_keep)]
head = "install_s\tfirst_section_s\tfirst_finding_s\treport_s\ttotal_cost_usd\titems\tnon_keep"
(out / "summary.tsv").write_text(head + "\n" + "\t".join(map(str, row)) + "\n")
print(head)
print("\t".join(map(str, row)))
PYEOF
exit "$rc"
