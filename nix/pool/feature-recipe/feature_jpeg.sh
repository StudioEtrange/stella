if [ ! "_JPEG_INCLUDED_" == "1" ]; then 
_JPEG_INCLUDED_=1


function feature_jpeg() {
	FEAT_NAME=jpeg
	FEAT_LIST_SCHEMA="9_0_0:source"
	FEAT_DEFAULT_VERSION=9_0_0
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_jpeg_9_0_0() {
	FEAT_VERSION=9_0_0

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=http://www.ijg.org/files/jpegsrc.v9.tar.gz
	FEAT_SOURCE_URL_FILENAME=jpegsrc.v9.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/lib/libjpeg.a
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}


function feature_jpeg_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"
	
	AUTO_INSTALL_CONF_FLAG_PREFIX=
	AUTO_INSTALL_CONF_FLAG_POSTFIX="--disable-dependency-tracking"
	AUTO_INSTALL_BUILD_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_POSTFIX=

	__feature_callback

	__auto_install "jpeg" "$FEAT_SOURCE_URL_FILENAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "$INSTALL_DIR" "CONFIG_TOOL configure BUILD_TOOL make"
	

}


fi
