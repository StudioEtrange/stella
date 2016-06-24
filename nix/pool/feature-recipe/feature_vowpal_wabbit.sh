if [ ! "$_vowpal_wabbit_INCLUDED_" == "1" ]; then
_vowpal_wabbit_INCLUDED_=1


function feature_vowpal_wabbit() {
	FEAT_NAME=vowpal_wabbit

	FEAT_LIST_SCHEMA="8_2_0:source"
	FEAT_DEFAULT_VERSION=8_2_0
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"


}

function feature_vowpal_wabbit_8_2_0() {
	FEAT_VERSION=8_2_0

	#  boost +no_single +no_static +openmpi +python27
	FEAT_SOURCE_DEPENDENCIES="boost"
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=https://github.com/JohnLangford/vowpal_wabbit/archive/8.2.0.tar.gz
	FEAT_SOURCE_URL_FILENAME=vowpal_wabbit-8.2.0.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/vw
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}


function feature_vowpal_wabbit_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"

	__set_toolset "STANDARD"

	__set_build_mode "OPTIMIZATION" ""
	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP FORCE_NAME $FEAT_SOURCE_URL_FILENAME"


	AUTO_INSTALL_CONF_FLAG_PREFIX=
	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ];then
		AUTO_INSTALL_CONF_FLAG_POSTFIX="--enable-libc++ --disable-dependency-tracking --with-boost=$BOOST_ROOT"
	fi
	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ];then
		AUTO_INSTALL_CONF_FLAG_POSTFIX="--disable-dependency-tracking --with-boost=$BOOST_ROOT"
	fi
	AUTO_INSTALL_BUILD_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_POSTFIX=

	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR" "NO_OUT_OF_TREE_BUILD POST_BUILD_STEP test install"

}


fi
