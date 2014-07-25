if [ ! "$_WGET_INCLUDED_" == "1" ]; then 
_WGET_INCLUDED_=1


function list_wget() {
	echo "1_15"
}

function install_wget() {
	local _VER=$1
	local _DEFAULT_VER="1_15"

	mkdir -p $TOOL_ROOT/wget

	if [ "$_VER" == "" ]; then
		install_wget_$_DEFAULT_VER
	else
		install_wget_$_VER
	fi
}
function feature_wget() {
	local _VER=$1
	local _DEFAULT_VER="1_15"

	if [ "$_VER" == "" ]; then
		feature_wget_$_DEFAULT_VER
	else
		feature_wget_$_VER
	fi
}



function install_wget_1_15() {
	URL=http://ftp.gnu.org/gnu/wget/wget-1.15.tar.gz
	VER=1_15
	FILE_NAME=wget-1.15.tar.gz
	INSTALL_DIR="$TOOL_ROOT/wget/$VER"
	SRC_DIR="$TOOL_ROOT/wget/$VER/code/wget-$VER-src"
	BUILD_DIR="$TOOL_ROOT/wget/$VER/code/wget-$VER-build"


	CONFIGURE_FLAG_PREFIX=
	CONFIGURE_FLAG_POSTFIX="--with-ssl=openssl"

	feature_wget_1_15
	if [ "$FORCE" ]; then
		TEST_FEATURE=0
		del_folder $INSTALL_DIR
	fi
	if [ "$TEST_FEATURE" == "0" ]; then
		_auto_install "configure" "wget" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"
	else
		echo " ** Already installed"
	fi
}
function feature_wget_1_15() {
	TEST_FEATURE=0
	FEATURE_PATH=
	FEATURE_VER=
	if [ -f "$TOOL_ROOT/wget/$VER/bin/wget" ]; then
		TEST_FEATURE="$TOOL_ROOT/wget/$VER/bin"
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : wget in $TEST_FEATURE"
		FEATURE_PATH="$TEST_FEATURE"
		FEATURE_VER="1_15"
	fi
}

fi