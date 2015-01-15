if [ ! "$_STELLA_CONF_INCLUDED_" == "1" ]; then
_STELLA_CONF_INCLUDED_=1

_STELLA_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ "$_STELLA_CURRENT_RUNNING_DIR" == "" ]; then
	_STELLA_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
fi

# STELLA PATHS ---------------------------------------------
STELLA_ROOT="$_STELLA_CURRENT_FILE_DIR"
STELLA_COMMON="$STELLA_ROOT/nix/common"
STELLA_POOL="$STELLA_ROOT/nix/pool"
STELLA_BIN="$STELLA_ROOT/nix/bin"
STELLA_FEATURE_RECIPE="$STELLA_POOL/feature-recipe"
STELLA_FEATURE_REPOSITORY="$STELLA_FEATURE_RECIPE/feature-repository"

# STELLA INCLUDE ---------------------------------------------

source $STELLA_COMMON/libscreenfetch.sh
source $STELLA_COMMON/platform.sh

source $STELLA_COMMON/common.sh
source $STELLA_COMMON/common-feature.sh
source $STELLA_COMMON/common-app.sh
source $STELLA_COMMON/common-virtual.sh
source $STELLA_COMMON/common-api.sh

# GATHER PLATFORM INFO ---------------------------------------------
__set_current_platform_info

# DEFAULT APP INFO -------------
STELLA_APP_ROOT="$_STELLA_CURRENT_RUNNING_DIR"
STELLA_APP_WORK_ROOT="$_STELLA_CURRENT_RUNNING_DIR"
STELLA_APP_CACHE_DIR=
STELLA_APP_NAME=
STELLA_APP_PROPERTIES_FILENAME="stella.properties"

# GATHER CURRENT APP INFO ---------------------------------------------
_STELLA_APP_PROPERTIES_FILE="$(__select_app)"
__get_all_properties $_STELLA_APP_PROPERTIES_FILE

# APP PATH ---------------------------------------------
STELLA_APP_ROOT=$(__rel_to_abs_path "$STELLA_APP_ROOT" "$_STELLA_CURRENT_RUNNING_DIR")
STELLA_APP_WORK_ROOT=$(__rel_to_abs_path "$STELLA_APP_WORK_ROOT" "$STELLA_APP_ROOT")
if [ "$STELLA_APP_CACHE_DIR" == "" ]; then
	STELLA_APP_CACHE_DIR="$STELLA_APP_WORK_ROOT/cache"
fi
STELLA_APP_CACHE_DIR=$(__rel_to_abs_path "$STELLA_APP_CACHE_DIR" "$STELLA_APP_ROOT")

STELLA_APP_TEMP_DIR="$STELLA_APP_WORK_ROOT/temp"
STELLA_APP_FEATURE_ROOT="$STELLA_APP_WORK_ROOT/feature_$STELLA_CURRENT_PLATFORM_SUFFIX/$STELLA_CURRENT_OS"
ASSETS_ROOT="$STELLA_APP_WORK_ROOT/assets"
ASSETS_REPOSITORY=$(__rel_to_abs_path "../assets_repository" "$STELLA_APP_WORK_ROOT")


# DEFAULT FEATURE ---------------------------------------------
# TODO replace command with these variables
#WGET="wget" # TODO for macos see STELLA_APP_FEATURE_ROOT/wget (=> useless because already replaced by curl in common.sh)
#WGET=$STELLA_APP_FEATURE_ROOT/wget
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

VIRTUAL_INTERNAL_ROOT="$STELLA_ROOT/common/virtual"
VIRTUAL_INTERNAL_TEMPLATE_ROOT="$VIRTUAL_INTERNAL_ROOT/template"
VIRTUAL_CONF_FILE="$VIRTUAL_INTERNAL_ROOT/virtual.ini"

PACKER_CMD=packer
VAGRANT_CMD=vagrant

export PACKER_STELLA_APP_CACHE_DIR="$STELLA_APP_CACHE_DIR"

# choose a default hypervisor for packer and vagrant
# vmware or virtualbox
VIRTUAL_DEFAULT_HYPERVISOR=virtualbox

# INTERNAL LIST---------------------------------------------
__STELLA_DISTRIB_LIST="ubuntu64_13_10 debian64_7_5 centos64_6_5 archlinux boot2docker"
__STELLA_FEATURE_LIST="wget ninja cmake packer autotools perl"

# API ---------------------------------------------
STELLA_API_COMMON_PUBLIC="is_abs argparse get_ressource download_uncompress copy_folder_content_into del_folder get_key add_key del_key mercurial_project_version git_project_version get_stella_version"
STELLA_API_APP_PUBLIC="get_data get_assets get_all_data get_all_assets update_data update_assets revert_data revert_assets get_env_properties setup_env"
STELLA_API_FEATURE_PUBLIC="install_feature init_feature"
STELLA_API_VIRTUAL_PUBLIC=""

STELLA_API_RETURN_FUNCTION="is_abs mercurial_project_version git_project_version"
STELLA_API=__api_proxy


fi
