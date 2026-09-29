if [ ! "$_YAZI_INCLUDED_" = "1" ]; then
_YAZI_INCLUDED_=1

feature_yazi() {
	FEAT_NAME="yazi"
	FEAT_LIST_SCHEMA="26_9_1@x64:binary"
	FEAT_DEFAULT_FLAVOUR="binary"
	FEAT_DESC="A terminal file manager with image previews and asynchronous operations"
	FEAT_LINK="https://github.com/sxyazi/yazi https://yazi-rs.github.io/ https://github.com/yazi-rs/flavors"
}

feature_yazi_26_9_1() {
	FEAT_VERSION="26_9_1"

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "intel" ]; then
			FEAT_BINARY_URL_x64="https://github.com/sxyazi/yazi/releases/download/v26.9.1/yazi-x86_64-apple-darwin.zip"
			FEAT_BINARY_URL_FILENAME_x64="yazi-x86_64-apple-darwin.zip"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
		fi
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "arm" ]; then
			FEAT_BINARY_URL_x64="https://github.com/sxyazi/yazi/releases/download/v26.9.1/yazi-aarch64-apple-darwin.zip"
			FEAT_BINARY_URL_FILENAME_x64="yazi-aarch64-apple-darwin.zip"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
		fi
	fi
	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "intel" ]; then
			FEAT_BINARY_URL_x64="https://github.com/sxyazi/yazi/releases/download/v26.9.1/yazi-x86_64-unknown-linux-gnu.zip"
			FEAT_BINARY_URL_FILENAME_x64="yazi-x86_64-unknown-linux-gnu.zip"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
		fi
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "arm" ]; then
			FEAT_BINARY_URL_x64="https://github.com/sxyazi/yazi/releases/download/v26.9.1/yazi-aarch64-unknown-linux-gnu.zip"
			FEAT_BINARY_URL_FILENAME_x64="yazi-aarch64-unknown-linux-gnu.zip"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
		fi
	fi

	FEAT_INSTALL_TEST="${FEAT_INSTALL_ROOT}/yazi"
	FEAT_SEARCH_PATH="${FEAT_INSTALL_ROOT}"
}

feature_yazi_install_binary() {
	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "DEST_ERASE STRIP FORCE_NAME $FEAT_BINARY_URL_FILENAME"
	chmod +x "${FEAT_INSTALL_ROOT}/yazi" "${FEAT_INSTALL_ROOT}/ya"
}

fi
