if [ ! "$_ALLEGRO_INCLUDED_" == "1" ]; then 
_ALLEGRO_INCLUDED_=1

# TODO

# -- Found Threads: TRUE  
# -- Found OpenAL: /System/Library/Frameworks/OpenAL.framework  
# -- Could NOT find FLAC (missing:  FLAC_INCLUDE_DIR OGG_LIBRARY FLAC_LIBRARY) 
# WARNING: libFLAC not found or compile test failed, disabling support.
# -- Could NOT find DUMB (missing:  DUMB_INCLUDE_DIR DUMB_LIBRARY) 
# WARNING: libdumb not found or compile test failed, disabling support. <http://dumb.sourceforge.net/>
# -- Could NOT find OGG (missing:  OGG_INCLUDE_DIR OGG_LIBRARY) 
# WARNING: libvorbis not found or compile test failed, disabling support.
# -- Found Freetype: /usr/X11R6/lib/libfreetype.dylib (found version "2.5.3") 
# -- Found ZLIB: /usr/lib/libz.dylib (found version "1.2.5") 
# -- Could NOT find PhysFS (missing:  PHYSFS_LIBRARY PHYSFS_INCLUDE_DIR) 
# -- Could NOT find PHYSFS (missing:  PHYSFS_LIBRARY PHYSFS_INCLUDE_DIR) 
# -- Not building ex_physfs
# -- Could NOT find LATEX (missing:  LATEX_COMPILER) 


# Library dependencies (from README.txt)
#- DirectX SDK (Windows only)
#- X11 development libraries (Linux/Unix only)
#- OpenGL development libraries (optional only on Windows)
# Addons dependencies
#- libpng and zlib
#- libjpeg
#- FreeType
#- Ogg Vorbis, a free lossy audio format. (libogg, libvorbis, libvorbisfile)
#- FLAC, a free lossless audio codec. (libFLAC, libogg)
#- DUMB, an IT, XM, S3M and MOD player library. (libdumb)
#- OpenAL, a 3D audio API.
#- PhysicsFS


function feature_allegro() {
	FEAT_NAME=allegro
	FEAT_LIST_SCHEMA="5_0_11:source"
	FEAT_DEFAULT_VERSION=5_0_11
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_allegro_5_0_11() {
	FEAT_VERSION=5_0_11
	FEAT_SOURCE_DEPENDENCIES="zlib#1_2_8 freetype#2_6_0 libpng#1_6_17 jpeg#9_0_0"
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=http://sourceforge.net/projects/alleg/files/allegro/5.0.11/allegro-5.0.11.tar.gz
	FEAT_SOURCE_URL_FILENAME=allegro-5.0.11.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP
	
	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=
	
	FEAT_SOURCE_CALLBACK=feature_allegro_link
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/lib/libz.a
	FEAT_SEARCH_PATH=
	
}

function feature_allegro_link() {
	__link_feature_library "freetype#2_6_0" "" "GET_FOLDER freetype"
	__link_feature_library "zlib#1_2_8" "" "FORCE_DYNAMIC"
	__link_feature_library "libpng#1_6_17"
	__link_feature_library "jpeg#9_0_0"
}


function feature_allegro_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"
	
	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP"

	__set_build_mode "RELOCATE" "OFF"

	__feature_callback

	AUTO_INSTALL_CONF_FLAG_PREFIX=
	# FREETYPE_INCLUDE_DIR_ft2build : Used by cmake module FindFreetype.cmake -- especially to found ft2build.h ==> USELESS with -DCMAKE_FIND_FRAMEWORK=LAST -DCMAKE_FIND_APPBUNDLE=LAST
	#AUTO_INSTALL_CONF_FLAG_POSTFIX="-DFREETYPE_INCLUDE_DIR_ft2build=$freetype_ROOT/include/freetype2"
	# WANT_NATIVE_IMAGE_LOADER   WANT_IMAGE_PNG : force cmake to find libpng and libjpeg. 
	#AUTO_INSTALL_CONF_FLAG_POSTFIX="-DWANT_IMAGE_PNG=ON -DWANT_NATIVE_IMAGE_LOADER=OFF"
	AUTO_INSTALL_CONF_FLAG_POSTFIX="-DWANT_DEMO=OFF -DWANT_EXAMPLES=OFF -DWANT_DOCS=OFF -DWANT_NATIVE_IMAGE_LOADER=OFF"
	AUTO_INSTALL_BUILD_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_POSTFIX=

	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR" "SOURCE_KEEP BUILD_KEEP CONFIG_TOOL cmake"


	
}



fi