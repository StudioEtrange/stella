if [ ! "$_vowpal_wabbit_INCLUDED_" == "1" ]; then
_vowpal_wabbit_INCLUDED_=1

# TODO : not finished

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
	FEAT_SOURCE_DEPENDENCIES="zlib#1_2_8 boost#1_61_0 openmpi#1_10_3 FORCE_ORIGIN_SYSTEM python"
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=https://github.com/JohnLangford/vowpal_wabbit/archive/8.2.0.tar.gz
	FEAT_SOURCE_URL_FILENAME=vowpal_wabbit-8.2.0.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=feature_vowpal_wabbit_link
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/vw
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}


function feature_vowpal_wabbit_link() {
	__link_feature_library "openmpi#1_10_3"
	__link_feature_library "zlib#1_2_8" "GET_FOLDER _zlib NO_SET_FLAGS LIBS_NAME z"
	__link_feature_library "boost#1_61_0" "NO_SET_FLAGS"
}

function feature_vowpal_wabbit_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"

	__set_toolset "STANDARD"

	# disable default OPTIMIZATION because build process of this feature manage it
	__set_build_mode "OPTIMIZATION" ""
	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP FORCE_NAME $FEAT_SOURCE_URL_FILENAME"

	__set_build_mode "DARWIN_STDLIB" "LIBCPP"

	__feature_callback

	AUTO_INSTALL_CONF_FLAG_PREFIX=
	#if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ];then
	#	AUTO_INSTALL_CONF_FLAG_POSTFIX="--enable-libc++ --disable-dependency-tracking --with-boost=$BOOST_ROOT"
	#fi
	#if [ "$STELLA_CURRENT_PLATFORM" == "linux" ];then
	# --with-zlib=DIR
	# --with-boost[=ARG]      use Boost library from a standard location
  #                         (ARG=yes), from the specified location (ARG=<path>),
  #                         or disable it (ARG=no) [ARG=yes]
  # --with-boost-libdir=LIB_DIR
  #                         Force given directory for boost libraries. Note that
  #                         this will override library path detection, so use
  #                         this parameter only if default library detection
  #                         fails and you know exactly where your boost
  #                         libraries are located.
	#

		AUTO_INSTALL_CONF_FLAG_POSTFIX="--disable-dependency-tracking --with-boost=$BOOST_ROOT --with-zlib=$_zlib_ROOT"
	#fi
	AUTO_INSTALL_BUILD_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_POSTFIX=

	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR" "SOURCE_KEEP NO_OUT_OF_TREE_BUILD POST_BUILD_STEP test install"

}


fi
