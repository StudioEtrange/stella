# shellcheck shell=bash
# shellcheck disable=SC2034
if [ ! "$_bindfs_INCLUDED_" = "1" ]; then
_bindfs_INCLUDED_=1

# NOTE : require fuse
# 			apt-get install libfuse-dev


feature_bindfs() {
	FEAT_NAME=bindfs

	FEAT_LIST_SCHEMA="1_14_1:source 1_13_11:source 1_13_10:source"
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"


	FEAT_DESC="Mount a directory elsewhere with changed permissions"
	FEAT_LINK="https://bindfs.org"
}



feature_bindfs_1_14_1() {
	FEAT_VERSION="1_14_1"


	FEAT_SOURCE_DEPENDENCIES="FORCE_ORIGIN_SYSTEM fuse"

	FEAT_SOURCE_URL="https://github.com/mpartel/bindfs/archive/1.14.1.tar.gz"
	FEAT_SOURCE_URL_FILENAME="bindfs-1.14.1.tar.gz"
	FEAT_SOURCE_URL_PROTOCOL="HTTP_ZIP"

	FEAT_SOURCE_CALLBACK="feature_bindfs_link"

	FEAT_TEST="bindfs"
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/bin/$FEAT_TEST"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT/bin"

}


feature_bindfs_1_13_11() {
	FEAT_VERSION="1_13_11"


	FEAT_SOURCE_DEPENDENCIES="FORCE_ORIGIN_SYSTEM fuse"

	FEAT_SOURCE_URL="https://github.com/mpartel/bindfs/archive/1.13.11.tar.gz"
	FEAT_SOURCE_URL_FILENAME="bindfs-1.13.11.tar.gz"
	FEAT_SOURCE_URL_PROTOCOL="HTTP_ZIP"

	FEAT_SOURCE_CALLBACK="feature_bindfs_link"

	FEAT_TEST="bindfs"
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/bin/$FEAT_TEST"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT/bin"

}

feature_bindfs_1_13_10() {
	FEAT_VERSION="1_13_10"


	FEAT_SOURCE_DEPENDENCIES="FORCE_ORIGIN_SYSTEM fuse"

	FEAT_SOURCE_URL="https://github.com/mpartel/bindfs/archive/1.13.10.tar.gz"
	FEAT_SOURCE_URL_FILENAME="bindfs-1.13.10.tar.gz"
	FEAT_SOURCE_URL_PROTOCOL="HTTP_ZIP"

	FEAT_SOURCE_CALLBACK="feature_bindfs_link"

	FEAT_TEST="bindfs"
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/bin/$FEAT_TEST"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT/bin"

}


feature_bindfs_link() {
	__link_feature_library "FORCE_ORIGIN_SYSTEM fuse" "USE_PKG_CONFIG"
}

feature_bindfs_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"

	__set_toolset "STANDARD"
	__add_toolset "autotools"

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP FORCE_NAME $FEAT_SOURCE_URL_FILENAME"

	__feature_callback


	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR" "NO_OUT_OF_TREE_BUILD AUTOTOOLS autogen"


}


fi
