if [ ! "$_LIBSOUNDIO_HOMEBREW_INCLUDED_" = "1" ]; then
_LIBSOUNDIO_HOMEBREW_INCLUDED_=1

feature_libsoundio-homebrew() {
	FEAT_NAME="libsoundio-homebrew"
	FEAT_LIST_SCHEMA="latest:binary"
	FEAT_DEFAULT_FLAVOUR="binary"
	FEAT_DESC="Cross-platform audio input and output"
	FEAT_LINK="https://github.com/andrewrk/libsoundio http://libsound.io https://formulae.brew.sh/formula/libsoundio"
}

feature_libsoundio-homebrew_latest() {
	FEAT_VERSION="latest"

	if [ "$STELLA_CPU_ARCH" = "64" ]; then
		FEAT_BINARY_URL_x64="libsoundio"
		FEAT_BINARY_URL_FILENAME_x64="_AUTO_"
		FEAT_BINARY_URL_PROTOCOL_x64="HOMEBREW_BOTTLE"
	fi

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/lib/pkgconfig/libsoundio.pc"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT/bin:$FEAT_INSTALL_ROOT/lib"
}

feature_libsoundio-homebrew_install_binary() {
	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "DEST_ERASE STRIP FORCE_NAME $FEAT_BINARY_URL_FILENAME"

	local _bottle_payload
	_bottle_payload=$(find "$FEAT_INSTALL_ROOT" -mindepth 1 -maxdepth 1 -type d | head -n 1)
	if [ ! "$_bottle_payload" = "" ] && [ ! "$_bottle_payload" = "$FEAT_INSTALL_ROOT" ]; then
		__copy_folder_content_into "$_bottle_payload" "$FEAT_INSTALL_ROOT"
		__del_folder "$_bottle_payload"
	fi
}

fi
