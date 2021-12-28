if [ ! "$_mambaforge_INCLUDED_" = "1" ]; then
_mambaforge_INCLUDED_=1

feature_mambaforge() {
	FEAT_NAME="mambaforge"
	FEAT_LIST_SCHEMA="4_11_0_0@x64:binary"
	FEAT_DEFAULT_ARCH="x64"
	FEAT_DEFAULT_FLAVOUR="binary"


	FEAT_DESC="Minimal env and package python manager with support conda and mamba connected to conda-forge."
	FEAT_LINK="https://github.com/conda-forge/miniforge"
}



feature_mambaforge_4_11_0_0() {
	FEAT_VERSION="4_11_0_0"

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		FEAT_BINARY_URL_x64="https://github.com/conda-forge/miniforge/releases/download/4.11.0-0/Mambaforge-4.11.0-0-MacOSX-x86_64.sh"
		FEAT_BINARY_URL_FILENAME_x64="Mambaforge-4.11.0-0-MacOSX-x86_64.sh"
		FEAT_BINARY_URL_PROTOCOL_x64="HTTP"
	fi

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		FEAT_BINARY_URL_x64="https://github.com/conda-forge/miniforge/releases/download/4.11.0-0/Mambaforge-4.11.0-0-Linux-x86_64.sh"
		FEAT_BINARY_URL_FILENAME_x64="Mambaforge-4.11.0-0-Linux-x86_64.sh"
		FEAT_BINARY_URL_PROTOCOL_x64="HTTP"
	fi

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/bin/conda"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT/bin"

}



feature_mambaforge_install_binary() {
	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "DEST_ERASE STRIP"
	cd "$FEAT_INSTALL_ROOT"
	bash "$FEAT_BINARY_URL_FILENAME" -p $FEAT_INSTALL_ROOT -b -f
	rm -f "$FEAT_INSTALL_ROOT/$FEAT_BINARY_URL_FILENAME"

}


fi
