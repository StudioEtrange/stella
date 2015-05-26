if [ ! "$_DOCKERCOMPOSE_INCLUDED_" == "1" ]; then 
_DOCKERCOMPOSE_INCLUDED_=1



function feature_docker-compose() {
	FEAT_NAME=docker-compose
	FEAT_LIST_SCHEMA="1_1_0@x64/binary"
	FEAT_DEFAULT_VERSION=1_1_0
	FEAT_DEFAULT_ARCH=x64
	FEAT_DEFAULT_FLAVOUR="binary"
}

function feature_docker-compose_1_1_0() {
	FEAT_VERSION=1_1_0

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_CALLBACK=	
	
	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		FEAT_BINARY_URL_x64=https://github.com/docker/compose/releases/download/1.1.0/docker-compose-Darwin-x86_64
		FEAT_BINARY_URL_FILENAME_x64=docker-compose-Darwin-x86_64-1_1_0

		FEAT_BINARY_URL_x86=
		FEAT_BINARY_URL_FILENAME_x86=

	fi
	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		FEAT_BINARY_URL_x64=https://github.com/docker/compose/releases/download/1.1.0/docker-compose-Linux-x86_64
		FEAT_BINARY_URL_FILENAME_x64=docker-compose-Linux-x86_64-1_1_0

		FEAT_BINARY_URL_x86=
		FEAT_BINARY_URL_FILENAME_x86=
	fi

	FEAT_BINARY_CALLBACK=

	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/docker-compose
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"
	FEAT_ENV_CALLBACK=
	
	FEAT_BUNDLE_ITEM=
}





function feature_docker-compose_install_binary() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR=
	BUILD_DIR=

	__download "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_FILENAME" "$INSTALL_DIR"
	mv $INSTALL_DIR/$FEAT_BINARY_URL_FILENAME $INSTALL_DIR/docker-compose
	chmod +x $INSTALL_DIR/docker-compose
}


fi
