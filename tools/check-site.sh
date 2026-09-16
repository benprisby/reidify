#!/bin/sh
# Builds the site and checks the output. Invoked by pre-commit.
#
# Every check here maps to something that has actually broken, not a generic
# best practice. Keep it that way, and keep it fast.

set -eu
OUT=$(mktemp -d)
trap 'rm -rf "$OUT"' EXIT
fail=0

if ! command -v hugo >/dev/null 2>&1; then
  echo "hugo not found, skipping site checks"
  exit 0
fi

if ! hugo --minify --gc --quiet --destination "$OUT" >/dev/null 2>&1; then
  echo "FAIL: hugo build"
  hugo --minify --gc --destination "$OUT" 2>&1 | grep -i error | head -5
  exit 1
fi

# Editorial comments must not reach the browser.
if grep -rq '<!--' "$OUT" --include='*.html'; then
  echo "FAIL: HTML comments in build output:"
  grep -rl '<!--' "$OUT" --include='*.html' | sed "s|$OUT|  |"
  fail=1
fi

# The video grid must not be empty.
if ! grep -q 'class="\?video__title' "$OUT/index.html"; then
  echo "FAIL: home page has no video cards, check data/videos.json"
  fail=1
fi

# External links open in a new tab with noopener and WITHOUT noreferrer;
# mailto: gets neither. See layouts/partials/is-external.html.
python3 - "$OUT" <<'PY' || fail=1
from html.parser import HTMLParser
import pathlib, sys

class A(HTMLParser):
    def __init__(self):
        super().__init__(); self.hits = []
    def handle_starttag(self, tag, attrs):
        if tag == "a":
            d = dict(attrs)
            self.hits.append((d.get("href", ""), d.get("target"), d.get("rel", "") or ""))

bad = []
for f in pathlib.Path(sys.argv[1]).rglob("*.html"):
    p = A(); p.feed(f.read_text())
    for href, target, rel in p.hits:
        blank = target == "_blank"
        if href.startswith(("http://", "https://", "//")):
            if not blank or "noopener" not in rel or "noreferrer" in rel:
                bad.append(f"{f.name}: {href} target={target} rel={rel!r}")
        elif href.startswith(("mailto:", "tel:")):
            if blank or rel:
                bad.append(f"{f.name}: {href} should have no target/rel")
        elif blank:
            bad.append(f"{f.name}: {href} is internal but opens a new tab")

if bad:
    print("FAIL: link policy")
    for b in bad[:8]:
        print("  " + b)
    sys.exit(1)
PY

exit $fail
