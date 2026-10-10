if [ ! "$_OPENTOFU_INCLUDED_" = "1" ]; then
_OPENTOFU_INCLUDED_=1

feature_opentofu() {
	FEAT_NAME="opentofu"
	FEAT_LIST_SCHEMA="1_13_1@x64:binary"
	FEAT_DEFAULT_FLAVOUR="binary"
	FEAT_DESC="OpenTofu is an open-source infrastructure as code tool"
	FEAT_LINK="https://opentofu.org https://github.com/opentofu/opentofu"
}

feature_opentofu_1_13_1() {
	FEAT_VERSION="1_13_1"

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "intel" ]; then
			FEAT_BINARY_URL_x64="https://github.com/opentofu/opentofu/releases/download/v1.13.1/tofu_1.13.1_linux_amd64.zip"
			FEAT_BINARY_URL_FILENAME_x64="tofu_1.13.1_linux_amd64.zip"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
		fi
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "arm" ]; then
			FEAT_BINARY_URL_x64="https://github.com/opentofu/opentofu/releases/download/v1.13.1/tofu_1.13.1_linux_arm64.zip"
			FEAT_BINARY_URL_FILENAME_x64="tofu_1.13.1_linux_arm64.zip"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
		fi
	fi
	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "intel" ]; then
			FEAT_BINARY_URL_x64="https://github.com/opentofu/opentofu/releases/download/v1.13.1/tofu_1.13.1_darwin_amd64.zip"
			FEAT_BINARY_URL_FILENAME_x64="tofu_1.13.1_darwin_amd64.zip"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
		fi
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "arm" ]; then
			FEAT_BINARY_URL_x64="https://github.com/opentofu/opentofu/releases/download/v1.13.1/tofu_1.13.1_darwin_arm64.zip"
			FEAT_BINARY_URL_FILENAME_x64="tofu_1.13.1_darwin_arm64.zip"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
		fi
	fi

	FEAT_INSTALL_TEST="${FEAT_INSTALL_ROOT}/tofu"
	FEAT_SEARCH_PATH="${FEAT_INSTALL_ROOT}"
}

feature_opentofu_install_binary() {
	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "DEST_ERASE STRIP FORCE_NAME $FEAT_BINARY_URL_FILENAME"
}

fi
