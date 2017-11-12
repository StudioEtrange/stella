if [ ! "$_GO_INCLUDED_" = "1" ]; then
_GO_INCLUDED_=1


feature_go() {

	FEAT_NAME=go
	FEAT_LIST_SCHEMA="1_9_2:binary 1_8_1:binary 1_6_3:binary 1_6_3:source 1_4_2:source 1_4_2:binary 1_4_3:source 1_4_3:binary 1_5_3:source 1_5_3:binary"
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="binary"
}

feature_go_set_env() {
	GOROOT="$FEAT_INSTALL_ROOT"
	export GOROOT="$FEAT_INSTALL_ROOT"
}


feature_go_1_9_2() {
	FEAT_VERSION=1_9_2

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=


	FEAT_SOURCE_URL=https://redirector.gvt1.com/edgedl/go/go1.9.2.src.tar.gz
	FEAT_SOURCE_URL_FILENAME=go1.9.2.src.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		FEAT_BINARY_URL=https://redirector.gvt1.com/edgedl/go/go1.9.2.darwin-amd64.tar.gz
		FEAT_BINARY_URL_FILENAME=go1.9.2.darwin-amd64.tar.gz
		FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP
	fi

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		FEAT_BINARY_URL=https://redirector.gvt1.com/edgedl/go/go1.9.2.linux-amd64.tar.gz
		FEAT_BINARY_URL_FILENAME=go1.9.2.linux-amd64.tar.gz
		FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP
	fi

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK="feature_go_set_env"

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/go
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
}


feature_go_1_8_1() {
	FEAT_VERSION=1_8_1

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=


	FEAT_SOURCE_URL=https://storage.googleapis.com/golang/go1.8.1.src.tar.gz
	FEAT_SOURCE_URL_FILENAME=go1.8.1.src.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		FEAT_BINARY_URL=https://storage.googleapis.com/golang/go1.8.1.darwin-amd64.tar.gz
		FEAT_BINARY_URL_FILENAME=go1.8.1.darwin-amd64.tar.gz
		FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP
	fi

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		FEAT_BINARY_URL=https://storage.googleapis.com/golang/go1.8.1.linux-amd64.tar.gz
		FEAT_BINARY_URL_FILENAME=go1.8.1.linux-amd64.tar.gz
		FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP
	fi

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK="feature_go_set_env"

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/go
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
}

feature_go_1_6_3() {
	FEAT_VERSION=1_6_3

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=


	FEAT_SOURCE_URL=https://storage.googleapis.com/golang/go1.6.3.src.tar.gz
	FEAT_SOURCE_URL_FILENAME=go1.6.3.src.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		FEAT_BINARY_URL=https://storage.googleapis.com/golang/go1.6.3.darwin-amd64.tar.gz
		FEAT_BINARY_URL_FILENAME=go1.6.3.darwin-amd64.tar.gz
		FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP
	fi

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		FEAT_BINARY_URL=https://storage.googleapis.com/golang/go1.6.3.linux-amd64.tar.gz
		FEAT_BINARY_URL_FILENAME=go1.6.3.linux-amd64.tar.gz
		FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP
	fi

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK="feature_go_set_env"

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/go
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
}

feature_go_1_5_3() {
	FEAT_VERSION=1_5_3

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	# TODO : Go 1.5 needs go 1.4 to build
	FEAT_SOURCE_URL=https://storage.googleapis.com/golang/go1.5.3.src.tar.gz
	FEAT_SOURCE_URL_FILENAME=go1.5.3.src.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		FEAT_BINARY_URL=https://storage.googleapis.com/golang/go1.5.3.darwin-amd64.tar.gz
		FEAT_BINARY_URL_FILENAME=go1.5.3.darwin-amd64.tar.gz
		FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP
	fi

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		FEAT_BINARY_URL=https://storage.googleapis.com/golang/go1.5.3.linux-amd64.tar.gz
		FEAT_BINARY_URL_FILENAME=go1.5.3.linux-amd64.tar.gz
		FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP
	fi

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK="feature_go_set_env"

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/go
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
}

feature_go_1_4_3() {
	FEAT_VERSION=1_4_3

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=https://storage.googleapis.com/golang/go1.4.3.src.tar.gz
	FEAT_SOURCE_URL_FILENAME=go1.4.3.src.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		FEAT_BINARY_URL=https://storage.googleapis.com/golang/go1.4.3.darwin-amd64.tar.gz
		FEAT_BINARY_URL_FILENAME=go1.4.3.darwin-amd64.tar.gz
		FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP
	fi
	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		FEAT_BINARY_URL=https://storage.googleapis.com/golang/go1.4.3.linux-amd64.tar.gz
		FEAT_BINARY_URL_FILENAME=go1.4.3.linux-amd64.tar.gz
		FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP
	fi

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK="feature_go_set_env"

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/go
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
}


feature_go_1_4_2() {
	FEAT_VERSION=1_4_2

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=https://storage.googleapis.com/golang/go1.4.2.src.tar.gz
	FEAT_SOURCE_URL_FILENAME=go1.4.2.src.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		FEAT_BINARY_URL=https://storage.googleapis.com/golang/go1.4.2.darwin-amd64-osx10.8.tar.gz
		FEAT_BINARY_URL_FILENAME=go1.4.2.darwin-amd64-osx10.8.tar.gz
		FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP
	fi
	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		FEAT_BINARY_URL=https://storage.googleapis.com/golang/go1.4.2.linux-amd64.tar.gz
		FEAT_BINARY_URL_FILENAME=go1.4.2.linux-amd64.tar.gz
		FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP
	fi

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK="feature_go_set_env"

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/go
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
}

feature_go_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$INSTALL_DIR" "DEST_ERASE STRIP"

	# GOOS and GOARCH are selected with the current system
	#GOOS
	#GOARCH=amd64 or 386 or arm

	cd "$INSTALL_DIR"
	cd src

	# line below include tests which are too slow
	#./all.bash
	./make.bash

}

feature_go_install_binary() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"

	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$INSTALL_DIR" "STRIP"

}


fi
