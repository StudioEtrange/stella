if [ ! "$_CONF_INCLUDED_" == "1" ]; then
_CONF_INCLUDED_=1

# STELLA PATHS ---------------------------------------------
STELLA_ROOT="$_CURRENT_FILE_DIR"
STELLA_COMMON="$STELLA_ROOT/stella-common/nix"
STELLA_POOL="$STELLA_ROOT/stella-pool/nix"
STELLA_TOOL_RECIPE="$STELLA_POOL/tool-recipe"

# STELLA INCLUDE ---------------------------------------------

source $STELLA_COMMON/libscreenfetch.sh
source $STELLA_COMMON/platform.sh

source $STELLA_COMMON/common.sh
source $STELLA_COMMON/common-tools.sh
source $STELLA_COMMON/common-app.sh
source $STELLA_COMMON/common-virtual.sh
source $STELLA_COMMON/common-api.sh

# GATHER PLATFORM INFO ---------------------------------------------
__set_current_platform_info

# DEFAULT APP INFO -------------
APP_ROOT="$_CURRENT_RUNNING_DIR"
APP_WORK_ROOT="$_CURRENT_RUNNING_DIR"
PROJECT_ROOT="$_CURRENT_RUNNING_DIR"
CACHE_DIR=
APP_NAME=

# GATHER CURRENT APP INFO ---------------------------------------------
__select_app
__get_all_properties

# APP PATH ---------------------------------------------
APP_ROOT=$(__rel_to_abs_path "$APP_ROOT" "$_CURRENT_RUNNING_DIR")
PROJECT_ROOT=$(__rel_to_abs_path "$APP_WORK_ROOT" "$APP_ROOT")
if [ "$CACHE_DIR" == "" ]; then
	CACHE_DIR="$PROJECT_ROOT/cache"
fi
CACHE_DIR=$(__rel_to_abs_path "$CACHE_DIR" "$APP_ROOT")

TEMP_DIR="$PROJECT_ROOT/temp"
TOOL_ROOT="$PROJECT_ROOT/tool_$STELLA_CURRENT_PLATFORM_SUFFIX/$STELLA_CURRENT_OS"
DATA_ROOT="$PROJECT_ROOT/data"
ASSETS_ROOT="$PROJECT_ROOT/assets"
ASSETS_REPOSITORY=$(__rel_to_abs_path "../assets_repository" "$PROJECT_ROOT")


# DEFAULT TOOLS ---------------------------------------------
# TODO replace command with these variables
#WGET="wget" # for macos see TOOL_ROOT/wget
#WGET=$TOOL_ROOT/wget
#UZIP="unzip"
#U7ZIP="7z"
#PATCH="patch"
#GNUMAKE="make"

# OTHERS ---------------------------------------------
FEATURE_LIST_ENABLED=
VERBOSE_MODE=0

# VIRTUALIZATION ------------------------------------------
VIRTUAL_WORK_ROOT="$PROJECT_ROOT/virtual"
VIRTUAL_TEMPLATE_ROOT="$VIRTUAL_WORK_ROOT/template"
VIRTUAL_ENV_ROOT="$VIRTUAL_WORK_ROOT/env"

VIRTUAL_INTERNAL_ROOT="$STELLA_ROOT/stella-virtual"
VIRTUAL_INTERNAL_TEMPLATE_ROOT="$VIRTUAL_INTERNAL_ROOT/template"
VIRTUAL_CONF_FILE="$VIRTUAL_INTERNAL_ROOT/virtual.ini"

PACKER_CMD=packer
VAGRANT_CMD=vagrant

export PACKER_CACHE_DIR="$CACHE_DIR"

# choose a default hypervisor for packer and vagrant
# vmware or virtualbox
VIRTUAL_DEFAULT_HYPERVISOR=virtualbox

# INTERNAL LIST---------------------------------------------
DISTRIB_LIST="ubuntu64 debian64 centos64 archlinux boot2docker"
TOOL_LIST="wget ninja cmake packer autotools perl"

# API ---------------------------------------------
STELLA_API_COMMON_PUBLIC="is_abs argparse get_ressource"
STELLA_API_APP_PUBLIC=""
STELLA_API_TOOLS_PUBLIC=""
STELLA_API_VIRTUAL_PUBLIC=""

STELLA_API="api_proxy"



fi
