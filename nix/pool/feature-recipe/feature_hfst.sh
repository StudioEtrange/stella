if [ ! "$_hfst_INCLUDED_" == "1" ]; then 
_hfst_INCLUDED_=1

#http://wiki.apertium.org/wiki/Hfst#Building_and_installing_HFST

function feature_hfst() {
	FEAT_NAME=hfst
	FEAT_LIST_SCHEMA="3_8_3:source"
	FEAT_DEFAULT_VERSION=3_8_3
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_hfst_3_8_3() {
	FEAT_VERSION=3_8_3

	FEAT_SOURCE_DEPENDENCIES="zlib#1_2_8"
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=http://sourceforge.net/projects/hfst/files/hfst/source/hfst-3.8.3.tar.gz
	FEAT_SOURCE_URL_FILENAME=hfst-3.8.3.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=feature_hfst_link
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/lib/libhfst.a
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
}


function feature_hfst_link() {
	#__link_feature_library "icu4c#55_1"
	__link_feature_library "zlib#1_2_8"
}


function feature_hfst_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"
	
	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP"


	AUTO_INSTALL_CONF_FLAG_PREFIX=
	AUTO_INSTALL_CONF_FLAG_POSTFIX="--disable-dependency-tracking --enable-all-tools \
									--enable-proc --enable-lexc --enable-tagger \
									--with-unicode-handler=hfst \
									--enable-shared --enable-static"
	# --with-unicode-handler=icu
	#configure: error: ICU not yet implemented
	AUTO_INSTALL_BUILD_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_POSTFIX=

	__feature_callback

	# Makefile do not create bin directory
	mkdir -p "$FEAT_INSTALL_ROOT/bin"

	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR" "NO_OUT_OF_TREE_BUILD CONFIG_TOOL configure BUILD_TOOL make"

}


fi