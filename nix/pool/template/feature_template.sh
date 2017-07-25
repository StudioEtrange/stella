if [ ! "$_TEMPLATE_INCLUDED_" = "1" ]; then
_TEMPLATE_INCLUDED_=1


feature_template() {
	FEAT_NAME=template
	FEAT_LIST_SCHEMA="1_0_0@x64:binary 1_0_0@x86:binary"
	FEAT_DEFAULT_ARCH=x64
	FEAT_DEFAULT_FLAVOUR="binary"

	FEAT_DESC="template is foo"
	FEAT_LINK="https://github.com/bar/template"
}



feature_template_1_0_0() {
	# if FEAT_ARCH (ie:FEAT_BINARY_URL_x86) is not not null, properties FOO_ARCH=BAR will be selected and setted as FOO=BAR (ie:FEAT_BINARY_URL)
	# if FOO_ARCH is empty, FOO will not be changed

	FEAT_VERSION=1_0_0

	# Dependencies
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES_x86=
	FEAT_BINARY_DEPENDENCIES_x64=

	# Properties for SOURCE flavour
	FEAT_SOURCE_URL="http://foo.com/template-1_0_0-src.zip"
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL="HTTP_ZIP"

	# Properties for BINARY flavour
	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=
	FEAT_BINARY_URL_x86="http://foo.com/bar"
	FEAT_BINARY_URL_FILENAME_x86="template-1_0_0-x86.zip"
	FEAT_BINARY_URL_PROTOCOL_x86="HTTP_ZIP"
	FEAT_BINARY_URL_x64="http://foo.com/bar"
	FEAT_BINARY_URL_FILENAME_x64="template-1_0_0-x86.zip"
	FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"

	# callback are list of functions
	# manual callback (with feature_callback)
	FEAT_SOURCE_CALLBACK=feature_template_1_0_0_source_callback
	FEAT_BINARY_CALLBACK=
	# automatic callback each time feature is initialized, to init env var
	FEAT_ENV_CALLBACK=feature_template_setenv

	# List of files to test if feature is installed
	FEAT_INSTALL_TEST=$FEAT_INSTALL_ROOT/bin/template
	# PATH to add to system PATH
	FEAT_SEARCH_PATH=$FEAT_INSTALL_ROOT/bin

}

feature_template_setenv()  {
	TEMPLATE_HOME=$FEAT_INSTALL_ROOT
	export TEMPLATE_HOME
}

feature_template_install_binary() {

	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "DEST_ERASE STRIP FORCE_NAME $FEAT_BINARY_URL_FILENAME"

	__feature_callback

}




# ---------------------------------------------------------------------------------------------------------------------------
feature_template_1_0_0_source_callback() {
	__link_feature_library "libxml2#2_9_1" "GET_FLAGS _libxml2 LIBS_NAME xml2 FORCE_INCLUDE_FOLDER include/libxml2"
	AUTO_INSTALL_CONF_FLAG_PREFIX="LIBXML_CFLAGS=\"$_libxml2_C_CXX_FLAGS $_libxml2_CPP_FLAGS\" LIBXML_LIBS=\"$_libxml2_LINK_FLAGS\""

}

feature_template_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"


	__set_toolset "STANDARD"

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "DEST_ERASE STRIP"

	__feature_callback

	__start_manual_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR"

	cd "$SRC_DIR"

	make -j$STELLA_NB_CPU
	make install && __del_folder $SRC_DIR

	__end_manual_build
}



feature_template_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"

	__set_toolset "STANDARD"

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "DEST_ERASE STRIP"

	__feature_callback
	__link_feature_library "zlib#1_2_8" "FORCE_DYNAMIC"

	__set_build_mode "OPTIMIZATION" "2"

	__start_manual_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR"

	cd "$SRC_DIR"

	make -j$STELLA_NB_CPU
	make install && __del_folder $SRC_DIR

	__inspect_and_fix_build "$INSTALL_DIR"

	__end_manual_build
}


feature_template_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"

	__set_toolset "STANDARD"
	__check_toolset "C++"

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP"

	__feature_callback

	AUTO_INSTALL_CONF_FLAG_PREFIX=
	AUTO_INSTALL_CONF_FLAG_POSTFIX=
	AUTO_INSTALL_BUILD_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_POSTFIX=


	__set_build_mode "OPTIMIZATION" "1"

	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR"

}




fi
