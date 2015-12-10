if [ ! "$_openttd_INCLUDED_" == "1" ]; then 
_openttd_INCLUDED_=1

# TO FINISH
# https://github.com/Homebrew/homebrew-games/blob/master/openttd.rb

function feature_openttd() {
	FEAT_NAME=openttd
	FEAT_LIST_SCHEMA="1_5_3:source"
	FEAT_DEFAULT_VERSION=1_5_3
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}




function feature_openttd_1_5_3() {
	FEAT_VERSION=1_5_3
	
	FEAT_SOURCE_DEPENDENCIES="lzo#2_09 libpng#1_6_17 zlib#1_2_8 xzutils#5_2_1 freetype#2_6_1 pkgconfig"
	[ "$STELLA_CURRENT_PLATFORM" == "linux" ] && FEAT_SOURCE_DEPENDENCIES="sdl#1_2_15 $FEAT_SOURCE_DEPENDENCIES"
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=https://binaries.openttd.org/releases/1.5.3/openttd-1.5.3-source.tar.gz
	FEAT_SOURCE_URL_FILENAME=openttd-1.5.3-source.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK="feature_openttd_link feature_openttd_patch"
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/games/openttd
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/games
	
}

function feature_openttd_link() {
	[ "$STELLA_CURRENT_PLATFORM" == "linux" ] && __link_feature_library "sdl#1_2_15" "GET_FOLDER sdl"
	
	__link_feature_library "xzutils#5_2_1" "GET_FOLDER xzutils"
	__link_feature_library "lzo#2_09" "GET_FOLDER lzo"
	__link_feature_library "zlib#1_2_8" "GET_FOLDER zlib"
	__link_feature_library "libpng#1_6_17" "GET_FOLDER png"
	__link_feature_library "freetype#2_6_1" "GET_FOLDER freetype"

	[ "$STELLA_CURRENT_PLATFORM" == "linux" ] && export PKG_CONFIG_PATH="$xzutils_LIB/pkgconfig:$sdl_LIB/pkgconfig:$freetype_LIB/pkgconfig:$png_LIB/pkgconfig:$PKG_CONFIG_PATH"
	[ "$STELLA_CURRENT_PLATFORM" == "darwin" ] && export PKG_CONFIG_PATH="$xzutils_LIB/pkgconfig:$freetype_LIB/pkgconfig:$png_LIB/pkgconfig:$PKG_CONFIG_PATH"
	
	AUTO_INSTALL_CONF_FLAG_POSTFIX="$AUTO_INSTALL_CONF_FLAG_POSTFIX --with-liblzo2=$lzo_LIB --with-zlib=$zlib_LIB --with-png --with-freetype"
	
}

function feature_openttd_patch() {
	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		__get_resource "patch openttd macoxminversion" "https://trac.macports.org/export/117147/trunk/dports/games/openttd/files/patch-config.lib-remove-deployment-target.diff" "HTTP" "$SRC_DIR"

		cd "$SRC_DIR"
		patch -Np0 < patch-config.lib-remove-deployment-target.diff


		cp "$STELLA_PATCH/openttd/patch_osx_quartz_CMGetSystemProfile_deprecated.diff" "$SRC_DIR"
		cd "$SRC_DIR"
		patch -Np0 < patch_osx_quartz_CMGetSystemProfile_deprecated.diff
	fi

}



function feature_openttd_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"
	
	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP"

	__set_toolset "STANDARD"
	
	# configure script do not play well with CPPFLAGS
	__set_build_mode "MIX_CPP_C_FLAGS" "ON"

	
	AUTO_INSTALL_CONF_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_POSTFIX=

	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		__set_build_mode "DARWIN_STDLIB" "LIBSTDCPP"
		__set_build_mode "MACOSX_DEPLOYMENT_TARGET" "10.11"

		AUTO_INSTALL_CONF_FLAG_POSTFIX="--with-cocoa --without-application-bundle"
		STELLA_C_CXX_FLAGS="$STELLA_C_CXX_FLAGS -D__AUDIOCOMPONENT_H__"
	fi

	

	__feature_callback

	
	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR" "NO_OUT_OF_TREE_BUILD"
	

	# (buildpath/"bundle/OpenTTD.app/Contents/Resources/data/opengfx").install resource("opengfx")
 #    (buildpath/"bundle/OpenTTD.app/Contents/Resources/data/opensfx").install resource("opensfx")
 #    (buildpath/"bundle/OpenTTD.app/Contents/Resources/gm/openmsx").install resource("openmsx")
 #    resource "opengfx" do
 #    url "https://bundles.openttdcoop.org/opengfx/releases/0.5.2/opengfx-0.5.2.zip"
 #    sha256 "19be61f1cb04cbb3cb9602f0b8eb6e6f56ecbefbfdd6e0e03f9579e5a5c1cbc8"
 #  end

 #  resource "opensfx" do
 #    url "https://bundles.openttdcoop.org/opensfx/releases/0.2.3/opensfx-0.2.3.zip"
 #    sha256 "3574745ac0c138bae53b56972591db8d778ad9faffd51deae37a48a563e71662"
 #  end

 #  resource "openmsx" do
 #    url "https://bundles.openttdcoop.org/openmsx/releases/0.3.1/openmsx-0.3.1.zip"
 #    sha256 "92e293ae89f13ad679f43185e83fb81fb8cad47fe63f4af3d3d9f955130460f5"
 #  end

}


# Features and packages:
#   --enable-debug[=LVL]           enable debug-mode (LVL=[0123], 0 is release)
#   --enable-desync-debug=[LVL]    enable desync debug options (LVL=[012], 0 is none
#   --enable-profiling             enables profiling
#   --enable-lto                   enables GCC's Link Time Optimization (LTO)/ICC's
#                                  Interprocedural Optimization if available
#   --enable-dedicated             compile a dedicated server (without video)
#   --enable-static                enable static compile (doesn't work for
#                                  all HOSTs)
#   --enable-translator            enable extra output for translators
#   --enable-universal[=ARCH]      enable universal builds (OSX ONLY). Allowed is any combination
#                                  of architectures: i386 ppc ppc970 ppc64 x86_64
#                                  Default architectures are: i386 ppc
#   --enable-osx-g5                enables optimizations for ppc970 (G5) (OSX ONLY)
#   --disable-cocoa-quartz         disable the quartz window mode driver for Cocoa (OSX ONLY)
#   --disable-cocoa-quickdraw      disable the quickdraw window mode driver for Cocoa (OSX ONLY)
#   --disable-unicode              disable unicode support to build win9x
#                                  version (Win32 ONLY)
#   --enable-console               compile as a console application instead of as a GUI application.
#                                  If this setting is active, debug output will appear in the same
#                                  console instead of opening a new window. (Win32 ONLY)
#   --disable-network              disable network support
#   --disable-assert               disable asserts (continue on errors)
#   --enable-strip                 enable any possible stripping
#   --without-osx-sysroot          disable the automatic adding of sysroot 
#                                  (OSX ONLY)
#   --without-application-bundle   disable generation of application bundle
#                                  (OSX ONLY)
#   --without-menu-entry           Don't generate a menu item (Freedesktop based only)
#   --menu-group=group             Category in which the menu item will be placed (Freedesktop based only)
#   --menu-name=name               Name of the menu item when placed [OpenTTD]
#   --with-direct-music            enable direct music support (Win32 ONLY)
#   --with-sort=sort               define a non-default location for sort
#   --with-midi=midi               define which midi-player to use
#   --with-midi-arg=arg            define which args to use for the
#                                  midi-player
#   --with-libtimidity             enables libtimidity support
#   --with-allegro[=allegro-config]
#                                  enables Allegro video driver support
#   --with-cocoa                   enables COCOA video driver (OSX ONLY)
#   --with-sdl[=sdl-config]        enables SDL video driver support
#   --with-zlib[=zlib.a]           enables zlib support
#   --with-liblzma[="pkg-config liblzma"]
#                                  enables liblzma support
#   --with-liblzo2[=liblzo2.a]     enables liblzo2 support
#   --with-png[=libpng-config]     enables libpng support
#   --with-freetype[=freetype-config]
#                                  enables libfreetype support
#   --with-fontconfig[="pkg-config fontconfig"]
#                                  enables fontconfig support
#   --with-xdg-basedir[="pkg-config libxdg-basedir"]
#                                  enables XDG base directory support
#   --with-icu[=icu-config]        enables icu (used for right-to-left support)
#   --static-icu                   try to link statically (libsicu instead of
#                                  libicu; can fail as the new name is guessed)
#   --with-iconv[=iconv-path]      enables iconv support
#   --with-psp-config[=psp-config] enables psp-config support (PSP ONLY)
#   --disable-builtin-depend       disable use of builtin deps finder
#   --with-makedepend[=makedepend] enables makedepend support
#   --with-ccache                  enables ccache support
#   --with-distcc                  enables distcc support
#   --without-grfcodec             disable usage of grfcodec and re-generation of base sets
#   --without-threads              disable threading support
#   --without-sse                  disable SSE support (x86/x86_64 only)



fi