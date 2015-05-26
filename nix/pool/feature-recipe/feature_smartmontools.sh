if [ ! "$_SMARTMONTOOLS_INCLUDED_" == "1" ]; then 
_SMARTMONTOOLS_INCLUDED_=1



function feature_smartmontools() {
	FEAT_NAME=smartmontools
	FEAT_LIST_SCHEMA="6_3/source"
	FEAT_DEFAULT_VERSION=6_3
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_smartmontools_6_3() {
	FEAT_VERSION=6_3

	FEAT_SOURCE_URL=http://downloads.sourceforge.net/project/smartmontools/smartmontools/6.3/smartmontools-6.3.tar.gz
	FEAT_SOURCE_URL_FILENAME=smartmontools-6.3.tar.gz
	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_CALLBACK=

	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/sbin/smartctl
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/sbin
	FEAT_ENV_CALLBACK=
	
	FEAT_BUNDLE_ITEM=
}



function feature_smartmontools_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-build"
	
	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX=


	__auto_install "configure" "smartmontools" "$FEAT_SOURCE_URL_FILENAME" "$FEAT_SOURCE_URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "DEST_ERASE STRIP"
	

}


fi