if [ ! "$_PERL_INCLUDED_" == "1" ]; then 
_PERL_INCLUDED_=1


 
function __list_perl() {
	echo "5_18_2"
}


function __install_perl() {
	local _VER=$1
	local _DEFAULT_VER="5_18_2"

	mkdir -p $TOOL_ROOT/perl

	if [ "$_VER" == "" ]; then
		__install_perl_$_DEFAULT_VER
	else
		__install_perl_$_VER
	fi
}
function __feature_perl() {
	local _VER=$1
	local _DEFAULT_VER="5_18_2"

	if [ "$_VER" == "" ]; then
		__feature_perl_$_DEFAULT_VER
	else
		__feature_perl_$_VER
	fi
}


function __install_perl_5_18_2() { 
	URL=http://www.cpan.org/src/5.0/perl-5.18.2.tar.gz
	VER=5_18_2
	FILE_NAME=perl-5.18.2.tar.gz
	INSTALL_DIR="$TOOL_ROOT/perl/$VER"
	SRC_DIR="$TOOL_ROOT/perl/$VER/code/perl-$VER-src"
	BUILD_DIR=

	CONFIGURE_FLAG_PREFIX=
	CONFIGURE_FLAG_POSTFIX=

	__feature_perl_5_18_2
	if [ "$FORCE" ]; then
		TEST_FEATURE=0
		__del_folder $INSTALL_DIR
	fi
	if [ "$TEST_FEATURE" == "0" ]; then
		__download_uncompress "$URL" "$FILE_NAME" "$SRC_DIR" "DEST_ERASE STRIP"

		rm -Rf "$BUILD_DIR"
		mkdir -p "$INSTALL_DIR"
		cd "$SRC_DIR"

		sh "$SRC_DIR/Configure" -des -Dprefix=$INSTALL_DIR \
	                  -Dvendorprefix=$INSTALL_DIR \
	                  -Dpager="/usr/bin/less -isR"  \
	                  -Duseshrplib

		make -j$BUILD_JOB
		make install

		__feature_perl_5_18_2
		if [ ! "$TEST_FEATURE" == "0" ]; then
			echo " ** Perl installed"
			"$TEST_FEATURE/bin/perl" --version
		else
			echo "** ERROR"
		fi

	else
		echo " ** Already installed"
	fi
}
function __feature_perl_5_18_2() {
	TEST_FEATURE=0
	FEATURE_PATH=
	FEATURE_VER=
	if [ -f "$TOOL_ROOT/perl/5_18_2/bin/perl" ]; then
		TEST_FEATURE="$TOOL_ROOT/perl/5_18_2"
	fi

	if [ ! "$TEST_FEATURE" == "0" ]; then
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : perl in $TEST_FEATURE"
		FEATURE_PATH="$TEST_FEATURE/bin"
		FEATURE_VER="5_18_2"
	fi

}


fi