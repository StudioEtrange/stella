if [ ! "$_UCL_INCLUDED_" == "1" ]; then 
_UCL_INCLUDED_=1


function __list_ucl() {
	echo "1_03"
}

function __default_ucl() {
	echo "1_03"
}

function __install_ucl() {
	local _VER=$1

	mkdir -p $STELLA_APP_FEATURE_ROOT/ucl

	if [ "$_VER" == "" ]; then
		__install_ucl_$(__default_ucl)
	else
		# check for version
		for v in $(__list_ucl); do
			[ "$v" == "$_VER" ] && __install_ucl_$_VER
		done
	fi

}
function __feature_ucl() {
	local _VER=$1

	if [ "$_VER" == "" ]; then
		__feature_ucl_$(__default_ucl)
	else
		# check for version
		for v in $(__list_ucl); do
			[ "$v" == "$_VER" ] && __feature_ucl_$_VER
		done
	fi
}

# --------------------------------------
function __install_ucl_1_03() {
	URL=http://www.oberhumer.com/opensource/ucl/download/ucl-1.03.tar.gz
	VER=1_03
	FILE_NAME=ucl-1.03.tar.gz
	__install_ucl_internal
}


function __feature_ucl_1_03() {
	FEATURE_TEST="$STELLA_APP_FEATURE_ROOT/ucl/1_03/lib/libucl.a"
	FEATURE_RESULT_ROOT="$STELLA_APP_FEATURE_ROOT/ucl/1_03"
	FEATURE_RESULT_PATH="$STELLA_APP_FEATURE_ROOT/ucl/1_03/lib"
	FEATURE_RESULT_VER="1_03"
	__feature_ucl_internal
}


# --------------------------------------

function __install_ucl_internal() {
	
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/ucl/$VER"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/ucl/ucl-$VER-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/ucl/ucl-$VER-build"


	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX=""

	__feature_ucl_$VER
	if [ "$FORCE" ]; then
		TEST_FEATURE=0
		__del_folder "$INSTALL_DIR"
	fi
	if [ "$TEST_FEATURE" == "0" ]; then
		__auto_install "configure" "ucl" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "DEST_ERASE STRIP"

		__feature_ucl_$VER
		if [ "$TEST_FEATURE" == "1" ]; then
			echo " ** ucl installed"
		else
			echo "** ERROR"
		fi

	else
		echo " ** Already installed"
	fi
}
function __feature_ucl_internal() {
	TEST_FEATURE=0
	
	if [ -f "$FEATURE_TEST" ]; then
		TEST_FEATURE=1
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : ucl in $FEATURE_RESULT_ROOT"
		FEATURE_PATH="$FEATURE_RESULT_PATH"
		FEATURE_ROOT="$FEATURE_RESULT_ROOT"
		FEATURE_VER="$FEATURE_RESULT_VER"
	fi
}

fi