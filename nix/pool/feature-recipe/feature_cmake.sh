if [ ! "$_CMAKE_INCLUDED_" == "1" ]; then 
_CMAKE_INCLUDED_=1


function __list_cmake() {
	echo "3_1_2 2_8_12"
}

function __default_cmake() {
	echo "2_8_12"
}

function __install_cmake() {
	local _VER=$1

	TEST_FEATURE=0
	FEATURE_PATH=
	FEATURE_ROOT=
	FEATURE_VER=


	mkdir -p $STELLA_APP_FEATURE_ROOT/cmake
	if [ "$_VER" == "" ]; then
		__install_cmake_$(__default_cmake)
	else
		# check for version
		for v in $(__list_cmake); do
			[ "$v" == "$_VER" ] && __install_cmake_$_VER
		done
	fi
	
}
function __feature_cmake() {
	local _VER=$1

	TEST_FEATURE=0
	FEATURE_PATH=
	FEATURE_ROOT=
	FEATURE_VER=

	if [ "$_VER" == "" ]; then
		__feature_cmake_$(__default_cmake)
	else
		# check for version
		for v in $(__list_cmake); do
			[ "$v" == "$_VER" ] && __feature_cmake_$_VER
		done
	fi
}



# --------------------------------------
function __install_cmake_2_8_12() {
	URL=http://www.cmake.org/files/v2.8/cmake-2.8.12.tar.gz
	VER=2_8_12
	FILE_NAME=cmake-2.8.12.tar.gz
	echo " ** NEED : cURL-7.32.0, libarchive-3.1.2 and expat-2.1.0"
	__install_cmake_internal
}

function __feature_cmake_2_8_12() {
	FEATURE_TEST="$STELLA_APP_FEATURE_ROOT/cmake/2_8_12/bin/cmake"
	FEATURE_RESULT_ROOT="$STELLA_APP_FEATURE_ROOT/cmake/2_8_12"
	FEATURE_RESULT_PATH="$FEATURE_RESULT_ROOT/bin"
	FEATURE_RESULT_VER="2_8_12"
	__feature_cmake_internal
}

function __install_cmake_3_1_2() {
	URL=http://www.cmake.org/files/v3.1/cmake-3.1.2.tar.gz
	VER=3_1_2
	FILE_NAME=cmake-3.1.2.tar.gz
	#echo " ** NEED : cURL-7.32.0, libarchive-3.1.2 and expat-2.1.0"
	__install_cmake_internal
}


function __feature_cmake_3_1_2() {
	FEATURE_TEST="$STELLA_APP_FEATURE_ROOT/cmake/3_1_2/bin/cmake"
	FEATURE_RESULT_ROOT="$STELLA_APP_FEATURE_ROOT/cmake/3_1_2"
	FEATURE_RESULT_PATH="$FEATURE_RESULT_PATH/bin"
	FEATURE_RESULT_VER="3_1_2"
	__feature_cmake_internal

}


# --------------------------------------



function __install_cmake_internal() {
	
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/cmake/$VER"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/cmake/cmake_$VER-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/cmake/cmake_$VER-build"


	echo " ** Installing cmake version $VER in $INSTALL_DIR"
	

	__feature_cmake_$VER
	if [ "$FORCE" ]; then
		TEST_FEATURE=0
		__del_folder $INSTALL_DIR
	fi
	if [ "$TEST_FEATURE" == "0" ]; then

		__download_uncompress "$URL" "$FILE_NAME" "$SRC_DIR" "DEST_ERASE STRIP"

		__del_folder "$BUILD_DIR"
		mkdir -p "$BUILD_DIR"

		cd "$BUILD_DIR"

		chmod +x $SRC_DIR/bootstrap
		$SRC_DIR/bootstrap --prefix="$INSTALL_DIR"
		#cmake "$SRC_DIR" -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR"
		#make -j$BUILD_JOB 
		make
		make install


		__feature_cmake_$VER
		if [ "$TEST_FEATURE" == "1" ]; then
			echo " ** CMake installed"
			"$FEATURE_ROOT/bin/cmake" --version

			__del_folder "$BUILD_DIR"
			__del_folder "$SRC_DIR"

		else
			echo "** ERROR"
		fi
	else
		echo " ** Already installed"
	fi

}
function __feature_cmake_internal() {
	TEST_FEATURE=0
	
	if [ -f "$FEATURE_TEST" ]; then
		TEST_FEATURE=1
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : cmake in $FEATURE_RESULT_ROOT"
		FEATURE_PATH="$FEATURE_RESULT_PATH"
		FEATURE_ROOT="$FEATURE_RESULT_ROOT"
		FEATURE_VER="$FEATURE_RESULT_VER"
	fi
}

fi