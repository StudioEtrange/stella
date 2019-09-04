if [ ! "$_vitetris_INCLUDED_" = "1" ]; then
_vitetris_INCLUDED_=1


feature_vitetris() {
	FEAT_NAME=vitetris
	FEAT_LIST_SCHEMA="0_58_0:source"
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
	
	FEAT_DESC="Classic multiplayer tetris for the terminal "
	FEAT_LINK="https://github.com/vicgeralds/vitetris/"
}


feature_vitetris_0_58_0() {
	FEAT_VERSION=0_58_0
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=https://github.com/vicgeralds/vitetris/archive/v0.58.0.tar.gz
	FEAT_SOURCE_URL_FILENAME=vitetris-v0.58.0.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/tetris
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}


feature_vitetris_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"

	__set_toolset "STANDARD"


	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP"

	AUTO_INSTALL_BUILD_FLAG_POSTFIX="INSTALL=install"

	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR" "NO_OUT_OF_TREE_BUILD"

}



fi
