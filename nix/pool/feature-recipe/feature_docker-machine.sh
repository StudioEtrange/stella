if [ ! "$_DOCKERMACHINE_INCLUDED_" == "1" ]; then 
_DOCKERMACHINE_INCLUDED_=1



function feature_docker-machine() {
	FEAT_NAME=docker-machine
	FEAT_LIST_SCHEMA="0_1_0@x64/binary 0_1_0@x86/binary 0_2_0_rc3/binary"
	FEAT_DEFAULT_VERSION=0_1_0
	FEAT_DEFAULT_ARCH=x64
	FEAT_DEFAULT_FLAVOUR="binary"
}

function feature_docker-machine_0_1_0() {
	FEAT_VERSION=0_1_0

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_CALLBACK=	
	
	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		FEAT_BINARY_URL_x64=https://github.com/docker/machine/releases/download/v0.1.0/docker-machine_darwin-amd64
		FEAT_BINARY_URL_FILENAME_x64=docker-machine_darwin-amd64-0_1_0

		FEAT_BINARY_URL_x86=https://github.com/docker/machine/releases/download/v0.1.0/docker-machine_darwin-386
		FEAT_BINARY_URL_FILENAME_x86=docker-machine_darwin-386-0_1_0

	fi
	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		FEAT_BINARY_URL_x64=https://github.com/docker/machine/releases/download/v0.1.0/docker-machine_linux-amd64
		FEAT_BINARY_URL_FILENAME_x64=docker-machine_linux-amd64-0_1_0

		FEAT_BINARY_URL_x86=https://github.com/docker/machine/releases/download/v0.1.0/docker-machine_linux-386
		FEAT_BINARY_URL_FILENAME_x64=docker-machine_linux-386-0_1_0
	fi

	FEAT_BINARY_CALLBACK=

	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/docker-machine
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"
	FEAT_ENV=
	
	FEAT_BUNDLE_LIST=
}




function feature_docker-machine_0_2_0_rc3() {
	FEAT_VERSION=0_2_0_rc3

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_CALLBACK=	
	
	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		FEAT_BINARY_URL_x64=https://github.com/docker/machine/releases/download/v0.2.0-rc3/docker-machine_darwin-amd64
		FEAT_BINARY_URL_FILENAME_x64=docker-machine_darwin-amd64-0_2_0_rc3

		FEAT_BINARY_URL_x86=https://github.com/docker/machine/releases/download/v0.2.0-rc3/docker-machine_darwin-386
		FEAT_BINARY_URL_FILENAME_x86=docker-machine_darwin-386-0_2_0_rc3

	fi
	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		FEAT_BINARY_URL_x64=https://github.com/docker/machine/releases/download/v0.2.0-rc3/docker-machine_linux-amd64
		FEAT_BINARY_URL_FILENAME_x64=docker-machine_linux-amd64-0_2_0_rc3

		FEAT_BINARY_URL_x86=https://github.com/docker/machine/releases/download/v0.2.0-rc3/docker-machine_linux-386
		FEAT_BINARY_URL_FILENAME_x64=docker-machine_linux-386-0_2_0_rc3
	fi

	FEAT_BINARY_CALLBACK=

	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/docker-machine
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"
	FEAT_ENV=
	
	FEAT_BUNDLE_LIST=
}



function feature_docker-machine_install_binary() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR=
	BUILD_DIR=

	__download "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_FILENAME" "$INSTALL_DIR"
	mv $INSTALL_DIR/$FEAT_BINARY_URL_FILENAME $INSTALL_DIR/docker-machine
	chmod +x $INSTALL_DIR/docker-machine
}


fi
