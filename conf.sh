if [ ! "$_STELLA_CONF_INCLUDED_" == "1" ]; then
_STELLA_CONF_INCLUDED_=1

# disable PATH lookup command cache
set -h

# DEBUG STELLA
#set -x
#set -xv

_STELLA_CONF_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ "$STELLA_CURRENT_RUNNING_DIR" == "" ]; then
	#STELLA_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
	STELLA_CURRENT_RUNNING_DIR="$( cd "$( dirname "." )" && pwd )"
fi
_STELLA_CONF_CURRENT_FILE="$_STELLA_CONF_CURRENT_FILE_DIR/$(basename ${BASH_SOURCE[0]})"


# STELLA PATHS ---------------------------------------------
STELLA_ROOT="$_STELLA_CONF_CURRENT_FILE_DIR"
STELLA_COMMON="$STELLA_ROOT/nix/common"
STELLA_POOL="$STELLA_ROOT/nix/pool"
STELLA_PATCH="$STELLA_POOL/patch"
STELLA_BIN="$STELLA_ROOT/nix/bin"
STELLA_FEATURE_RECIPE="$STELLA_POOL/feature-recipe"
STELLA_FEATURE_RECIPE_EXPERIMENTAL="$STELLA_FEATURE_RECIPE/exp"
STELLA_ARTEFACT="$STELLA_POOL/artefact"
STELLA_APPLICATION="$STELLA_ROOT/app"
STELLA_TEMPLATE="$STELLA_POOL/template"

# URL PATHS ---------------------------------------------
STELLA_URL="http://stella.sh"
STELLA_POOL_URL="$STELLA_URL/pool"
STELLA_ARTEFACT_URL="$STELLA_POOL_URL/nix/artefact"
STELLA_FEATURE_RECIPE_URL="$STELLA_POOL_URL/nix/feature-recipe"
STELLA_DIST_URL="$STELLA_URL/dist"

# SITE SCHEMA
# /pool
# /pool/nix
# /pool/nix/feature-recipe
# /pool/nix/artefact
# /dist

# STELLA INCLUDE ---------------------------------------------
source $STELLA_COMMON/stack.sh
source $STELLA_COMMON/common-platform.sh
source $STELLA_COMMON/common.sh
source $STELLA_COMMON/common-feature.sh
source $STELLA_COMMON/common-app.sh
source $STELLA_COMMON/lib-parse-bin.sh
source $STELLA_COMMON/common-binary.sh
source $STELLA_COMMON/common-build.sh
source $STELLA_COMMON/common-api.sh
source $STELLA_COMMON/lib-sfx.sh
source $STELLA_COMMON/common-network.sh
source $STELLA_COMMON/common-boot.sh

# GATHER PLATFORM INFO ---------------------------------------------
__set_current_platform_info

# GATHER CURRENT APP INFO ---------------------------------------------
STELLA_APP_PROPERTIES_FILENAME="stella.properties"
STELLA_APP_NAME=

[ "$STELLA_APP_ROOT" == "" ] && STELLA_APP_ROOT="$STELLA_CURRENT_RUNNING_DIR"

_STELLA_APP_PROPERTIES_FILE="$(__select_app $STELLA_APP_ROOT)"
__get_all_properties $_STELLA_APP_PROPERTIES_FILE

[ "$STELLA_APP_NAME" == "" ] && STELLA_APP_NAME=stella

# APP PATH ---------------------------------------------
STELLA_APP_ROOT=$(__rel_to_abs_path "$STELLA_APP_ROOT" "$STELLA_CURRENT_RUNNING_DIR")

[ "$STELLA_APP_WORK_ROOT" == "" ] && STELLA_APP_WORK_ROOT="$STELLA_APP_ROOT/workspace"
STELLA_APP_WORK_ROOT=$(__rel_to_abs_path "$STELLA_APP_WORK_ROOT" "$STELLA_APP_ROOT")

[ "$STELLA_APP_CACHE_DIR" == "" ] && STELLA_APP_CACHE_DIR="$STELLA_APP_ROOT/cache"
STELLA_APP_CACHE_DIR=$(__rel_to_abs_path "$STELLA_APP_CACHE_DIR" "$STELLA_APP_ROOT")

STELLA_APP_TEMP_DIR="$STELLA_APP_WORK_ROOT/temp"
STELLA_APP_FEATURE_ROOT="$STELLA_APP_WORK_ROOT/feature_$STELLA_CURRENT_PLATFORM_SUFFIX/$STELLA_CURRENT_OS"
ASSETS_ROOT="$STELLA_APP_WORK_ROOT/assets"
ASSETS_REPOSITORY=$(__rel_to_abs_path "../assets_repository" "$STELLA_APP_WORK_ROOT")

# for internal features
STELLA_INTERNAL_WORK_ROOT=$STELLA_ROOT/workspace
STELLA_INTERNAL_FEATURE_ROOT=$STELLA_INTERNAL_WORK_ROOT/feature_$STELLA_CURRENT_PLATFORM_SUFFIX/$STELLA_CURRENT_OS
STELLA_INTERNAL_CACHE_DIR=$STELLA_ROOT/cache
STELLA_INTERNAL_TEMP_DIR=$STELLA_INTERNAL_WORK_ROOT/temp

STELLA_INTERNAL_TOOLSET_ROOT=$STELLA_INTERNAL_WORK_ROOT/toolset_$STELLA_CURRENT_PLATFORM_SUFFIX/$STELLA_CURRENT_OS

# current config env
# app env config has priority over stella config env
STELLA_ENV_FILE=
if [ -f "$STELLA_APP_ROOT/.stella-env" ]; then
	STELLA_ENV_FILE="$STELLA_APP_ROOT/.stella-env"
else
	STELLA_ENV_FILE="$STELLA_ROOT/.stella-env"
fi


# OTHERS ---------------------------------------------
FEATURE_LIST_ENABLED=
VERBOSE_MODE=0
STELLA_DEFAULT_NO_PROXY="localhost,127.0.0.1,localaddress,.localdomain.com"


# FEATURE LIST---------------------------------------------
__STELLA_FEATURE_LIST=
__STELLA_FEATURE_LIST_STABLE=
__STELLA_FEATURE_LIST_EXP=
for recipe in "$STELLA_FEATURE_RECIPE"/*.sh; do
	recipe=$(basename "$recipe")
	recipe=${recipe#feature_}
	recipe=${recipe%.sh}
	__STELLA_FEATURE_LIST_STABLE="$__STELLA_FEATURE_LIST_STABLE $recipe"
done
for recipe in "$STELLA_FEATURE_RECIPE_EXPERIMENTAL"/*.sh; do
	recipe=$(basename "$recipe")
	recipe=${recipe#feature_}
	recipe=${recipe%.sh}
	__STELLA_FEATURE_LIST_EXP="$__STELLA_FEATURE_LIST_EXP $recipe"
done
__STELLA_FEATURE_LIST="$__STELLA_FEATURE_LIST_STABLE $__STELLA_FEATURE_LIST_EXP"

# SYS PACKAGE --------------------------------------------
# list of available installable system package
[ "$STELLA_CURRENT_PLATFORM" == "darwin" ] && STELLA_SYS_PACKAGE_LIST="git brew x11 build-chain-standard sevenzip wget curl unzip cmake"
[ "$STELLA_CURRENT_PLATFORM" == "linux" ] && STELLA_SYS_PACKAGE_LIST="git build-chain-standard sevenzip wget curl unzip cmake"



# BUILD MODULE ---------------------------------------------
# Define linking mode.
# have an effect only for feature linked with __link_feature_libray (do not ovveride specific FORCE_STATIC or FORCE_DYNAMIC)
# DEFAULT | STATIC | DYNAMIC
__set_build_mode_default "LINK_MODE" "DEFAULT"
# these features will be picked from the system
# have an effect only for feature declared in FEAT_SOURCE_DEPENDENCIES, FEAT_BINARY_DEPENDENCIES or passed to __link_feature_libray
[ "$STELLA_CURRENT_PLATFORM" == "darwin" ] && STELLA_BUILD_DEP_FROM_SYSTEM_DEFAULT="python"
[ "$STELLA_CURRENT_PLATFORM" == "linux" ] && STELLA_BUILD_DEP_FROM_SYSTEM_DEFAULT="openssl python"
# parallelize build (except specificied unparallelized one)
# ON | OFF
__set_build_mode_default "PARALLELIZE" "ON"
# compiler optimization
__set_build_mode_default "OPTIMIZATION" "2"
# rellocatable shared libraries
# you will not enable to move from another system any binary (executable or shared libs) linked to stella shared libs
# everything will be sticked to your stella shared lib installation path
# this will affect rpath values (and install_name for darwin)
__set_build_mode_default "RELOCATE" "OFF"

# ARCH x86 x64
# By default we do not provide any build arch information
#__set_build_mode_default "ARCH" ""
# do not mix CPPFLAGS with CXXFLAGS and CFLAGS
__set_build_mode_default "MIX_CPP_C_FLAGS" "OFF"
# activate some usefull default linker flags
__set_build_mode_default "LINK_FLAGS_DEFAULT" "ON"

[ "$STELLA_CURRENT_OS" == "macos" ] && __set_build_mode_default MACOSX_DEPLOYMENT_TARGET "$(__get_macos_version)"

STELLA_BUILD_DEFAULT_TOOLSET=STANDARD


# . is current running directory
# $ORIGIN and @loader_path is directory of the file who wants to load a shared library
# NOTE : '@loader_path' does not work, you have to write '@loader_path/.'
# NOTE : $ORIGIN may have problem with cmake, see : http://www.cmake.org/pipermail/cmake/2008-January/019290.html
STELLA_BUILD_RPATH_DEFAULT=

# buid engine reset
__reset_build_env

# BINARY MODULE ---------------------------
# linked libs we do not want to tweak (change link to)
STELLA_BINARY_DEFAULT_LIB_IGNORED='^/System/Library|^/usr/lib|^/lib'


# API ---------------------------------------------
STELLA_API_COMMON_PUBLIC="get_active_path uncompress daemonize rel_to_abs_path is_abs argparse get_filename_from_string \
get_resource delete_resource update_resource revert_resource download_uncompress copy_folder_content_into del_folder \
get_key add_key del_key mercurial_project_version git_project_version get_stella_version \
make_sevenzip_sfx_bin make_targz_sfx_shell compress trim"
STELLA_API_API_PUBLIC="api_connect api_disconnect"
STELLA_API_APP_PUBLIC="get_app_property link_app get_data get_assets get_data_pack get_assets_pack delete_data delete_assets delete_data_pack delete_assets_pack update_data update_assets revert_data revert_assets update_data_pack update_assets_pack revert_data_pack revert_assets_pack get_feature get_features"
STELLA_API_FEATURE_PUBLIC="feature_info list_feature_version feature_remove feature_catalog_info feature_install feature_install_list feature_init list_active_features feature_reinit_installed feature_inspect"
STELLA_API_BINARY_PUBLIC="tweak_linked_lib get_rpath add_rpath check_rpath check_binary_file tweak_binary_file"
STELLA_API_BUILD_PUBLIC="toolset_info set_toolset start_build_session set_build_mode auto_build"
STELLA_API_PLATFORM_PUBLIC="python_major_version python_short_version sys_install sys_remove require"
STELLA_API_NETWORK_PUBLIC="proxy_tunnel enable_proxy disable_proxy no_proxy_for register_proxy register_no_proxy"
STELLA_API_BOOT_PUBLIC="boot_shell boot_cmd boot_script"

STELLA_API_RETURN_FUNCTION="python_major_version python_short_version list_feature_version get_active_path rel_to_abs_path trim is_abs mercurial_project_version git_project_version get_stella_version list_active_features get_filename_from_string get_key"
STELLA_API=__api_proxy


fi
