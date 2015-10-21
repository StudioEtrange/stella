if [ ! "$_freeciv_INCLUDED_" == "1" ]; then 
_freeciv_INCLUDED_=1

# TODO
# dep : freetype sdl curl gettext
# to finish do not work

function feature_freeciv() {
	FEAT_NAME=freeciv
	FEAT_LIST_SCHEMA="2_5_1:source"
	FEAT_DEFAULT_VERSION=2_5_1
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_freeciv_2_5_1() {
	FEAT_VERSION=2_5_1
	
	FEAT_SOURCE_DEPENDENCIES="sdl#1_2_15 gettext#0_19_4 pkgconfig#0_29"
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=http://downloads.sourceforge.net/project/freeciv/Freeciv%202.5/2.5.1/freeciv-2.5.1.tar.bz2
	FEAT_SOURCE_URL_FILENAME=freeciv-2.5.1.tar.bz2
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=feature_freeciv_link	
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/freeciv-sdl
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/
	
}

function feature_freeciv_link() {
	__link_feature_library "sdl#1_2_15"
	__link_feature_library "gettext#0_19_4"
	

}



function feature_freeciv_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"
	
	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP"


	__set_toolset "STANDARD"
	

	AUTO_INSTALL_CONF_FLAG_PREFIX=
	AUTO_INSTALL_CONF_FLAG_POSTFIX=
	AUTO_INSTALL_BUILD_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_POSTFIX=

	__feature_callback

	
	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR" "SOURCE_KEEP"
	
	

}




fi