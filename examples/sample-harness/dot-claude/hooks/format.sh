#!/usr/bin/env bash
# Format the edited Python file with ruff.
file=$(jq -r '.tool_input.file_path // empty')
[[ $file == *.py ]] && ruff format "$file" >/dev/null 2>&1
exit 0
