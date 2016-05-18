if [ ! "$_STELLA_COMMON_BINARY_INCLUDED_" == "1" ]; then
_STELLA_COMMON_BINARY_INCLUDED_=1

# GENERIC
# __get_arch
# __check_arch

# __check_binary_files


# DARWIN | LINUX
# __is_darwin_bin 								__is_linux_bin

# __get_install_name_darwin
# __check_install_name_darwin
# __tweak_install_name_darwin

# __get_rpath_darwin
# __have_rpath_darwin
# __tweak_rpath_darwin						__tweak_rpath_linux
# __remove_all_rpath_darwin
# __add_rpath_darwin							__add_rpath_linux
# __check_rpath_darwin						__check_rpath_linux

# __get_linked_lib_darwin
# __check_linked_lib_darwin				__check_linked_lib_linux
# __fix_linked_lib_darwin



# GENERIC -------------------------------------------------------------------
function __get_arch() {
	local _file=$1
	local _result=

	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		_result="$(otool -hv $_file | grep MH_MAGIC_64)"

		if [ ! "$_result" == "" ]; then
			_result=x64
		else
			_result=x86
		fi
	fi

	# TODO
	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		_result="TODO"
	fi

	echo "$_result"
}


function __check_arch() {
	local _file="$1"
	local _wanted_arch="$2"
	local _arch=
	local _result=0

	_arch="$(__get_arch $_file)"

	if [ "$_wanted_arch" == "" ]; then
		echo "*** Detected ARCH : $_arch"
	else
		if [ "$_wanted_arch" == "$_arch" ]; then
			echo "*** Detected ARCH : $_arch -- OK"
		else
			_result=1
			echo "*** Detected ARCH : $_arch Wanted ARCH : $_wanted_arch -- WARN"
		fi
	fi

	return $_result
}


# for stella built files
#__check_binary_files NON_RELOCATE ARCH "$STELLA_BUILD_ARCH" MISSING_RPATH $STELLA_BUILD_RPATH...


function __check_binary_files() {
	local path="$1"
	local OPT="$2"
	local _result=0

	# EXCLUDE_INSPECT -- ignore these files
	# RELOCATE -- binary file should be relocatable
	# NON_RELOCATE -- binary file should be non relocatable
	# ARCH <arch> -- test a specific arch
	# MISSING_RPATH val1 val2 ... -- test if binary files have some specific values as rpath
	local _filter=
	local _flag_filter=OFF
	local _opt_filter=OFF
	local _arch=
	local _flag_arch=OFF
	local _opt_arch=OFF
	local _flag_relocate=DEFAULT
	local _flag_missing_rpath=OFF
	local _missing_rpath_values=
	local _opt_missing_rpath=OFF
	for o in $OPT; do
		[ "$_flag_filter" == "ON" ] && _filter=$o && _flag_filter=OFF
		[ "$o" == "EXCLUDE_INSPECT" ] && _opt_filter=ON && _flag_filter=ON && _flag_missing_rpath=OFF
		[ "$_flag_arch" == "ON" ] && _arch=$o && _flag_arch=OFF
		[ "$o" == "ARCH" ] && _opt_arch=ON && _flag_arch=ON && _flag_missing_rpath=OFF
		[ "$_flag_missing_rpath" == "ON" ] && _missing_rpath_values="$o $_missing_rpath_values"
		[ "$o" == "MISSING_RPATH" ] && _flag_missing_rpath=ON && _opt_missing_rpath=ON

		[ "$o" == "RELOCATE" ] && _flag_relocate=YES && _flag_missing_rpath=OFF
		[ "$o" == "NON_RELOCATE" ] && _flag_relocate=NO && _flag_missing_rpath=OFF
	done



	if [ "$_opt_filter" == "ON" ]; then
		if [ ! "$(echo $path | grep -E "$_filter")" == "" ]; then
			return $_result
		fi
	fi

	local f=
	if [ -d "$path" ]; then
		for f in  "$path"/*; do
			__check_binary_files "$f" "$OPT" || _result=1
		done
	fi

	if [ -f "$path" ]; then

		local _check_rpath_opt=
		if [ "$_opt_missing_rpath" == "ON" ];then
			_check_rpath_opt="MISSING_RPATH $_missing_rpath_values"
		fi
		case $STELLA_CURRENT_PLATFORM in
			linux)
				if [ "$(__is_linux_bin $path)" == "TRUE" ]; then
					echo
					echo "** Analysing $path"

					__check_arch "$path" "$_arch"

					case $_flag_relocate in
						YES)
							if [ ! "$(__get_extension_from_string $path)" == "a" ]; then
								__check_rpath_linux "$path" "REL_RPATH $_check_rpath_opt"
								__check_linked_lib_linux "$path"
							fi
							;;
						NO)
							if [ ! "$(__get_extension_from_string $path)" == "a" ]; then
								__check_rpath_linux "$path" "ABS_RPATH $_check_rpath_opt"
								__check_linked_lib_linux "$path"
							fi
							;;
						DEFAULT)
							if [ ! "$(__get_extension_from_string $path)" == "a" ]; then
								__check_rpath_linux "$path" "$_check_rpath_opt"
								__check_linked_lib_linux "$path"
							fi
							;;
					esac

					echo
				fi
			;;
			darwin)
				if [ "$(__is_darwin_bin $path)" == "TRUE" ]; then
					echo
					echo "** Analysing $path"

					__check_arch "$path" "$_arch"
					case $_flag_relocate in
						YES)
							[[ "$path" =~ .*dylib.* ]] && __check_install_name_darwin "$path" "RPATH"
							if [ ! "$(__get_extension_from_string $path)" == "a" ]; then
								__check_rpath_darwin "$path" "REL_RPATH $_check_rpath_opt"
								__check_linked_lib_darwin "$path"
							fi
						;;
						NO)
							[[ "$path" =~ .*dylib.* ]] && __check_install_name_darwin "$path" "PATH"
							if [ ! "$(__get_extension_from_string $path)" == "a" ]; then
								__check_rpath_darwin "$path" "NO_RPATH $_check_rpath_opt"
								__check_linked_lib_darwin "$path"
							fi
						;;
						DEFAULT)
							[[ "$path" =~ .*dylib.* ]] && __check_install_name_darwin "$path"
							if [ ! "$(__get_extension_from_string $path)" == "a" ]; then
								__check_rpath_darwin "$path" "$_check_rpath_opt"
								__check_linked_lib_darwin "$path"
							fi
						;;
					esac
					echo
				fi
			;;
		esac
	fi

}























# DARWIN -------------------------------------------------------------------
# MACOS -----  install_name, rpath, loader_path, executable_path
# https://mikeash.com/pyblog/friday-qa-2009-11-06-linking-and-install-names.html

function __is_darwin_bin() {
	local _file=$1
	if [ ! "$(otool -h "$_file" 2>/dev/null | grep Mach)" == "" ]; then
		echo "TRUE"
	else
		echo "FALSE"
	fi
}




# DARWIN : INSTALL NAME --------------------------------
function __get_install_name_darwin() {
	local _file=$1
	echo $(otool -l "$_file" | grep -E "LC_ID_DYLIB" -A2 | awk '/LC_ID_DYLIB/{for(i=2;i;--i)getline; print $0 }' | tr -s ' ' | cut -d ' ' -f 3)

}

# check ID/Install Name value
# 		RPATH -- check if install_name has @rpath
# 		PATH -- check if install_name is a standard path and is matching current file location
function __check_install_name_darwin() {
	local _path=$1
	local OPT="$2"
	local t
	local _result=0
	local f=

	if [ -d "$_path" ]; then
		for f in  "$_path"/*; do
			__check_install_name_darwin "$f" "$OPT" || _result=1
		done
	fi

	if [ -f "$_path" ]; then

		if [ "$(__is_darwin_bin $_path)" == "TRUE" ]; then

			local _opt_rpath=OFF
			local _opt_path=OFF
			for o in $OPT; do
				[ "$o" == "RPATH" ] && _opt_rpath=ON && _opt_path=OFF
				[ "$o" == "PATH" ] && _opt_rpath=OFF && _opt_path=ON
			done

			printf "*** Checking ID/Install Name value : "
			local _install_name="$(__get_install_name_darwin $_path)"

			if [ "$_install_name" == "" ]; then
				echo
				echo " *** WARN $_path do not have any install name (LC_ID_DYLIB field)"
				_result=1
			else

				if [ "$_opt_rpath" == "ON" ]; then
					t=`echo $_install_name | grep -E "@rpath/"`
					if [ "$t" == "" ]; then
						printf %s " WARN ID/Install Name does not contain @rpath : $_install_name"
						_result=1
					else
						printf %s " $_install_name -- OK"
					fi
				fi

				if [ "$_opt_path" == "ON" ]; then
					if [ "$(dirname $_path)" == "$(dirname $_install_name)" ]; then
						printf %s " $_install_name -- OK"
					else
						if [ "$(dirname $_install_name)" == "." ]; then
							printf %s " WARN ID/Install Name contain only a name : $_install_name"
							_result=1
						else
							printf %s " WARN ID/Install Name does not match location of file : $_install_name"
							_result=1
						fi
					fi
				fi

			fi
			echo
		fi
	fi

	return $_result
}

# tweak install name with @rpath/lib_name OR tweak install name replacing @rpath/lib_name with /lib/path/lib_name
# we cannot pass '-Wl,install_name @rpath/library_name' during build time because we do not know the library name yet
# 		RPATH -- fix install_name with @rpath
# 		PATH -- fix install_name with current location
function __tweak_install_name_darwin() {
	local _path=$1
	local OPT="$2"
	local _new_install_name
	local _original_install_name

	local _result=0

	local f=
	if [ -d "$_path" ]; then
		for f in  "$_path"/*; do
			__tweak_install_name_darwin "$f" "$OPT" || _result=1
		done
	fi

	if [ -f "$_path" ]; then

		if [ "$(__is_darwin_bin $_path)" == "TRUE" ]; then

			local _opt_rpath=ON
			local _opt_path=OFF
			for o in $OPT; do
				[ "$o" == "RPATH" ] && _opt_rpath=ON && _opt_path=OFF
				[ "$o" == "PATH" ] && _opt_rpath=OFF && _opt_path=ON
			done



			_original_install_name="$(__get_install_name_darwin $_path)"

			if [ "$_original_install_name" == "" ]; then
				echo " ** WARN $_path do not have any install name (LC_ID_DYLIB field)"
				_result=1
				return $_result
			fi

			case "$_original_install_name" in
				@rpath*)
					if [ "$_opt_path" == "ON" ]; then
						_new_install_name="$(__get_path_from_string $_path)/$(__get_filename_from_string $_original_install_name)"
						echo "** Fixing install_name for $_path with value : FROM $_original_install_name TO $_new_install_name"
						install_name_tool -id "$_new_install_name" $_path
					fi
				;;

				*)
					if [ "$_opt_rpath" == "ON" ]; then
						_new_install_name="@rpath/$(__get_filename_from_string $_original_install_name)"
						echo "** Fixing install_name for $_path with value : FROM $_original_install_name TO $_new_install_name"
						install_name_tool -id "$_new_install_name" $_path
					fi
					if [ "$_opt_path" == "ON" ]; then
						# location path is not the good one
						if [ ! "$(dirname $_path)" == "$(dirname $_original_install_name)" ]; then
							_new_install_name="$(__get_path_from_string $_path)/$(__get_filename_from_string $_original_install_name)"
							echo "** Fixing install_name for $_path with value : FROM $_original_install_name TO $_new_install_name"
							install_name_tool -id "$_new_install_name" $_path
						fi
					fi
				;;

			esac
		fi
	fi
}


# DARWIN : RPATH --------------------------------
# return rpath values in search order
function __get_rpath_darwin() {
	local _file="$1"
	local t
	t="$(otool -l "$_file" | grep -E "LC_RPATH" -A2 | awk '/LC_RPATH/{for(i=2;i;--i)getline; print $0 }' | tr -s ' ' | cut -d ' ' -f 3 |  tr '\n' ' ')"

	echo "$(__trim $t)"
}

# check if binary have some specific rpath values
function __have_rpath_darwin() {
	local _path="$1"
	local _rpath_values="$2"
	local _result=0
	local t=
	local r=

	for r in $_rpath_values; do
		printf %s "*** Checking if this RPATH value is missing : $r"
		t=`otool -l $_path | grep -E "LC_RPATH" -A2 | grep -E "path $r \("`

		if [ "$t" == "" ];then
			printf %s " -- WARN RPATH is missing"
			_result=1
		else
			printf %s " -- OK"
		fi
		echo
	done

	return $_result
}

# modify rpath values
# ABS_RPATH : transform relative rpath values to absolute path - so rpath values turn from ../foo to /path/foo
# REL_RPATH [DEFAULT] : transform absolute rpath values to relative path - so rpath values turn from /path/foo to @loader_path/foo
function __tweak_rpath_darwin() {
	local _path=$1
	local _OPT="$2"


	if [ -d "$_path" ]; then
		for f in  "$_path"/*; do
			__tweak_rpath_darwin "$f" "$_OPT"
		done
	fi

	if [ -f "$_path" ]; then

		if [ "$(__is_darwin_bin $_path)" == "TRUE" ]; then

			local _rel_rpath=ON
			local _abs_rpath=OFF
			for o in $_OPT; do
				[ "$o" == "REL_RPATH" ] && _rel_rpath=ON && _abs_rpath=OFF
				[ "$o" == "ABS_RPATH" ] && _rel_rpath=OFF && _abs_rpath=ON
			done

			local _rpath_values=
			local _new_rpath_values=
			local _flag_change=
			local _p=

			_rpath_values="$(__get_rpath_darwin $_path)"

			for line in $_rpath_values; do

				if [ "$_abs_rpath" == "ON" ]; then
			 		if [ "$(__is_abs $line)" == "FALSE" ];then
			 			[ ! "$_flag_change" == "1" ] && echo "*** Fixing RPATH for $_path"

			 			_p="$(__rel_to_abs_path "$line" $(__get_path_from_string $_path))"
			 			echo "====> Transform $line to abs path : $_p"

			 			_new_rpath_values="$_new_rpath_values $_p"
			 			_flag_change=1
			 		else
			 			_new_rpath_values="$_new_rpath_values $line"
			 		fi
			 	else
				 	if [ "$_rel_rpath" == "ON" ]; then
				 		if [ "$(__is_abs $line)" == "TRUE" ];then
				 			[ ! "$_flag_change" == "1" ] && echo "*** Fixing RPATH for $_path"

				 			_p="@loader_path/$(__abs_to_rel_path "$line" $(__get_path_from_string $_path))"
				 			echo "====> Transform $line to rel path : $_p"

				 			_new_rpath_values="$_new_rpath_values $_p"
				 			_flag_change=1
				 		else
			 				_new_rpath_values="$_new_rpath_values $line"
				 		fi
				 	fi
				fi
			done

			if [ "$_flag_change" == "1" ]; then
				for p in $_rpath_values; do
					install_name_tool -delete_rpath "$p" "$_path"
				done
				for n in $_new_rpath_values; do
					install_name_tool -add_rpath "$n" "$_path"
				done
			fi

		fi
	fi
}

# remove all rpath values
function __remove_all_rpath_darwin() {
	local _path=$1

	local _rpath_list_values
	local msg=

	if [ -d "$_path" ]; then
		for f in  "$_path"/*; do
			__remove_all_rpath_darwin "$f"
		done
	fi

	if [ -f "$_path" ]; then

		if [ "$(__is_darwin_bin $_path)" == "TRUE" ]; then
			_rpath_list_values="$(__get_rpath_darwin $_path)"
			for r in $_rpath_list_values; do
				msg="$msg -- deleting RPATH value : $r"
				install_name_tool -delete_rpath "$r" "$_path"
			done
		fi

		[ ! "$msg" == "" ] && echo "** Deleting rpath values from $_path $msg"
	fi
}


# add rpath values by adding rpath values contained in list _rpath_list_values
# if a rpath value is already setted, it will be just reordered
# 		FIRST (DEFAULT) : rpath values will be put in first order search
#		LAST : rpath values will be put in last order search
function __add_rpath_darwin() {
	local _path=$1
	local _rpath_list_values="$2"
	local OPT="$3"

	if [ "$_rpath_list_values" == "" ]; then
		return 0
	fi



	if [ -d "$_path" ]; then
		for f in  "$_path"/*; do
			__add_rpath_darwin "$f" "$_rpath_list_values" "$OPT"
		done
	fi

	local msg=

	if [ -f "$_path" ]; then

		if [ "$(__is_darwin_bin $_path)" == "TRUE" ]; then

			local _flag_first_place=ON
			local _flag_last_place=OFF
			for o in $OPT; do
				[ "$o" == "FIRST" ] && _flag_first_place=ON && _flag_last_place=OFF
				[ "$o" == "LAST" ] && _flag_first_place=OFF && _flag_last_place=ON
			done

			local _old_rpath=
			local _flag_found=
			local _rpath=
			local _new_rpath=

			_old_rpath="$(__get_rpath_darwin $_path)"
			for r in $_old_rpath; do
				_flag_found=0
				for n in $_rpath_list_values; do
					if [ "$n" == "$r" ]; then
						msg="$msg -- moving RPATH value : $r"
						_flag_found=1
					fi
				done
				[ "$_flag_found" == "0" ] && _new_rpath="$_new_rpath $r"
			done

			__remove_all_rpath_darwin "$_path"

			if [ "$_flag_first_place" == "ON" ]; then
				_new_rpath="$_rpath_list_values $_new_rpath"
			fi
			if [ "$_flag_last_place" == "ON" ]; then
				_new_rpath="$_new_rpath $_rpath_list_values"
			fi

			# adding values
			_rpath="$(__trim $_rpath)"
			for p in $_new_rpath; do
				msg="$msg -- adding RPATH value : $p"
				install_name_tool -add_rpath "$p" "$_path"
			done



			[ ! "$msg" == "" ] && echo "** Adding rpath values to $_path $msg"
		fi
	fi

}


# check rpath values of exexcutable binary and shared lib
# 		NO_RPATH -- must no have any rpath
# 		REL_RPATH -- rpath must be a relative path
# 		ABS_RPATH -- rpath must be an absolute path
#			MISSING_RPATH val1 val2 ... -- check some missing rpath
function __check_rpath_darwin() {
	local _path="$1"
	local OPT="$2"
	local t
	local _result=0

	if [ -d "$_path" ]; then
		for f in  "$_path"/*; do
			__check_rpath_darwin "$f" "$OPT" || _result=1
		done
	fi

	local _no_rpath=OFF
	local _rel_rpath=OFF
	local _abs_rpath=OFF
	local _flag_missing_rpath=OFF
	local _missing_rpath_values=
	local _opt_missing_rpath=OFF
	for o in $OPT; do
		[ "$_flag_missing_rpath" == "ON" ] && _missing_rpath_values="$o $_missing_rpath_values"
		[ "$o" == "MISSING_RPATH" ] && _flag_missing_rpath=ON && _opt_missing_rpath=ON
		[ "$o" == "NO_RPATH" ] && _no_rpath=ON && _flag_missing_rpath=OFF
		[ "$o" == "REL_RPATH" ] && _rel_rpath=ON && _abs_rpath=OFF && _flag_missing_rpath=OFF
		[ "$o" == "ABS_RPATH" ] && _rel_rpath=OFF && _abs_rpath=ON && _flag_missing_rpath=OFF
	done

	if [ -f "$_path" ]; then
		if [ "$(__is_darwin_bin $_path)" == "TRUE" ]; then

			t="$(__get_rpath_darwin $_path)"

			if [ "$_no_rpath" == "ON" ];then
				printf %s "*** Checking if there is no RPATH setted "
				if [ "$t" == "" ]; then
					printf %s " -- OK"
					echo
				else
					printf %s " -- WARN RPATH is setted"
					_result=1
					echo
					echo "*** List RPATH values in search order :"
					echo $t
				fi

			else

				for r in $t; do
					printf %s "*** Checking RPATH value : $r "
					if [ "$_abs_rpath" == "ON" ]; then
						if [ "$(__is_abs $r)" == "TRUE" ];then
							printf %s "-- is abs path : OK"
						else
							printf %s "-- is not an abs path : WARN"
						_result=1
						fi
					fi

					if [ "$_rel_rpath" == "ON" ]; then
						if [ "$(__is_abs $r)" == "TRUE" ];then
							printf %s "-- is not a rel path : WARN"
						_result=1
						else
							printf %s "-- is rel path : OK"
						fi
					fi
					echo
				done

				__have_rpath_darwin "$_path" "$_missing_rpath_values" || _result=1

			fi

		fi
	fi

	return $_result

}





# DARWIN : LINKED LIB --------------------------------
# return linked libs
function __get_linked_lib_darwin() {
	local _file="$1"
	local t

	t="$(otool -l "$_file" | grep -E "LC_LOAD_DYLIB" -A2 | awk '/LC_LOAD_DYLIB/{for(i=2;i;--i)getline; print $0 }' | tr -s ' ' | cut -d ' ' -f 3 |  tr '\n' ' ')"

	echo "$(__trim $t)"
}


# check dynamic link at runtime
# Print out dynamic libraries loaded at runtime when launching a program :
# 		DYLD_PRINT_LIBRARIES=y program
function __check_linked_lib_darwin() {
	local _path="$1"
	local line=
	local linked_lib_list=
	local linked_lib=

	local _result=0

	if [ -d "$_path" ]; then
		for f in  "$_path"/*; do
			__check_linked_lib_darwin "$f" ||	_result=1
		done
	fi

	if [ -f "$_path" ]; then
		if [ "$(__is_darwin_bin $_path)" == "TRUE" ]; then

			echo "*** Checking missing dynamic library at runtime"

			local _rpath=
			_rpath="$(__get_rpath_darwin $_path)"

			local _match=
			local loader_path="$(__get_path_from_string "$_path")"
			local original_rpath_value=
			local p=

			linked_lib_list="$(__get_linked_lib_darwin "$_path")"

			for line in $linked_lib_list; do
				printf %s "====> checking linked lib : $line "
				_match=
				# @rpath case
				if [ -z "${line##*@rpath*}" ]; then

					for p in $_rpath; do
						original_rpath_value="$p"
						#replace @loader_path
						if [ -z "${p##*@loader_path*}" ]; then
							p="${p/@loader_path/$loader_path}"
						fi
						linked_lib="${line/@rpath/$p}"
						if [ -f "$linked_lib" ]; then
							printf %s "-- OK -- [$original_rpath_value] ==> $linked_lib"
							_match=1
							break
						fi
					done
				else
					# @loader_path case
					if [ -z "${line##*@loader_path*}" ]; then
						linked_lib="${line/@loader_path/$loader_path}"
						if [ -f "$linked_lib" ]; then
							printf %s "-- OK -- [$line] ==> $linked_lib"
							_match=1
						fi
					else
						if [ -f "$line" ]; then
							printf %s "-- OK"
							_match=1
						fi
					fi
				fi
				if [ "$_match" == "" ]; then
					printf %s "-- WARN not found"
					_result=1
				fi
				echo
			done

		fi
	fi

	return $_result
}



# fix linked shared lib by modifying LOAD_DYLIB and adding rpath values
# 	first choose linked lib to modify path -- you can filter libs by exclude some (EXCLUDE_FILTER) or include some (INCLUDE_FILTER)
#	second transform path to linked lib -- you can choose to
#					transform all linked libs with rel path to abs path (ABS_RPATH) (including @loader_path, but do not change @rpath or @executable_path because we cant determine the path)
#					transform all linked libs with abs path to rel path (REL_RPATH) (use @rpath and add an RPATH value corresponding to the relative path to the file with @loader_path/)
#					force a specific path (FIXED_PATH <path>) -- so each linked lib is registered now with path/linked_lib
# TODO should exclude linked lib with @rpath/lib
function __fix_linked_lib_darwin() {
	local _file=$1
	local OPT="$2"
	# linked lib filter :
	# INCLUDE_FILTER <expr> -- include from the transformation these linked libraries
	# EXCLUDE_FILTER <expr> -- exclude from the transformation these linked libraries

	# path management :
	# ABS_RPATH -- fix linked lib with an absolute path (only linked libs with rel path or with @loader_path are selected - NOT the others)
	# REL_RPATH [DEFAULT MODE] -- fix linked lib with a relative path (use @rpath and add an RPATH value corresponding to the relative path to the file with @loader_path/)
	# FIXED_PATH <path> -- fix with a given path -- so each linked lib is registered now with path/linked_lib



	local _flag_exclude_filter=OFF
	local _exclude_filter=
	local _invert_filter=
	local _flag_include_filter=OFF
	local _include_filter=
	local _abs_rpath=OFF
	local _rel_rpath=ON

	local _flag_fixed_path=OFF
	local _force_path=
	local _fixed_path=OFF

	for o in $OPT; do
		[ "$o" == "FIX_RPATH" ] && echo "ERROR : deprecated -- use FIXED_PATH instead" && exit 1

		[ "$_flag_fixed_path" == "ON" ] && _force_path="$o" && _flag_fixed_path=OFF && _fixed_path=ON && _rel_rpath=OFF && _abs_rpath=OFF
		[ "$o" == "FIXED_PATH" ] && _flag_fixed_path=ON
		[ "$_flag_include_filter" == "ON" ] && _include_filter="$o" && _flag_include_filter=OFF
		[ "$o" == "INCLUDE_FILTER" ] && _flag_include_filter=ON
		[ "$_flag_exclude_filter" == "ON" ] && _exclude_filter="$o" && _flag_exclude_filter=OFF
		[ "$o" == "EXCLUDE_FILTER" ] && _flag_exclude_filter=ON && _invert_filter="-Ev"

		[ "$o" == "REL_RPATH" ] && _rel_rpath=ON && _abs_rpath=OFF && _fixed_path=OFF
		[ "$o" == "ABS_RPATH" ] && _rel_rpath=OFF && _abs_rpath=ON && _fixed_path=OFF

		[ "$o" == "ABS_LINK_TO_REL" ] && _rel_rpath=ON && _abs_rpath=OFF && _fixed_path=OFF
		[ "$o" == "REL_LINK_TO_ABS" ] && _rel_rpath=OFF && _abs_rpath=ON && _fixed_path=OFF


	done


	local f=
	if [ -d "$_file" ]; then
		for f in  "$_file"/*; do
			__fix_linked_lib_darwin "$f" "$OPT"
		done
	fi

	if [ -f "$_file" ]; then
		if [ "$(__is_darwin_bin $_path)" == "TRUE" ]; then

			local _new_load_dylib=
			local line=
			local _linked_lib_filename=
			local _filename
			local _linked_lib_list=
			local _flag_existing_rpath=


			# get existing linked lib
			while read -r line; do
				# FIXED_PATH : pick all filtered libraries
				if [ "$_fixed_path" == "ON" ]; then
					_linked_lib_list="$_linked_lib_list $line"
				fi

				# ABS_RPATH : pick only rel path or @loader_path - do not pick @rpath or @executable_path
				if [ "$_abs_rpath" == "ON" ]; then
					case $line in
						@rpath*|@executable_path*);;
						@loader_path)
							_linked_lib_list="$_linked_lib_list $line"
							;;
						*)
							if [ "$(__is_abs "$line")" == "FALSE" ]; then
								_linked_lib_list="$_linked_lib_list $line"
							fi
							;;
					esac
				fi
				# REL_RPATH : pick only abs path
				if [ "$_rel_rpath" == "ON" ]; then
					if [ "$(__is_abs "$line")" == "TRUE" ]; then
						_linked_lib_list="$_linked_lib_list $line"
					fi
				fi
				# TODO change to __get_rpath_darwin
			done <<< "$(otool -l "$_file" | grep -E "LC_LOAD_DYLIB" -A2 | awk '/LC_LOAD_DYLIB/{for(i=2;i;--i)getline; print $0 }' | grep -E "$_include_filter" | grep $_invert_filter "$_exclude_filter" | tr -s ' ' | cut -d ' ' -f 3)"


			for l in $_linked_lib_list; do

				_filename=$(__get_filename_from_string $_file)
				_linked_lib_filename="$(__get_filename_from_string $l)"

				echo "** Fixing $_filename linked to $_linked_lib_filename shared lib"

				if [ "$_fixed_path" == "ON" ]; then
					echo "====> setting LC_LOAD_DYLIB : $_force_path/$_linked_lib_filename"
					install_name_tool -change "$l" "$_force_path/$_linked_lib_filename" "$_file"
				fi


				if [ "$_abs_rpath" == "ON" ]; then
					_new_load_dylib="$(__get_path_from_string $l)"
					echo "====> setting LC_LOAD_DYLIB : $_new_load_dylib/$_linked_lib_filename"
					install_name_tool -change "$l" "$_new_load_dylib/$_linked_lib_filename" "$_file"
				fi


				if [ "$_rel_rpath" == "ON" ]; then
					_new_load_dylib="@loader_path/$(__abs_to_rel_path $_new_load_dylib $(__get_path_from_string $_file))"
					echo "====> setting LC_LOAD_DYLIB : @rpath/$_linked_lib_filename"
					install_name_tool -change "$l" "@rpath/$_linked_lib_filename" "$_file"

					echo "====> Adding RPATH value : $_new_load_dylib"
					#__set_build_mode "RPATH" "ADD" "$_new_load_dylib"
					_flag_existing_rpath=0
					# TODO change to __get_rpath_darwin
					while read -r line; do
						[ "$line" == "$_new_load_dylib" ] && _flag_existing_rpath=1
					done <<< "$(otool -l "$_file" | grep -E "LC_RPATH" -A2 | awk '/LC_RPATH/{for(i=2;i;--i)getline; print $0 }' | tr -s ' ' | cut -d ' ' -f 3)"
					if [ "$_flag_existing_rpath" == "0" ]; then
						install_name_tool -add_rpath "$_new_load_dylib" "$_file"
						echo "ADDING : install_name_tool -add_rpath $_new_load_dylib" "$_file"
					else
						echo "EXIST: install_name_tool -add_rpath $_new_load_dylib" "$_file"
					fi
				fi
			done
		fi
	fi
}



























# LINUX -------------------------------------------------------------------

function __is_linux_bin() {
	local _file=$1
	if [ ! "$(objdump -p "$_file" 2>/dev/null)" == "" ]; then
		echo "TRUE"
	else
		echo "FALSE"
	fi
}


# modify rpath values
# ABS_RPATH : transform relative rpath values to absolute path - so rpath values turn from ../foo to /path/foo
# REL_RPATH [DEFAULT] : transform absolute rpath values to relative path - so rpath values turn from /path/foo to $ORIGIN/foo
function __tweak_rpath_linux() {
	local _file=$1
	local _OPT="$2"


	if [ -d "$_file" ]; then
		for f in  "$_file"/*; do
			__tweak_rpath_linux "$f" "$_OPT"
		done
	fi

	local msg=

	if [ ! "$(objdump -p "$_file" 2>/dev/null)" == "" ]; then

		local _rel_rpath=ON
		local _abs_rpath=OFF
		for o in $OPT; do
			[ "$o" == "REL_RPATH" ] && _rel_rpath=ON && _abs_rpath=OFF
			[ "$o" == "ABS_RPATH" ] && _rel_rpath=OFF && _abs_rpath=ON
		done




		local _rpath_values=
		local _new_rpath_values=
		local _flag_change=
		local _path=

		# Transform existing RPATH
		local _field="RPATH"
		[ "$(objdump -p $_file | grep -E "$_field\s" | tr -s ' ' | cut -d ' ' -f 3)" == "" ] && _field="RUNPATH"

		IFS=':' read -ra _rpath_values <<< $(objdump -p $_file | grep -E "$_field\s" | tr -s ' ' | cut -d ' ' -f 3)

		#_rpath_values=${_rpath_values/\$ORIGIN/\\\$ORIGIN}

		for line in "${_rpath_values[@]}"; do
			if [ "$_abs_rpath" == "ON" ]; then
		 		if [ ! "$(__is_abs $line)" == "TRUE" ];then
		 			[ ! "$_flag_change" == "1" ] && echo "*** Fixing RPATH for $_file"

		 			_path="$(__rel_to_abs_path "$line" $(__get_path_from_string $_file))"
		 			echo "====> Transform $line to abs path $_path"

		 			_new_rpath_values="$_new_rpath_values:$_path"
		 			_flag_change=1
		 		else
		 			_new_rpath_values="$_new_rpath_values:$line"
		 		fi
		 	else
			 	if [ "$_rel_rpath" == "ON" ]; then
			 		if [ "$(__is_abs $line)" == "TRUE" ];then
			 			[ ! "$_flag_change" == "1" ] && echo "*** Fixing RPATH for $_file"

			 			_path="\$ORIGIN/$(__abs_to_rel_path "$line" $(__get_path_from_string $_file))"
			 			echo "====> Transform $line to abs path : $_path"

			 			_new_rpath_values="$_new_rpath_values:$_path"
			 			_flag_change=1
			 		else
		 				_new_rpath_values="$_new_rpath_values:$line"
			 		fi
			 	fi
			 fi
		done

		if [ "$_flag_change" == "1" ]; then
			__require "patchelf" "PREFER_STELLA"

			patchelf --set-rpath "${_new_rpath_values#?}" "$_file"
			echo
		fi
	fi


}


# check if binary have some specific rpath values
function __have_rpath_linux() {
	local _path="$1"
	local _rpath_values="$2"
	local _result=0
	local t=
	local r=

	for r in $_rpath_values; do
		printf %s "*** Checking if this RPATH value is missing : $r"
		t=`otool -l $_path | grep -E "LC_RPATH" -A2 | grep -E "path $r \("`

		if [ "$t" == "" ];then
			printf %s " -- WARN RPATH is missing"
			_result=1
		else
			printf %s " -- OK"
		fi
		echo
	done

	return $_result
}

# add rpath values by adding rpath values contained in list _rpath_list_values
# and reorder all rpath values
function __add_rpath_linux() {
	local _file=$1
	local _rpath_list_values="$2"

	if [ -d "$_file" ]; then
		for f in  "$_file"/*; do
			__add_rpath_linux "$f" "$_rpath_list_values"
		done
	fi

	local msg=
	# TODO replace by function
	if [ ! "$(objdump -p "$_file" 2>/dev/null)" == "" ]; then


		for r in $_rpath_list_values; do
			local _flag_rpath=
			local _rpath_values=
			local _flag_move=
			local line=
			local old_rpath=

			local _field="RPATH"
			# TODO replace by function
			[ "$(objdump -p $_file | grep -E "$_field\s" | tr -s ' ' | cut -d ' ' -f 3)" == "" ] && _field="RUNPATH"

			IFS=':' read -ra _rpath_values <<< $(objdump -p $_file | grep -E "$_field\s" | tr -s ' ' | cut -d ' ' -f 3)


			for line in "${_rpath_values[@]}"; do
				if [ "$line" == "$r" ]; then
					_flag_rpath=1
				fi
				old_rpath="$old_rpath:$line"
			done


			if [ "$_flag_rpath" == "" ];then
				msg="$msg -- adding RPATH value : $r"
				old_rpath="$old_rpath:$r"

				__require "patchelf" "patchelf" "PREFER_STELLA"
				patchelf --set-rpath "${old_rpath#?}" "$_file"
				echo
			fi

		done

	fi

	[ ! "$msg" == "" ] && echo "** Adding rpath values to $_file $msg"
}

# check rpath values of exexcutable binary and shared lib
# 		NO_RPATH -- must no have any rpath
# 		REL_RPATH -- rpath must be a relative path
# 		ABS_RPATH -- rpath must be an absolute path
#			MISSING_RPATH val1 val2 ... -- check some missing rpath
function __check_rpath_linux() {
	local _path=$1
	local OPT="$2"
	local t
	local _result=0

	if [ -d "$_path" ]; then
		for f in  "$_path"/*; do
			__check_rpath_linux "$f" "$OPT" || _result=1
		done
	fi


	local _no_rpath=OFF
	local _rel_rpath=OFF
	local _abs_rpath=OFF
	local _flag_missing_rpath=OFF
	local _missing_rpath_values=
	local _opt_missing_rpath=OFF

	for o in $OPT; do
		[ "$_flag_missing_rpath" == "ON" ] && _missing_rpath_values="$o $_missing_rpath_values"
		[ "$o" == "MISSING_RPATH" ] && _flag_missing_rpath=ON && _opt_missing_rpath=ON
		[ "$o" == "NO_RPATH" ] && _no_rpath=ON && _flag_missing_rpath=OFF
		[ "$o" == "REL_RPATH" ] && _rel_rpath=ON && _abs_rpath=OFF && _flag_missing_rpath=OFF
		[ "$o" == "ABS_RPATH" ] && _rel_rpath=OFF && _abs_rpath=ON && _flag_missing_rpath=OFF
	done


	if [ -f "$_path" ]; then
		if [ "$(__is_linux_bin $_path)" == "TRUE" ]; then

			local _rpath_values

			local _field="RPATH"
			[ "$(objdump -p $_path | grep -E "$_field\s" | tr -s ' ' | cut -d ' ' -f 3)" == "" ] && _field="RUNPATH"

			IFS=':' read -ra _rpath_values <<< $(objdump -p $_path | grep -E "$_field\s" | tr -s ' ' | cut -d ' ' -f 3)


			if [ "$_no_rpath" == "ON" ];then
				printf %s "*** Checking if there is no RPATH setted "
				if [ "$_rpath_values" == "" ]; then
					printf %s " -- OK"
					echo
				else
					printf %s " -- WARN RPATH is setted"
					_result=1
					echo
					echo "*** List RPATH values in search order :"
					echo $_rpath_values
				fi

			else

				for line in "${_rpath_values[@]}"; do
					printf %s "*** Checking RPATH value : $line "
					if [ "$_abs_rpath" == "ON" ]; then
						if [ "$(__is_abs $line)" == "TRUE" ];then
							printf %s "-- is abs path : OK"
						else
							printf %s "-- is not an abs path : WARN"
							_result=1
						fi
					fi

					if [ "$_rel_rpath" == "ON" ]; then
						if [ "$(__is_abs $line)" == "TRUE" ];then
							printf %s "-- is not a rel path : WARN"
							_result=1
						else
							printf %s "-- is rel path : OK"
						fi
					fi
					echo
				done
			fi




			# TODO replace with __have_rpath_linux
			# TODO do not use STELLA_BUILD_RPATH
			local _err=0
			for r in $STELLA_BUILD_RPATH; do

				printf %s "*** Checking if setted RPATH value is missing : $r"

				for i in "${_rpath_values[@]}"; do
					if [ "$i" == "$r" ]; then
						 printf %s " -- OK"
						 _err=1
					fi
				done
				if [ "$_err" == "0" ]; then
					printf %s " -- WARN RPATH is missing"
					_result=1
				fi
				_err=0
				echo
			done


		fi
	fi



	return $_result

}



# check dynamic link at runtime
# Print out dynamic libraries loaded at runtime when launching a program :
# 		LD_TRACE_LOADED_OBJECTS=1 program
# ldd might not work on symlink and other situations
# TODO to finish
function __check_linked_lib_linux() {
	local _file=$1
	local t

	local _result=0

	#readelf -d "$_file" | grep NEEDED | cut -d ')' -f2
	#t=`ldd $_file | grep "=>"`
	#echo $t
	printf %s "*** Checking missing dynamic library at runtime"
	#_CUR_DIR=`pwd`
	t=`ldd $_file | grep "not found"`
	#cd $_CUR_DIR
	#[ $VERBOSE_MODE -gt 0 ] && ldd $_file
	if [ ! "$t" == "" ]; then
		printf %s "-- WARN not found"
		_result=1
		echo "		$t"
	else
		printf %s "-- OK"
	fi

	return $_result

}




fi
