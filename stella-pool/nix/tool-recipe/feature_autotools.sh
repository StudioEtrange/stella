if [ ! "$_AUTOTOOLS_INCLUDED_" == "1" ]; then 
_AUTOTOOLS_INCLUDED_=1

function __list_autotools() {
	echo "N/A"
}

function __install_autotools() {
	[ "$FORCE" ] && rm -Rf "$STELLA_APP_TOOL_ROOT/autotools"
	[ ! -d "$STELLA_APP_TOOL_ROOT/autotools" ] && mkdir -p "$STELLA_APP_TOOL_ROOT/autotools"
	# order is important
	# see http://petio.org/tools.html
	__install_m4_1_4_17
	__install_autoconf_2_69
	__install_automake_1_14
	__install_libtool_2_4_2
	__feature_autotools
}
function __feature_autotools() {
	TEST_FEATURE=0
	FEATURE_PATH=
	FEATURE_VER=
	if [ -f "$STELLA_APP_TOOL_ROOT/autotools/bin/autoconf" ]; then
		TEST_FEATURE="$STELLA_APP_TOOL_ROOT/autotools/bin"
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : autotools in $TEST_FEATURE"
		FEATURE_PATH="$TEST_FEATURE"
	fi
}

function __install_autoconf_2_69() {
	URL=http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
	VER=2.69
	FILE_NAME=autoconf-2.69.tar.gz
	INSTALL_DIR="$STELLA_APP_TOOL_ROOT/autotools"
	SRC_DIR="$STELLA_APP_TOOL_ROOT/autotools/code/autoconf-$VER-src"
	BUILD_DIR="$STELLA_APP_TOOL_ROOT/autotools/code/autoconf-$VER-build"

	echo " ** NEED : perl 5.6"
	# TODO prerequites
	__init_feature "perl"

	CONFIGURE_FLAG_PREFIX=
	CONFIGURE_FLAG_POSTFIX="--docdir=$INSTALL_DIR/share/doc/automake-1.14"

	__feature_autoconf_2_69
	[ "$FORCE" ] && TEST_FEATURE=0
	if [ "$TEST_FEATURE" == "0" ]; then
		__auto_install "configure" "autoconf" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"
	else
		echo " ** Already installed"
	fi
}
function __feature_autoconf_2_69() {
	TEST_FEATURE=0
	FEATURE_PATH=
	FEATURE_VER=
	if [ -f "$STELLA_APP_TOOL_ROOT/autotools/bin/autoconf" ]; then
		TEST_FEATURE="$STELLA_APP_TOOL_ROOT/autotools/bin"
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : autoconf in $TEST_FEATURE"
		$TEST_FEATURE/autoconf --version | sed -ne "1,1p"
		FEATURE_PATH="$TEST_FEATURE"
		FEATURE_VER=2_69
	fi
}


function __install_automake_1_14() {
	URL=http://ftp.gnu.org/gnu/automake/automake-1.14.tar.gz
	VER=1.14
	FILE_NAME=automake-1.14.tar.gz
	INSTALL_DIR="$STELLA_APP_TOOL_ROOT/autotools"
	SRC_DIR="$STELLA_APP_TOOL_ROOT/autotools/code/automake-$VER-src"
	BUILD_DIR="$STELLA_APP_TOOL_ROOT/autotools/code/automake-$VER-build"

	CONFIGURE_FLAG_PREFIX=
	CONFIGURE_FLAG_POSTFIX="--docdir=$INSTALL_DIR/share/doc/automake-1.14"

	__feature_automake_1_14
	[ "$FORCE" ] && TEST_FEATURE=0
	if [ "$TEST_FEATURE" == "0" ]; then
		__auto_install "configure" "automake" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"
	else
		echo " ** Already installed"
	fi
}
function __feature_automake_1_14() {
	TEST_FEATURE=0
	FEATURE_PATH=
	FEATURE_VER=
	if [ -f "$STELLA_APP_TOOL_ROOT/autotools/bin/automake" ]; then
		TEST_FEATURE="$STELLA_APP_TOOL_ROOT/autotools/bin"
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : automake in $TEST_FEATURE"
		$TEST_FEATURE/automake --version | sed -ne "1,1p"
		FEATURE_PATH="$TEST_FEATURE"
		FEATURE_VER=1_14
	fi
}

function __install_libtool_2_4_2() {
	URL=http://ftp.gnu.org/gnu/libtool/libtool-2.4.2.tar.gz
	VER=2.4.2
	FILE_NAME=libtool-2.4.2.tar.gz
	INSTALL_DIR="$STELLA_APP_TOOL_ROOT/autotools"
	SRC_DIR="$STELLA_APP_TOOL_ROOT/autotools/code/libtool-$VER-src"
	BUILD_DIR="$STELLA_APP_TOOL_ROOT/autotools/code/libtool-$VER-build"

	CONFIGURE_FLAG_PREFIX=
	CONFIGURE_FLAG_POSTFIX=

	feature_libtool_2_4_2
	[ "$FORCE" ] && TEST_FEATURE=0
	if [ "$TEST_FEATURE" == "0" ]; then
		__auto_install "configure" "libtool" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"
	else
		echo " ** Already installed"
	fi
}
function __feature_libtool_2_4_2() {
	TEST_FEATURE=0
	FEATURE_PATH=
	FEATURE_VER=
	if [ -f "$STELLA_APP_TOOL_ROOT/autotools/bin/libtool" ]; then
		TEST_FEATURE="$STELLA_APP_TOOL_ROOT/autotools/bin"
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : libtool in $TEST_FEATURE"
		$TEST_FEATURE/libtool --version | sed -ne "1,1p"
		FEATURE_PATH="$TEST_FEATURE"
		FEATURE_VER=2_4_2
	fi
}

function __install_m4_1_4_17() {
	URL=http://ftp.gnu.org/gnu/m4/m4-1.4.17.tar.gz
	VER=1.4.17
	FILE_NAME=m4-1.4.17.tar.gz
	INSTALL_DIR="$STELLA_APP_TOOL_ROOT/autotools"
	SRC_DIR="$STELLA_APP_TOOL_ROOT/autotools/code/m4-$VER-src"
	BUILD_DIR="$STELLA_APP_TOOL_ROOT/autotools/code/m4-$VER-build"

	CONFIGURE_FLAG_PREFIX=
	CONFIGURE_FLAG_POSTFIX=

	__feature_m4_1_4_17
	[ "$FORCE" ] && TEST_FEATURE=0
	if [ "$TEST_FEATURE" == "0" ]; then
		__auto_install "configure" "m4" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"
	else
		echo " ** Already installed"
	fi
}
function __feature_m4_1_4_17() {
	TEST_FEATURE=0
	FEATURE_PATH=
	FEATURE_VER=
	if [ -f "$STELLA_APP_TOOL_ROOT/autotools/bin/m4" ]; then
		TEST_FEATURE="$STELLA_APP_TOOL_ROOT/autotools/bin"
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : m4 in $TEST_FEATURE"
		$TEST_FEATURE/m4 --version | sed -ne "1,1p"
		FEATURE_PATH="$TEST_FEATURE"
		FEATURE_VER=1_4_17
	fi
}


fi