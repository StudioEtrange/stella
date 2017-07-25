if [ ! "$_sdlgfx_INCLUDED_" = "1" ]; then
_sdlgfx_INCLUDED_=1

#http://cms.ferzkopp.net/index.php/software/13-sdl-gfx

# NOTE this use sdl-config binaries to set correct flag

# sdl 2.x => sdl-gfx 1_0_1
# sdl 1.2.x => sdl-gfx 2_0_25

feature_sdl-gfx() {
	FEAT_NAME=sdl-gfx
	FEAT_LIST_SCHEMA="1_0_1:source 2_0_25:source"
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}




feature_sdl-gfx_1_0_1() {
	FEAT_VERSION=1_0_1

	FEAT_SOURCE_DEPENDENCIES="sdl#2_0_3"
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=http://www.ferzkopp.net/Software/SDL2_gfx/SDL2_gfx-1.0.1.tar.gz
	FEAT_SOURCE_URL_FILENAME=SDL2_gfx-1.0.1.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=feature_sdl-gfx_link_sdl2
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/lib/libSDL2_gfx.a
	FEAT_SEARCH_PATH=

}

feature_sdl-gfx_2_0_25() {
	FEAT_VERSION=2_0_25

	FEAT_SOURCE_DEPENDENCIES="sdl#1_2_15"
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=http://www.ferzkopp.net/Software/SDL_gfx-2.0/SDL_gfx-2.0.25.tar.gz
	FEAT_SOURCE_URL_FILENAME=SDL_gfx-2.0.25.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=feature_sdl-gfx_link_sdl1
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/lib/libSDL_gfx.a
	FEAT_SEARCH_PATH=

}



feature_sdl-gfx_link_sdl1() {
	__link_feature_library "sdl#1_2_15" "GET_FOLDER _sdl1 FORCE_INCLUDE_FOLDER include/SDL NO_SET_FLAGS"

	AUTO_INSTALL_CONF_FLAG_POSTFIX="$AUTO_INSTALL_CONF_FLAG_POSTFIX --with-sdl-prefix=$_sdl1_ROOT"
}

feature_sdl-gfx_link_sdl2() {
	__link_feature_library "sdl#2_0_3" "GET_FOLDER _sdl2 FORCE_INCLUDE_FOLDER include/SDL NO_SET_FLAGS"

	AUTO_INSTALL_CONF_FLAG_POSTFIX="$AUTO_INSTALL_CONF_FLAG_POSTFIX --with-sdl-prefix=$_sdl2_ROOT"
}


feature_sdl-gfx_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"


	__set_toolset "STANDARD"


	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP"

	AUTO_INSTALL_CONF_FLAG_PREFIX=
	AUTO_INSTALL_CONF_FLAG_POSTFIX="--enable-mmx"
	AUTO_INSTALL_BUILD_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_POSTFIX=


	__feature_callback

	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR"

}




fi
