#!/usr/bin/env bash
_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_CURRENT_RUNNING_DIR="$( cd "$( dirname "." )" && pwd )"


# --- NOTES ---
# Build a custom glibc runtime on a host
# Sample usage :
# 	./build-custom-glibc-runtime.sh "$HOME/custom-glibc228-runtime" "2.28"
# 	./build-custom-glibc-runtime.sh "$HOME/custom-glibc239-runtime" "2.39" "11.4.0" "3.10" "AUTO"
#
# To use it in a container you could use distrobox, to run this script inside it
# 	distrobox rm buildenv --yes
# 	distrobox create --image oraclelinux:7.9 --name buildenv --yes
# 	distrobox enter buildenv
# Then inside the container, you can run this script to build glibc:
# 	 export NB_PROC="5" # By default, value is AUTO to use all your processor at build time
# 	./build-custom-glibc-runtime.sh $HOME/custom-glibc228-runtime "$HOME/custom-glibc228-runtime" "2.28"
#
# Sample for copying glibc result to /opt/custom-glibc228-runtime
#   sudo rm -rf /opt/custom-glibc228-runtime
# 	sudo mv $HOME/custom-glibc228-runtime /opt/
# 	sudo chmod -R a+rx /opt/custom-glibc228-runtime
# 
# Cleaning work dir
#   rm -rf $HOME/.build-custom-glibc-runtime
#
# Some doc : https://github.com/jueve/build-glibc 


# --- Variables ---
# get external environment variable and fix default value
GLIBC_VERSION="${GLIBC_VERSION:-2.28}"
# https://anaconda.org/channels/conda-forge/packages/gcc/overview
GCC_VERSION="${GCC_VERSION:-8.5.0}"
KERNEL_SUPPORTED_VERSION="${KERNEL_SUPPORTED_VERSION:-3.10}"
NB_PROC="${NB_PROC:-AUTO}"

PROJECT_WORKSPACE_ROOT="$HOME/.build-custom-glibc-runtime"

MINIFORGE_ROOT="${PROJECT_WORKSPACE_ROOT}/miniforge3"
MAMBA_ENV_NAME="build-custom-glibc-runtime"

# parameters
GLIBC_INSTALL_DIR="${1}"
GLIBC_VERSION="${2:-${GLIBC_VERSION}}"
GCC_VERSION="${3:-${GCC_VERSION}}"
KERNEL_SUPPORTED_VERSION="${4:-${KERNEL_SUPPORTED_VERSION}}"
NB_PROC="${5:-${NB_PROC}}"

GLIBC_ROOT="${PROJECT_WORKSPACE_ROOT}/glibc"
GLIBC_SRC_ROOT="${GLIBC_ROOT}/src-dir"
GLIBC_TAR_FILE="${GLIBC_SRC_ROOT}/glibc-${GLIBC_VERSION}.tar.gz"
GLIBC_SRC_DIR="${GLIBC_SRC_ROOT}/glibc-${GLIBC_VERSION}"
GLIBC_BUILD_DIR="${GLIBC_ROOT}/build-dir"


# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Helper functions ---

usage() {
    echo "Build a custom glibc runtime"
    echo
    echo "$0 <install path> <glibc version>] [<gcc version>] [<nb processor>]"
    echo
    echo Arguments:
    echo "  <install path>: Built glibc with minimal runtime will be copied in this path. Will be delete and recreated at launch."
    echo "  <glibc version>: libc version to build with a minimal runtime. Source code is donwloaded. Default value is ${GLIBC_VERSION}. (can be set using env variable GLIBC_VERSION)"
    echo "  <gcc version>: gcc version downloaded and used. Default value is ${GCC_VERSION}. (can be set using env variable GCC_VERSION)"
    echo "  <kernel supported>: Linux kernel minimal supported version by glibc. Default value is ${KERNEL_SUPPORTED_VERSION}. (can be set using env variable KERNEL_SUPPORTED_VERSION)"
    echo "  <nb processor>: Processor total number used for build gcc. Default value is all processor. (can be set using env variable NB_PROC)"
    echo
    echo "Sample command:"
    echo "  $0 \"\$HOME/custom-glibc239-runtime\" \"2.39\" \"11.4.0\" \"3.10\" \"AUTO\""
}

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    exit 1
}

check_command() {
    cmd="$1"
    mode="${2:-}"

    if ! command -v "$cmd" &> /dev/null; then
        [ "$mode" = "stop" ] && error "$1 could not be found. Please install it."
        return 1
    fi
    return 0
}

copy_versions_with_symlinks() {
    base="$1"; src="$2"; dst="$3"
    mkdir -p "$dst"
    info "copy $base"
    find "$src" -maxdepth 1 \( -name "$base" -o -name "$base.*" \) |
    while read -r f; do
        b="$(basename "$f")"
        if [ -L "$f" ]; then
            ln -snf "$(readlink "$f")" "$dst/$b"
            cp -a "$(readlink -f "$f")" "$dst/" 2>/dev/null || true
        else
            cp -a "$f" "$dst/"
        fi
    done
}


# --- Main script ---
case "$1" in
    "-h"|"--help"|"-help") 
        usage
        exit 0
        ;;
esac

if [ -z "${GLIBC_INSTALL_DIR}" ]; then
    usage
	error "Please provide glibc install dir at first argument : $0 /opt/glibc"
fi

info "Will build glibc version ${GLIBC_VERSION} for minimal linux kernel version $KERNEL_SUPPORTED_VERSION into $GLIBC_INSTALL_DIR"
info "Will install and use gcc version: ${GCC_VERSION}"
if check_command gcc; then
    gcc_system_version="$(gcc -dumpfullversion -dumpversion)"
    info "Current gcc version installed on system is ${gcc_system_version}"
fi
info "Number of processor to use for build: $NB_PROC (set to AUTO to use all available processors)"


info "Current host linux kernel information: $(uname -a)"
info "Current host linux kernel version: $(uname -r)"

info "------- CHECK AND INSTALL REQUIREMENTS --------------"

# install requirements

# Check for required commands
check_command "wget" "stop"
check_command "nproc" "stop"
check_command "tar" "stop"
check_command "readelf" "stop"
check_command "file" "stop"

# install patchelf
PATCHELF="$PROJECT_WORKSPACE_ROOT/patchelf/bin/patchelf"
export PATH="$PROJECT_WORKSPACE_ROOT/patchelf/bin:$PATH"
if [ -x "$PATCHELF" ]; then
    info "Patchelf is already installed."
else
    rm -rf "$PROJECT_WORKSPACE_ROOT/patchelf"
    mkdir -p "$PROJECT_WORKSPACE_ROOT/patchelf"
    cd "$PROJECT_WORKSPACE_ROOT/patchelf"
    wget --no-check-certificate "https://github.com/NixOS/patchelf/releases/download/0.18.0/patchelf-0.18.0-x86_64.tar.gz"
    tar -zxvf "patchelf-0.18.0-x86_64.tar.gz" 1>/dev/null
    rm -f "patchelf-0.18.0-x86_64.tar.gz"
fi
check_command "patchelf" "stop"



# install miniforge3
export PATH="${MINIFORGE_ROOT}/bin:$PATH"

if check_command "mamba"; then
    info "Mamba is already installed."
else
    info "Mamba is not installed. Installing Miniforge3..."
    mkdir -p "${MINIFORGE_ROOT}"
    cd "${MINIFORGE_ROOT}"
    wget -O "${MINIFORGE_ROOT}/Miniforge3.sh" "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
    bash "${MINIFORGE_ROOT}/Miniforge3.sh" -p "${MINIFORGE_ROOT}" -b -f
    rm -f "${MINIFORGE_ROOT}/Miniforge3.sh"
fi


if mamba env list | awk '{print $1}' | grep -qx "$MAMBA_ENV_NAME"; then
	info "Mamba environment $MAMBA_ENV_NAME already exists..."
else
	info "Creating mamba environment..."
	mamba create -n "$MAMBA_ENV_NAME"
fi

MAMBA_ENV_PREFIX="$(mamba info --envs | awk -v env="$MAMBA_ENV_NAME" '$1==env {print $NF}')"
[ -n "$MAMBA_ENV_PREFIX" ] || error "Unable to determine MAMBA_ENV_PREFIX, environment $MAMBA_ENV_NAME may not have been created successfully."


info "Activating mamba environment"
source activate "$MAMBA_ENV_NAME"


check_command "make" "stop"
check_command "gcc" "stop"

info "Adding requirements into mamba environment"
# mamba install -c conda-forge -y gcc=${GCC_VERSION} make=4.3 bison python=3.12 texinfo=7.2 python=3.12

# info "-------------- GLIBC COMPILATION ------------------"
mkdir -p "$GLIBC_SRC_ROOT"

if [ ! -f "$GLIBC_TAR_FILE" ]; then
    info "Downloading glibc $GLIBC_VERSION..."
    wget --no-check-certificate -O "$GLIBC_TAR_FILE" "https://ftp.gnu.org/gnu/glibc/glibc-$GLIBC_VERSION.tar.gz"
else
    info "Glibc tarball file already exists."
fi

rm -rf "$GLIBC_SRC_DIR"
info "Extracting glibc source..."
tar -zxvf "$GLIBC_TAR_FILE" -C "$GLIBC_SRC_ROOT" 1>/dev/null

info "Configuring glibc..."
rm -rf "$GLIBC_BUILD_DIR"
mkdir -p "$GLIBC_BUILD_DIR"
cd "$GLIBC_BUILD_DIR"

rm -rf "$GLIBC_INSTALL_DIR"
mkdir -p "$GLIBC_INSTALL_DIR"

# building glibc require LD_LIBRARY_PATH to be empty or configuration step fail
export LD_LIBRARY_PATH=""

$GLIBC_SRC_DIR/configure --prefix="$GLIBC_INSTALL_DIR" \
            --disable-profile \
            --disable-werror \
            --enable-kernel="$KERNEL_SUPPORTED_VERSION" \
            CC="gcc -m64" \
            CXX="g++ -m64" \
            CFLAGS="-O2" \
            CXXFLAGS="-O2" \
            MAKE=make

info "Building glibc..."
case $NB_PROC in
	"AUTO")
		make -j"$(nproc)"
		;;
	[0-9]*)
		make -j${NB_PROC}
		;;
	*)
		make
		;;
esac

info "Installing glibc in $GLIBC_INSTALL_DIR..."
make install || warn "make install failed but continuing."

info "Glibc $GLIBC_VERSION build process finished."
info "Installation directory: $GLIBC_INSTALL_DIR"


GLIBC_LIB="$GLIBC_INSTALL_DIR/lib/libc-${GLIBC_VERSION}.so"
if [ ! -f "$GLIBC_LIB" ]; then
    warn "no glibc ($GLIBC_LIB) built found, build may have failed, trying other filename"

    GLIBC_LIB="$(find "$GLIBC_INSTALL_DIR/lib" \
        -maxdepth 1 \
        -name 'libc.so.*' \
        | sort \
        | tail -n 1)"

    if [ -z "$GLIBC_LIB" ] || [ ! -e "$GLIBC_LIB" ]; then
        error "no glibc libc.so.* found in $GLIBC_INSTALL_DIR/lib, build may have failed"
    fi
fi

info "glibc file found: ${GLIBC_LIB}"

info "-------------- CLEANING AND COLLECTING ------------------"

info "Cleaning any RUNPATH/RPATH value from loader ld-linux.so"
# loader MUST not have any RPATH/RUNPATH
for LOADER in \
  "$GLIBC_LIB" \
  "$GLIBC_INSTALL_DIR/lib/ld-linux-x86-64.so."*;
do
    [ -e "$LOADER" ] || continue
    "$PATCHELF" --remove-rpath "$LOADER" 2>/dev/null || true
    if readelf -d "$LOADER" | grep -E 'RPATH|RUNPATH' >/dev/null 2>&1; then
        error "Loader has RPATH/RUNPATH (but must be empty)"
    fi
done


info "Assemble a small custom runtime with built glibc and other libraries"
info "Copy some libraries from mamba env"
mkdir -p "$GLIBC_INSTALL_DIR/rtlib"

copy_versions_with_symlinks "libgcc_s.so" "$MAMBA_ENV_PREFIX/lib" "$GLIBC_INSTALL_DIR/rtlib"
copy_versions_with_symlinks "libstdc++.so" "$MAMBA_ENV_PREFIX/lib" "$GLIBC_INSTALL_DIR/rtlib"
copy_versions_with_symlinks "libz.so" "$MAMBA_ENV_PREFIX/lib" "$GLIBC_INSTALL_DIR/rtlib"

info "Cleaning any useless RUNPATH/RPATH from all objects"
# clean all object which have RUNPATH/RPATH with value not under of "$GLIBC_INSTALL_DIR", and keep also $ORIGIN and ${ORIGIN}
p="${GLIBC_INSTALL_DIR%/}"
find "$p" -type f -size +0c -print0 |
while IFS= read -r -d '' f; do
    file -b "$f" 2>/dev/null | grep -q ELF || continue

    old="$("$PATCHELF" --print-rpath "$f" 2>/dev/null || true)"
    [ -n "$old" ] || continue

    new="$(
        printf '%s\n' "$old" |
        tr ':' '\n' |
        awk -v p="$p" '
            NF==0 {next}
            index($0,"$ORIGIN") || index($0,"${ORIGIN}") || index($0,"\\$ORIGIN") {print; next}
            $0==p || index($0, p "/")==1 {print; next}
            {next}
        ' |
        awk '!seen[$0]++' |
        paste -sd: -
    )"

    if [ "$old" != "$new" ]; then
        info "== file $f =="
        if [ -z "$new" ]; then
            info "Remove this RPATH/RUNPATH : $old"
            "$PATCHELF" --remove-rpath "$f" 2>/dev/null || true
        else
            info "Change RPATH/RUNPATH value $old to $new"
            "$PATCHELF" --set-rpath "$new" "$f" 2>/dev/null || true
        fi
    fi
done

info "-------------- FINAL TEST ------------------"

# Test
"$GLIBC_LIB" --library-path "$GLIBC_INSTALL_DIR/lib:$GLIBC_INSTALL_DIR/rtlib" /bin/true \
  && info "Sample test OK" \
  || error "Sample test FAILED"

info "Custom glibc runtime ${GLIBC_VERSION} is in $GLIBC_INSTALL_DIR"
