if [ ! "$_augeas_INCLUDED_" == "1" ]; then
_augeas_INCLUDED_=1



function feature_augeas() {
	FEAT_NAME=augeas

	FEAT_LIST_SCHEMA="1_5_0:source"
	FEAT_DEFAULT_VERSION=1_5_0
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"


}

function feature_augeas_1_5_0() {
	FEAT_VERSION=1_5_0


	FEAT_SOURCE_DEPENDENCIES="autotools-bundle#1 libxml2#2_9_1"
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=http://download.augeas.net/augeas-1.5.0.tar.gz
	FEAT_SOURCE_URL_FILENAME=augeas-1.5.0.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=feature_augeas_link
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/augtool
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}

function feature_augeas_link() {

	__link_feature_library "libxml2#2_9_1" "GET_FLAGS _libxml2 LIBS_NAME xml2 FORCE_INCLUDE_FOLDER include/libxml2"
	#export LIBXML_CFLAGS="$_libxml2_C_CXX_FLAGS $_libxml2_CPP_FLAGS"
	#export LIBXML_LIBS="$_libxml2_LINK_FLAGS"
	AUTO_INSTALL_CONF_FLAG_PREFIX="LIBXML_CFLAGS=\"$_libxml2_C_CXX_FLAGS $_libxml2_CPP_FLAGS\" LIBXML_LIBS=\"$_libxml2_LINK_FLAGS\""

}


function feature_augeas_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"

	__set_toolset "STANDARD"

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP"

	AUTO_INSTALL_CONF_FLAG_PREFIX=
	AUTO_INSTALL_CONF_FLAG_POSTFIX=
	AUTO_INSTALL_BUILD_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_POSTFIX=


	__feature_callback

	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR"

}


fi
