if [ ! "$_UCL_INCLUDED_" == "1" ]; then 
_UCL_INCLUDED_=1



function feature_ucl() {
	FEAT_NAME=ucl
	FEAT_LIST_SCHEMA="1_03/source"
	FEAT_DEFAULT_VERSION=1_03
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_ucl_1_03() {
	FEAT_VERSION=1_03

	FEAT_SOURCE_URL=http://www.oberhumer.com/opensource/ucl/download/ucl-1.03.tar.gz
	FEAT_SOURCE_URL_FILENAME=ucl-1.03.tar.gz
	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_CALLBACK=

	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/lib/libucl.a
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/lib
	FEAT_ENV_CALLBACK=
	
	FEAT_BUNDLE_ITEM=
}

function feature_ucl_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-build"

	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX=

	__auto_install "configure" "ucl" "$FEAT_SOURCE_URL_FILENAME" "$FEAT_SOURCE_URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "DEST_ERASE STRIP"

}



fi