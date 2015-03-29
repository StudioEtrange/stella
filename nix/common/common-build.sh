if [ ! "$_STELLA_COMMON_BUILD_INCLUDED_" == "1" ]; then 
_STELLA_COMMON_BUILD_INCLUDED_=1

# NOTE : homebrew flag setting system : https://github.com/Homebrew/homebrew/blob/master/Library/Homebrew/extend/ENV/super.rb

# MACOS specific build : install_name, rpath, loader_path, executable_path ---------------------------
# fix rpath value
#		remove all rpath value
#		add "@loader_path/" and "." as rpath 
function __fix_rpath_darwin() {
	local _file=$1

	otool -l "$_file" | grep -E "LC_RPATH" -A2 | grep path | tr -s ' ' | cut -d ' ' -f 3 | while read -r line; do 
		if [ ! "$line" == "." ]; then
			if [ ! "$line" == "@loader_path/" ]; then
				install_name_tool -delete_rpath "$line" "$_file"
			fi
		fi
	done;

	install_name_tool -add_rpath "." "$_file"
	install_name_tool -add_rpath "@loader_path/" "$_file"
}

# fix linked dynamic lib with hardcoded path with @rpath/libname
function __fix_linked_lib_darwin() {
	local _file=$1
	local _linked_lib_name=$2

	local _linked_lib_path=$(otool -l $_file | grep -E "LC_LOAD_DYLIB" -A2 | grep $_linked_lib_name | tr -s ' ' | cut -d ' ' -f 3)
	local _linked_lib_filename=$(__get_filename_from_string $_linked_lib_path)
	install_name_tool -change "$_linked_lib_path" "@rpath/$_linked_lib_filename" "$_file"

}



# fix install name with @rpath/lib_name
function __fix_dynamiclib_install_name_darwin() {
	local _lib=$1
	
	if [ -f "$_lib" ]; then
		_original_install_name=$(otool -l $_lib | grep -E "LC_ID_DYLIB" -A2 | grep name | tr -s ' ' | cut -d ' ' -f 3)

		case $_original_install_name in
			@rpath*)
			;;

			*)
				_new_install_name=@rpath/$(__get_filename_from_string $_original_install_name)
				install_name_tool -id "$_new_install_name" $_lib
			;;

		esac
	fi

}

# fix install name with @rpath/lib_name
# find all dylib beginning with _lib_root_name
function __fix_dynamiclib_install_name_darwin_by_rootname() {
	local _lib_path=$1
	local _lib_root_name=$2

	for l in $_lib_path/$_lib_root_name*.dylib; do
		__fix_dynamiclib_install_name_darwin $l
	done
}

# fix install name with @rpath/lib_name
# find all dylib inside a specified folder
function __fix_dynamiclib_install_name_darwin_by_folder() {
	for f in  "$1"/*; do
		[ -d "$f" ] && __fix_all_dynamiclib_install_name_darwin "$f"
		if [ -f "$f" ]; then
			case $f in
				*.dylib) __fix_dynamiclib_install_name_darwin "$f"
				;;
			esac
		fi
	done
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
		if [ "$AUTO_INSTALL_FLAG_PREFIX" == "" ]; then
			make -C "$AUTO_SOURCE_DIR" prefix=$AUTO_INSTALL_DIR $AUTO_INSTALL_FLAG_POSTFIX install
		else
			$AUTO_INSTALL_FLAG_PREFIX make -C "$AUTO_SOURCE_DIR" prefix=$AUTO_INSTALL_DIR $AUTO_INSTALL_FLAG_POSTFIX install
		fi
	fi
	
}



#---------------------------
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

	

	echo " ** Auto-installing $NAME in $INSTALL_DIR"

	#local _store_dir="$(cd "$( dirname "." )" && pwd)"

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

	#cd $_store_dir

	[ ! "$_opt_source_keep" == "ON" ] && rm -Rf "$SOURCE_DIR"
	[ ! "$_opt_build_keep" == "ON" ] && rm -Rf "$BUILD_DIR"

	

	echo " ** Done"

}




fi