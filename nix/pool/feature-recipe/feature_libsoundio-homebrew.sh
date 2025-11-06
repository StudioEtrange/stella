if [ ! "$_LIBSOUNDIO-HOMEBREW_INCLUDED_" = "1" ]; then
_LIBSOUNDIO-HOMEBREW_INCLUDED_=1

feature_libsoundio-homebrew() {
	FEAT_NAME="libsoundio-homebrew"
	FEAT_LIST_SCHEMA="latest:binary"
	FEAT_DEFAULT_FLAVOUR="binary"
	FEAT_DESC="Cross-platform audio input and output"
	FEAT_LINK="https://github.com/andrewrk/libsoundio http://libsound.io https://formulae.brew.sh/formula/libsoundio"
}

feature_libsoundio-homebrew_latest() {
	FEAT_VERSION="latest"

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "intel" ]; then
			FEAT_BINARY_URL_x64="https://github.com/fathyb/libsoundio-homebrew/releases/download/v0.0.3/libsoundio-homebrew.macos-amd64.zip"
			FEAT_BINARY_URL_FILENAME_x64="libsoundio-homebrew-macos-amd64-${FEAT_VERSION}.zip"
			FEAT_BINARY_URL_PROTOCOL_x64="HOMEBREW_BOTTLE"
		fi
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "arm" ]; then
			FEAT_BINARY_URL_x64="https://github.com/fathyb/libsoundio-homebrew/releases/download/v0.0.3/libsoundio-homebrew.macos-arm64.zip"
			FEAT_BINARY_URL_FILENAME_x64="libsoundio-homebrew-macos-arm64-${FEAT_VERSION}.zip"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
		fi
	fi
	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "intel" ]; then
			FEAT_BINARY_URL_x64="https://github.com/fathyb/libsoundio-homebrew/releases/download/v0.0.3/libsoundio-homebrew.linux-amd64.zip"
			FEAT_BINARY_URL_FILENAME_x64="libsoundio-homebrew-linux-amd64-${FEAT_VERSION}.zip"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
		fi
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "arm" ]; then
			FEAT_BINARY_URL_x64="https://github.com/fathyb/libsoundio-homebrew/releases/download/v0.0.3/libsoundio-homebrew.linux-arm64.zip"
			FEAT_BINARY_URL_FILENAME_x64="libsoundio-homebrew-linux-arm64-${FEAT_VERSION}.zip"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
		fi
	fi

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/libsoundio-homebrew"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"
}

feature_libsoundio-homebrew_install_binary() {
	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "DEST_ERASE STRIP FORCE_NAME $FEAT_BINARY_URL_FILENAME"
	
	if [ -f "${FEAT_INSTALL_ROOT}/${FEAT_BINARY_URL_FILENAME}" ]; then
		mv "${FEAT_INSTALL_ROOT}/${FEAT_BINARY_URL_FILENAME}" "${FEAT_INSTALL_ROOT}/libsoundio-homebrew"
		chmod +x "${FEAT_INSTALL_ROOT}/libsoundio-homebrew"
	fi
}

fi
