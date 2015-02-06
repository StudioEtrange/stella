if [ ! "$_STELLA_COMMON_BUILD_INCLUDED_" == "1" ]; then 
_STELLA_COMMON_BUILD_INCLUDED_=1



# MACOS specific build : install_name, rpath, loader_path, executable_path ---------------------------
# fix rpath value
#		remove all rpath value
#		add "@loader_path/" and "." as rpath 
function __fix_rpath_macos() {
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
function __fix_linked_lib_macos() {
	local _file=$1
	local _linked_lib_name=$2

	local _linked_lib_path=$(otool -l $_file | grep -E "LC_LOAD_DYLIB" -A2 | grep $_linked_lib_name | tr -s ' ' | cut -d ' ' -f 3)
	local _linked_lib_filename=$(__get_filename_from_string $_linked_lib_path)
	install_name_tool -change "$_linked_lib_path" "@rpath/$_linked_lib_filename" "$_file"

}



# fix install name with @rpath/lib_name
function __fix_dynamiclib_install_name_macos() {
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
function __fix_dynamiclib_install_name_macos_by_rootname() {
	local _lib_path=$1
	local _lib_root_name=$2

	for l in $_lib_path/$_lib_root_name*.dylib; do
		__fix_dynamiclib_install_name_macos $l
	done
}

# fix install name with @rpath/lib_name
# find all dylib inside a specified folder
function __fix_dynamiclib_install_name_macos_by_folder() {
	for f in  "$1"/*; do
		[ -d "$f" ] && __fix_all_dynamiclib_install_name_macos "$f"
		if [ -f "$f" ]; then
			case $f in
				*.dylib) __fix_dynamiclib_install_name_macos "$f"
				;;
			esac
		fi
	done
}


fi