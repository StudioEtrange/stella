if [ ! "$_WGET_INCLUDED_" == "1" ]; then 
_WGET_INCLUDED_=1


function __list_wget() {
	echo "1_15"
}

function __default_wget() {
	echo "1_15"
}

function __install_wget() {
	local _VER=$1
	local _DEFAULT_VER="$(__default_wget)"

	mkdir -p $STELLA_APP_FEATURE_ROOT/wget

	if [ "$_VER" == "" ]; then
		__install_wget_$_DEFAULT_VER
	else
		__install_wget_$_VER
	fi
}
function __feature_wget() {
	local _VER=$1
	local _DEFAULT_VER="$(__default_wget)"

	if [ "$_VER" == "" ]; then
		__feature_wget_$_DEFAULT_VER
	else
		__feature_wget_$_VER
	fi
}

# --------------------------------------
function __install_wget_1_15() {
	URL=http://ftp.gnu.org/gnu/wget/wget-1.15.tar.gz
	VER=1_15
	FILE_NAME=wget-1.15.tar.gz
	__install_wget_internal
}


function __feature_wget_1_15() {
	FEATURE_TEST="$STELLA_APP_FEATURE_ROOT/wget/1_15/bin/wget"
	FEATURE_RESULT_ROOT="$STELLA_APP_FEATURE_ROOT/wget/1_15"
	FEATURE_RESULT_PATH="$FEATURE_RESULT_ROOT/bin"
	FEATURE_RESULT_VER="1_15"
	__feature_wget_internal
}


# --------------------------------------

function __install_wget_internal() {
	
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/wget/$VER"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/wget/$VER/code/wget-$VER-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/wget/$VER/code/wget-$VER-build"


	CONFIGURE_FLAG_PREFIX=
	CONFIGURE_FLAG_POSTFIX="--with-ssl=openssl"

	feature_wget_$VER
	if [ "$FORCE" ]; then
		TEST_FEATURE=0
		__del_folder $INSTALL_DIR
	fi
	if [ "$TEST_FEATURE" == "0" ]; then
		__auto_install "configure" "wget" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"
	else
		echo " ** Already installed"
	fi
}
function __feature_wget_internal() {
	TEST_FEATURE=0
	FEATURE_ROOT=
	FEATURE_PATH=
	FEATURE_VER=
	if [ -f "$FEATURE_TEST" ]; then
		TEST_FEATURE=1
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : wget in $FEATURE_RESULT_ROOT"
		FEATURE_PATH="$FEATURE_RESULT_PATH"
		FEATURE_ROOT="$FEATURE_RESULT_ROOT"
		FEATURE_VER="$FEATURE_RESULT_VER"
	fi
}

fi