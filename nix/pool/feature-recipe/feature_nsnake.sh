if [ ! "$_nsnake_INCLUDED_" = "1" ]; then
_nsnake_INCLUDED_=1


feature_nsnake() {
	FEAT_NAME=nsnake
	FEAT_LIST_SCHEMA="3_0_1:source"
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
	
	FEAT_DESC="Nsnake: The classic snake game with textual interface."
	FEAT_LINK="https://github.com/alexdantas/nSnake"
}


feature_nsnake_3_0_1() {
	FEAT_VERSION=3_0_1
	FEAT_SOURCE_DEPENDENCIES="ncurses#^6_0"
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=https://github.com/alexdantas/nSnake/archive/v3.0.1.tar.gz
	FEAT_SOURCE_URL_FILENAME=nsnake-v3.0.1.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=feature_nsnake_link
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/nsnake
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}


feature_nsnake_link() {
	__link_feature_library "ncurses#^6_0"
}


feature_nsnake_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"


	__set_toolset "STANDARD"


	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP"

	AUTO_INSTALL_CONF_FLAG_PREFIX=
	AUTO_INSTALL_CONF_FLAG_POSTFIX=
	AUTO_INSTALL_BUILD_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_POSTFIX=

	__feature_callback

	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR" "NO_CONFIG"

}



fi
