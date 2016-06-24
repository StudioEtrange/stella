if [ ! "$_openmpi_INCLUDED_" == "1" ]; then
_openmpi_INCLUDED_=1

# https://www.open-mpi.org/
# see https://github.com/Homebrew/homebrew-core/blob/master/Formula/open-mpi.rb


# TODO not finished

function feature_openmpi() {
	FEAT_NAME=openmpi
	FEAT_LIST_SCHEMA="1_10_3:source"
	FEAT_DEFAULT_VERSION=1_10_3
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_openmpi_1_10_3() {
	FEAT_VERSION=1_10_3


	FEAT_SOURCE_DEPENDENCIES="libevent#2_0_22"
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=https://www.open-mpi.org/software/ompi/v1.10/downloads/openmpi-1.10.3.tar.gz
	FEAT_SOURCE_URL_FILENAME=openmpi-1.10.3.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=feature_openmpi_link
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/openmpi-server
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}


function feature_openmpi_link() {
  __link_feature_library "libevent" "GET_FOLDER _libevent NO_SET_FLAGS"
}

function feature_openmpi_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"


	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP"

	__set_toolset "AUTOTOOLS"

  __feature_callback

  AUTO_INSTALL_CONF_FLAG_PREFIX=
  AUTO_INSTALL_CONF_FLAG_POSTFIX="--enable-mpi-thread-multiple --disable-mpi-fortran disable-dependency-tracking \
      --disable-silent-rules \
      --with-sge \
      --with-libevent=$_libevent \
      --enable-ipv6"
  AUTO_INSTALL_BUILD_FLAG_PREFIX=
  AUTO_INSTALL_BUILD_FLAG_POSTFIX=

	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR"


}


fi
