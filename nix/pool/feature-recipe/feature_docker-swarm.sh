if [ ! "$_DOCKERSWARM_INCLUDED_" == "1" ]; then 
_DOCKERSWARM_INCLUDED_=1


function feature_docker-swarm() {
	FEAT_NAME="docker-swarm"
	FEAT_LIST_SCHEMA="0_3_0:source"
	FEAT_DEFAULT_VERSION="0_3_0"
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}


function feature_docker-swarm_0_3_0() {
	FEAT_VERSION="0_3_0"
	FEAT_SOURCE_DEPENDENCIES="go-build-chain#1_4_2"
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL="https://github.com/docker/swarm/archive/v0.3.0.zip"
	FEAT_SOURCE_URL_FILENAME="docker-swarm-v0.3.0.zip"
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=
	
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/bin/swarm"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT/bin"

}


function feature_docker-swarm_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$FEAT_INSTALL_ROOT/src/swarm"
	BUILD_DIR=

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP FORCE_NAME $FEAT_SOURCE_URL_FILENAME"


	# get internal dependencies (in the same github)
	cd "$INSTALL_DIR"
	mkdir -p "$INSTALL_DIR/src/github.com/docker"
	ln -fs "$SRC_DIR" "$INSTALL_DIR/src/github.com/docker/swarm"

	# get all others dependencies
	cd "$SRC_DIR"
	cd Godeps
	GOPATH="$INSTALL_DIR" godep restore

	GOPATH="$INSTALL_DIR" go install swarm
}

fi
