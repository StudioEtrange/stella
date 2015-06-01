if [ ! "$_CMAKE_INCLUDED_" == "1" ]; then 
_CMAKE_INCLUDED_=1


function feature_cmake() {

	FEAT_NAME=cmake
	FEAT_LIST_SCHEMA="2_8_12:source 2_8_12:binary 3_2_2:binary 3_2_2:source"
	FEAT_DEFAULT_VERSION=2_8_12
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_cmake_2_8_12() {

	FEAT_VERSION=2_8_12

	FEAT_SOURCE_URL=http://www.cmake.org/files/v2.8/cmake-2.8.12.2.tar.gz
	FEAT_SOURCE_URL_FILENAME=cmake-2.8.12.2.tar.gz
	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_URL=
	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		FEAT_BINARY_URL=http://www.cmake.org/files/v2.8/cmake-2.8.12.2-Darwin64-universal.tar.gz
		FEAT_BINARY_URL_FILENAME=cmake-2.8.12.2-Darwin64-universal.tar.gz
	fi
	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		FEAT_BINARY_URL=http://www.cmake.org/files/v2.8/cmake-2.8.12.2-Linux-i386.tar.gz
		FEAT_BINARY_URL_FILENAME=cmake-2.8.12.2-Linux-i386.tar.gz
	fi

	# TODO  ** NEED : cURL-7.32.0, libarchive-3.1.2 and expat-2.1.0
	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/cmake
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
	FEAT_ENV_CALLBACK=
	
	FEAT_BUNDLE_ITEM=
}




function feature_cmake_3_2_2() {

	FEAT_VERSION=3_2_2

	FEAT_SOURCE_URL=http://www.cmake.org/files/v3.2/cmake-3.2.2.tar.gz
	FEAT_SOURCE_URL_FILENAME=cmake-3.2.2.tar.gz
	FEAT_SOURCE_CALLBACK=
	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		FEAT_BINARY_URL=http://www.cmake.org/files/v3.2/cmake-3.2.2-Darwin-x86_64.tar.gz
		FEAT_BINARY_URL_FILENAME=cmake-3.2.2-Darwin-x86_64.tar.gz
	fi
	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		FEAT_BINARY_URL=http://www.cmake.org/files/v3.2/cmake-3.2.2-Linux-x86_64.tar.gz
		FEAT_BINARY_URL_FILENAME=cmake-3.2.2-Linux-x86_64.tar.gz
	fi
	# TODO  ** NEED : cURL-7.32.0, libarchive-3.1.2 and expat-2.1.0
	FEAT_DEPENDENCIES=
	
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/cmake
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
	
	FEAT_BUNDLE_ITEM=
}

function feature_cmake_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-build"


	__download_uncompress "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_FILENAME" "$SRC_DIR" "DEST_ERASE STRIP"

	__del_folder "$BUILD_DIR"
	mkdir -p "$BUILD_DIR"

	cd "$BUILD_DIR"

	chmod +x $SRC_DIR/bootstrap
	$SRC_DIR/bootstrap --prefix="$INSTALL_DIR"
	#cmake "$SRC_DIR" -DTEMPLATE_INSTALL_PREFIX="$INSTALL_DIR"
	#make -j$BUILD_JOB 
	make
	make install

	__del_folder "$SRC_DIR"
	__del_folder "$BUILD_DIR"

}


function feature_cmake_install_binary() {
	
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR=
	BUILD_DIR=

	__download_uncompress "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_FILENAME" "$INSTALL_DIR" "DEST_ERASE STRIP"
	
	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		ln -s "$FEAT_INSTALL_ROOT"/CMake.app/Contents/bin "$FEAT_INSTALL_ROOT"/bin
		ln -s "$FEAT_INSTALL_ROOT"/CMake.app/Contents/doc "$FEAT_INSTALL_ROOT"/doc
		ln -s "$FEAT_INSTALL_ROOT"/CMake.app/Contents/man "$FEAT_INSTALL_ROOT"/man
		ln -s "$FEAT_INSTALL_ROOT"/CMake.app/Contents/share "$FEAT_INSTALL_ROOT"/share
	fi	
}


fi