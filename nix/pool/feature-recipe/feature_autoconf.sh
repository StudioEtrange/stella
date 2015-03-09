if [ ! "$_AUTOCONF_INCLUDED_" == "1" ]; then 
_AUTOCONF_INCLUDED_=1


function feature_autoconf() {
	FEAT_NAME=autoconf
	FEAT_LIST_SCHEMA="2_69/source"
	FEAT_DEFAULT_VERSION=2_69
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_autoconf_2_69() {
	FEAT_VERSION=2_69

	FEAT_SOURCE_URL=http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
	FEAT_SOURCE_URL_FILENAME=autoconf-2.69.tar.gz
	FEAT_SOURCE_CALLBACK=feature_autoconf_2_69_patch
	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_CALLBACK=

	# TODO NEED : perl 5.6 and M4
	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/autoconf
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

	FEAT_BUNDLE_LIST=
}

function feature_autoconf_2_69_patch() {
	#TODO : really need this ?
	#AUTO_INSTALL_FLAG_POSTFIX="--docdir=$INSTALL_DIR/share/doc/automake-1.14"
	AUTO_INSTALL_FLAG_POSTFIX=
}

function feature_autoconf_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-build"
	
	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX=

	
	__feature_apply_source_callback

	__auto_install "configure" "autoconf" "$FEAT_SOURCE_URL_FILENAME" "$FEAT_SOURCE_URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"
}

fi