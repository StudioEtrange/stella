if [ ! "$_CMAKE_INCLUDED_" == "1" ]; then 
_CMAKE_INCLUDED_=1


function feature_cmake() {

	FEAT_NAME=cmake
	FEAT_LIST_SCHEMA="2_8_12:source 2_8_12:binary 3_2_3:binary 3_2_3:source 3_3_1:binary 3_3_1:source"
	FEAT_DEFAULT_VERSION=3_3_1
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="binary"
}

function feature_cmake_2_8_12() {
	FEAT_VERSION=2_8_12
	# TODO  ** NEED : cURL-7.32.0, libarchive-3.1.2 and expat-2.1.0
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=http://www.cmake.org/files/v2.8/cmake-2.8.12.2.tar.gz
	FEAT_SOURCE_URL_FILENAME=cmake-2.8.12.2.tar.gz

	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		FEAT_BINARY_URL=http://www.cmake.org/files/v2.8/cmake-2.8.12.2-Darwin64-universal.tar.gz
		FEAT_BINARY_URL_FILENAME=cmake-2.8.12.2-Darwin64-universal.tar.gz
	fi
	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		FEAT_BINARY_URL=http://www.cmake.org/files/v2.8/cmake-2.8.12.2-Linux-i386.tar.gz
		FEAT_BINARY_URL_FILENAME=cmake-2.8.12.2-Linux-i386.tar.gz
	fi

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/cmake
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		CMAKE_FILE_APP="CMake 2.8-12.app"
	fi

}


function feature_cmake_3_2_3() {
	FEAT_VERSION=3_2_3
	# TODO  ** NEED : cURL-7.32.0, libarchive-3.1.2 and expat-2.1.0
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=http://www.cmake.org/files/v3.2/cmake-3.2.3.tar.gz
	FEAT_SOURCE_URL_FILENAME=cmake-3.2.3.tar.gz

	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		FEAT_BINARY_URL=http://www.cmake.org/files/v3.2/cmake-3.2.3-Darwin-x86_64.tar.gz
		FEAT_BINARY_URL_FILENAME=cmake-3.2.3-Darwin-x86_64.tar.gz
	fi
	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		FEAT_BINARY_URL=http://www.cmake.org/files/v3.2/cmake-3.2.3-Linux-x86_64.tar.gz
		FEAT_BINARY_URL_FILENAME=cmake-3.2.3-Linux-x86_64.tar.gz
	fi
	
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/cmake
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		CMAKE_FILE_APP="CMake.app"
	fi
}


function feature_cmake_3_3_1() {
	FEAT_VERSION=3_3_1
	# TODO  ** NEED : cURL-7.32.0, libarchive-3.1.2 and expat-2.1.0
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=http://www.cmake.org/files/v3.3/cmake-3.3.1.tar.gz
	FEAT_SOURCE_URL_FILENAME=cmake-3.3.1.tar.gz

	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		FEAT_BINARY_URL=http://www.cmake.org/files/v3.3/cmake-3.3.1-Darwin-x86_64.tar.gz
		FEAT_BINARY_URL_FILENAME=cmake-3.3.1-Darwin-x86_64.tar.gz
	fi
	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		FEAT_BINARY_URL="http://www.cmake.org/files/v3.3/cmake-3.3.1-Linux-x86_64.tar.gz"
		FEAT_BINARY_URL_FILENAME=cmake-3.3.1-Linux-x86_64.tar.gz
	fi
	
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/cmake
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		CMAKE_FILE_APP="CMake.app"
	fi
}


function feature_cmake_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-build"


	__download_uncompress "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_FILENAME" "$SRC_DIR" "DEST_ERASE STRIP"

	__set_toolset "STANDARD"

	__prepare_build "$INSTALL_DIR"

	__del_folder "$BUILD_DIR"
	mkdir -p "$BUILD_DIR"

	cd "$BUILD_DIR"

	chmod +x $SRC_DIR/bootstrap
	$SRC_DIR/bootstrap --prefix="$INSTALL_DIR"
	#cmake "$SRC_DIR" -DTEMPLATE_INSTALL_PREFIX="$INSTALL_DIR"
	#make -j$BUILD_JOB 
	make -j$STELLA_NB_CPU
	make install

	__del_folder "$SRC_DIR"
	__del_folder "$BUILD_DIR"


	__inspect_build "$INSTALL_DIR" "EXCLUDE_INSPECT /share/"

}


function feature_cmake_install_binary() {

	__download_uncompress "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_FILENAME" "$FEAT_INSTALL_ROOT" "DEST_ERASE STRIP"
	
	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		ln -s "$FEAT_INSTALL_ROOT"/"$CMAKE_FILE_APP"/Contents/bin "$FEAT_INSTALL_ROOT"/bin
		ln -s "$FEAT_INSTALL_ROOT"/"$CMAKE_FILE_APP"/Contents/doc "$FEAT_INSTALL_ROOT"/doc
		ln -s "$FEAT_INSTALL_ROOT"/"$CMAKE_FILE_APP"/Contents/man "$FEAT_INSTALL_ROOT"/man
		ln -s "$FEAT_INSTALL_ROOT"/"$CMAKE_FILE_APP"/Contents/share "$FEAT_INSTALL_ROOT"/share
	fi	
}


fi