#!/usr/bin/env bash
set -euo pipefail

# --- Options parsing ---
usage() {
    cat <<EOF

Download a Homebrew bottle (precompiled package) from GHCR for a formula
Homebrew Formulae catalog : https://formulae.brew.sh/

Usage:
  Help:
    $0 -h|--help
  Download: 
    $0 -n FORMULA -o OS -a ARCH [-v VERSION] [-d OUTFILE_DIR] [-f OUTFILE] [-q|--quiet]
  List available OS/ARCH:
    $0 -n FORMULA -L|--list [-v VERSION] [-q|--quiet]

  VERSION by default will be the latest stable version known
  OUTFILE_DIR is a path to a directory that will be created where the bottle will be stored

Example:
    $0 -n wget --list
    $0 -n privoxy --list -v 4.0.0
    $0 -n wget -o linux -a amd64
    $0 -n privoxy -o linux -a amd64 -v 4.0.0 -d /tmp -f privoxy.tar.gz

Environment:
  GITHUB_TOKEN   Optional; if set, used for GHCR Authorization instead of anonymous token.

Author:
  StudioEtrange (c) 2025

EOF
}

FORMULA=""
VERSION=""
OS=""
ARCH=""
OUT=""
LIST_PLATFORMS=0
OUT_DIR="."
QUIET=0

# --- Parse options (short + a long flag for listing) ---
while [ $# -gt 0 ]; do
  case "${1:-}" in
    -n) FORMULA="${2:-}"; shift 2 ;;
    -v) VERSION="${2:-}"; shift 2 ;;
    -o) OS="${2:-}"; shift 2 ;;
    -a) ARCH="${2:-}"; shift 2 ;;
    -f) OUT="${2:-}"; shift 2 ;;
    -d) OUT_DIR="${2:-}"; shift 2 ;;
    -L|--list) LIST_PLATFORMS=1; shift ;;
    -q|--quiet) QUIET=1; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*|*)
      echo "Invalid option or missing argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

# Logging helper (no-op when QUIET=1)
log() { [ "$QUIET" -eq 0 ] && echo "$@" || :; }

require() { command -v "$1" >/dev/null 2>&1 || { echo "Missing $1" >&2; exit 1; }; }
require curl; require jq; require tar

# --- Validate required inputs for the chosen mode ---
if [ -z "$FORMULA" ]; then
    echo "Error: -n FORMULA is mandatory." >&2
    usage
    exit 1
fi

# Resolve IMAGE_REPO from formula (no brew needed; use formulae API)
log "→ Resolving IMAGE_REPO for formula '$FORMULA'..."
FORMULA_JSON="$(curl -fsSL --connect-timeout 5 "https://formulae.brew.sh/api/formula/${FORMULA}.json" 2>/dev/null || true)"
if [ -z "$FORMULA_JSON" ]; then 
    echo "Failed: formula '$FORMULA' not found on formulae.brew.sh." >&2
    exit 1
fi
IMAGE_REPO="$(echo "$FORMULA_JSON" | jq -r '"\(.tap)/\(.name)"')"

if [ -z "$IMAGE_REPO" ] || [ "$IMAGE_REPO" = "null/null" ]; then
    echo "Failed to resolve IMAGE_REPO for formula: $FORMULA" >&2
    exit 1
fi
log "→ IMAGE_REPO: $IMAGE_REPO"

# If VERSION not provided, use latest stable from formulae API
if [ -z "$VERSION" ]; then
    log "→ Resolving latest stable version..."
    VERSION="$(echo "$FORMULA_JSON" | jq -r '.versions.stable // empty')"
    if [ -z "$VERSION" ] || [ "$VERSION" = "null" ]; then
        echo "Failed: could not determine stable version for '$FORMULA'." >&2
        exit 1
    fi
    log "→ Using VERSION=$VERSION"
fi

BASE="https://ghcr.io/v2/${IMAGE_REPO}"

# --- Auth: use GITHUB_TOKEN if provided, else anonymous token ---
if [ -n "${GITHUB_TOKEN:-}" ]; then
    log "→ Using GITHUB_TOKEN for GHCR..."
    TOKEN="$GITHUB_TOKEN"
else
    log "→ Getting anonymous GHCR token..."
    TOKEN="$(curl -fsSL --connect-timeout 5 "https://ghcr.io/token?scope=repository:${IMAGE_REPO}:pull" | jq -r '.token')"
    [ -n "${TOKEN}" ] || { echo "Failed: empty token." >&2; exit 1; }
fi

# --- Helper: curl with sane defaults & auth ---
curl_helper() {
    curl -fsSL \
        --connect-timeout 10 --max-time 600 \
        --retry 3 --retry-delay 2 --retry-connrefused --retry-all-errors \
        -H "Authorization: Bearer ${TOKEN}" "$@"
}

INDEX_URL="${BASE}/manifests/${VERSION}"
log "→ Fetching multi-arch index: ${INDEX_URL}"
INDEX_JSON="$(curl_helper \
    -H "Accept: application/vnd.oci.image.index.v1+json, application/vnd.docker.distribution.manifest.list.v2+json" \
    "$INDEX_URL")"
if [ -z "$INDEX_JSON" ]; then
    echo "Failed: GHCR index not found for ${IMAGE_REPO}:${VERSION} (check version)." >&2
    exit 1
fi

# --- List platforms mode ---
if [ "$LIST_PLATFORMS" -eq 1 ]; then
    log "Available platforms for ${FORMULA}:${VERSION}"
    echo "$INDEX_JSON" \
        | jq -r '.manifests[]
             | select(.platform.os!=null and .platform.architecture!=null)
             | "\(.platform.os)/\(.platform.architecture)"' \
        | sort -u
    exit 0
fi

# --- Download mode (requires OS + ARCH) ---
if [ -z "$OS" ] || [ -z "$ARCH" ]; then
    echo "Error: -o OS and -a ARCH are mandatory." >&2
    usage
    exit 1
fi

DIGEST="$(jq -r --arg os "$OS" --arg arch "$ARCH" '
    if has("manifests") then
        (.manifests[] | select(.platform.os==$os and .platform.architecture==$arch) | .digest)
    else
        empty
    end
' <<<"$INDEX_JSON" | head -n1)"
[ -n "${DIGEST}" ] || { echo "Failed: digest for $OS/$ARCH not found." >&2; exit 1; }
[ -n "${DIGEST}" ] || {
    echo "Failed:" 
    echo "  digest for $OS/$ARCH not found"
    echo "  no bottle for $OS/$ARCH at ${IMAGE_REPO}:${VERSION}"
    exit 1
}

log "→ Digest $OS/$ARCH: ${DIGEST}"

PLAT_URL="${BASE}/manifests/${DIGEST}"
log "→ Fetching platform manifest: ${PLAT_URL}"
PLAT_JSON="$(curl_helper \
    -H "Accept: application/vnd.oci.image.manifest.v1+json, application/vnd.docker.distribution.manifest.v2+json" \
    "$PLAT_URL")"

BLOB_DIGEST="$(jq -r '
    .layers[]
    | select(.mediaType=="application/vnd.oci.image.layer.v1.tar+gzip"
        or .mediaType=="application/vnd.docker.image.rootfs.diff.tar.gzip")
    | .digest
' <<<"$PLAT_JSON" | head -n1)"
[ -n "${BLOB_DIGEST}" ] || { echo "Failed: .tar.gz layer not found." >&2; exit 1; }
log "→ Blob digest: ${BLOB_DIGEST}"

# Default outfile name if not provided
[ -n "$OUT" ] || OUT="${FORMULA}-${VERSION}.${OS}_${ARCH}.bottle.tar.gz"

# Prepend output directory
mkdir -p "$OUT_DIR" || { echo "Failed: cannot create OUT_DIR '$OUT_DIR'." >&2; exit 1; }
[ -w "$OUT_DIR" ] || { echo "Failed: OUT_DIR '$OUT_DIR' is not writable." >&2; exit 1; }
OUT="${OUT_DIR%/}/$OUT"

BLOB_URL="${BASE}/blobs/${BLOB_DIGEST}"
log "→ Downloading: ${BLOB_URL}"
trap 'rc=$?; if [ $rc -ne 0 ]; then echo "Download failed, removing: $OUT" >&2; rm -f "$OUT"; fi; exit $rc' EXIT
curl_helper \
    -H "Accept: application/octet-stream" \
    "$BLOB_URL" -o "$OUT"
trap - EXIT

if [ "$QUIET" -eq 0 ]; then
    echo "✅ Download complete: $OUT"
    echo "   Content preview:"
    tar -tzf "$OUT" | sed -n '1,12p'
fi