#!/bin/sh
set -eu

BASE=${BOTKEEP_ROOT:-/home/container}
ARCHIVE="$BASE/.9r-standalone-runtime-d24d98a.tar.gz"
PART="$BASE/.9r-runtime-download-d24d98a.part"
STAGE="$BASE/.9r-runtime-stage-d24d98a"
RELEASE="$BASE/9r-standalone-d24d98a"
LOCK="$BASE/.9r-runtime-bootstrap.lock"
URL="https://raw.githubusercontent.com/akunpindo55/9r-deploy/deploy/standalone-runtime-20261007/deploy-artifacts/9r-standalone-runtime-d24d98a.tar.gz"
EXPECTED_SIZE=52787477
EXPECTED_SHA256="b26dfe99645624d075e67b93df098c5457aeedc77942d395fae53101b086b574"

runtime_ready() {
  [ -f "$1/custom-server.js" ] &&
  [ -f "$1/server.js" ] &&
  [ -f "$1/.next/BUILD_ID" ] &&
  [ -d "$1/node_modules" ]
}

verify_archive() {
  node - "$1" "$EXPECTED_SIZE" "$EXPECTED_SHA256" <<'NODE'
const fs = require("node:fs");
const crypto = require("node:crypto");
(async () => {
  const file = process.argv[2];
  const expectedSize = Number(process.argv[3]);
  const expectedHash = process.argv[4];
  const hash = crypto.createHash("sha256");
  let size = 0;
  for await (const chunk of fs.createReadStream(file)) {
    hash.update(chunk);
    size += chunk.length;
  }
  if (size !== expectedSize || hash.digest("hex") !== expectedHash) {
    throw new Error("runtime archive size/SHA-256 mismatch");
  }
})().catch((error) => {
  console.error("Archive verification failed:", error.message);
  process.exit(1);
});
NODE
}

patch_env_fallback() {
  node - "$1" <<'NODE'
const fs = require("node:fs");
const file = process.argv[2];
const text = fs.readFileSync(file, "utf8");
if (text.includes('path.join(__dirname, "..", ".env")')) process.exit(0);
const oldText = [
  '  for (const name of [".env.local", ".env"]) {',
  "    let text;",
  "    try {",
  '      text = fs.readFileSync(path.join(__dirname, name), "utf8");',
].join("\n");
const newText = [
  "  for (const envPath of [",
  '    path.join(__dirname, ".env.local"),',
  '    path.join(__dirname, ".env"),',
  '    path.join(__dirname, "..", ".env.local"),',
  '    path.join(__dirname, "..", ".env"),',
  "  ]) {",
  "    let text;",
  "    try {",
  '      text = fs.readFileSync(envPath, "utf8");',
].join("\n");
if (!text.includes(oldText)) {
  console.error("Expected env-loader code was not found; refusing to patch runtime.");
  process.exit(1);
}
fs.writeFileSync(file, text.replace(oldText, newText));
NODE
}

mkdir -p "$BASE"
if ! mkdir "$LOCK" 2>/dev/null; then
  echo "Runtime bootstrap already running; stop this start and inspect the Botkeep console." >&2
  exit 1
fi
trap 'rmdir "$LOCK" 2>/dev/null || true' 0
trap 'exit 1' 1 2 15

if runtime_ready "$RELEASE"; then
  patch_env_fallback "$RELEASE/custom-server.js"
  echo "Runtime already installed; bootstrap skipped."
  exit 0
fi
if [ -e "$RELEASE" ]; then
  echo "Release directory exists but is incomplete: $RELEASE" >&2
  echo "Inspect it manually; bootstrap will not overwrite an existing release." >&2
  exit 1
fi

# These paths are dedicated to this pinned runtime; clean only interrupted staging/downloads.
rm -f "$PART"
rm -rf "$STAGE"

if [ -f "$ARCHIVE" ] && ! verify_archive "$ARCHIVE"; then
  rm -f "$ARCHIVE"
fi
if [ ! -f "$ARCHIVE" ]; then
  echo "Downloading pinned 9Router runtime..."
  node - "$URL" "$PART" <<'NODE'
const fs = require("node:fs");
const { Readable } = require("node:stream");
const { pipeline } = require("node:stream/promises");
(async () => {
  const response = await fetch(process.argv[2]);
  if (!response.ok || !response.body) throw new Error(`HTTP ${response.status}`);
  await pipeline(Readable.fromWeb(response.body), fs.createWriteStream(process.argv[3], { flags: "wx" }));
})().catch((error) => {
  console.error("Runtime download failed:", error.message);
  process.exit(1);
});
NODE
  verify_archive "$PART"
  mv "$PART" "$ARCHIVE"
fi

verify_archive "$ARCHIVE"
mkdir "$STAGE"
tar -xzf "$ARCHIVE" -C "$STAGE"
if ! runtime_ready "$STAGE"; then
  echo "Extracted runtime is missing required files; refusing to install it." >&2
  exit 1
fi
patch_env_fallback "$STAGE/custom-server.js"
mv "$STAGE" "$RELEASE"
rm -f "$ARCHIVE"
echo "Pinned runtime installed at $RELEASE; temporary archive removed."
