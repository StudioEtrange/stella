#!/usr/bin/env bash
# patch a binary interpreter/rpath with patchelf

set -eu

# --- NOTES ---
# Link a binary to a custom built glibc runtime
# Sample usage :
#    export CUSTOM_GLIBC_PATH="$HOME/custom-glibc228-runtime"
#    export CUSTOM_GLIBC_LINKER="$HOME/custom-glibc228-runtime/lib/ld-linux-x86-64.so.2"
# 	./patch-with-custom-glibc.sh "tool" "$HOME/folder/to/binary"
#

# ---Default config ---
DEFAULT_GLIBC_RUNTIME_PATH="/opt/custom-glibc228-runtime"
DEFAULT_INTERPRETER="${DEFAULT_GLIBC_RUNTIME_PATH}/lib/ld-linux-x86-64.so.2"

usage() {
    echo "Link a binary to a custom built glibc runtime"
    echo
    echo
    echo "$0 <binary filename> <binary search folder>"
    echo
    echo Arguments:
    echo "  <binary filename>: Binary file to link to custom built glibc runtime"
    echo "  <binary search folder>: Seach path to found binary file"
    echo 
    echo "Required environment variables:"
    echo "  CUSTOM_GLIBC_PATH: Path to custom glibc runtime built with build-custom-glibc-runtime script, which contains /lib and /rtlib folders (i.e: /opt/custom-glibc239-runtime)"
    echo "                            Default value is ${DEFAULT_GLIBC_RUNTIME_PATH}"
    echo "  CUSTOM_GLIBC_LINKER: Path to dynamic loader/interpreter. (i.e: /opt/custom-glibc239-runtime/lib/ld-linux-x86-64.so.2)"
    echo "                            Default value is ${DEFAULT_INTERPRETER}"
    echo
    echo "Sample command:"
    echo "  export CUSTOM_GLIBC_PATH=\"\$HOME/custom-glibc239-runtime\""
    echo "  export CUSTOM_GLIBC_LINKER=\"\$HOME/custom-glibc239-runtime/lib/ld-linux-x86-64.so.2\""
    echo "  $0 \"tool\" \"\$HOME/folder/to/binary\""
}




print_info() {
    local f="${1}"
    echo "Current interpreter : $("${PATCHELF}" --print-interpreter "${f}" 2>/dev/null || true)"
    echo "Current rpath : $( "${PATCHELF}" --print-rpath "${f}" 2>/dev/null || true)"
}

patch() {
    local f="$1"
    [ -f "${f}" ] || return 0
        
    echo "----------------------------"
    echo "Analyse file : ${f}"
    print_info "${f}"

    interpreter="$("${PATCHELF}" --print-interpreter "${f}" 2>/dev/null || true)"
    if [ "${interpreter}" != "${EXPECTED_INTERPRETER}" ]; then
        # Apply rpath then interpreter

        # force legacy RPATH instead of RUNPATH because RUNPATH is not reliably used to resolve transitive dependencies loaded via dlopen() 
        # (e.g., native modules like node-pty) 
        if "${PATCHELF}" --force-rpath --set-rpath "${EXPECTED_RPATH}" "${f}" 2>/dev/null && \
            "${PATCHELF}" --set-interpreter "${EXPECTED_INTERPRETER}" "${f}" 2>/dev/null; then
            
            echo "Patch applied on ${f}"
            print_info "${f}"
        else
            echo "ERROR: failed to patch: ${f}" >&2
            print_info "${f}"
            return 1
        fi
    fi
    echo "----------------------------"
    return 0
}


info() {
    echo "Link a binary to a custom built glibc runtime"
    echo
    echo "binary: ${BINARY_TO_PATCH}"
    echo "binary search folder: ${FOLDER_TO_PATCH_ROOT}"
    echo 
    echo "custom glibc runtime path: ${CUSTOM_GLIBC_PATH:-${DEFAULT_GLIBC_RUNTIME_PATH}} "
    echo "interpreter: ${EXPECTED_INTERPRETER}"
    echo
    local _ldd_version="$(ldd --version 2>/dev/null | awk '/ldd/{print $NF}')"
	echo "current system glibc version: ${_ldd_version}"
}


# --- Main script ---
case "${1:-}" in
    "-h"|"--help"|"-help") 
        usage
        exit 0
        ;;
esac

BINARY_TO_PATCH="${1:-}"
FOLDER_TO_PATCH_ROOT="${2:-}"


if [ -z "$BINARY_TO_PATCH" ]; then
    echo "ERROR: missing first argument : binary name to patch"
    echo
    usage
    exit 1
fi

if [ -z "$FOLDER_TO_PATCH_ROOT" ]; then
    echo "ERROR: missing second argument : folder where to find binary to patch"
    echo
    usage
    exit 1
fi

if [ ! -d "${FOLDER_TO_PATCH_ROOT}" ]; then
    echo "ERROR: search folder do not exists $FOLDER_TO_PATCH_ROOT" >&2
    echo
    usage
    exit 1
fi

FOLDER_TO_PATCH_ROOT="${FOLDER_TO_PATCH_ROOT}/"
PATCH_WORKSPACE="$HOME/.patch-workspace/$(basename "${FOLDER_TO_PATCH_ROOT}")"

DEFAULT_EXTENDED_RPATH="${DEFAULT_GLIBC_RUNTIME_PATH}/lib:${DEFAULT_GLIBC_RUNTIME_PATH}/rtlib"
[ ! "${CUSTOM_GLIBC_PATH:-}" = "" ] && EXTENDED_USER_RPATH="${CUSTOM_GLIBC_PATH}/lib:${CUSTOM_GLIBC_PATH}/rtlib" || EXTENDED_USER_RPATH=""
EXPECTED_RPATH="${EXTENDED_USER_RPATH:-${DEFAULT_EXTENDED_RPATH}}"

EXPECTED_INTERPRETER="${CUSTOM_GLIBC_LINKER:-${DEFAULT_INTERPRETER}}"



info

# LOCK when using multiple remote ssh connection (which is the case of VS Code Remote SSH)
LOCK_DIR="${PATCH_WORKSPACE}/patch.lock.d"
mkdir -p "${PATCH_WORKSPACE}"
# purge old lock (>1 day)
[ -d "$LOCK_DIR" ] && find "$LOCK_DIR" -maxdepth 0 -mtime +0 -exec rm -rf {} \; 2>/dev/null || true
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    exit 0
fi
trap 'rm -rf "$LOCK_DIR" 2>/dev/null || true' EXIT INT HUP TERM QUIT PIPE

# install patchelf
PATCHELF="$PATCH_WORKSPACE/patchelf/bin/patchelf"
PATH="$PATCH_WORKSPACE/patchelf/bin:$PATH"
if [ -x "$PATCHELF" ]; then
    echo "patchelf is already installed."
else
    mkdir -p "$PATCH_WORKSPACE/patchelf"
    cd "$PATCH_WORKSPACE/patchelf"
    wget --no-check-certificate "https://github.com/NixOS/patchelf/releases/download/0.18.0/patchelf-0.18.0-x86_64.tar.gz" || exit 0
    tar -zxvf "patchelf-0.18.0-x86_64.tar.gz" 1>/dev/null || exit 0
    rm -f "patchelf-0.18.0-x86_64.tar.gz"
fi
# check patchelf exists and is executable
if ! command -v "patchelf" >/dev/null 2>&1; then
    echo "ERROR: patchelf not found" >&2
    exit 0
fi

# check expected interpreter exists
if [ ! -f "${EXPECTED_INTERPRETER}" ]; then
    echo "ERROR: expected interpreter not found: ${EXPECTED_INTERPRETER}" >&2
    exit 0
fi

# find binary
echo "try to find $BINARY_TO_PATCH in $FOLDER_TO_PATCH_ROOT"

find "$FOLDER_TO_PATCH_ROOT" -type f -executable -size +0c -name "$BINARY_TO_PATCH" -print0 |
while IFS= read -r -d '' f; do
    echo "found $f"
    commit_dir="$(dirname "$f")"
    stamp="$commit_dir/.patched"
    # already patched
    if [ -f "$stamp" ]; then
	echo "already patched"
	continue
    fi
    if patch "$f"; then
        touch "$stamp" 2>/dev/null || true
    fi
done


exit 0

