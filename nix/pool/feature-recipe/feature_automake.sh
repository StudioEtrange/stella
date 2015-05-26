if [ ! "$_AUTOMAKE_INCLUDED_" == "1" ]; then 
_AUTOMAKE_INCLUDED_=1


function feature_automake() {
	FEAT_NAME=automake
	FEAT_LIST_SCHEMA="1_14/source"
	FEAT_DEFAULT_VERSION=1_14
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_automake_1_14() {
	FEAT_VERSION=1_14

	FEAT_SOURCE_URL=http://ftp.gnu.org/gnu/automake/automake-1.14.tar.gz
	FEAT_SOURCE_URL_FILENAME=automake-1.14.tar.gz
	FEAT_SOURCE_CALLBACK=feature_automake_1_14_patch
	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_CALLBACK=


	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/automake
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
	FEAT_ENV_CALLBACK=
	
	FEAT_BUNDLE_ITEM=
}

function feature_automake_1_14_patch() {
	AUTO_INSTALL_FLAG_POSTFIX="--docdir=$INSTALL_DIR/share/doc/automake-1.14"
}

function feature_automake_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-build"
	
	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX=

	
	__feature_callback

	__auto_install "configure" "automake" "$FEAT_SOURCE_URL_FILENAME" "$FEAT_SOURCE_URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"
}

fi