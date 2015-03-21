if [ ! "$_GO_INCLUDED_" == "1" ]; then 
_GO_INCLUDED_=1


function feature_go() {

	FEAT_NAME=go
	FEAT_LIST_SCHEMA="1_4_2/source"
	FEAT_DEFAULT_VERSION=1_4_2
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_go_1_4_2() {

	FEAT_VERSION=1_4_2

	FEAT_SOURCE_URL=https://storage.googleapis.com/golang/go1.4.2.src.tar.gz
	FEAT_SOURCE_URL_FILENAME=go1.4.2.src.tar.gz
	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_CALLBACK=

	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/go
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
	FEAT_ENV=
	
	FEAT_BUNDLE_LIST=
}

function feature_go_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR=
	BUILD_DIR=


	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX=


	__download_uncompress "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_FILENAME" "$INSTALL_DIR" "DEST_ERASE STRIP"
	
	
	# GOOS and GOARCH are selected xith the current system
	#GOOS
	#GOARCH=amd64 or 386 or arm

	cd "$INSTALL_DIR"
	cd src

	# line below include tests which are too slow
	#./all.bash
	./make.bash

}


fi