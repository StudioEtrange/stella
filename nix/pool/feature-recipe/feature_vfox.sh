if [ ! "$_VFOX_INCLUDED_" = "1" ]; then
_VFOX_INCLUDED_=1

# Initialize shell integration after loading the Stella environment:
# Bash: eval "$(vfox activate bash)"
# Zsh: eval "$(vfox activate zsh)"


feature_vfox() {
	FEAT_NAME="vfox"
	FEAT_LIST_SCHEMA="1_0_13@x64:binary 1_0_13@x86:binary"
	FEAT_DEFAULT_FLAVOUR="binary"

	FEAT_DESC="A cross-platform version manager for managing multiple SDK versions with an extensible plugin system"
	FEAT_LINK="https://github.com/version-fox/vfox https://vfox.dev"
}

feature_vfox_1_0_13() {
	FEAT_VERSION="1_0_13"

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "intel" ]; then
			FEAT_BINARY_URL_x64="https://github.com/version-fox/vfox/releases/download/v1.0.13/vfox_1.0.13_linux_x86_64.tar.gz"
			FEAT_BINARY_URL_FILENAME_x64="vfox_1.0.13_linux_x86_64.tar.gz"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
			FEAT_BINARY_URL_x86="https://github.com/version-fox/vfox/releases/download/v1.0.13/vfox_1.0.13_linux_i386.tar.gz"
			FEAT_BINARY_URL_FILENAME_x86="vfox_1.0.13_linux_i386.tar.gz"
			FEAT_BINARY_URL_PROTOCOL_x86="HTTP_ZIP"
		fi
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "arm" ]; then
			FEAT_BINARY_URL_x64="https://github.com/version-fox/vfox/releases/download/v1.0.13/vfox_1.0.13_linux_aarch64.tar.gz"
			FEAT_BINARY_URL_FILENAME_x64="vfox_1.0.13_linux_aarch64.tar.gz"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
			FEAT_BINARY_URL_x86="https://github.com/version-fox/vfox/releases/download/v1.0.13/vfox_1.0.13_linux_armv7.tar.gz"
			FEAT_BINARY_URL_FILENAME_x86="vfox_1.0.13_linux_armv7.tar.gz"
			FEAT_BINARY_URL_PROTOCOL_x86="HTTP_ZIP"
		fi
	fi
	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "intel" ]; then
			FEAT_BINARY_URL_x64="https://github.com/version-fox/vfox/releases/download/v1.0.13/vfox_1.0.13_macos_x86_64.tar.gz"
			FEAT_BINARY_URL_FILENAME_x64="vfox_1.0.13_macos_x86_64.tar.gz"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
		fi
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "arm" ]; then
			FEAT_BINARY_URL_x64="https://github.com/version-fox/vfox/releases/download/v1.0.13/vfox_1.0.13_macos_aarch64.tar.gz"
			FEAT_BINARY_URL_FILENAME_x64="vfox_1.0.13_macos_aarch64.tar.gz"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
		fi
	fi

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/vfox"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"
}


feature_vfox_install_binary() {
	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "DEST_ERASE STRIP FORCE_NAME $FEAT_BINARY_URL_FILENAME"
	chmod +x "${FEAT_INSTALL_ROOT}/vfox"
}

fi
