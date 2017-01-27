if [ ! "$_lightgbm_INCLUDED_" == "1" ]; then
_lightgbm_INCLUDED_=1

# https://github.com/Microsoft/LightGBM



function feature_lightgbm() {
	FEAT_NAME=lightgbm
	FEAT_LIST_SCHEMA="SNAPSHOT:source"
	FEAT_DEFAULT_VERSION=SNAPSHOT
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}



function feature_lightgbm_SNAPSHOT() {
	FEAT_VERSION=SNAPSHOT

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=https://github.com/Microsoft/LightGBM
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=GIT

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/lightgbm
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

	FEAT_GIT_TAG="master"

}




function feature_lightgbm_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"


	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "VERSION $FEAT_GIT_TAG"

	__set_toolset "CUSTOM" "COMPIL_FRONTEND clang-omp#3_9_0 CONFIG_TOOL cmake BUILD_TOOL make"

	__feature_callback

	AUTO_INSTALL_CONF_FLAG_PREFIX=
	AUTO_INSTALL_CONF_FLAG_POSTFIX=
	AUTO_INSTALL_BUILD_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_POSTFIX=

	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR" "SOURCE_KEEP"

	__copy_folder_content_into "$SRC_DIR" "$INSTALL_DIR" "*package"
	__copy_folder_content_into "$SRC_DIR" "$INSTALL_DIR" "examples"
	__copy_folder_content_into "$SRC_DIR" "$INSTALL_DIR" "docs"

	__del_folder "$SRC_DIR"

}


fi
