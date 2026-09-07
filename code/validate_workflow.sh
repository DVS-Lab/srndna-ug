#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
project_root="$(dirname "$script_dir")"

bash -n "$script_dir/validate_workflow.sh"
echo "PASS: active shell syntax"

PYTHONPYCACHEPREFIX="${TMPDIR:-/tmp}/srndna-ug-pycache" \
    python3 -m py_compile "$script_dir/audit_task_events.py"
echo "PASS: active Python syntax"

cd "$project_root"
python3 -m unittest discover -s tests -p 'test_*.py' -v

python3 "$script_dir/audit_task_events.py"

if grep -En '/Users/[^/]+|/home/[^/]+' "$script_dir/audit_task_events.py"; then
    echo "ERROR: active reviewer workflow contains a personal absolute path" >&2
    exit 1
fi
echo "PASS: active reviewer workflow is path-portable"
