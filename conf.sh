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
STELLA_APP_ROOT="$_CURRENT_RUNNING_DIR"
STELLA_APP_WORK_ROOT="$_CURRENT_RUNNING_DIR"
STELLA_APP_CACHE_DIR=
APP_NAME=

# GATHER CURRENT APP INFO ---------------------------------------------
__select_app
__get_all_properties

# APP PATH ---------------------------------------------
STELLA_APP_ROOT=$(__rel_to_abs_path "$STELLA_APP_ROOT" "$_CURRENT_RUNNING_DIR")
STELLA_APP_WORK_ROOT=$(__rel_to_abs_path "$STELLA_APP_WORK_ROOT" "$STELLA_APP_ROOT")
if [ "$STELLA_APP_CACHE_DIR" == "" ]; then
	STELLA_APP_CACHE_DIR="$STELLA_APP_WORK_ROOT/cache"
fi
STELLA_APP_CACHE_DIR=$(__rel_to_abs_path "$STELLA_APP_CACHE_DIR" "$STELLA_APP_ROOT")

TEMP_DIR="$STELLA_APP_WORK_ROOT/temp"
STELLA_TOOL_ROOT="$STELLA_APP_WORK_ROOT/tool_$STELLA_CURRENT_PLATFORM_SUFFIX/$STELLA_CURRENT_OS"
ASSETS_ROOT="$STELLA_APP_WORK_ROOT/assets"
ASSETS_REPOSITORY=$(__rel_to_abs_path "../assets_repository" "$STELLA_APP_WORK_ROOT")


# DEFAULT TOOLS ---------------------------------------------
# TODO replace command with these variables
#WGET="wget" # for macos see STELLA_TOOL_ROOT/wget
#WGET=$STELLA_TOOL_ROOT/wget
#UZIP="unzip"
#U7ZIP="7z"
#PATCH="patch"
#GNUMAKE="make"

# OTHERS ---------------------------------------------
FEATURE_LIST_ENABLED=
VERBOSE_MODE=0

# VIRTUALIZATION ------------------------------------------
VIRTUAL_WORK_ROOT="$STELLA_APP_WORK_ROOT/virtual"
VIRTUAL_TEMPLATE_ROOT="$VIRTUAL_WORK_ROOT/template"
VIRTUAL_ENV_ROOT="$VIRTUAL_WORK_ROOT/env"

VIRTUAL_INTERNAL_ROOT="$STELLA_ROOT/stella-virtual"
VIRTUAL_INTERNAL_TEMPLATE_ROOT="$VIRTUAL_INTERNAL_ROOT/template"
VIRTUAL_CONF_FILE="$VIRTUAL_INTERNAL_ROOT/virtual.ini"

PACKER_CMD=packer
VAGRANT_CMD=vagrant

export PACKER_STELLA_APP_CACHE_DIR="$STELLA_APP_CACHE_DIR"

# choose a default hypervisor for packer and vagrant
# vmware or virtualbox
VIRTUAL_DEFAULT_HYPERVISOR=virtualbox

# INTERNAL LIST---------------------------------------------
DISTRIB_LIST="ubuntu64 debian64 centos64 archlinux boot2docker"
TOOL_LIST="wget ninja cmake packer autotools perl"

# API ---------------------------------------------
STELLA_API_COMMON_PUBLIC="is_abs argparse get_ressource download_uncompress"
STELLA_API_APP_PUBLIC="get_data get_assets get_all_data get_all_assets update_data update_assets revert_data revert_assets"
STELLA_API_TOOLS_PUBLIC="install_feature init_feature"
STELLA_API_VIRTUAL_PUBLIC=""

STELLA_API="api_proxy"



fi
