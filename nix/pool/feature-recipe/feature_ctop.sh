if [ ! "$_ctop_INCLUDED_" = "1" ]; then
_ctop_INCLUDED_=1

# https://github.com/bcicen/ctop

# NOTE a ctop fork is working on swarm mode : https://github.com/sah4ez/ctop

feature_ctop() {
	FEAT_NAME=ctop
	FEAT_LIST_SCHEMA="0_7_2:binary 0_7_1:binary 0_6_1:binary"
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="binary"

	FEAT_DESC="Top-like interface for container metrics"
	FEAT_LINK="https://ctop.sh"
}


feature_ctop_0_7_2() {
	FEAT_VERSION=0_7_2
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		FEAT_BINARY_URL=https://github.com/bcicen/ctop/releases/download/v0.7.2/ctop-0.7.2-linux-amd64
		FEAT_BINARY_URL_FILENAME=ctop-0.7.2-linux-amd64
		FEAT_BINARY_URL_PROTOCOL=HTTP
	fi

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		FEAT_BINARY_URL=https://github.com/bcicen/ctop/releases/download/v0.7.2/ctop-0.7.2-darwin-amd64
		FEAT_BINARY_URL_FILENAME=ctop-0.7.2-darwin-amd64
		FEAT_BINARY_URL_PROTOCOL=HTTP
	fi


	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/ctop
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"

}

feature_ctop_0_7_1() {
	FEAT_VERSION=0_7_1
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		FEAT_BINARY_URL=https://github.com/bcicen/ctop/releases/download/v0.7.1/ctop-0.7.1-linux-amd64
		FEAT_BINARY_URL_FILENAME=ctop-0.7.1-linux-amd64
		FEAT_BINARY_URL_PROTOCOL=HTTP
	fi

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		FEAT_BINARY_URL=https://github.com/bcicen/ctop/releases/download/v0.7.1/ctop-0.7.1-darwin-amd64
		FEAT_BINARY_URL_FILENAME=ctop-0.7.1-darwin-amd64
		FEAT_BINARY_URL_PROTOCOL=HTTP
	fi


	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/ctop
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"

}

feature_ctop_0_6_1() {
	FEAT_VERSION=0_6_1
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		FEAT_BINARY_URL=https://github.com/bcicen/ctop/releases/download/v0.6.1/ctop-0.6.1-linux-amd64
		FEAT_BINARY_URL_FILENAME=ctop-0.6.1-linux-amd64
		FEAT_BINARY_URL_PROTOCOL=HTTP
	fi

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		FEAT_BINARY_URL=https://github.com/bcicen/ctop/releases/download/v0.6.1/ctop-0.6.1-darwin-amd64
		FEAT_BINARY_URL_FILENAME=ctop-0.6.1-darwin-amd64
		FEAT_BINARY_URL_PROTOCOL=HTTP
	fi


	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/ctop
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"

}


feature_ctop_install_binary() {
	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT"

	mv "$FEAT_INSTALL_ROOT/$FEAT_BINARY_URL_FILENAME" "$FEAT_INSTALL_ROOT/ctop"
	chmod +x $FEAT_INSTALL_ROOT/ctop
}


fi
