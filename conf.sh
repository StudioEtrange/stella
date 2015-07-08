if [ ! "$_STELLA_CONF_INCLUDED_" == "1" ]; then
_STELLA_CONF_INCLUDED_=1

_STELLA_CONF_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ "$STELLA_CURRENT_RUNNING_DIR" == "" ]; then
	#STELLA_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
	STELLA_CURRENT_RUNNING_DIR="$( cd "$( dirname "." )" && pwd )"
fi

# for I in $(seq 0 $(expr ${#BASH_SOURCE[@]} - 1) ); do
#         echo BASH_SOURCE\[$I\] ${BASH_SOURCE[$I]}
# done

# STELLA PATHS ---------------------------------------------
STELLA_ROOT="$_STELLA_CONF_CURRENT_FILE_DIR"
STELLA_COMMON="$STELLA_ROOT/nix/common"
STELLA_POOL="$STELLA_ROOT/nix/pool"
STELLA_BIN="$STELLA_ROOT/nix/bin"
STELLA_FEATURE_RECIPE="$STELLA_POOL/feature-recipe"
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

source $STELLA_COMMON/screenfetch-dev
source $STELLA_COMMON/platform.sh
source $STELLA_COMMON/common.sh
source $STELLA_COMMON/common-feature.sh
source $STELLA_COMMON/common-app.sh
source $STELLA_COMMON/common-build.sh
source $STELLA_COMMON/common-api.sh
source $STELLA_COMMON/make-sfx.sh
source $STELLA_COMMON/common-network.sh

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

[ "$STELLA_APP_WORK_ROOT" == "" ] && STELLA_APP_WORK_ROOT=$STELLA_APP_ROOT/workspace
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

# OTHERS ---------------------------------------------
FEATURE_LIST_ENABLED=
VERBOSE_MODE=0

# INTERNAL LIST---------------------------------------------
__STELLA_FEATURE_LIST="nodejs lftp foma boost-bcp bzip2 ant boost boost-build sevenzip goconfig-cli go-crosscompile-chain go-build-chain oracle-jdk smartmontools python zlib socat gnu-netcat maven spark sbt scala docker-compose docker-machine jq wget ninja cmake packer autotools-bundle perl gettext getopt ucl upx elasticsearch kibana nginx ngrok go pcre libtool m4 automake autoconf"

# API ---------------------------------------------
STELLA_API_COMMON_PUBLIC="get_active_path uncompress daemonize rel_to_abs_path is_abs argparse get_filename_from_string \
get_resource delete_resource update_resource revert_resource download_uncompress copy_folder_content_into del_folder \
get_key add_key del_key mercurial_project_version git_project_version get_stella_version \
make_sevenzip_sfx_bin make_targz_sfx_shell compress trim"
STELLA_API_API_PUBLIC="api_connect api_disconnect"
STELLA_API_APP_PUBLIC="get_app_property link_app get_data get_assets get_data_pack get_assets_pack delete_data delete_assets delete_data_pack delete_assets_pack update_data update_assets revert_data revert_assets update_data_pack update_assets_pack revert_data_pack revert_assets_pack get_feature get_features"
STELLA_API_FEATURE_PUBLIC="list_feature_version feature_remove feature_catalog_info feature_install feature_install_list feature_init list_active_features feature_reinit_installed feature_inspect"
STELLA_API_BUILD_PUBLIC="fix_rpath_darwin fix_linked_lib_darwin fix_dynamiclib_install_name_darwin fix_dynamiclib_install_name_darwin_by_rootname fix_dynamiclib_install_name_darwin_by_folder"
STELLA_API_PLATFORM_PUBLIC="require"

STELLA_API_RETURN_FUNCTION="list_feature_version get_active_path rel_to_abs_path trim is_abs mercurial_project_version git_project_version get_stella_version list_active_features get_filename_from_string get_key"
STELLA_API=__api_proxy


fi
