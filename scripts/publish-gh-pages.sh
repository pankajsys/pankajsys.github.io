#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
DIST_DIR="$ROOT_DIR/dist"
REMOTE_NAME="${1:-origin}"
BRANCH_NAME="${2:-gh-pages}"
REMOTE_URL="$(git -C "$ROOT_DIR" remote get-url "$REMOTE_NAME")"
TMP_DIR="$(mktemp -d)"

cleanup() {
	rm -rf "$TMP_DIR"
}

trap cleanup EXIT

if [ ! -d "$DIST_DIR" ]; then
	echo "dist directory not found: $DIST_DIR" >&2
	echo "Run the site build before publishing." >&2
	exit 1
fi

cp -R "$DIST_DIR"/. "$TMP_DIR"/

git -C "$TMP_DIR" init --initial-branch="$BRANCH_NAME" >/dev/null
git -C "$TMP_DIR" add --all

if git -C "$TMP_DIR" diff --cached --quiet; then
	echo "No files to publish from dist/."
	exit 0
fi

git -C "$TMP_DIR" \
	-c user.name="gh-pages deploy" \
	-c user.email="gh-pages@local" \
	commit -m "Deploy GitHub Pages" >/dev/null

git -C "$TMP_DIR" remote add "$REMOTE_NAME" "$REMOTE_URL"
git -C "$TMP_DIR" push --force "$REMOTE_NAME" "HEAD:$BRANCH_NAME"
