if [ ! "$_STELLA_COMMON_FEATURE_INCLUDED_" == "1" ]; then 
_STELLA_COMMON_FEATURE_INCLUDED_=1


# --------------- FEATURES MANAGEMENT ----------------------------

function __init_all_features() {
	for a in $__STELLA_FEATURE_LIST; do
		__init_feature $a
	done
	[ ! "$FEATURE_LIST_ENABLED" == "" ] && echo "** Features initialized : $FEATURE_LIST_ENABLED"
}

function __list_feature_version() {
	local _FEATURE=$1
	source $STELLA_FEATURE_RECIPE/feature_$_FEATURE.sh
	echo $(__list_"$_FEATURE")
}

function __init_feature() {
	local _FEATURE=$1
	local _VER=$2

	source $STELLA_FEATURE_RECIPE/feature_$_FEATURE.sh
	if [ "$_VER" == "" ]; then
		_VER="$(__default_$_FEATURE)"
	fi

	_flag=0
	for a in $FEATURE_LIST_ENABLED; do
		[ "$_FEATURE#$_VER" == "$a" ] && _flag=1
	done
	if [ "$_flag" == "0" ]; then
		FEATURE_PATH=
		__feature_"$_FEATURE" $_VER
		if [ ! "$TEST_FEATURE" == "0" ]; then
			FEATURE_LIST_ENABLED="$FEATURE_LIST_ENABLED $_FEATURE#$FEATURE_VER"
			if [ ! "$FEATURE_PATH" == "" ]; then
				PATH="$FEATURE_PATH:$PATH"
			fi
		fi
	fi
}

function __install_feature_list() {
	local _list=$1
	local _char="#"

	for f in $_list; do
		if [ -z "${f##*$_char*}" ]; then
			_VER=${f##*#}
			_FEATURE=${f%#*}
		else
			_VER=
			_FEATURE=$f
		fi
		__install_feature $_FEATURE $_VER
	done
}

function __install_feature() {
	local _FEATURE=$1
	local _VER=$2

	source $STELLA_FEATURE_RECIPE/feature_$_FEATURE.sh

	if [ "$_VER" == "" ]; then
		_VER="$(__default_$_FEATURE)"
	fi

	_flag=0
	for a in $FEATURE_LIST_ENABLED; do 
		[ "$_FEATURE#$_VER" == "$a" ] && _flag=1
	done
	if [ "$_flag" == "0" ]; then
		FEATURE_PATH=
		__install_"$_FEATURE" $_VER
		if [ ! "$TEST_FEATURE" == "0" ]; then
			FEATURE_LIST_ENABLED="$FEATURE_LIST_ENABLED $_FEATURE#$FEATURE_VER"
			if [ ! "$FEATURE_PATH" == "" ]; then
				PATH="$FEATURE_PATH:$PATH"
			fi
			__add_app_feature
		fi
	else
		echo "** Feature $_FEATURE#$_VER already installed"
	fi
}

function __reinit_all_features() {
	local _VER=
	local _FEATURE=
	for f in $FEATURE_LIST_ENABLED; do
		_VER=${f##*#}
		_FEATURE=${f%#*}
		FEATURE_PATH=
		source $STELLA_FEATURE_RECIPE/feature_$_FEATURE.sh
		__feature_"$_FEATURE" $_VER
		if [ ! "$TEST_FEATURE" == "0" ]; then
			if [ ! "$FEATURE_PATH" == "" ]; then 
				PATH="$FEATURE_PATH:$PATH"
			fi
		fi
	done
}






#FEATURES FOR CROSS COMPILING------------------------------------
# TODO : migrate to separate recipe (or erase?)
function __texinfo() {
	URL=http://ftp.gnu.org/gnu/texinfo/texinfo-5.1.tar.xz
	VER=5.1
	FILE_NAME=texinfo-5.1.tar.xz
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/cross-tools"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/cross-tools/code/texinfo-$VER-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/cross-tools/code/texinfo-$VER-build"

	CONFIGURE_FLAG_PREFIX=
	CONFIGURE_FLAG_POSTFIX=

	
	__auto_install "configure" "texinfo" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"

}

function __bc() {
	#http://www.gnu.org/software/bc/bc.html

	URL=http://alpha.gnu.org/gnu/bc/bc-1.06.95.tar.bz2
	VER=1.06.95
	FILE_NAME=bc-1.06.95.tar.bz2
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/cross-tools"	
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/cross-tools/code/bc-$VER-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/cross-tools/code/bc-$VER-build"

	CONFIGURE_FLAG_PREFIX=
	CONFIGURE_FLAG_POSTFIX=
	
	__auto_install "configure" "bc" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"
}

function __file5() {
	URL=ftp://ftp.astron.com/pub/file/file-5.15.tar.gz
	VER=5.15
	FILE_NAME=file-5.15.tar.gz
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/cross-tools"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/cross-tools/code/file-$VER-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/cross-tools/code/file-$VER-build"

	CONFIGURE_FLAG_PREFIX=
	CONFIGURE_FLAG_POSTFIX="--disable-static"

	__auto_install "configure" "file" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"

}

function __m4() {

	URL=http://ftp.gnu.org/gnu/m4/m4-1.4.17.tar.gz
	VER=1.4.17
	FILE_NAME=m4-1.4.17.tar.gz
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/cross-tools"	
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/cross-tools/code/m4-$VER-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/cross-tools/code/m4-$VER-build"

	CONFIGURE_FLAG_PREFIX=
	CONFIGURE_FLAG_POSTFIX=

	__auto_install "configure" "m4" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"
}

function __binutils() {
	#TODO configure flag
	URL=http://ftp.gnu.org/gnu/binutils/binutils-2.23.2.tar.bz2
	VER=2.23.2
	FILE_NAME=binutils-2.23.2.tar.bz2
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/cross-tools"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/cross-tools/code/binutils-$VER-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/cross-tools/code/binutils-$VER-build"

	CONFIGURE_FLAG_PREFIX="AR=ar AS=as"
	CONFIGURE_FLAG_POSTFIX="--host=$CROSS_HOST --target=$CROSS_TARGET \
  	--with-sysroot=${CLFS} --with-lib-path=/tools/lib --disable-nls \
  	--disable-static --enable-64-bit-bfd"

	__auto_install "configure" "binutils" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"
}









#INTERNAL FUNCTION---------------------------------------------------
function __auto_build_install_configure() {
	local AUTO_SOURCE_DIR
	local AUTO_BUILD_DIR
	local AUTO_INSTALL_DIR
	local OPT

	AUTO_SOURCE_DIR="$1"
	AUTO_BUILD_DIR="$2"
	AUTO_INSTALL_DIR="$3"
	OPT="$4"

	local _opt_dest_erase
	_opt_dest_erase=OFF # erase installation dir before install (default : FALSE)
	for o in $OPT; do 
		[ "$o" == "DEST_ERASE" ] && _opt_dest_erase=ON
	done


	[ "$_opt_dest_erase" == "ON" ] && rm -Rf "$AUTO_INSTALL_DIR"
	mkdir -p "$AUTO_INSTALL_DIR"
	

	# useless cause rm -Rf "$BUILD_DIR"
	#if [ ! "$NOCONFIG" ]; then
	#	if [ -d "$AUTO_BUILD_DIR" ]; then
	#		make distclean # useless cause rm -Rf "$BUILD_DIR"
	#		make clean # useless rm -Rf "$BUILD_DIR"
	#	fi
	#fi

	[ ! "$NOCONFIG" ] && rm -Rf "$AUTO_BUILD_DIR"
	mkdir -p "$AUTO_BUILD_DIR"

	cd "$AUTO_BUILD_DIR"

	if [ ! "$NOCONFIG" ]; then
		chmod +x "$AUTO_SOURCE_DIR/configure"
		if [ "$CONFIGURE_FLAG_PREFIX" == "" ]; then
			"$AUTO_SOURCE_DIR/configure" --prefix="$AUTO_INSTALL_DIR" $CONFIGURE_FLAG_POSTFIX
		else
			$CONFIGURE_FLAG_PREFIX "$AUTO_SOURCE_DIR/configure" --prefix="$AUTO_INSTALL_DIR" $CONFIGURE_FLAG_POSTFIX
		fi
	fi

	if [ ! "$NOBUILD" ]; then
		make -j$BUILD_JOB
		make install
	fi

}

function __auto_install() {
	local MODE
	local NAME
	local FILE_NAME
	local URL
	local SOURCE_DIR
	local BUILD_DIR
	local INSTALL_DIR
	local OPT
	local _opt_dest_erase
	local _opt_strip
	local DEST_ERASE

	MODE="$1"
	NAME="$2"
	FILE_NAME="$3"
	URL="$4"
	SOURCE_DIR="$5"
	BUILD_DIR="$6"
	INSTALL_DIR="$7"
	OPT="$8"


	_opt_dest_erase=OFF # erase installation dir before install (default : FALSE)
	_opt_strip=OFF # delete first folder in archive  (default : FALSE)
	for o in $OPT; do 
		[ "$o" == "DEST_ERASE" ] && _opt_dest_erase=ON
		[ "$o" == "STRIP" ] && _opt_strip=ON
	done


	echo " ** Installing $NAME in $INSTALL_DIR"

	__download_uncompress "$URL" "$FILE_NAME" "$SOURCE_DIR" "$OPT"
	
	DEST_ERASE=
	[ "$_opt_dest_erase" == "ON" ] && DEST_ERASE=DEST_ERASE
	
	case $MODE in
		cmake)
				echo "TODO"
				;;
		configure)
				__auto_build_install_configure "$SOURCE_DIR" "$BUILD_DIR" "$INSTALL_DIR" "$DEST_ERASE" 
				;;
	esac

	echo " ** Done"

}




fi
