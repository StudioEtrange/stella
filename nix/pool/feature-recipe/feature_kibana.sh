if [ ! "$_KIBANA_INCLUDED_" == "1" ]; then 
_KIBANA_INCLUDED_=1



function feature_kibana() {
	FEAT_NAME=kibana
	FEAT_LIST_SCHEMA="3_1_2/source 4_0_0/binary 4_0_1/binary"
	FEAT_DEFAULT_VERSION=4_0_0
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="binary"
}


function feature_kibana_3_1_2() {
	FEAT_VERSION=3_1_2

	FEAT_SOURCE_URL=https://download.elasticsearch.org/kibana/kibana/kibana-3.1.2.tar.gz
	FEAT_SOURCE_URL_FILENAME=kibana-3.1.2.tar.gz
	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_CALLBACK=
	
	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/config.js
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"
	FEAT_ENV_CALLBACK=

	FEAT_BUNDLE_ITEM=
}


function feature_kibana_4_0_0() {
	FEAT_VERSION=4_0_0

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_CALLBACK=
	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then 
		FEAT_BINARY_URL=https://download.elasticsearch.org/kibana/kibana/kibana-4.0.0-darwin-x64.tar.gz
		FEAT_BINARY_URL_FILENAME=kibana-4.0.0-darwin-x64.tar.gz
	fi

	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		FEAT_BINARY_URL=https://download.elasticsearch.org/kibana/kibana/kibana-4.0.0-linux-x64.tar.gz
		FEAT_BINARY_URL_FILENAME=kibana-4.0.0-linux-x64.tar.gz
	fi

	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/kibana
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
	FEAT_ENV_CALLBACK=
	
	FEAT_BUNDLE_ITEM=
}

function feature_kibana_4_0_1() {
	FEAT_VERSION=4_0_1

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_CALLBACK=
	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then 
		FEAT_BINARY_URL=https://download.elasticsearch.org/kibana/kibana/kibana-4.0.1-darwin-x64.tar.gz
		FEAT_BINARY_URL_FILENAME=kibana-4.0.1-darwin-x64.tar.gz
	fi

	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		FEAT_BINARY_URL=https://download.elasticsearch.org/kibana/kibana/kibana-4.0.1-linux-x64.tar.gz
		FEAT_BINARY_URL_FILENAME=kibana-4.0.1-linux-x64.tar.gz
	fi

	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/kibana
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

	FEAT_BUNDLE_ITEM=
}




function feature_kibana_install_binary() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR=
	BUILD_DIR=

	__download_uncompress "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_FILENAME" "$INSTALL_DIR" "DEST_ERASE STRIP"

}




fi