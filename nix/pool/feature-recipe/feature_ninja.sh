if [ ! "$_NINJA_INCLUDED_" == "1" ]; then 
_NINJA_INCLUDED_=1



function __list_ninja() {
	echo "last_release"
}

function __default_ninja() {
	echo "last_release"
}

function __install_ninja() {
	local _VER=$1

	TEST_FEATURE=0
	FEATURE_PATH=
	FEATURE_ROOT=
	FEATURE_VER=

	mkdir -p $STELLA_APP_FEATURE_ROOT/ninja
	
	if [ "$_VER" == "" ]; then
		__install_ninja_$(__default_ninja)
	else
		# check for version
		for v in $(__list_ninja); do
			[ "$v" == "$_VER" ] && __install_ninja_$_VER
		done
	fi
	
}
function __feature_ninja() {
	local _VER=$1

	TEST_FEATURE=0
	FEATURE_PATH=
	FEATURE_ROOT=
	FEATURE_VER=

	if [ "$_VER" == "" ]; then
		__feature_ninja_$(__default_ninja)
	else
		# check for version
		for v in $(__list_ninja); do
			[ "$v" == "$_VER" ] && __feature_ninja_$_VER
		done
	fi
}


# --------------------------------------
function __install_ninja_last_release() {
	URL="https://github.com/martine/ninja/archive/release.zip"
	VER="last_release"
	FILE_NAME=ninja-release.zip
	__install_ninja_internal
}


function __feature_ninja_last_release() {
	FEATURE_TEST="$STELLA_APP_FEATURE_ROOT/ninja/last_release/ninja"
	FEATURE_RESULT_ROOT="$STELLA_APP_FEATURE_ROOT/ninja/last_release"
	FEATURE_RESULT_PATH="$FEATURE_RESULT_ROOT"
	FEATURE_RESULT_VER="last_release"
	__feature_ninja_internal
}


# --------------------------------------



function __install_ninja_internal() {
	
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/ninja/$VER"

	echo " ** Installing ninja in $INSTALL_DIR"
	echo " ** NEED : python"

	__feature_ninja_$VER
	if [ "$FORCE" ]; then
		TEST_FEATURE=0
		__del_folder $INSTALL_DIR
	fi
	if [ "$TEST_FEATURE" == "0" ]; then
		__download_uncompress "$URL" "$FILE_NAME" "$INSTALL_DIR" "DEST_ERASE STRIP"

		#TODO
		#prerequites python

		cd "$INSTALL_DIR"
		#python ./bootstrap.py
		python ./configure.py --bootstrap

		__feature_ninja_$VER
		if [ "$TEST_FEATURE" == "1" ]; then
			echo " ** Ninja installed"
			"$FEATURE_ROOT/ninja" --version
		else
			echo "** ERROR"
		fi
	else
		echo " ** Already installed"
	fi
}

function __feature_ninja_internal() {
	TEST_FEATURE=0
	
	if [ -f "$FEATURE_TEST" ]; then
		TEST_FEATURE=1
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : ninja in $FEATURE_RESULT_ROOT"
		FEATURE_PATH="$FEATURE_RESULT_PATH"
		FEATURE_ROOT="$FEATURE_RESULT_ROOT"
		FEATURE_VER="$FEATURE_RESULT_VER"
	fi
}


fi