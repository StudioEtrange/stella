if [ ! "$_qt_INCLUDED_" = "1" ]; then
_qt_INCLUDED_=1


#https://bitbucket.org/StudioEtrange/ryzomcore-script/src/b5b7fc357f33a46e894ab1ff97019ccb98ac3018/nix/lib_qt_build.sh?at=default&fileviewer=file-view-default
#https://github.com/cartr/homebrew-qt4
# TODO not finished


feature_qt() {
	FEAT_NAME=qt

	FEAT_LIST_SCHEMA="5_1_1:source 4_8_6:source"
	FEAT_DEFAULT_VERSION=4_8_6
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}


#
# feature_qt_5_1_1() {
# 	FEAT_VERSION=5_1_1
#
# 	FEAT_SOURCE_DEPENDENCIES=
# 	FEAT_BINARY_DEPENDENCIES=
#
# 	FEAT_SOURCE_URL=http://download.qt.io/archive/qt/5.1/5.1.1/single/qt-everywhere-opensource-src-5.1.1.tar.gz
# 	FEAT_SOURCE_URL_FILENAME=
# 	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP
#
# 	FEAT_BINARY_URL=
# 	FEAT_BINARY_URL_FILENAME=
# 	FEAT_BINARY_URL_PROTOCOL=
#
# 	FEAT_SOURCE_CALLBACK=
# 	FEAT_BINARY_CALLBACK=
# 	FEAT_ENV_CALLBACK=
#
# 	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/lib/libzmq.a
# 	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
#
# }


feature_qt_4_8_6() {
	FEAT_VERSION=4_8_6

	FEAT_SOURCE_DEPENDENCIES="openssl#1_0_2k freetype zlib#1_2_8 jpeg libpng"
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=http://download.qt.io/archive/qt/4.8/4.8.6/qt-everywhere-opensource-src-4.8.6.tar.gz
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=feature_qt_link
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/lib/libzmq.a
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}



feature_qt_link() {
	__link_feature_library "openssl#1_0_2k"
	__link_feature_library "freetype"
	__link_feature_library "zlib#1_2_8"
	__link_feature_library "jpeg"
	__link_feature_library "libpng"
}


feature_qt_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"


	__set_toolset "STANDARD"

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "STRIP" #DEST_ERASE"

	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		QMAKESPEC=macx-g++
		# TODO 32 bits http://www.qtcentre.org/threads/40557-spec-to-use-when-compiling-for-32-bit-MacOS-X-on-Snow-Leopard-(no-macx-g-32-)
	else
		if [ ! -z "$STELLA_BUILD_ARCH"]; then
			[ "$STELLA_BUILD_ARCH" = "x64" ] && QMAKESPEC=linux-g++-64
			[ "$STELLA_BUILD_ARCH" = "x86" ] && QMAKESPEC=linux-g++-32
		else
			[ "$STELLA_CPU_ARCH" = "64" ] && QMAKESPEC=linux-g++-64
			[ "$STELLA_CPU_ARCH" = "32" ] && QMAKESPEC=linux-g++-32
			# fallback to 32bits
			[ -z "$STELLA_CPU_ARCH" ] && QMAKESPEC=linux-g++-32
		fi
	fi

	# TODO : FREETYPE / FONTCONFIG
	# -no-fontconfig ..... Do not compile FontConfig (anti-aliased font) support.
 	# -fontconfig (DEFAULT) ........ Compile FontConfig support. Requires fontconfig/fontconfig.h, libfontconfig,freetype.h and libfreetype.

 	# TODO : OPENSSL
 	#	-no-openssl ........ Do not compile support for OpenSSL.
	#  	-openssl .(DEFAULT)... Enable run-time OpenSSL support.
    #	-openssl-linked .... Enabled linked OpenSSL support.

# TODO libtiff
# TODO libmng http://www.linuxfromscratch.org/blfs/view/cvs/general/libmng.html

	#configure -no-qmake -no-qt3support -qt-zlib -qt-libpng -qt-libmng -qt-libtiff -qt-libjpeg -openssl -I c:\external\include\openssl -no-exceptions -no-rtti -no-style-cde -no-style-motif -no-style-cleanlooks -no-style-plastique
	#configure -static -debug-and-release -qt-sql-odbc -opensource -confirm-license -ltcg -no-fast -exceptions -accessibility -stl -qt-sql-sqlite -no-qt3support -no-openvg -no-webkit -platform win32-msvc2008 -graphicssystem raster -qt-zlib -qt-gif -qt-libpng -qt-libmng -qt-libtiff -qt-libjpeg -no-dsp -no-vcproj -incredibuild-xge -plugin-manifests -qmake -process -rtti -mmx -3dnow -sse -sse2 -openssl -no-dbus -phonon -phonon-backend -multimedia -audio-backend  -script -scripttools -declarative -arch windows -qt-style-windows -qt-style-windowsxp -qt-style-windowsvista -no-style-plastique -no-style-cleanlooks -no-style-motif -no-style-cde -no-style-windowsce -no-style-windowsmobile -no-style-s60 -native-gestures
	# -make libs -make examples -make demos -make tools -make docs

	__feature_callback

	AUTO_INSTALL_CONF_FLAG_PREFIX=
	AUTO_INSTALL_CONF_FLAG_POSTFIX="-v -debug-and-release -stl -opensource -shared -no-qt3support \
							-qt-zlib -qt-libpng -qt-libjpeg -qt-libmng -qt-libtiff -qt-freetype -openssl -fontconfig \
							-no-exceptions -nomake demos -nomake examples -confirm-license -prefix $FEAT_INSTALL_ROOT \
							-platform $QMAKESPE $STELLA_C_CXX_FLAGS $STELLA_LINK_FLAGS"
	AUTO_INSTALL_BUILD_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_POSTFIX=

# TODO STELLA_C_CXX_FLAGS is initialized after, too late in auto_build ?

	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR" "SOURCE_KEEP"


}



fi
