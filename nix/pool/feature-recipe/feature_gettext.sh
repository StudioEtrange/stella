if [ ! "$_GETTEXT_INCLUDED_" == "1" ]; then 
_GETTEXT_INCLUDED_=1


function __list_gettext() {
	echo "0_19_4"
}

function __default_gettext() {
	echo "0_19_4"
}

function __install_gettext() {
		local _VER=$1

		mkdir -p $STELLA_APP_FEATURE_ROOT/gettext

		if [ "$_VER" == "" ]; then
			__install_gettext_$(__default_gettext)
		else
			# check for version
			for v in $(__list_gettext); do
				[ "$v" == "$_VER" ] && __install_gettext_$_VER
			done
		fi
}
function __feature_gettext() {
	local _VER=$1

	if [ "$_VER" == "" ]; then
		__feature_gettext_$(__default_gettext)
	else
		# check for version
		for v in $(__list_gettext); do
			[ "$v" == "$_VER" ] && __feature_gettext_$_VER
		done
	fi
}

# --------------------------------------
function __install_gettext_0_19_4() {
	URL=http://ftpmirror.gnu.org/gettext/gettext-0.19.4.tar.xz
	VER=0_19_4
	FILE_NAME=gettext-0.19.4.tar.xz
	__install_gettext_internal
}


function __feature_gettext_0_19_4() {
	FEATURE_TEST="$STELLA_APP_FEATURE_ROOT/gettext/0_19_4/bin/gettext"
	FEATURE_RESULT_ROOT="$STELLA_APP_FEATURE_ROOT/gettext/0_19_4"
	FEATURE_RESULT_PATH="$FEATURE_RESULT_ROOT/bin"
	FEATURE_RESULT_VER="0_19_4"
	__feature_gettext_internal
	FEATURE_TEST=
	FEATURE_RESULT_PATH=
	FEATURE_RESULT_ROOT=
	FEATURE_RESULT_VER=
}


# --------------------------------------
# https://github.com/Homebrew/homebrew/blob/master/Library/Formula/gettext.rb
function __install_gettext_internal() {
	
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/gettext/$VER"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/gettext/gettext-$VER-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/gettext/gettext-$VER-build"

export LDFLAGS="$RCS_STATIC_LINK_FLAGS $RCS_DYNAMIC_LINK_FLAGS" 
	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX="--disable-dependency-tracking \
                          --disable-silent-rules \
                          --disable-debug \
                          --with-included-gettext \
                          --with-included-glib \
                          --with-included-libcroco \
                          --with-included-libunistring \
                          --with-emacs \
                          --disable-java \
                          --disable-csharp \
                          --without-git \
                          --without-cvs\
                          --without-xz"

	feature_gettext_$VER
	if [ "$FORCE" ]; then
		TEST_FEATURE=0
		__del_folder "$INSTALL_DIR"
	fi
	if [ "$TEST_FEATURE" == "0" ]; then
		__auto_install "configure" "gettext" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "DEST_ERASE STRIP"
	else
		echo " ** Already installed"
	fi
}
function __feature_gettext_internal() {
	TEST_FEATURE=0
	FEATURE_ROOT=
	FEATURE_PATH=
	FEATURE_VER=
	if [ -f "$FEATURE_TEST" ]; then
		TEST_FEATURE=1
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : gettext in $FEATURE_RESULT_ROOT"
		FEATURE_PATH="$FEATURE_RESULT_PATH"
		FEATURE_ROOT="$FEATURE_RESULT_ROOT"
		FEATURE_VER="$FEATURE_RESULT_VER"
	fi
}

fi