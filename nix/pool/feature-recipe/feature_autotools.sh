if [ ! "$_AUTOTOOLS_INCLUDED_" == "1" ]; then 
_AUTOTOOLS_INCLUDED_=1

function __list_autotools() {
	echo "pack"
}


function __default_autotools() {
	echo "pack"
}

function __install_autotools() {
	local _VER=$1
	local _DEFAULT_VER="$(__default_autotools)"

	[ "$FORCE" ] && rm -Rf "$STELLA_APP_FEATURE_ROOT/autotools"
	[ ! -d "$STELLA_APP_FEATURE_ROOT/autotools" ] && mkdir -p "$STELLA_APP_FEATURE_ROOT/autotools"
	
	if [ "$_VER" == "" ]; then
		__install_autotools_$_DEFAULT_VER
	else
		__install_autotools_$_VER
	fi
}


function __feature_autotools() {
	local _VER=$1
	local _DEFAULT_VER="$(__default_autotools)"

	if [ "$_VER" == "" ]; then
		__feature_autotools_$_DEFAULT_VER
	else
		__feature_autotools_$_VER
	fi
}


function __install_autotools_pack() {
	# order is important
	# see http://petio.org/tools.html
	__install_autotools_m4_1_4_17
	__init_feature autotools m4_1_4_17
	__install_autotools_autoconf_2_69
	__init_feature autotools autoconf_2_69
	__install_autotools_automake_1_14
	__init_feature autotools automake_1_14
	__install_autotools_libtool_2_4_2
	__init_feature autotools libtool_2_4_2
}
function __feature_autotools_pack() {
	TEST_FEATURE=0
	FEATURE_PATH=
	FEATURE_VER=

	local _flag=1

	__feature_autotools_m4_1_4_17
	[ "$TEST_FEATURE" == "0" ] && _flag=0
	__feature_autotools_autoconf_2_69
	[ "$TEST_FEATURE" == "0" ] && _flag=0
	__feature_autotools_automake_1_14
	[ "$TEST_FEATURE" == "0" ] && _flag=0
	__feature_autotools_libtool_2_4_2
	[ "$TEST_FEATURE" == "0" ] && _flag=0

	if [ "$_flag" == "1" ]; then
		TEST_FEATURE=1
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : autotools in $FEATURE_RESULT_ROOT"
		FEATURE_ROOT="$STELLA_APP_FEATURE_ROOT/autotools"
		FEATURE_PATH="$FEATURE_ROOT/bin"
		FEATURE_VER=pack
	else
		TEST_FEATURE=0
		FEATURE_PATH=
		FEATURE_VER=
	fi
}




# ---------------------------------------

function __install_autotools_autoconf_2_69() {
	URL=http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
	VER=2.69
	FILE_NAME=autoconf-2.69.tar.gz
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/autotools"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/autoconf-$VER-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/autoconf-$VER-build"

	echo " ** NEED : perl 5.6"
	# TODO prerequites
	__init_feature "perl"

	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX="--docdir=$INSTALL_DIR/share/doc/automake-1.14"

	__feature_autotools_autoconf_2_69
	[ "$FORCE" ] && TEST_FEATURE=0
	if [ "$TEST_FEATURE" == "0" ]; then
		__auto_install "configure" "autoconf" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"
	else
		echo " ** Already installed"
	fi
}
function __feature_autotools_autoconf_2_69() {
	FEATURE_TEST="$STELLA_APP_FEATURE_ROOT/autotools/bin/autoconf"
	FEATURE_RESULT_ROOT="$STELLA_APP_FEATURE_ROOT/autotools"
	FEATURE_RESULT_PATH="$FEATURE_RESULT_ROOT/bin"
	FEATURE_RESULT_VER="2_69"
	__feature_autotools_internal autoconf
	[ "$TEST_FEATURE" == "1" ] && $FEATURE_RESULT_ROOT/bin/autoconf --version | sed -ne "1,1p"
	FEATURE_RESULT_PATH=
	FEATURE_RESULT_ROOT=
	FEATURE_RESULT_VER=

	
}




function __install_autotools_automake_1_14() {
	URL=http://ftp.gnu.org/gnu/automake/automake-1.14.tar.gz
	VER=1.14
	FILE_NAME=automake-1.14.tar.gz
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/autotools"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/automake-$VER-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/automake-$VER-build"

	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX="--docdir=$INSTALL_DIR/share/doc/automake-1.14"

	__feature_autotools_automake_1_14
	[ "$FORCE" ] && TEST_FEATURE=0
	if [ "$TEST_FEATURE" == "0" ]; then
		__auto_install "configure" "automake" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"
	else
		echo " ** Already installed"
	fi
}
function __feature_autotools_automake_1_14() {
	FEATURE_TEST="$STELLA_APP_FEATURE_ROOT/autotools/bin/automake"
	FEATURE_RESULT_ROOT="$STELLA_APP_FEATURE_ROOT/autotools"
	FEATURE_RESULT_PATH="$FEATURE_RESULT_ROOT/bin"
	FEATURE_RESULT_VER="1_14"
	__feature_autotools_internal automake
	[ "$TEST_FEATURE" == "1" ] && $FEATURE_RESULT_ROOT/bin/automake --version | sed -ne "1,1p"
	FEATURE_RESULT_PATH=
	FEATURE_RESULT_ROOT=
	FEATURE_RESULT_VER=

}




function __install_autotools_libtool_2_4_2() {
	URL=http://ftp.gnu.org/gnu/libtool/libtool-2.4.2.tar.gz
	VER=2.4.2
	FILE_NAME=libtool-2.4.2.tar.gz
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/autotools"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/libtool-$VER-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/libtool-$VER-build"

	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX=

	__feature_autotools_libtool_2_4_2
	[ "$FORCE" ] && TEST_FEATURE=0
	if [ "$TEST_FEATURE" == "0" ]; then
		__auto_install "configure" "libtool" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"
	else
		echo " ** Already installed"
	fi
}
function __feature_autotools_libtool_2_4_2() {
	FEATURE_TEST="$STELLA_APP_FEATURE_ROOT/autotools/bin/libtool"
	FEATURE_RESULT_ROOT="$STELLA_APP_FEATURE_ROOT/autotools"
	FEATURE_RESULT_PATH="$FEATURE_RESULT_ROOT/bin"
	FEATURE_RESULT_VER="2_4_2"
	__feature_autotools_internal libtool
	[ "$TEST_FEATURE" == "1" ] && $FEATURE_RESULT_ROOT/bin/libtool --version | sed -ne "1,1p"
	FEATURE_RESULT_PATH=
	FEATURE_RESULT_ROOT=
	FEATURE_RESULT_VER=

	
}




function __install_autotools_m4_1_4_17() {
	URL=http://ftp.gnu.org/gnu/m4/m4-1.4.17.tar.gz
	VER=1.4.17
	FILE_NAME=m4-1.4.17.tar.gz
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/autotools"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/m4-$VER-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/m4-$VER-build"

	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX=

	__feature_autotools_m4_1_4_17
	[ "$FORCE" ] && TEST_FEATURE=0
	if [ "$TEST_FEATURE" == "0" ]; then
		__auto_install "configure" "m4" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"
	else
		echo " ** Already installed"
	fi
}
function __feature_autotools_m4_1_4_17() {
	FEATURE_TEST="$STELLA_APP_FEATURE_ROOT/autotools/bin/m4"
	FEATURE_RESULT_ROOT="$STELLA_APP_FEATURE_ROOT/autotools"
	FEATURE_RESULT_PATH="$FEATURE_RESULT_ROOT/bin"
	FEATURE_RESULT_VER="1_4_17"
	__feature_autotools_internal m4
	[ "$TEST_FEATURE" == "1" ] && $FEATURE_RESULT_ROOT/bin/m4 --version | sed -ne "1,1p"
	FEATURE_RESULT_PATH=
	FEATURE_RESULT_ROOT=
	FEATURE_RESULT_VER=

	
}





function __feature_autotools_internal() {
	TEST_FEATURE=0
	FEATURE_ROOT=
	FEATURE_PATH=
	FEATURE_VER=
	if [ -f "$FEATURE_TEST" ]; then
		TEST_FEATURE=1
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : $1 in $FEATURE_RESULT_ROOT"
		FEATURE_PATH="$FEATURE_RESULT_PATH"
		FEATURE_ROOT="$FEATURE_RESULT_ROOT"
		FEATURE_VER="$FEATURE_RESULT_VER"
	fi
}




fi