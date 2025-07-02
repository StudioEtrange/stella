if [ ! "$_miniforge_INCLUDED_" = "1" ]; then
_miniforge_INCLUDED_=1

# mambaforge releases are into https://github.com/conda-forge/miniforge can install different python env management tools
# Miniforge and Mambaforge are identical "That said, if you had to start using one today, we recommend to stick to Miniforge."
# both connected to conda-forge package repository


# list of versions : https://github.com/conda-forge/miniforge/releases


feature_miniforge() {
	FEAT_NAME="miniforge"
	FEAT_LIST_SCHEMA="25_3_0_3@x64:binary"
	FEAT_DEFAULT_ARCH="x64"
	FEAT_DEFAULT_FLAVOUR="binary"


	FEAT_DESC="Minimal env and package python manager with mamba and conda environment management tool and connected to conda-forge."
	FEAT_LINK="https://github.com/conda-forge/miniforge"
}



feature_miniforge_25_3_0_3() {
	FEAT_VERSION="25_3_0_3"

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		FEAT_BINARY_URL_x64="https://github.com/conda-forge/miniforge/releases/download/25.3.0-3/Miniforge3-25.3.0-3-Linux-x86_64.sh"
		FEAT_BINARY_URL_FILENAME_x64="Miniforge3-25.3.0-3-Linux-x86_64.sh"
		FEAT_BINARY_URL_PROTOCOL_x64="HTTP"
	fi

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		if [ "$STELLA_CURRENT_CPU_ARCH" = "x86_64" ]; then
			FEAT_BINARY_URL_x64="hhttps://github.com/conda-forge/miniforge/releases/download/25.3.0-3/Miniforge3-25.3.0-3-MacOSX-x86_64.sh"
			FEAT_BINARY_URL_FILENAME_x64="Miniforge3-25.3.0-3-MacOSX-x86_64.sh"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP"
		fi
		if [ "$STELLA_CURRENT_CPU_ARCH" = "arm64" ]; then
			FEAT_BINARY_URL_x64="https://github.com/conda-forge/miniforge/releases/download/25.3.0-3/Miniforge3-25.3.0-3-MacOSX-arm64.sh"
			FEAT_BINARY_URL_FILENAME_x64="Miniforge3-25.3.0-3-MacOSX-arm64.sh"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP"
		fi
		
	fi

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/bin/mamba"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT/bin"

}


feature_miniforge_install_binary() {
	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "DEST_ERASE STRIP"
	cd "$FEAT_INSTALL_ROOT"
	bash "$FEAT_BINARY_URL_FILENAME" -p $FEAT_INSTALL_ROOT -b -f
	rm -f "$FEAT_INSTALL_ROOT/$FEAT_BINARY_URL_FILENAME"

}


fi
