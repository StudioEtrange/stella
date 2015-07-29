if [ ! "$_GO_INCLUDED_" == "1" ]; then 
_GO_INCLUDED_=1


function feature_go() {

	FEAT_NAME=go
	FEAT_LIST_SCHEMA="1_4_2:source"
	FEAT_DEFAULT_VERSION=1_4_2
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function go_set_env() {
	GOROOT="$FEAT_INSTALL_ROOT"
	export 	GOROOT="$FEAT_INSTALL_ROOT"
}

function feature_go_1_4_2() {
	FEAT_VERSION=1_4_2

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=https://storage.googleapis.com/golang/go1.4.2.src.tar.gz
	FEAT_SOURCE_URL_FILENAME=go1.4.2.src.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK="go_set_env"

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/go
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
}

function feature_go_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"

	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX=

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$INSTALL_DIR" "DEST_ERASE STRIP"

	# __download_uncompress "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_FILENAME" "$INSTALL_DIR" "DEST_ERASE STRIP"
	
	
	# GOOS and GOARCH are selected with the current system
	#GOOS
	#GOARCH=amd64 or 386 or arm

	cd "$INSTALL_DIR"
	cd src

	# line below include tests which are too slow
	#./all.bash
	./make.bash

}


fi