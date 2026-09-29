if [ ! "$_LF_INCLUDED_" = "1" ]; then
_LF_INCLUDED_=1

feature_lf() {
	FEAT_NAME="lf"
	FEAT_LIST_SCHEMA="r42@x64:binary"
	FEAT_DEFAULT_FLAVOUR="binary"
	FEAT_DESC="A terminal file manager written in Go"
	FEAT_LINK="https://github.com/gokcehan/lf"
}

feature_lf_r42() {
	FEAT_VERSION="r42"

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "intel" ]; then
			FEAT_BINARY_URL_x64="https://github.com/gokcehan/lf/releases/download/r42/lf-darwin-amd64.tar.gz"
			FEAT_BINARY_URL_FILENAME_x64="lf-darwin-amd64.tar.gz"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
		fi
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "arm" ]; then
			FEAT_BINARY_URL_x64="https://github.com/gokcehan/lf/releases/download/r42/lf-darwin-arm64.tar.gz"
			FEAT_BINARY_URL_FILENAME_x64="lf-darwin-arm64.tar.gz"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
		fi
	fi
	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "intel" ]; then
			FEAT_BINARY_URL_x64="https://github.com/gokcehan/lf/releases/download/r42/lf-linux-amd64.tar.gz"
			FEAT_BINARY_URL_FILENAME_x64="lf-linux-amd64.tar.gz"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
		fi
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "arm" ]; then
			FEAT_BINARY_URL_x64="https://github.com/gokcehan/lf/releases/download/r42/lf-linux-arm64.tar.gz"
			FEAT_BINARY_URL_FILENAME_x64="lf-linux-arm64.tar.gz"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
		fi
	fi

	FEAT_INSTALL_TEST="${FEAT_INSTALL_ROOT}/lf"
	FEAT_SEARCH_PATH="${FEAT_INSTALL_ROOT}"
}

feature_lf_install_binary() {
	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "DEST_ERASE"
	chmod +x "${FEAT_INSTALL_ROOT}/lf"
}

fi
