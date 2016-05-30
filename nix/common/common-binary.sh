if [ ! "$_STELLA_COMMON_BINARY_INCLUDED_" == "1" ]; then
_STELLA_COMMON_BINARY_INCLUDED_=1

# GENERIC
# __is_multi_arch		# TEST FILE IS BIN - NON RECURSIVE -- [RETURN ERROR CODE]
# __get_arch				# TEST FILE IS BIN - NON RECURSIVE
# __check_arch			# TEST FILE IS BIN - RECURSIVE -- [RETURN ERROR CODE]
# __check_binary_file # TEST FILE IS BIN - RECURSIVE -- OPTIONAL FILTER -- [RETURN ERROR CODE]
# __tweak_binary_file # TEST FILE IS BIN - RECURSIVE -- OPTIONAL FILTER AND OPTIONAL FILTER FOR LIB

# RPATH
# __get_rpath					# TEST IS EXEC OR DYN FILE - NON RECURSIVE
# __have_rpath				# TEST IS A FILE - RECURSIVE	-- [RETURN ERROR CODE]
# __tweak_rpath				# TEST IS EXEC OR DYN FILE - RECURSIVE -- OPTIONAL FILTER
# __remove_all_rpath 	# TEST IS EXEC OR DYN FILE - RECURSIVE
# __add_rpath					# TEST IS EXEC OR DYN FILE - RECURSIVE
# __check_rpath				# TEST IS EXEC OR DYN FILE - RECURSIVE -- [RETURN ERROR CODE]

# LINKED LIB
# __get_linked_lib		# TEST IS EXEC OR DYN FILE - NON RECURSIVE -- OPTIONAL FILTER FOR LIB
# __check_linked_lib	# TEST IS EXEC OR DYN FILE - RECURSIVE -- OPTIONAL FILTER -- [RETURN ERROR CODE]
# __find_linked_lib_darwin	# TEST IS EXEC OR DYN FILE - RECURSIVE -- [RETURN ERROR CODE]
#	__find_linked_lib_linux		# TEST IS EXEC OR DYN FILE - RECURSIVE -- [RETURN ERROR CODE]
# __tweak_linked_lib	# TEST IS EXEC OR DYN FILE - RECURSIVE -- OPTIONAL FILTER AND OPTIONAL FILTER FOR LIB

# DARWIN : install_name
# __get_install_name_darwin 	# TEST IS MACHO AND IS DYN FILE - NON RECURSIVE
# __check_install_name_darwin	# TEST IS MACHO AND IS DYN FILE - RECURSIVE -- OPTIONAL FILTER -- [RETURN ERROR CODE]
# __tweak_install_name_darwin # TEST IS MACHO AND IS DYN FILE - RECURSIVE -- OPTIONAL FILTER

# NOTE
#			LINUX ELF TOOLS
#					objdump (needed to analysis) -- in sys package gnu binutils
#					ldd (needed for linked lib analys) -- present by default ==> security warning
#					patchelf (needed to analysis AND modify rpath) -- in stella recipe patchelf
#					scanelf (needed to analysis) -- in stella recipe pax-utils
#					readelf (needed to analysis)-- in sys package gnu binutils
#			MACOS BINARY TOOLS :
#					otool (needed to analysis) -- in ??
#					install_name_tool (needed to modify) -- in ??
#			MACOS : install_name, rpath, loader_path, executable_path
# 					https://mikeash.com/pyblog/friday-qa-2009-11-06-linking-and-install-names.html
#
#			LINKED LIBS
#						LINUX : Dynamic libs will be searched in the following directories in the given order:
#							1. DT_RPATH - a list of directories which is linked into the executable, supported on most UNIX systems.
#														The DT_RPATH entries are ignored if DT_RUNPATH entries exist.
#							2. LD_LIBRARY_PATH - an environment variable which holds a list of directories
#							3. DT_RUNPATH - same as RPATH, but searched after LD_LIBRARY_PATH, supported only on most recent UNIX systems, e.g. on most current Linux systems
#							4. /etc/ld.so.conf and /etc/ld.so.conf/* - configuration file for ld.so which lists additional library directories
#							5. builtin directories - basically /lib and /usr/lib
#
#					  LINUX INFO :
#								http://blog.tremily.us/posts/rpath/
# 							https://bbs.archlinux.org/viewtopic.php?id=6460
# 							http://www.cyberciti.biz/tips/linux-shared-library-management.html
#
#						LINUX	TOOLS :
#								https://github.com/gentoo/pax-utils
#								https://github.com/ncopa/lddtree
#
# 	 	LINUX RPATH : PATCHELF
#							using patchelf  "--set-rpath, --shrink-rpath and --print-rpath now prefer DT_RUNPATH over DT_RPATH,
#							which is obsolete. When updating, if both are present, both are updated.
# 						If only DT_RPATH is present, it is converted to DT_RUNPATH unless --force-rpath is specified.
# 						If neither is present, a DT_RUNPATH is added unless --force-rpath is specified, in which case a DT_RPATH is added."
#




# GENERIC -------------------------------------------------------------------
function __is_multi_arch() {
	local _file="$1"
	local _result=1
	if __is_bin "$_file"; then
		__is_macho_universal "$_file" && _result=0
	fi
	return $_result
}

function __get_arch() {
	local _file="$1"
	local _arch
	if __is_bin "$_file"; then
		local _bit="$(__bit_bin "$_file")"
		case $_bit in
			32)
			_arch="x86"
				;;
			64)
			_arch="x64"
				;;
		esac
	fi
	echo "$_arch"
}


function __check_arch() {
	local _path="$1"
	local _wanted_arch="$2"
	local _arch=
	local _result=0


	if [ -d "$_path" ]; then
		for f in  "$_path"/*; do
			__check_arch "$f" "$_wanted_arch" || _result=1
		done
	fi

	if __is_bin "$_path"; then
		_arch="$(__get_arch $_path)"
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
	fi
	return $_result
}



# run some test for binary files
function __check_binary_file() {
	local path="$1"
	local OPT="$2"
	local _result=0

	local f
	if [ -d "$path" ]; then
		for f in  "$path"/*; do
			__check_binary_file "$f" "$OPT" || _result=1
		done
	fi

	# INCLUDE_FILTER <expr> -- include these files
	# EXCLUDE_FILTER <expr> -- exclude these files
	# INCLUDE_FILTER is apply first, before EXCLUDE_FILTER
	# RELOCATE -- binary file should be relocatable
	# NON_RELOCATE -- binary file should be non relocatable
	# ARCH <arch> -- test a specific arch
	# MISSING_RPATH val1 val2 ... -- test if binary files have some specific values as rpath
	local _flag_exclude_filter=OFF
	local _exclude_filter=
	local _invert_filter=
	local _flag_include_filter=OFF
	local _include_filter=
	local _opt_filter=OFF
	local _arch=
	local _flag_arch=OFF
	local _opt_arch=OFF
	local _flag_relocate=DEFAULT
	local _flag_missing_rpath=OFF
	local _missing_rpath_values=
	local _opt_missing_rpath=OFF
	for o in $OPT; do
		[ "$_flag_include_filter" == "ON" ] && _include_filter="$o" && _flag_include_filter=OFF
		[ "$o" == "INCLUDE_FILTER" ] && _flag_include_filter=ON && _opt_filter=ON && _flag_missing_rpath=OFF
		[ "$_flag_exclude_filter" == "ON" ] && _exclude_filter="$o" && _flag_exclude_filter=OFF
		[ "$o" == "EXCLUDE_FILTER" ] && _flag_exclude_filter=ON && _invert_filter="-Ev" && _opt_filter=ON && _flag_missing_rpath=OFF
		[ "$_flag_arch" == "ON" ] && _arch=$o && _flag_arch=OFF
		[ "$o" == "ARCH" ] && _opt_arch=ON && _flag_arch=ON && _flag_missing_rpath=OFF
		[ "$_flag_missing_rpath" == "ON" ] && _missing_rpath_values="$o $_missing_rpath_values"
		[ "$o" == "MISSING_RPATH" ] && _flag_missing_rpath=ON && _opt_missing_rpath=ON

		[ "$o" == "RELOCATE" ] && _flag_relocate=YES && _flag_missing_rpath=OFF
		[ "$o" == "NON_RELOCATE" ] && _flag_relocate=NO && _flag_missing_rpath=OFF
	done

	if [ "$_opt_filter" == "ON" ]; then
		if [ ! "$(echo $path | grep -E "$_include_filter" | grep $_invert_filter $_exclude_filter)" == "" ]; then
			return $_result
		fi
	fi

	if __is_bin "$path"; then
		local _check_rpath_opt=
		if [ "$_opt_missing_rpath" == "ON" ];then
			_check_rpath_opt="MISSING_RPATH $_missing_rpath_values"
		fi

		echo
		echo "** Analysing $path"

		if [ "$_opt_arch" == "ON" ]; then
			__check_arch "$path" "$_arch" || _result=1
		fi

		case $_flag_relocate in
			YES)
				if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
					__check_install_name_darwin "$path" "RPATH" || _result=1
				fi
				__check_rpath "$path" "REL_RPATH $_check_rpath_opt" || _result=1
				;;
			NO)
				if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
					__check_install_name_darwin "$path" "PATH" || _result=1
				fi
				__check_rpath "$path" "ABS_RPATH $_check_rpath_opt" || _result=1
				;;
			DEFAULT)
				if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
					__check_install_name_darwin "$path" || _result=1
				fi
				__check_rpath "$path" "$_check_rpath_opt" || _result=1
				;;
		esac

		__check_linked_lib "$path" || _result=1
		echo
	fi

	return $_result

}





function __tweak_binary_file() {
	local _path="$1"
	local OPT="$2"
	# EXCLUDE -- ignore these files
	local f
	if [ -d "$_path" ]; then
		for f in  "$_path"/*; do
			__tweak_binary_file "$f" "$OPT"
		done
	fi

	# INCLUDE_LINKED_LIB <expr> -- include these linked libs
	# EXCLUDE_LINKED_LIB <expr> -- exclude these linked libs
	# INCLUDE_LINKED_LIB is apply first, before EXCLUDE_LINKED_LIB
	# INCLUDE_FILTER <expr> -- include these files
	# EXCLUDE_FILTER <expr> -- exclude these files
	# INCLUDE_FILTER is apply first, before EXCLUDE_FILTER
	# RELOCATE -- binary have to be relocatable
	# NON_RELOCATE -- binary have to be non relocatable
	# WANTED_RPATH val1 val2 ... -- binary rpath values to set
	local _flag_exclude_filter=OFF
	local _exclude_filter=
	local _invert_filter=
	local _flag_include_filter=OFF
	local _include_filter=
	local _opt_filter=OFF
	local _flag_relocate=DEFAULT
	local _flag_wanted_rpath=OFF
	local _wanted_rpath_values=
	local _opt_wanted_rpath=OFF
	for o in $OPT; do
		[ "$_flag_include_filter" == "ON" ] && _include_filter="$o" && _flag_include_filter=OFF
		[ "$o" == "INCLUDE_FILTER" ] && _flag_include_filter=ON && _flag_missing_rpath=OFF && _flag_wanted_rpath=OFF
		[ "$_flag_exclude_filter" == "ON" ] && _exclude_filter="$o" && _flag_exclude_filter=OFF
		[ "$o" == "EXCLUDE_FILTER" ] && _flag_exclude_filter=ON && _invert_filter="-Ev" && _opt_filter=ON && _flag_wanted_rpath=OFF
		[ "$_flag_wanted_rpath" == "ON" ] && _wanted_rpath_values="$o $_wanted_rpath_values"
		[ "$o" == "WANTED_RPATH" ] && _flag_wanted_rpath=ON && _opt_wanted_rpath=ON
		[ "$o" == "RELOCATE" ] && _flag_relocate=YES && _flag_wanted_rpath=OFF
		[ "$o" == "NON_RELOCATE" ] && _flag_relocate=NO && _flag_wanted_rpath=OFF
	done

	if [ "$_opt_filter" == "ON" ]; then
		if [ ! "$(echo $_path | grep -E "$_include_filter" | grep $_invert_filter $_exclude_filter)" == "" ]; then
			return
		fi
	fi

	if __is_bin "$_path"; then


		echo
		echo "** Fixing if necessary $_path"

		# TODO - write permission ?
		# fix write permission
		chmod +w "$_path"

		case $_flag_relocate in
			YES)
				if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
					__tweak_install_name_darwin "$_path" "RPATH"
				fi
				# TODO
				#__tweak_linked_lib "$_path" "REL_RPATH EXCLUDE_LINKED_LIB /System/Library|/usr/lib"
				__tweak_linked_lib "$_path" "REL_RPATH $OPT"
				if [ "$_wanted_rpath_values" == "" ]; then
					if ! __have_rpath "$_path" "$_wanted_rpath_values"; then
						__add_rpath "$_path" "$_wanted_rpath_values"
					fi
				fi
				__tweak_rpath "$_path" "REL_RPATH"
				;;
			NO)
				if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
					__tweak_install_name_darwin "$path" "PATH"
				fi
				# TODO
				#__tweak_linked_lib "$_path" "REL_RPATH EXCLUDE_LINKED_LIB /System/Library|/usr/lib"
				__tweak_linked_lib "$_path" "REL_RPATH $OPT"
				if [ "$_wanted_rpath_values" == "" ]; then
					if ! __have_rpath "$_path" "$_wanted_rpath_values"; then
						__add_rpath "$_path" "$_wanted_rpath_values"
					fi
				fi
				;;
			DEFAULT)
				if [ "$_wanted_rpath_values" == "" ]; then
					if ! __have_rpath "$_path" "$_wanted_rpath_values"; then
						__add_rpath "$_path" "$_wanted_rpath_values"
					fi
				fi
				;;
		esac

	fi
}






# RPATH -------------------------------------------------------------------
# return rpath values in search order
function __get_rpath() {
	local _file="$1"
	local _rpath_values

	if __is_executable_or_shareable_bin "$_file"; then
		if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
			_rpath_values="$(otool -l "$_file" | grep -E "LC_RPATH" -A2 | awk '/LC_RPATH/{for(i=2;i;--i)getline; print $0 }' | tr -s ' ' | cut -d ' ' -f 3 |  tr '\n' ' ')"
			echo "$(__trim $_rpath_values)"
		fi

		if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
			local _field='RUNPATH'
			IFS=':' read -ra _rpath_values <<< $(objdump -p $_file | grep -E "$_field\s" | tr -s ' ' | cut -d ' ' -f 3)
			if [ "$_rpath" == "" ]; then
				_field="RPATH"
				IFS=':' read -ra _rpath_values <<< $(objdump -p $_file | grep -E "$_field\s" | tr -s ' ' | cut -d ' ' -f 3)
			fi
			echo "${_rpath_values[@]}"
		fi
	fi
}





# modify rpath values to all binaries in the path
# ABS_RPATH : transform relative rpath values to absolute path - so rpath values turn from ../foo to /path/foo
# REL_RPATH [DEFAULT] : transform absolute rpath values to relative path
#																-	FOR MACOS : rpath values turn from /path/foo to @loader_path/foo
#																-	FOR LINUX : rpath values turn from /path/foo to $ORIGIN/foo
function __tweak_rpath() {
	local _path=$1
	local _OPT="$2"
	# INCLUDE_FILTER <expr> -- include these files
	# EXCLUDE_FILTER <expr> -- exclude these files
	# INCLUDE_FILTER is apply first, before EXCLUDE_FILTER

	if [ -d "$_path" ]; then
		for f in  "$_path"/*; do
			__tweak_rpath "$f" "$_OPT"
		done
	fi

	local _flag_exclude_filter=OFF
	local _exclude_filter=
	local _invert_filter=
	local _flag_include_filter=OFF
	local _include_filter=
	local _opt_filter=OFF
	local _rel_rpath=ON
	local _abs_rpath=OFF
	for o in $_OPT; do
		[ "$_flag_include_filter" == "ON" ] && _include_filter="$o" && _flag_include_filter=OFF
		[ "$o" == "INCLUDE_FILTER" ] && _flag_include_filter=ON && _opt_filter=ON
		[ "$_flag_exclude_filter" == "ON" ] && _exclude_filter="$o" && _flag_exclude_filter=OFF
		[ "$o" == "EXCLUDE_FILTER" ] && _flag_exclude_filter=ON && _invert_filter="-Ev" && _opt_filter=ON
		[ "$o" == "REL_RPATH" ] && _rel_rpath=ON && _abs_rpath=OFF
		[ "$o" == "ABS_RPATH" ] && _rel_rpath=OFF && _abs_rpath=ON
	done


	if [ "$_opt_filter" == "ON" ]; then
		if [ ! "$(echo $_path | grep -E "$_include_filter" | grep $_invert_filter $_exclude_filter)" == "" ]; then
			return
		fi
	fi

	if __is_executable_or_shareable_bin "$_path"; then
		local _rpath_values=
		local _new_rpath_values=
		local _flag_change=
		local _p=

		_rpath_values="$(__get_rpath $_path)"

		for line in $_rpath_values; do
			_p=
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

						[ "$STELLA_CURRENT_PLATFORM" == "darwin" ] && _p="@loader_path/$(__abs_to_rel_path "$line" $(__get_path_from_string $_path))"
						[ "$STELLA_CURRENT_PLATFORM" == "linux" ] && _p="\$ORIGIN/$(__abs_to_rel_path "$line" $(__get_path_from_string $_path))"
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
			__remove_all_rpath "$_path"
			__add_rpath "$_path" "$_new_rpath_values" "LAST"
		fi
	fi
}




# remove all rpath values to all binaries in the path
function __remove_all_rpath() {
	local _path=$1

	local _rpath_list_values
	local msg=

	if [ -d "$_path" ]; then
		for f in  "$_path"/*; do
			__remove_all_rpath "$f"
		done
	fi

	if __is_executable_or_shareable_bin "$_file"; then
		_rpath_list_values="$(__get_rpath $_path)"

		if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
			for r in $_rpath_list_values; do
				msg="$msg -- deleting RPATH value : $r"
				install_name_tool -delete_rpath "$r" "$_path"
			done
		fi
		if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
			__require "patchelf" "patchelf" "PREFER_STELLA"
			patchelf --set-rpath "" "$_path"
		fi
		[ ! "$msg" == "" ] && echo "** Deleting rpath values from $_path $msg"
	fi
}


# check if binary have some specific rpath values
function __have_rpath() {
	local _path="$1"
	local _rpath_values="$2"
	local _result=1
	local j
	local r


	if [ -d "$_path" ]; then
		for f in  "$_path"/*; do
			__have_rpath "$f" || _result=1
		done
	fi

	if [ -f "$_file" ]; then
		local _existing_rpath="$(__get_rpath $_path)"

		for r in $_rpath_values; do
			printf %s "*** Checking if this RPATH value is missing : $r"
			for j in $_existing_rpath; do
				[ "$j" == "$r" ] && _result=0
			done
			if [ "$_result" == "1" ];then
				printf %s " -- WARN RPATH is missing"
			else
				printf %s " -- OK"
			fi
			echo
		done
	fi

	return $_result
}


# add rpath values to all binaries in the path by adding rpath values contained in list _rpath_list_values
# if a rpath value is already setted, it will be just reordered
# 		FIRST (DEFAULT) : rpath values will be put in first order search
#			LAST : rpath values will be put in last order search
function __add_rpath() {
	local _path=$1
	local _rpath_list_values="$2"
	local OPT="$3"

	if [ -d "$_path" ]; then
		for f in  "$_path"/*; do
			__add_rpath "$f" "$_rpath_list_values" "$OPT"
		done
	fi

	local msg=

	if __is_executable_or_shareable_bin "$_file"; then
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

		_old_rpath="$(__get_rpath $_path)"
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

		[ "$STELLA_CURRENT_PLATFORM" == "darwin" ] && __remove_all_rpath "$_path"

		if [ "$_flag_first_place" == "ON" ]; then
			_new_rpath="$_rpath_list_values $_new_rpath"
		fi
		if [ "$_flag_last_place" == "ON" ]; then
			_new_rpath="$_new_rpath $_rpath_list_values"
		fi

		# adding values
		_new_rpath="$(__trim $_new_rpath)"
		if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
			for p in $_new_rpath; do
				msg="$msg -- adding RPATH value : $p"
				install_name_tool -add_rpath "$p" "$_path"
			done
		fi
		if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
			__require "patchelf" "patchelf" "PREFER_STELLA"
			patchelf --set-rpath "${_new_rpath// /:}" "$_path"
			msg="$msg -- adding : $_new_rpath"
		fi

		[ ! "$msg" == "" ] && echo "** Adding rpath values to $_path $msg"
	fi
}


# check rpath values of exexcutable binary and shared lib
# 		NO_RPATH -- must not have any rpath
# 		REL_RPATH -- rpath must be a relative path
# 		ABS_RPATH -- rpath must be an absolute path
#			MISSING_RPATH val1 val2 ... -- check some missing rpath
# 		INCLUDE_FILTER <expr> -- include these files
#			EXCLUDE_FILTER <expr> -- exclude these files
# 		INCLUDE_FILTER is apply first, before EXCLUDE_FILTER
function __check_rpath() {
	local _path="$1"
	local OPT="$2"
	local t
	local _result=0

	if [ -d "$_path" ]; then
		for f in  "$_path"/*; do
			__check_rpath "$f" "$OPT" || _result=1
		done
	fi

	local _flag_exclude_filter=OFF
	local _exclude_filter=
	local _invert_filter=
	local _flag_include_filter=OFF
	local _include_filter=
	local _opt_filter=OFF
	local _no_rpath=OFF
	local _rel_rpath=OFF
	local _abs_rpath=OFF
	local _flag_missing_rpath=OFF
	local _missing_rpath_values=
	local _opt_missing_rpath=OFF
	for o in $OPT; do
		[ "$_flag_include_filter" == "ON" ] && _include_filter="$o" && _flag_include_filter=OFF
		[ "$o" == "INCLUDE_FILTER" ] && _flag_include_filter=ON && _opt_filter=ON && _flag_missing_rpath=OFF
		[ "$_flag_exclude_filter" == "ON" ] && _exclude_filter="$o" && _flag_exclude_filter=OFF
		[ "$o" == "EXCLUDE_FILTER" ] && _flag_exclude_filter=ON && _invert_filter="-Ev" && _opt_filter=ON && _flag_missing_rpath=OFF
		[ "$_flag_missing_rpath" == "ON" ] && _missing_rpath_values="$o $_missing_rpath_values"
		[ "$o" == "MISSING_RPATH" ] && _flag_missing_rpath=ON && _opt_missing_rpath=ON
		[ "$o" == "NO_RPATH" ] && _no_rpath=ON && _flag_missing_rpath=OFF
		[ "$o" == "REL_RPATH" ] && _rel_rpath=ON && _abs_rpath=OFF && _flag_missing_rpath=OFF
		[ "$o" == "ABS_RPATH" ] && _rel_rpath=OFF && _abs_rpath=ON && _flag_missing_rpath=OFF
	done

	if [ "$_opt_filter" == "ON" ]; then
		if [ ! "$(echo $_path | grep -E "$_include_filter" | grep $_invert_filter $_exclude_filter)" == "" ]; then
			return $_result
		fi
	fi

	if __is_executable_or_shareable_bin "$_path"; then
		t="$(__get_rpath $_path)"

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

			__have_rpath "$_path" "$_missing_rpath_values" || _result=1

		fi
	fi

	return $_result

}








# LINKED LIB --------------------------------
# return linked libs
function __get_linked_lib() {
	local _file="$1"
	local _opt="$2"

	# INCLUDE_LINKED_LIB <expr> -- include these linked libs
	# EXCLUDE_LINKED_LIB <expr> -- exclude these linked libs
	# INCLUDE_LINKED_LIB is apply first, before EXCLUDE_LINKED_LIB

	local _flag_exclude_filter=OFF
	local _exclude_filter=
	local _invert_filter=
	local _flag_include_filter=OFF
	local _include_filter=
	for o in $_opt; do
		[ "$_flag_include_filter" == "ON" ] && _include_filter="$o" && _flag_include_filter=OFF
		[ "$o" == "INCLUDE_LINKED_LIB" ] && _flag_include_filter=ON
		[ "$_flag_exclude_filter" == "ON" ] && _exclude_filter="$o" && _flag_exclude_filter=OFF
		[ "$o" == "EXCLUDE_LINKED_LIB" ] && _flag_exclude_filter=ON && _invert_filter="-Ev"
	done


	local _linked_lib
	if __is_executable_or_shareable_bin "$_file"; then
		if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
			_linked_lib="$(otool -l "$_file" | grep -E "LC_LOAD_DYLIB" -A2 | awk '/LC_LOAD_DYLIB/{for(i=2;i;--i)getline; print $0 }' | grep -E "$_include_filter" | grep $_invert_filter "$_exclude_filter" | tr -s ' ' | cut -d ' ' -f 3 |  tr '\n' ' ')"
			echo "$(__trim $_linked_lib)"
		fi

		if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
			_linked_lib="$(objdump -p $_file | grep -E "NEEDED" | grep -E "$_include_filter" | grep $_invert_filter "$_exclude_filter" | tr -s ' ' | cut -d ' ' -f 3 |  tr '\n' ' ')"
			echo "$(__trim $_linked_lib)"
		fi
	fi
}

# check dynamic link at runtime
# Print out dynamic libraries loaded at runtime when launching a program :
# 		on DARWIN : DYLD_PRINT_LIBRARIES=y program
# 		on LINUX : LD_TRACE_LOADED_OBJECTS=1 program
function __check_linked_lib() {
	local _path="$1"
	local _OPT="$2"
	# INCLUDE_FILTER <expr> -- include these files
	# EXCLUDE_FILTER <expr> -- exclude these files
	# INCLUDE_FILTER is apply first, before EXCLUDE_FILTER

	local line=
	local linked_lib_list=
	local linked_lib=

	local _result=0

	if [ -d "$_path" ]; then
		for f in  "$_path"/*; do
			__check_linked_lib "$f" "$_OPT"|| _result=1
		done
	fi

	local _flag_exclude_filter=OFF
	local _exclude_filter=
	local _invert_filter=
	local _flag_include_filter=OFF
	local _include_filter=
	local _opt_filter=OFF
	for o in $_OPT; do
		[ "$_flag_include_filter" == "ON" ] && _include_filter="$o" && _flag_include_filter=OFF
		[ "$o" == "INCLUDE_FILTER" ] && _flag_include_filter=ON && _opt_filter=ON
		[ "$_flag_exclude_filter" == "ON" ] && _exclude_filter="$o" && _flag_exclude_filter=OFF
		[ "$o" == "EXCLUDE_FILTER" ] && _flag_exclude_filter=ON && _invert_filter="-Ev" && _opt_filter=ON
	done

	if [ "$_opt_filter" == "ON" ]; then
		if [ ! "$(echo $_path | grep -E "$_include_filter" | grep $_invert_filter $_exclude_filter)" == "" ]; then
			return $_result
		fi
	fi

	if __is_executable_or_shareable_bin "$_path"; then
		echo "*** Checking missing dynamic library at runtime"
		if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
			__find_linked_lib_darwin "$_path" || _result=1
		fi
		if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
			__find_linked_lib_linux "$_path" || _result=1
		fi
	fi

	return $_result
}


# try to resolve linked libs of all binaries in path
function __find_linked_lib_darwin() {
	local _path="$1"
	local _result=0

	if [ -d "$_path" ]; then
		for f in  "$_path"/*; do
			__find_linked_lib_darwin "$f" || _result=1
		done
	fi

	if __is_executable_or_shareable_bin "$_path"; then
		local _lib_list="$(__get_linked_lib "$_path")"
		echo "====> Binary : $_path"
		echo "====> Linked libraries : $_lib_list"
		local _rpath=
		_rpath="$(__get_rpath $_path)"
		echo "====> setted rpath : $_rpath"
		local loader_path="$(__get_path_from_string "$_path")"
		echo "====> loader path (computed) : $loader_path"
		echo "====> install name (not used while resolving libs) : $(__get_install_name_darwin "$_path")"

		local _match
		local line
		local linked_lib
		local p
		local original_rpath_value

		for line in $_lib_list; do
			printf %s "====> checking lib : $line "
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

	return $_result
}

# try to resolve linked libs
function __find_linked_lib_linux() {
	local _path="$1"
	local _result=0

	if [ -d "$_path" ]; then
		for f in  "$_path"/*; do
			__find_linked_lib_linux "$f" || _result=1
		done
	fi
	if __is_executable_or_shareable_bin "$_path"; then
		local _lib_list="$(__get_linked_lib "$_path")"
		echo "====> Binary : $_path"
		echo "====> Linked libraries : $_lib_list"
		local _rpath=
		_rpath="$(__get_rpath $_path)"
		echo "====> setted binary rpath : $_rpath"
		local loader_path="$(__get_path_from_string "$_path")"
		echo "====> loader path (computed) : $loader_path"

		$STELLA_ARTEFACT/lddtree/lddtree.sh -m --no-recursive --no-header $_path || _result=1
	fi
	return $_result
}






# fix linked shared lib by modifying LOAD_DYLIB and adding rpath values
# 	- before you can filter libs to tweak with filters
# 				INCLUDE_FILTER <expr> -- include these files
# 				EXCLUDE_FILTER <expr> -- exclude these files
# 				INCLUDE_FILTER is apply first, before EXCLUDE_FILTER
# 	-	first choose linked lib to modify path
# 				INCLUDE_LINKED_LIB <expr> -- include these linked libs
# 				EXCLUDE_LINKED_LIB <expr> -- exclude these linked libs
# 				INCLUDE_LINKED_LIB is apply first, before EXCLUDE_LINKED_LIB
#		-	second transform path to linked lib -- you can choose to :
#				-	transform all linked libs with rel path to abs path (ABS_RPATH) (for MachO : including @loader_path, but do not change @rpath or @executable_path because we cant determine the path)
#				-	transform all linked libs with abs path to rel path (REL_RPATH) (for ELF : set linked lib with lib file name and add an RPATH value corresponding to the relative path to the file with $ORIGIN)
#																																					(for MachO : set linked lib as @rpath/lib and add an RPATH value corresponding to the relative path to the file with @loader_path/)
#				-	force a specific path (FIXED_PATH <path>) for all lib -- so each linked lib is registered now with path/linked_lib
function __tweak_linked_lib() {
	local _file=$1
	local OPT="$2"

	local f=
	if [ -d "$_file" ]; then
		for f in  "$_file"/*; do
			__tweak_linked_lib "$f" "$OPT"
		done
	fi

	# linked lib filter :
	# INCLUDE_LINKED_LIB <expr> -- include from the transformation these linked libraries
	# EXCLUDE_LINKED_LIB <expr> -- exclude from the transformation these linked libraries
	# INCLUDE_LINKED_LIB is apply first, before EXCLUDE_LINKED_LIB
	# path management :
	# ABS_RPATH -- turn linked lib path into an absolute path (only linked libs with rel path are selected (for MachO : including @loader_path not @rpath or @executable_path because we cant determine the path))
	# REL_RPATH [DEFAULT MODE] -- turn linked lib path into a relative path (only linked libs with absolute paths are selected)
	# FIXED_PATH <path> -- fix with a given path -- so each linked lib is registered now with fixed_path/linked_lib

	local _flag_exclude_filter_files=OFF
	local _exclude_filter_files=
	local _invert_filter_files=
	local _flag_include_filter_files=OFF
	local _include_filter_files=
	local _opt_filter_files=OFF

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

	if [ "$_opt_filter_files" == "ON" ]; then
		if [ ! "$(echo $_file | grep -E "$_include_filter_files" | grep $_invert_filter_files $_exclude_filter_files)" == "" ]; then
			return
		fi
	fi

	if __is_executable_or_shareable_bin "$_file"; then
		local _new_load_lib=
		local line=
		local _linked_lib_filename=
		local _filename
		local _linked_lib_list=
		local _flag_existing_rpath=

		# get all linked libs
		# INCLUDE_LINKED_LIB and EXCLUDE_LINKED_LIB apply here
		local __all_linked_libs="$(__get_linked_lib "$_file" "$OPT")"

		# get existing linked lib
		for line in $__all_linked_libs; do
			# FIXED_PATH : pick all filtered libraries
			if [ "$_fixed_path" == "ON" ]; then
				_linked_lib_list="$_linked_lib_list $line"
			fi

			# ABS_RPATH : pick only rel path (for MachO pick also @loader_path - do not pick @rpath or @executable_path because we cant determine the path )
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
		done

		if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
			__require "patchelf" "patchelf" "PREFER_STELLA"
		fi
		for l in $_linked_lib_list; do
			_filename=$(__get_filename_from_string $_file)
			_linked_lib_filename="$(__get_filename_from_string $l)"

			echo "** Fixing $_filename linked to $_linked_lib_filename shared lib"

			if [ "$_fixed_path" == "ON" ]; then
				if [ "$STELLA_CURRENT_PLATFORM" == "linux"]; then
					echo "====> setting NEEDED : $_force_path/$_linked_lib_filename"
					patchelf --replace-needed "$l" "$_force_path/$_linked_lib_filename" "$_file"
				fi
				if [ "$STELLA_CURRENT_PLATFORM" == "darwin"]; then
					echo "====> setting LC_LOAD_DYLIB : $_force_path/$_linked_lib_filename"
					install_name_tool -change "$l" "$_force_path/$_linked_lib_filename" "$_file"
				fi
			fi

			if [ "$_abs_rpath" == "ON" ]; then
				if [ "$STELLA_CURRENT_PLATFORM" == "linux"]; then
					_new_load_lib="$(__get_path_from_string $l)"
					echo "====> setting NEEDED : $_new_load_lib/$_linked_lib_filename"
					patchelf --replace-needed "$l" "$_new_load_lib/$_linked_lib_filename" "$_file"
				fi
				if [ "$STELLA_CURRENT_PLATFORM" == "darwin"]; then
					_new_load_lib="$(__get_path_from_string $l)"
					echo "====> setting LC_LOAD_DYLIB : $_new_load_lib/$_linked_lib_filename"
					install_name_tool -change "$l" "$_new_load_lib/$_linked_lib_filename" "$_file"
				fi
			fi


			if [ "$_rel_rpath" == "ON" ]; then
				if [ "$STELLA_CURRENT_PLATFORM" == "linux"]; then
					_new_load_lib="\$ORIGIN/$(__abs_to_rel_path $_new_load_lib $(__get_path_from_string $_file))"
					echo "====> setting NEEDED : $_linked_lib_filename"
					patchelf --replace-needed "$l" "$_linked_lib_filename" "$_file"

					echo "====> Adding RPATH value : $_new_load_lib"
					#__set_build_mode "RPATH" "ADD" "$_new_load_lib"
					__add_rpath "$_file" "$_new_load_lib"
				fi
				if [ "$STELLA_CURRENT_PLATFORM" == "darwin"]; then
					_new_load_lib="@loader_path/$(__abs_to_rel_path $_new_load_lib $(__get_path_from_string $_file))"
					echo "====> setting LC_LOAD_DYLIB : @rpath/$_linked_lib_filename"
					install_name_tool -change "$l" "@rpath/$_linked_lib_filename" "$_file"

					echo "====> Adding RPATH value : $_new_load_lib"
					#__set_build_mode "RPATH" "ADD" "$_new_load_lib"
					__add_rpath "$_file" "$_new_load_lib"
				fi
			fi
		done


	fi

}





# DARWIN -------------------------------------------------------------------


# DARWIN : INSTALL NAME --------------------------------
function __get_install_name_darwin() {
	local _file=$1
	if __is_shareable_bin "$_file"; then
		if __is_macho "$_file" || __is_macho_universal "$_file"; then
			echo $(otool -l "$_file" | grep -E "LC_ID_DYLIB" -A2 | awk '/LC_ID_DYLIB/{for(i=2;i;--i)getline; print $0 }' | tr -s ' ' | cut -d ' ' -f 3)
		fi
	fi
}



# check ID/Install Name value
# 		RPATH -- check if install_name has @rpath
# 		PATH -- check if install_name is a standard path and is matching current file location
# INCLUDE_FILTER <expr> -- include these files
# EXCLUDE_FILTER <expr> -- exclude these files
# INCLUDE_FILTER is apply first, before EXCLUDE_FILTER
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

	local _flag_exclude_filter=OFF
	local _exclude_filter=
	local _invert_filter=
	local _flag_include_filter=OFF
	local _include_filter=
	local _opt_filter=OFF
	local _opt_rpath=OFF
	local _opt_path=OFF
	for o in $OPT; do
		[ "$_flag_include_filter" == "ON" ] && _include_filter="$o" && _flag_include_filter=OFF
		[ "$o" == "INCLUDE_FILTER" ] && _flag_include_filter=ON && _opt_filter=ON
		[ "$_flag_exclude_filter" == "ON" ] && _exclude_filter="$o" && _flag_exclude_filter=OFF
		[ "$o" == "EXCLUDE_FILTER" ] && _flag_exclude_filter=ON && _invert_filter="-Ev" && _opt_filter=ON
		[ "$o" == "RPATH" ] && _opt_rpath=ON && _opt_path=OFF
		[ "$o" == "PATH" ] && _opt_rpath=OFF && _opt_path=ON
	done

	if [ "$_opt_filter" == "ON" ]; then
		if [ ! "$(echo $_path | grep -E "$_include_filter" | grep $_invert_filter $_exclude_filter)" == "" ]; then
			return $_result
		fi
	fi


	if __is_shareable_bin "$_path"; then
		if __is_macho "$_path" || __is_macho_universal "$_path"; then


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
# 		RPATH -- tweak install_name with @rpath [DEFAULT]
# 		PATH -- tweak install_name with current location
# INCLUDE_FILTER <expr> -- include these files
# EXCLUDE_FILTER <expr> -- exclude these files
# INCLUDE_FILTER is apply first, before EXCLUDE_FILTER
function __tweak_install_name_darwin() {
	local _path=$1
	local OPT="$2"
	local _new_install_name
	local _original_install_name


	local f=
	if [ -d "$_path" ]; then
		for f in  "$_path"/*; do
			__tweak_install_name_darwin "$f" "$OPT"
		done
	fi

	local _flag_exclude_filter=OFF
	local _exclude_filter=
	local _invert_filter=
	local _flag_include_filter=OFF
	local _include_filter=
	local _opt_filter=OFF
	local _opt_rpath=ON
	local _opt_path=OFF
	for o in $OPT; do
		[ "$_flag_include_filter" == "ON" ] && _include_filter="$o" && _flag_include_filter=OFF
		[ "$o" == "INCLUDE_FILTER" ] && _flag_include_filter=ON && _opt_filter=ON
		[ "$_flag_exclude_filter" == "ON" ] && _exclude_filter="$o" && _flag_exclude_filter=OFF
		[ "$o" == "EXCLUDE_FILTER" ] && _flag_exclude_filter=ON && _invert_filter="-Ev" && _opt_filter=ON
		[ "$o" == "RPATH" ] && _opt_rpath=ON && _opt_path=OFF
		[ "$o" == "PATH" ] && _opt_rpath=OFF && _opt_path=ON
	done

	if [ "$_opt_filter" == "ON" ]; then
		if [ ! "$(echo $_path | grep -E "$_include_filter" | grep $_invert_filter $_exclude_filter)" == "" ]; then
			return
		fi
	fi

	if __is_shareable_bin "$_path"; then
		if __is_macho "$_path" || __is_macho_universal "$_path"; then


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







fi
