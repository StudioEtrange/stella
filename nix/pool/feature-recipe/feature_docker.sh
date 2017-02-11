if [ ! "$_DOCKER_INCLUDED_" == "1" ]; then
_DOCKER_INCLUDED_=1



# docker have a lof ot dependencies and OS specific stuff
# consider to install it from your OS system package manager or by the provided method here http://docs.docker.com/ OR the install script here https://get.docker.com/

# depending of the supporting state of your current OS,
# this recipe will install a docker binary which will be a server AND a client, or just a client, depending of your OS

# this recipe is based on https://docs.docker.com/engine/installation/binaries/

feature_docker() {
	FEAT_NAME=docker
	FEAT_LIST_SCHEMA="1_12_6:binary 1_8_1:binary 1_9_1:binary 1_10_3:binary 1_11_1:binary"
	FEAT_DEFAULT_VERSION=1_12_6
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="binary"
}



feature_docker_1_12_6() {
	FEAT_VERSION=1_12_6

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		FEAT_BINARY_URL=https://get.docker.com/builds/Darwin/x86_64/docker-1.12.6.tgz
		FEAT_BINARY_URL_FILENAME=docker-client-1.12.6-darwin.tgz
	fi

	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		FEAT_BINARY_URL=https://get.docker.com/builds/Linux/x86_64/docker-1.12.6.tgz
		FEAT_BINARY_URL_FILENAME=docker-1.12.6-linux.tgz
	fi
	FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=


	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/docker
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"

}


feature_docker_1_11_1() {
	FEAT_VERSION=1_11_1

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		FEAT_BINARY_URL=https://get.docker.com/builds/Darwin/x86_64/docker-1.11.1.tgz
		FEAT_BINARY_URL_FILENAME=docker-client-1.11.1-darwin.tgz
	fi

	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		FEAT_BINARY_URL=https://get.docker.com/builds/Linux/x86_64/docker-1.11.1.tgz
		FEAT_BINARY_URL_FILENAME=docker-1.11.1-linux.tgz
	fi
	FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=


	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/docker
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"

}


feature_docker_1_10_3() {
	FEAT_VERSION=1_10_3

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		FEAT_BINARY_URL=https://get.docker.com/builds/Darwin/x86_64/docker-1.10.3
		FEAT_BINARY_URL_FILENAME=docker-client-1.10.3-darwin
	fi

	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		FEAT_BINARY_URL=https://get.docker.com/builds/Linux/x86_64/docker-1.10.3
		FEAT_BINARY_URL_FILENAME=docker-1.10.3-linux
	fi
	FEAT_BINARY_URL_PROTOCOL=HTTP

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=


	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/docker
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"

}

feature_docker_1_9_1() {
	FEAT_VERSION=1_9_1

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		FEAT_BINARY_URL=https://get.docker.com/builds/Darwin/x86_64/docker-1.9.1
		FEAT_BINARY_URL_FILENAME=docker-client-1.9.1-darwin
	fi

	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		FEAT_BINARY_URL=https://get.docker.com/builds/Linux/x86_64/docker-1.9.1
		FEAT_BINARY_URL_FILENAME=docker-1.9.1-linux
	fi
	FEAT_BINARY_URL_PROTOCOL=HTTP

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=


	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/docker
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"

}

feature_docker_1_8_1() {
	FEAT_VERSION=1_8_1

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		FEAT_BINARY_URL=https://get.docker.com/builds/Darwin/x86_64/docker-1.8.1
		FEAT_BINARY_URL_FILENAME=docker-client-1.8.1-darwin
	fi

	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		FEAT_BINARY_URL=https://get.docker.com/builds/Linux/x86_64/docker-1.8.1
		FEAT_BINARY_URL_FILENAME=docker-1.8.1-linux
	fi
	FEAT_BINARY_URL_PROTOCOL=HTTP

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=


	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/docker
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"

}

feature_docker_install_binary() {
	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "STRIP DEST_ERASE FORCE_NAME $FEAT_BINARY_URL_FILENAME"
	[ "$FEAT_BINARY_URL_PROTOCOL" == "HTTP" ] && mv "$FEAT_INSTALL_ROOT"/"$FEAT_BINARY_URL_FILENAME" "$FEAT_INSTALL_ROOT"/docker

	chmod +x "$FEAT_INSTALL_ROOT"/docker
	[ "$STELLA_CURRENT_PLATFORM" == "darwin" ] && echo " ** On darwin, docker is in client mode only"

	echo " ** Consider create a docker group, and add your user to this group"
}


fi
