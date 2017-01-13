if [ ! "$_xgboost_INCLUDED_" == "1" ]; then
_xgboost_INCLUDED_=1

# https://github.com/dmlc/xgboost



function feature_xgboost() {
	FEAT_NAME=xgboost
	FEAT_LIST_SCHEMA="0_60:source"
	FEAT_DEFAULT_VERSION=0_60
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_xgboost_0_60() {
	FEAT_VERSION=0_60


	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=https://github.com/dmlc/xgboost
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=GIT

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/xgboost
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"

	FEAT_GIT_TAG="v0.60"

}




function feature_xgboost_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"


	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "VERSION $FEAT_GIT_TAG"

	__set_toolset "CUSTOM" "COMPIL_FRONTEND clang-omp#3_9_0 CONFIG_TOOL cmake BUILD_TOOL make"

	__feature_callback

	AUTO_INSTALL_CONF_FLAG_PREFIX=
	AUTO_INSTALL_CONF_FLAG_POSTFIX=
	AUTO_INSTALL_BUILD_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_POSTFIX=

	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR" "NO_OUT_OF_TREE_BUILD SOURCE_KEEP NO_INSTALL"

	__copy_folder_content_into "$SRC_DIR" "$INSTALL_DIR"

	__del_folder "$INSTALL_DIR"/CMakeFiles

	__inspect_and_fix_build "$INSTALL_DIR"

	__del_folder "$SRC_DIR"

	local _ext="so"
	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		_ext="dylib"
	fi
	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		_ext="so"
	fi

	ln -s $INSTALL_DIR/liblibxgboost.$_ext $INSTALL_DIR/libxgboost.so
	mkdir $INSTALL_DIR/lib
	ln -s $INSTALL_DIR/liblibxgboost.$_ext $INSTALL_DIR/lib/libxgboost.so

}


fi
