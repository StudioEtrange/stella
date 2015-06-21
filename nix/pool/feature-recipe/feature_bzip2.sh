if [ ! "$_BZIP2_INCLUDED_" == "1" ]; then 
_BZIP2_INCLUDED_=1



function feature_bzip2() {
	FEAT_NAME=bzip2
	FEAT_LIST_SCHEMA="1_0_6:source"
	FEAT_DEFAULT_VERSION=1_0_6
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_bzip2_1_0_6() {
	FEAT_VERSION=1_0_6


	# do NOT depend on Boost.Build
	# Boost build is own embedded version of Boost.Build. If we do not want thaht, precise --with-bjam=<path> when building
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz
	FEAT_SOURCE_URL_FILENAME=bzip2-1.0.6.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/bzip2
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}



function feature_bzip2_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP"

	cd "$SRC_DIR"
	make
	make install PREFIX="$INSTALL_DIR"
  
    __del_folder "$SRC_DIR"

}


fi
