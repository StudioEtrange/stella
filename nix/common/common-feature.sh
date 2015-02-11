if [ ! "$_STELLA_COMMON_FEATURE_INCLUDED_" == "1" ]; then 
_STELLA_COMMON_FEATURE_INCLUDED_=1


# --------------- FEATURES MANAGEMENT ----------------------------

function __list_active_features() {
	echo "$FEATURE_LIST_ENABLED"
}

function __init_installed_features() {
	local _flag
	for f in  "$STELLA_APP_FEATURE_ROOT"/*; do
		if [ -d "$f" ]; then
			_flag=0
			# check for official feature
			for a in $__STELLA_FEATURE_LIST; do
				if [ "$a" == "$(__get_filename_from_string $f)" ]; then
					# for each detected version
					for v in  "$f"/*; do
						[ -d "$v" ] && __init_feature $(__get_filename_from_string $f) $(__get_filename_from_string $v)
					done
				fi
			done
		fi
	done

	if [ ! "$STELLA_APP_FEATURE_ROOT" == "STELLA_INTERNAL_FEATURE_ROOT" ]; then
		# internal feature are not prioritary over app feature
		_save_app_feature_root=$STELLA_APP_FEATURE_ROOT
		STELLA_APP_FEATURE_ROOT=$STELLA_INTERNAL_FEATURE_ROOT
		for f in  "$STELLA_INTERNAL_FEATURE_ROOT"/*; do
			if [ -d "$f" ]; then
				_flag=0
				# check for official feature
				for a in $__STELLA_FEATURE_LIST; do
					if [ "$a" == "$(__get_filename_from_string $f)" ]; then
						# for each detected version
						for v in  "$f"/*; do
							[ -d "$v" ] && __init_feature $(__get_filename_from_string $f) $(__get_filename_from_string $v)
						done
					fi
				done
			fi
		done
		STELLA_APP_FEATURE_ROOT=$_save_app_feature_root
	fi


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
		if [ "$TEST_FEATURE" == "1" ]; then
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
	local _OPT="$3"

	local _opt_hidden_feature=OFF
	for o in $_OPT; do 
		[ "$o" == "HIDDEN" ] && _opt_hidden_feature=ON
	done

	local _save_app_feature_root=

	if [ "$_FEATURE" == "required" ]; then
		__stella_features_requirement_by_os $STELLA_CURRENT_OS
	else

		_flag=0
		# check for official feature
		for a in $__STELLA_FEATURE_LIST; do
			[ "$a" == "$_FEATURE" ] && _flag=1
		done
		
		if [ "$_flag" == "1" ]; then
			if [ "$_opt_hidden_feature" == "ON" ]; then
				_save_app_feature_root=$STELLA_APP_FEATURE_ROOT
				STELLA_APP_FEATURE_ROOT=$STELLA_INTERNAL_FEATURE_ROOT
			else
				__add_app_feature $_FEATURE $_VER
			fi


			source $STELLA_FEATURE_RECIPE/feature_$_FEATURE.sh

			if [ "$_VER" == "" ]; then
				_VER="$(__default_$_FEATURE)"
			fi

			_flag=0
			if [ ! "$FORCE" == "1" ]
				for a in $FEATURE_LIST_ENABLED; do 
					[ "$_FEATURE#$_VER" == "$a" ] && _flag=1
				done
			fi
			
			if [ "$_flag" == "0" ]; then
				FEATURE_PATH=

				__install_"$_FEATURE" $_VER
				__feature_"$_FEATURE" $_VER
				if [ "$TEST_FEATURE" == "1" ]; then
					FEATURE_LIST_ENABLED="$FEATURE_LIST_ENABLED $_FEATURE#$FEATURE_VER"
					if [ ! "$FEATURE_PATH" == "" ]; then
						PATH="$FEATURE_PATH:$PATH"
					fi
				fi
			else
				echo "** Feature $_FEATURE#$_VER already installed"
			fi

			if [ "$_opt_hidden_feature" == "ON" ]; then
				STELLA_APP_FEATURE_ROOT=$_save_app_feature_root
			fi
		fi
	fi
}

function __reinit_installed_features() {
	FEATURE_LIST_ENABLED=
	__init_installed_features
}






#FEATURES FOR CROSS COMPILING------------------------------------
# TODO : migrate to separate recipe (or erase?)
function __texinfo() {
	URL=http://ftp.gnu.org/gnu/texinfo/texinfo-5.1.tar.xz
	VER=5.1
	FILE_NAME=texinfo-5.1.tar.xz
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/cross-tools"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/texinfo-$VER-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/texinfo-$VER-build"

	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX=

	
	__auto_install "configure" "texinfo" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"

}

function __bc() {
	#http://www.gnu.org/software/bc/bc.html

	URL=http://alpha.gnu.org/gnu/bc/bc-1.06.95.tar.bz2
	VER=1.06.95
	FILE_NAME=bc-1.06.95.tar.bz2
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/cross-tools"	
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/bc-$VER-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/bc-$VER-build"

	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX=
	
	__auto_install "configure" "bc" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"
}

function __file5() {
	URL=ftp://ftp.astron.com/pub/file/file-5.15.tar.gz
	VER=5.15
	FILE_NAME=file-5.15.tar.gz
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/cross-tools"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/file-$VER-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/file-$VER-build"

	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX="--disable-static"

	__auto_install "configure" "file" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"

}

function __m4() {

	URL=http://ftp.gnu.org/gnu/m4/m4-1.4.17.tar.gz
	VER=1.4.17
	FILE_NAME=m4-1.4.17.tar.gz
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/cross-tools"	
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/m4-$VER-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/m4-$VER-build"

	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX=

	__auto_install "configure" "m4" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"
}

function __binutils() {
	#TODO configure flag
	URL=http://ftp.gnu.org/gnu/binutils/binutils-2.23.2.tar.bz2
	VER=2.23.2
	FILE_NAME=binutils-2.23.2.tar.bz2
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/cross-tools"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/binutils-$VER-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/binutils-$VER-build"

	AUTO_INSTALL_FLAG_PREFIX="AR=ar AS=as"
	AUTO_INSTALL_FLAG_POSTFIX="--host=$CROSS_HOST --target=$CROSS_TARGET \
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

	local _opt_without_configure=
	for o in $OPT; do 
		[ "$o" == "WITHOUT_CONFIGURE" ] && _opt_without_configure=ON
	done
	
	
	mkdir -p "$AUTO_BUILD_DIR"
	cd "$AUTO_BUILD_DIR"
	
	if [ ! "$_opt_without_configure" == "ON" ]; then
		chmod +x "$AUTO_SOURCE_DIR/configure"
		if [ "$AUTO_INSTALL_FLAG_PREFIX" == "" ]; then
			"$AUTO_SOURCE_DIR/configure" --prefix="$AUTO_INSTALL_DIR" $AUTO_INSTALL_FLAG_POSTFIX
		else
			$AUTO_INSTALL_FLAG_PREFIX "$AUTO_SOURCE_DIR/configure" --prefix="$AUTO_INSTALL_DIR" $AUTO_INSTALL_FLAG_POSTFIX
		fi

		make
		make install
	else
		$AUTO_SOURCE_DIR/make
		if [ "$AUTO_INSTALL_FLAG_PREFIX" == "" ]; then
			"$AUTO_SOURCE_DIR/make" prefix=$AUTO_INSTALL_DIR $AUTO_INSTALL_FLAG_POSTFIX install
		else
			$AUTO_INSTALL_FLAG_PREFIX "$AUTO_SOURCE_DIR/make" prefix=$AUTO_INSTALL_DIR $AUTO_INSTALL_FLAG_POSTFIX install
		fi
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

	

	MODE="$1"
	NAME="$2"
	FILE_NAME="$3"
	URL="$4"
	SOURCE_DIR="$5"
	BUILD_DIR="$6"
	INSTALL_DIR="$7"
	OPT="$8"

	# erase installation dir before install (default : FALSE)
	local _opt_dest_erase=
	# delete first folder in archive  (default : FALSE)
	local _opt_strip=
	# keep source code after build (default : FALSE)
	local _opt_source_keep=
	# keep build dir after build (default : FALSE)
	local _opt_build_keep=
	for o in $OPT; do 
		[ "$o" == "DEST_ERASE" ] && _opt_dest_erase=ON
		[ "$o" == "STRIP" ] && _opt_strip=ON
		[ "$o" == "SOURCE_KEEP" ] && _opt_source_keep=ON
		[ "$o" == "BUILD_KEEP" ] && _opt_build_keep=ON
	done

	

	echo " ** Installing $NAME in $INSTALL_DIR"

	local _store_dir=$(cd "$( dirname "." )" && pwd)

	[ "$_opt_dest_erase" == "ON" ] && rm -Rf "$INSTALL_DIR"
	mkdir -p "$INSTALL_DIR"

	local STRIP=
	[ "$_opt_strip" == "ON" ] && STRIP=STRIP
	__download_uncompress "$URL" "$FILE_NAME" "$SOURCE_DIR" "$STRIP"
	
	
	case $MODE in
		cmake)
				echo "TODO"
				;;
		configure)
				__auto_build_install_configure "$SOURCE_DIR" "$BUILD_DIR" "$INSTALL_DIR" 
				;;
		make)
				__auto_build_install_configure "$SOURCE_DIR" "$BUILD_DIR" "$INSTALL_DIR" "WITHOUT_CONFIGURE"
				;;
	esac

	cd $_store_dir

	[ ! "$_opt_source_keep" == "ON" ] && rm -Rf "$SOURCE_DIR"
	[ ! "$_opt_build_keep" == "ON" ] && rm -Rf "$BUILD_DIR"

	

	echo " ** Done"

}




fi
