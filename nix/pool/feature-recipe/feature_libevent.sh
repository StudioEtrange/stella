if [ ! "$_libevent_INCLUDED_" == "1" ]; then
_libevent_INCLUDED_=1

# TODO not finished

function feature_libevent() {
	FEAT_NAME=libevent
	FEAT_LIST_SCHEMA="2_0_22:source"
	FEAT_DEFAULT_VERSION=2_0_22
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_libevent_2_0_22() {
	FEAT_VERSION=2_0_22


	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=https://github.com/libevent/libevent/releases/download/release-2.0.22-stable/libevent-2.0.22-stable.tar.gz
	FEAT_SOURCE_URL_FILENAME=libevent-2.0.22-stable.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/libevent-server
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}


function feature_libevent_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"


	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP"

	__set_toolset "STANDARD"

  __feature_callback

  AUTO_INSTALL_CONF_FLAG_PREFIX=
  AUTO_INSTALL_CONF_FLAG_POSTFIX="--disable-dependency-tracking --disable-debug-mode"
  AUTO_INSTALL_BUILD_FLAG_PREFIX=
  AUTO_INSTALL_BUILD_FLAG_POSTFIX=

	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR"


}


fi
