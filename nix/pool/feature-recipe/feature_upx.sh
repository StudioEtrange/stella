if [ ! "$_UPX_INCLUDED_" == "1" ]; then 
_UPX_INCLUDED_=1


function __list_upx() {
	echo "3_91"
}

function __default_upx() {
	echo "3_91"
}

function __install_upx() {
	local _VER=$1

	TEST_FEATURE=0
	FEATURE_PATH=
	FEATURE_ROOT=
	FEATURE_VER=

	mkdir -p $STELLA_APP_FEATURE_ROOT/upx

	if [ "$_VER" == "" ]; then
		__install_upx_$(__default_upx)
	else
		# check for version
		for v in $(__list_upx); do
			[ "$v" == "$_VER" ] && __install_upx_$_VER
		done
	fi

}
function __feature_upx() {
	local _VER=$1

	TEST_FEATURE=0
	FEATURE_PATH=
	FEATURE_ROOT=
	FEATURE_VER=

	if [ "$_VER" == "" ]; then
		__feature_upx_$(__default_upx)
	else
		# check for version
		for v in $(__list_upx); do
			[ "$v" == "$_VER" ] && __feature_upx_$_VER
		done
	fi
}

# --------------------------------------
function __install_upx_3_91() {
	URL=http://upx.sourceforge.net/download/upx-3.91-src.tar.bz2
	VER=3_91
	FILE_NAME=upx-3.91-src.tar.bz2
	__install_upx_internal
}


function __feature_upx_3_91() {
	FEATURE_TEST="$STELLA_APP_FEATURE_ROOT/upx/3_91/bin/upx"
	FEATURE_RESULT_ROOT="$STELLA_APP_FEATURE_ROOT/upx/3_91"
	FEATURE_RESULT_PATH="$STELLA_APP_FEATURE_ROOT/upx/3_91/bin"
	FEATURE_RESULT_VER="3_91"
	__feature_upx_internal
}


# --------------------------------------

function __install_upx_internal() {
	
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/upx/$VER"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/upx/upx-$VER-src"
	BUILD_DIR=


	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX=""

	__feature_upx_$VER
	if [ "$FORCE" ]; then
		TEST_FEATURE=0
		__del_folder "$INSTALL_DIR"
	fi
	if [ "$TEST_FEATURE" == "0" ]; then
		__download_uncompress "$URL" "$FILE_NAME" "$SRC_DIR" "DEST_ERASE STRIP"

		# depend on ucl
		source $STELLA_FEATURE_RECIPE/feature_ucl.sh
		__feature_ucl_1_03
		export UPX_UCLDIR="$FEATURE_ROOT"
		ln -fs $FEATURE_ROOT/lib/libucl.a $FEATURE_ROOT/libucl.a


		# cant build doc
		sed -i".old" '/-C doc/d' "$SRC_DIR/Makefile"

		cd "$SRC_DIR"
		make all

		if [ -f "$SRC_DIR/src/upx.out" ]; then
			mkdir -p "$INSTALL_DIR/bin"
			cp "$SRC_DIR/src/upx.out" "$INSTALL_DIR/bin/upx"
		fi

		__feature_upx_$VER
		if [ "$TEST_FEATURE" == "1" ]; then
			echo " ** upx installed"
			"$FEATURE_PATH"/upx -V
			__del_folder "$SRC_DIR"

		else
			echo "** ERROR"
		fi


	else
		echo " ** Already installed"
	fi
}
function __feature_upx_internal() {
	TEST_FEATURE=0
	
	if [ -f "$FEATURE_TEST" ]; then
		TEST_FEATURE=1
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : upx in $FEATURE_RESULT_ROOT"
		FEATURE_PATH="$FEATURE_RESULT_PATH"
		FEATURE_ROOT="$FEATURE_RESULT_ROOT"
		FEATURE_VER="$FEATURE_RESULT_VER"
	fi
}

fi