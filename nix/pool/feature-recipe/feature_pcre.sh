if [ ! "$_PCRE_INCLUDED_" == "1" ]; then 
_PCRE_INCLUDED_=1


function __list_pcre() {
	echo "8_36"
}

function __default_pcre() {
	echo "8_36"
}

function __install_pcre() {
	local _VER=$1

	mkdir -p $STELLA_APP_FEATURE_ROOT/pcre

	if [ "$_VER" == "" ]; then
		__install_pcre_$(__default_pcre)
	else
		# check for version
		for v in $(__list_pcre); do
			[ "$v" == "$_VER" ] && __install_pcre_$_VER
		done
	fi

}
function __feature_pcre() {
	local _VER=$1

	if [ "$_VER" == "" ]; then
		__feature_pcre_$(__default_pcre)
	else
		# check for version
		for v in $(__list_pcre); do
			[ "$v" == "$_VER" ] && __feature_pcre_$_VER
		done
	fi
}

# --------------------------------------
function __install_pcre_8_36() {
	URL=https://downloads.sourceforge.net/project/pcre/pcre/8.36/pcre-8.36.tar.bz2
	VER=8_36
	FILE_NAME=pcre-8.36.tar.bz2
	__install_pcre_internal
}


function __feature_pcre_8_36() {
	FEATURE_TEST="$STELLA_APP_FEATURE_ROOT/pcre/8_36/lib/libpcre.a"
	FEATURE_RESULT_ROOT="$STELLA_APP_FEATURE_ROOT/pcre/8_36"
	FEATURE_RESULT_PATH="$STELLA_APP_FEATURE_ROOT/pcre/8_36/lib"
	FEATURE_RESULT_VER="8_36"
	__feature_pcre_internal
}


# --------------------------------------

function __install_pcre_internal() {
	
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/pcre/$VER"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/pcre/pcre-$VER-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/pcre/pcre-$VER-build"


	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX="--disable-dependency-tracking \
                          --enable-utf8 \
                          --enable-pcre8 \
                          --enable-pcre16 \
                          --enable-pcre32 \
                          --enable-unicode-properties \
                          --enable-pcregrep-libz \
                          --enable-pcregrep-libbz2 \
                          --enable-jit"

	__feature_pcre_$VER
	if [ "$FORCE" ]; then
		TEST_FEATURE=0
		__del_folder "$INSTALL_DIR"
	fi
	if [ "$TEST_FEATURE" == "0" ]; then
		__auto_install "configure" "pcre" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "DEST_ERASE STRIP"

		__feature_pcre_$VER
		if [ "$TEST_FEATURE" == "1" ]; then
			echo " ** pcre installed"
		else
			echo "** ERROR"
		fi

	else
		echo " ** Already installed"
	fi
}
function __feature_pcre_internal() {
	TEST_FEATURE=0
	
	if [ -f "$FEATURE_TEST" ]; then
		TEST_FEATURE=1
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : pcre in $FEATURE_RESULT_ROOT"
		FEATURE_PATH="$FEATURE_RESULT_PATH"
		FEATURE_ROOT="$FEATURE_RESULT_ROOT"
		FEATURE_VER="$FEATURE_RESULT_VER"
	fi
}

fi