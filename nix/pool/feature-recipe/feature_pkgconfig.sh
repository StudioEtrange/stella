if [ ! "$_pkgconfig_INCLUDED_" == "1" ]; then 
_pkgconfig_INCLUDED_=1

# http://www.linuxfromscratch.org/lfs/view/development/chapter06/pkg-config.html
# https://github.com/Homebrew/homebrew/blob/master/Library/Formula/pkg-config.rb

function feature_pkgconfig() {
	FEAT_NAME=pkgconfig
	FEAT_LIST_SCHEMA="0_29:source"
	FEAT_DEFAULT_VERSION=0_29
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_pkgconfig_0_29() {
	FEAT_VERSION=0_29
	
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=http://pkgconfig.freedesktop.org/releases/pkg-config-0.29.tar.gz
	FEAT_SOURCE_URL_FILENAME=fpkg-config-0.29.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=	
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/pkg-config
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
	
}




function feature_pkgconfig_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"
	
	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP"


	__set_toolset "STANDARD"
	

	AUTO_INSTALL_CONF_FLAG_PREFIX=
	AUTO_INSTALL_CONF_FLAG_POSTFIX="--with-internal-glib --disable-host-tool --disable-debug"
	AUTO_INSTALL_BUILD_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_POSTFIX=

	# to build blib on darwin
	[ "$STELLA_CURRENT_PLATFORM" == "darwin" ] && STELLA_LINK_FLAGS="-framework Carbon $STELLA_LINK_FLAGS"

	
	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR" "NO_OUT_OF_TREE_BUILD"
	
	

}




fi