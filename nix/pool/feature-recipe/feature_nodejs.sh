if [ ! "$_NODEJS_INCLUDED_" == "1" ]; then 
_NODEJS_INCLUDED_=1



function feature_nodejs() {
	FEAT_NAME=nodejs
	FEAT_LIST_SCHEMA="0_12_6@x64:binary 0_12_6@x86:binary 0_10_31@x64:binary 0_10_31@x86:binary"
	FEAT_DEFAULT_VERSION=0_12_6
	FEAT_DEFAULT_ARCH=x64
	FEAT_DEFAULT_FLAVOUR="binary"
}


function feature_nodejs_0_10_31() {
	FEAT_VERSION=0_10_31

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		FEAT_BINARY_URL_x86=https://nodejs.org/dist/v0.10.31/node-v0.10.31-darwin-x86.tar.gz
		FEAT_BINARY_URL_FILENAME_x86=node-v0.10.31-darwin-x86.tar.gz
		FEAT_BINARY_URL_PROTOCOL_x86=HTTP_ZIP

		FEAT_BINARY_URL_x64=https://nodejs.org/dist/v0.10.31/node-v0.10.31-darwin-x64.tar.gz
		FEAT_BINARY_URL_FILENAME_x64=node-v0.10.31-darwin-x64.tar.gz
		FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP
	fi

	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		FEAT_BINARY_URL_x86=https://nodejs.org/dist/v0.10.31/node-v0.10.31-linux-x86.tar.gz
		FEAT_BINARY_URL_FILENAME_x86=node-v0.10.31-linux-x86.tar.gz
		FEAT_BINARY_URL_PROTOCOL_x86=HTTP_ZIP

		FEAT_BINARY_URL_x64=https://nodejs.org/dist/v0.10.31/node-v0.10.31-linux-x64.tar.gz
		FEAT_BINARY_URL_FILENAME_x64=node-v0.10.31-linux-x64.tar.gz
		FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP
	fi

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=


	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/node
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}

function feature_nodejs_0_12_6() {
	FEAT_VERSION=0_12_6

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		FEAT_BINARY_URL_x86=https://nodejs.org/dist/v0.12.6/node-v0.12.6-darwin-x86.tar.gz
		FEAT_BINARY_URL_FILENAME_x86=node-v0.12.6-darwin-x86.tar.gz
		FEAT_BINARY_URL_PROTOCOL_x86=HTTP_ZIP

		FEAT_BINARY_URL_x64=https://nodejs.org/dist/v0.12.6/node-v0.12.6-darwin-x64.tar.gz
		FEAT_BINARY_URL_FILENAME_x64=node-v0.12.6-darwin-x64.tar.gz
		FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP
	fi

	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		FEAT_BINARY_URL_x86=https://nodejs.org/dist/v0.12.6/node-v0.12.6-linux-x86.tar.gz
		FEAT_BINARY_URL_FILENAME_x86=node-v0.12.6-linux-x86.tar.gz
		FEAT_BINARY_URL_PROTOCOL_x86=HTTP_ZIP

		FEAT_BINARY_URL_x64=https://nodejs.org/dist/v0.12.6/node-v0.12.6-linux-x64.tar.gz
		FEAT_BINARY_URL_FILENAME_x64=node-v0.12.6-linux-x64.tar.gz
		FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP
	fi

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=


	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/node
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}

function feature_nodejs_install_binary() {
	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "DEST_ERASE STRIP"

}


fi
