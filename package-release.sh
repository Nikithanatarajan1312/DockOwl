#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

VERSION="${1:-0.1.0}"
ARCHIVE="DockOwl-${VERSION}.zip"

./build-app.sh

rm -f "$ARCHIVE"
ditto -c -k --sequesterRsrc --keepParent "$ROOT/DockOwl.app" "$ROOT/$ARCHIVE"

echo "Created $ARCHIVE"
echo "Upload this file to a GitHub Release (tag v${VERSION})."
