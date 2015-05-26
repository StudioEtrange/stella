if [ ! "$_ZLIB_INCLUDED_" == "1" ]; then 
_ZLIB_INCLUDED_=1



function feature_zlib() {

	FEAT_NAME=zlib
	FEAT_LIST_SCHEMA="1_2_8/source"
	FEAT_DEFAULT_VERSION=1_2_8
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_zlib_1_2_8() {

	FEAT_VERSION=1_2_8

	FEAT_SOURCE_URL=http://zlib.net/zlib-1.2.8.tar.gz
	FEAT_SOURCE_URL_FILENAME=zlib-1.2.8.tar.gz
	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_CALLBACK=

	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/lib/libz.a
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/lib
	FEAT_ENV_CALLBACK=
	
	FEAT_BUNDLE_ITEM=
}

function feature_zlib_install_source() {
	# out of tree build do not work
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"
	BUILD_DIR=""

	
	AUTO_INSTALL_FLAG_PREFIX=
	# Note : this will build shared AND static
	AUTO_INSTALL_FLAG_POSTFIX="--shared"

	__auto_install "configure" "zlib" "$FEAT_SOURCE_URL_FILENAME" "$FEAT_SOURCE_URL" "$SRC_DIR" "$SRC_DIR" "$INSTALL_DIR" "DEST_ERASE STRIP"

}



fi