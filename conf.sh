if [ ! "$_CONF_INCLUDED_" == "1" ]; then
_CONF_INCLUDED_=1

# STELLA PATHS ---------------------------------------------
STELLA_ROOT="$_INCLUDED_FILE_DIR"
STELLA_COMMON="$STELLA_ROOT/stella-common/nix"

# STELLA INCLUDE ---------------------------------------------

source $STELLA_COMMON/libscreenfetch.sh
source $STELLA_COMMON/platform.sh

source $STELLA_COMMON/common.sh
source $STELLA_COMMON/common-tools.sh
source $STELLA_COMMON/common-app.sh

# GATHER PLATFORM INFO ---------------------------------------------
set_current_platform_info

# GATHER CURRENT APP INFO ---------------------------------------------
APP_ROOT="$_CALLING_FILE_DIR"
APP_WORK_ROOT="$_CALLING_FILE_DIR"
PROJECT_ROOT="$APP_WORK_ROOT"
select_app_properties
get_all_properties

# APP PATHS ---------------------------------------------
PROJECT_ROOT="$APP_WORK_ROOT"
if [ "$CACHE_DIR" == "" ]; then
	CACHE_DIR="$PROJECT_ROOT/cache"
fi
TEMP_DIR="$PROJECT_ROOT/temp"
TOOL_ROOT="$PROJECT_ROOT/tool_$CURRENT_PLATFORM_SUFFIX/$CURRENT_OS"
DATA_ROOT="$PROJECT_ROOT/data"
ASSETS_ROOT="$PROJECT_ROOT/assets"
ASSETS_REPOSITORY="$(dirname $PROJECT_ROOT)"/assets_repository

# OTHERS
FEATURE_LIST_ENABLED=
DEFAULT_VERBOSE_MODE=0

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

fi
