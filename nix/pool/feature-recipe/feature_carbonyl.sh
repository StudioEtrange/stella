if [ ! "$_CARBONYL_INCLUDED_" = "1" ]; then
_CARBONYL_INCLUDED_=1

# runtime dependencies for 0.0.3 https://github.com/fathyb/carbonyl/releases/tag/v0.0.3
# libnss3: SSL library needed for root SSL certificates
# libexpat1: XML library, will be removed in the future
# libasound2: ALSA library for audio playback https://formulae.brew.sh/formula/libsoundio
# libfontconfig1: we need the configuration this package generates

feature_carbonyl() {
	FEAT_NAME="carbonyl"
	FEAT_LIST_SCHEMA="0_0_3@x64:binary"
	FEAT_DEFAULT_FLAVOUR="binary"
	FEAT_DESC="Chromium based browser built to run in a terminal"
	FEAT_LINK="https://github.com/fathyb/carbonyl"
}

feature_carbonyl_0_0_3() {
	FEAT_VERSION="0_0_3"

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "intel" ]; then
			FEAT_BINARY_URL_x64="https://github.com/fathyb/carbonyl/releases/download/v0.0.3/carbonyl.macos-amd64.zip"
			FEAT_BINARY_URL_FILENAME_x64="carbonyl-macos-amd64-${FEAT_VERSION}.zip"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
		fi
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "arm" ]; then
			FEAT_BINARY_URL_x64="https://github.com/fathyb/carbonyl/releases/download/v0.0.3/carbonyl.macos-arm64.zip"
			FEAT_BINARY_URL_FILENAME_x64="carbonyl-macos-arm64-${FEAT_VERSION}.zip"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
		fi
	fi
	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "intel" ]; then
			FEAT_BINARY_URL_x64="https://github.com/fathyb/carbonyl/releases/download/v0.0.3/carbonyl.linux-amd64.zip"
			FEAT_BINARY_URL_FILENAME_x64="carbonyl-linux-amd64-${FEAT_VERSION}.zip"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
		fi
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "arm" ]; then
			FEAT_BINARY_URL_x64="https://github.com/fathyb/carbonyl/releases/download/v0.0.3/carbonyl.linux-arm64.zip"
			FEAT_BINARY_URL_FILENAME_x64="carbonyl-linux-arm64-${FEAT_VERSION}.zip"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
		fi
	fi

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/carbonyl"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"
}

feature_carbonyl_install_binary() {
	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "DEST_ERASE STRIP FORCE_NAME $FEAT_BINARY_URL_FILENAME"
	
	if [ -f "${FEAT_INSTALL_ROOT}/${FEAT_BINARY_URL_FILENAME}" ]; then
		mv "${FEAT_INSTALL_ROOT}/${FEAT_BINARY_URL_FILENAME}" "${FEAT_INSTALL_ROOT}/carbonyl"
		chmod +x "${FEAT_INSTALL_ROOT}/carbonyl"
	fi
}

fi
