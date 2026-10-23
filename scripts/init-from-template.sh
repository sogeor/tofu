#!/usr/bin/env bash
# Fill template placeholders after creating a repository from sogeor/template.
# Usage: scripts/init-from-template.sh "Short description"
set -euo pipefail

REPO_NAME="$(basename "$(git rev-parse --show-toplevel)")"
SHORT_DESCRIPTION="${1:?Pass a one-line description}"
YEAR="$(date +%Y)"

files=$(git ls-files | grep -v '^scripts/init-from-template.sh$')
for f in $files; do
  sed -i \
    -e "s|{{REPO_NAME}}|${REPO_NAME}|g" \
    -e "s|{{YEAR}}|${YEAR}|g" \
    -e "s|{{SHORT_DESCRIPTION — one line, under 120 characters}}|${SHORT_DESCRIPTION}|g" \
    "$f"
done

if grep -rn '{{' --exclude-dir=.git --exclude=init-from-template.sh . ; then
  echo "Placeholders above still need manual editing (README sections)."
fi
git rm -q scripts/init-from-template.sh
echo "Done. Review README.md, then: pre-commit install && pre-commit run --all-files"
