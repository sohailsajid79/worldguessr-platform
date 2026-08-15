#!/usr/bin/env bash
set -euo pipefail

UPSTREAM_REPO="${UPSTREAM_REPO:-https://github.com/codergautam/worldguessr.git}"
UPSTREAM_REF="${UPSTREAM_REF:-8464986438127427f4257697280ce226175c461c}"
DEST="$(cd "$(dirname "$0")/.." && pwd)/upstream"

if [ ! -d "$DEST/.git" ]; then
  git clone --no-checkout "$UPSTREAM_REPO" "$DEST"
fi

git -C "$DEST" fetch origin "$UPSTREAM_REF"
git -C "$DEST" checkout --force "$UPSTREAM_REF"

cat > "$DEST/.dockerignore" << 'EOF'
.git
node_modules
mobile
!mobile/package.json
.next
out
docs
EOF

echo "upstream ready at $DEST @ $(git -C "$DEST" rev-parse --short HEAD)"