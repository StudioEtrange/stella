if [ ! "$_getopt_INCLUDED_" == "1" ]; then 
_getopt_INCLUDED_=1

#TODO not finished
# https://github.com/Homebrew/homebrew/blob/master/Library/Formula/getopt.rb
# TODO : patch makefile with macport recipe ?

function __list_getopt() {
	echo "1_1_5"
}

function __default_getopt() {
	echo "1_1_5"
}

function __install_getopt() {
	local _VER=$1

	mkdir -p $STELLA_APP_FEATURE_ROOT/getopt

	if [ "$_VER" == "" ]; then
		__install_getopt_$(__default_getopt)
	else
		# check for version
		for v in $(__list_getopt); do
			[ "$v" == "$_VER" ] && __install_getopt_$_VER
		done
	fi
}
function __feature_getopt() {
	local _VER=$1

	if [ "$_VER" == "" ]; then
		__feature_getopt_$(__default_getopt)
	else
		# check for version
		for v in $(__list_getopt); do
			[ "$v" == "$_VER" ] && __feature_getopt_$_VER
		done
	fi
}

# --------------------------------------
function __install_getopt_1_1_5() {
	URL=http://frodo.looijaard.name/system/files/software/getopt/getopt-1.1.5.tar.gz
	VER=1_1_5
	FILE_NAME=getopt-1.1.5.tar.gz
	__install_getopt_internal
}


function __feature_getopt_1_1_5() {
	FEATURE_TEST="$STELLA_APP_FEATURE_ROOT/getopt/1_1_5/bin/getopt"
	FEATURE_RESULT_ROOT="$STELLA_APP_FEATURE_ROOT/getopt/1_1_5"
	FEATURE_RESULT_PATH="$FEATURE_RESULT_ROOT/bin"
	FEATURE_RESULT_VER="1_1_5"
	__feature_getopt_internal
	FEATURE_TEST=
	FEATURE_RESULT_PATH=
	FEATURE_RESULT_ROOT=
	FEATURE_RESULT_VER=
}


# --------------------------------------
function __install_getopt_internal() {
	
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/getopt/$VER"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/getopt/getopt-$VER-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/getopt/getopt-$VER-build"


	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX="MANDIR=man"

	feature_getopt_$VER
	if [ "$FORCE" ]; then
		TEST_FEATURE=0
		__del_folder "$INSTALL_DIR"
	fi
	if [ "$TEST_FEATURE" == "0" ]; then
		__auto_install "make" "getopt" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "DEST_ERASE STRIP"
	else
		echo " ** Already installed"
	fi
}
function __feature_getopt_internal() {
	TEST_FEATURE=0
	FEATURE_ROOT=
	FEATURE_PATH=
	FEATURE_VER=
	if [ -f "$FEATURE_TEST" ]; then
		TEST_FEATURE=1
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : getopt in $FEATURE_RESULT_ROOT"
		FEATURE_PATH="$FEATURE_RESULT_PATH"
		FEATURE_ROOT="$FEATURE_RESULT_ROOT"
		FEATURE_VER="$FEATURE_RESULT_VER"
	fi
}

fi