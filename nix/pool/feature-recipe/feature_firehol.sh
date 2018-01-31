if [ ! "$_firehol_INCLUDED_" = "1" ]; then
_firehol_INCLUDED_=1

# https://firehol.org/
# https://github.com/firehol/firehol

# FireHOL, FireQOS, Link-Balancer, Update-Ipsets and VNetBuild are packaged as firehol
# this recipe will try to install what is it possible
# https://firehol.org/source-install/

# NOTE : FireHOL itself needs bash 4.x

feature_firehol() {
	FEAT_NAME=firehol
	[ "$STELLA_CURRENT_PLATFORM" = "linux" ] && FEAT_LIST_SCHEMA="3_1_5:source"
	[ "$STELLA_CURRENT_PLATFORM" = "darwin" ] && FEAT_LIST_SCHEMA=
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"

}



feature_firehol_3_1_5() {
	# if FEAT_ARCH (ie:FEAT_BINARY_URL_x86) is not not null, properties FOO_ARCH=BAR will be selected and setted as FOO=BAR (ie:FEAT_BINARY_URL)
	# if FOO_ARCH is empty, FOO will not be changed

	FEAT_VERSION=3_1_5

	# Dependencies
	FEAT_SOURCE_DEPENDENCIES="iprange#1_0_4"

	# Properties for SOURCE flavour
	FEAT_SOURCE_URL=https://github.com/firehol/firehol/releases/download/v3.1.5/firehol-3.1.5.tar.gz
	FEAT_SOURCE_URL_FILENAME=firehol-3.1.5.tar.gz
	FEAT_SOURCE_URL_PROTOCOL="HTTP_ZIP"

	# callback are list of functions
	# manual callback (with feature_callback)
	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	# automatic callback each time feature is initialized, to init env var
	FEAT_ENV_CALLBACK=

	# List of files to test if feature is installed
	FEAT_INSTALL_TEST=$FEAT_INSTALL_ROOT/sbin/firehol
	# PATH to add to system PATH
	FEAT_SEARCH_PATH=$FEAT_INSTALL_ROOT/sbin

}



feature_firehol_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"

	__set_toolset "STANDARD"

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP"

	__feature_callback

	AUTO_INSTALL_CONF_FLAG_PREFIX=
	type ipset &>/dev/null || AUTO_INSTALL_CONF_FLAG_POSTFIX="--disable-update-ipsets"
	AUTO_INSTALL_BUILD_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_POSTFIX=


	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR"

}




fi
