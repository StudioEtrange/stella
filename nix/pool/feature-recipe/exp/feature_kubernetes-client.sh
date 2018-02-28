if [ ! "$_kubernetesclient_INCLUDED_" = "1" ]; then
_kubernetesclient_INCLUDED_=1

# include kubectl

feature_kubernetes-client() {
	FEAT_NAME=kubernetes-client
	FEAT_LIST_SCHEMA="1_9_3:binary 1_8_0:binary 0_14_0:binary"
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="binary"
}

feature_kubernetes-client_1_9_3() {
	FEAT_VERSION=1_9_3
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		FEAT_BINARY_URL=https://storage.googleapis.com/kubernetes-release/release/v1.9.3/kubernetes-client-linux-amd64.tar.gz
		FEAT_BINARY_URL_FILENAME=kubernetes-client-linux-v1.9.3-amd64.tar.gz
		FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP

	fi
	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		FEAT_BINARY_URL=https://storage.googleapis.com/kubernetes-release/release/v1.9.3/kubernetes-client-darwin-amd64.tar.gz
		FEAT_BINARY_URL_FILENAME=kubernetes-client-darwin-v1.9.3-amd64.tar.gz
		FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP
	fi

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=


	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/client/bin/kubectl
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/client/bin

}

feature_kubernetes-client_1_8_0() {
	FEAT_VERSION=1_8_0
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		FEAT_BINARY_URL=https://storage.googleapis.com/kubernetes-release/release/v1.8.0/kubernetes-client-linux-amd64.tar.gz
		FEAT_BINARY_URL_FILENAME=kubernetes-client-linux-v1.8.0-amd64.tar.gz
		FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP

	fi
	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		FEAT_BINARY_URL=https://storage.googleapis.com/kubernetes-release/release/v1.8.0/kubernetes-client-darwin-amd64.tar.gz
		FEAT_BINARY_URL_FILENAME=kubernetes-client-darwin-v1.8.0-amd64.tar.gz
		FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP
	fi

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=


	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/client/bin/kubectl
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/client/bin

}


feature_kubernetes-client_0_14_0() {
	FEAT_VERSION=0_14_0
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		FEAT_BINARY_URL=https://storage.googleapis.com/kubernetes-release/release/v0.14.0/kubernetes-client-linux-amd64.tar.gz
		FEAT_BINARY_URL_FILENAME=kubernetes-client-linux-v0.14.0-amd64.tar.gz
		FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP

	fi
	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		FEAT_BINARY_URL=https://storage.googleapis.com/kubernetes-release/release/v0.14.0/kubernetes-client-darwin-amd64.tar.gz
		FEAT_BINARY_URL_FILENAME=kubernetes-client-darwin-v0.14.0-amd64.tar.gz
		FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP
	fi

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=


	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/client/bin/kubectl
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/client/bin

}



feature_kubernetes-client_install_binary() {
	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "STRIP FORCE_NAME $FEAT_BINARY_URL_FILENAME"
}


fi
