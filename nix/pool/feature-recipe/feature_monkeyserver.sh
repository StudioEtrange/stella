if [ ! "$_monkeyserver_INCLUDED_" == "1" ]; then
_monkeyserver_INCLUDED_=1

# NOT FINISHED
# DO NOT WORK ON OSX
# https://plus.google.com/u/0/110391426075643497490/posts/UbxNrngiwE9
function feature_monkeyserver() {
	FEAT_NAME=monkeyserver

	FEAT_LIST_SCHEMA="1_6_9:source"
	FEAT_DEFAULT_VERSION=1_6_9
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_monkeyserver_1_6_9() {
	FEAT_VERSION=1_6_9

	FEAT_SOURCE_DEPENDENCIES="cmake:binary"
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=http://monkey-project.com/releases/1.6/monkey-1.6.9.tar.gz
	FEAT_SOURCE_URL_FILENAME=monkey-1.6.9.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/monkeyserver
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}

function feature_monkeyserver_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"

	__set_toolset "CMAKE"

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP"

	AUTO_INSTALL_CONF_FLAG_PREFIX=
	AUTO_INSTALL_CONF_FLAG_POSTFIX="-DWITH_UCLIB=ON -DWITH_MUSL=ON -DWITH_SYSTEM_MALLOC=ON"
	AUTO_INSTALL_BUILD_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_POSTFIX=

	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR" "NO_OUT_OF_TREE_BUILD"

}


fi
