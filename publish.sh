#!/usr/bin/env bash
set -euo pipefail

EXPECTED_DIR="$HOME/Desktop/obs-web-web-github"
EXPECTED_REMOTE="https://github.com/obs-lab/obs-lab.github.io.git"
HISTORY_BRANCH="history"
PAGES_BRANCH="main"

if [ "$(cd "$(pwd)" && pwd -P)" != "$(cd "$EXPECTED_DIR" && pwd -P)" ]; then
  echo "STOP: run this from $EXPECTED_DIR (you are in $(pwd))"
  exit 1
fi

if [ ! -d .git ]; then
  echo "STOP: no git repository here."
  exit 1
fi

CURRENT_REMOTE="$(git remote get-url origin 2>/dev/null || echo "")"
if [ "$CURRENT_REMOTE" != "$EXPECTED_REMOTE" ]; then
  echo "STOP: origin is not the expected remote."
  echo "Expected: $EXPECTED_REMOTE"
  echo "Found:    ${CURRENT_REMOTE:-<none>}"
  echo "Fix with: git remote set-url origin $EXPECTED_REMOTE"
  exit 1
fi

git checkout -q "$HISTORY_BRANCH" 2>/dev/null || git checkout -q -b "$HISTORY_BRANCH"

git add -A
git commit -m "${1:-update site}" || echo "Nothing new to commit, continuing."

git branch -D "$PAGES_BRANCH" 2>/dev/null || true
git checkout -q --orphan "$PAGES_BRANCH"
git add -A
git commit -q -m "obs-lab site"

git push -f origin "$PAGES_BRANCH"

git checkout -q "$HISTORY_BRANCH"

echo "Published one commit to '$PAGES_BRANCH' on $EXPECTED_REMOTE"
echo "Full history preserved locally on '$HISTORY_BRANCH'."
