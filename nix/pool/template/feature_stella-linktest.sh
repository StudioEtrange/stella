if [ ! "$_stellalinktest_INCLUDED_" = "1" ]; then
_stellalinktest_INCLUDED_=1

# feature syntax :
#		name[#version][@arch][:flavour][/os_restriction][\os_exclusion]

feature_stella-linktest() {
	FEAT_NAME="stella-linktest"
	FEAT_LIST_SCHEMA="latest:source"
	FEAT_DEFAULT_FLAVOUR="source"

	FEAT_DESC="an internal feature to test if a library is available to be linked"
	FEAT_LINK=""
}




feature_stella-linktest_latest() {
	FEAT_VERSION="latest"

	# Dependencies
	FEAT_SOURCE_DEPENDENCIES="zlib#^1_2 FORCE_ORIGIN_SYSTEM fuse"
	FEAT_BINARY_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES_x86=
	FEAT_BINARY_DEPENDENCIES_x64=

	# For multiple FEAT_SOURCE_URL or FEAT_BINARY_URL, there is 1 example methods in gcc recipe

	# Properties for SOURCE flavour
	FEAT_SOURCE_URL="http://foo.com/stella-linktest-1_0_0-src.zip"
	FEAT_SOURCE_URL_FILENAME="stella-linktest-1_0_0-src.zip"
	FEAT_SOURCE_URL_PROTOCOL="HTTP_ZIP"

	# callback are list of functions
	# manual callback (with feature_callback)
	FEAT_SOURCE_CALLBACK="feature_stella-linktest_1_0_0_source_callback"
	# automatic callback each time feature is initialized, to init env var
	FEAT_ENV_CALLBACK="feature_stella-linktest_setenv"

	# List of files to test if feature is installed
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/bin/stella-linktest"
	# PATH to add to system PATH
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT/bin"
}




# ---------------------------------------------------------------------------------------------------------------------------
feature_stella-linktest_1_0_0_source_callback() {
	__link_feature_library "libxml2#2_9_1" "GET_FLAGS _libxml2 LIBS_NAME xml2 FORCE_INCLUDE_FOLDER include/libxml2"
	AUTO_INSTALL_CONF_FLAG_PREFIX="LIBXML_CFLAGS=\"$_libxml2_C_CXX_FLAGS $_libxml2_CPP_FLAGS\" LIBXML_LIBS=\"$_libxml2_LINK_FLAGS\""

	__link_feature_library "zlib#^1_2" "LIBS_NAME z"

	__link_feature_library "FORCE_ORIGIN_SYSTEM fuse" "USE_PKG_CONFIG"
}


feature_stella-linktest_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"

	__set_toolset "STANDARD"

	echo 'int main(void){return 0;}\n' > "$SRC_DIR/main.c"

	__feature_callback
	__link_feature_library "zlib#^1_2" "FORCE_DYNAMIC"


	__start_manual_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR"

	cd "$SRC_DIR"

	make -j$STELLA_NB_CPU
	make install && __del_folder "$SRC_DIR"

	__inspect_and_fix_build "$INSTALL_DIR"

	__end_manual_build
}








fi
