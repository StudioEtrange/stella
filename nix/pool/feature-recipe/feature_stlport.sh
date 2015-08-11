if [ ! "$_STLPORT_INCLUDED_" == "1" ]; then 
_STLPORT_INCLUDED_=1

function feature_stlport() {

	FEAT_NAME=stlport
	FEAT_LIST_SCHEMA="2_7_9:source"
	FEAT_DEFAULT_VERSION=2_7_9
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_stlport_2_7_9() {
	FEAT_VERSION=2_7_9
	
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=https://www.stlport.org/ftp/stlport/2.7.9/Python-2.7.9.tgz
	FEAT_SOURCE_URL_FILENAME=Python-2.7.9.tgz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=feature_stlport_link
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/stlport
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}



function feature_stlport_link() {
	__link_feature_library "zlib#1_2_8" "z"
	__link_feature_library "FORCE_ORIGIN_STELLA openssl#1_0_2d"
}


function feature_stlport_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"

	# AUTO_INSTALL_FLAG_POSTFIX="--disable-dependency-tracking \
 #                          --enable-utf8 \
 #							--enable-ipv6"
	#--with-ensurepip=install # build pip from pip source included into stlport source BUT need openssl

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP"


	__feature_callback


	AUTO_INSTALL_CONF_FLAG_PREFIX=
	AUTO_INSTALL_CONF_FLAG_POSTFIX="--disable-dependency-tracking \
									--enable-utf8 \
									--enable-shared"
	AUTO_INSTALL_BUILD_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_POSTFIX=

	# fix min macos version, information needed for building stlport
	# TODO
	[ "$STELLA_CURRENT_OS" == "macos" ] && __set_build_mode MACOSX_DEPLOYMENT_TARGET $(__get_macos_version)

	__auto_build "$FEAT_NAME" "$INSTALL_DIR" "NO_OUT_OF_TREE_BUILD CONFIG_TOOL configure BUILD_TOOL make"

	# install last pip/setuptools
	__get_resource "get-pip" "https://bootstrap.pypa.io/get-pip.py" "HTTP" "$FEAT_INSTALL_ROOT/pip"
	cd "$FEAT_INSTALL_ROOT/pip"
	"$FEAT_INSTALL_ROOT/bin/stlport" get-pip.py
	rm -Rf "$FEAT_INSTALL_ROOT/pip"

}



fi