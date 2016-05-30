if [ ! "$_STELLA_COMMON_BINARY_INCLUDED_" == "1" ]; then
_STELLA_COMMON_BINARY_INCLUDED_=1

# GENERIC
# __get_arch
# __check_arch
# __check_binary_files TODO : review
# __is_object_bin
# __is_shareable_bin
# __is_static_lib

# RPATH
# __get_rpath
# __have_rpath
# __tweak_rpath
# __remove_all_rpath
# __add_rpath
# __check_rpath

# LINKED LIB
# __get_linked_lib
# __check_linked_lib
# __find_linked_lib_darwin			__find_linked_lib_linux
# __fix_linked_lib_darwin					TODO : __tweak_linked_lib

# DARWIN : install_name
# __get_install_name_darwin
# __check_install_name_darwin
# __tweak_install_name_darwin

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
	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		__is_macho_universal "$_file" && _result=0
	fi
	return $_result
}

function __get_arch() {
	local _file="$1"
	local _result=

	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		__is_multi_arch "$_file" && _result="MULTI_ARCH" || \
		_result="$(__macho_magic "$(__macho_header "$_file")" | grep 64)"
		if [ ! "$_result" == "" ]; then
			_result=x64
		else
			_result=x86
		fi
	fi

	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		_result="$(__elf_class "$(__elf_header "$_file")" | grep 64)"
		if [ ! "$_result" == "" ]; then
			_result=x64
		else
			_result=x86
		fi
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


# is a binary object (static lib, shared lib, executable)
function __is_object_bin() {
		local _file="$1"
		local _result="FALSE"

		local _type_bin="$(__type_bin "$_file")"

		# is this a Mach O / Mach O Universal file or an archive
		if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
			local pattern="FILE_MACHO|FILE_MACHO_UNIVERSAL|FILE_AR"
			[[ "$_type_bin" =~ $pattern ]] && _result="TRUE"
		fi

		# is this an elf file or an archive
		if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
			local pattern="FILE_ELF|FILE_AR"
			[[ "$_type_bin" =~ $pattern ]] && _result="TRUE"
		fi

		echo $_result
}

function __is_static_lib() {
	local _file="$1"
	local _result=1

	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		__is_macho_universal "$_file" || return $(__is_archive "$_file") && \
		[[ "$(__macho_universal_global_filetype "$_file")" =~ UNIXARCH ]] && _result=0
	fi

	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		return $(__is_archive "$_file")
	fi
	return $_result
}

# object is shareable (shared lib or executable)
# NOTE on linux it happens that executable file have DYN flag instead of EXEC flag
# http://stackoverflow.com/a/34522357
function __is_shareable_bin() {
	local _file="$1"
	local _result=1

	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		if [ __is_macho "$_file" ]; then
			local _header="$(__macho_header "$_file")"
  		[[ "$(__macho_filetype "$(__macho_header "$_file")")" =~ MH_DYLIB ]] && _result=0
		else
			if [ __is_macho_universal "$_file" ]; then
				[[ "$(__macho_universal_global_filetype "$_file")" =~ MH_DYLIB ]] && _result=0
			fi
		fi
	fi

	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		if [ __is_elf "$_file" ]; then
			[[ "$(__elf_filetype "$(__elf_header "$_file")")" =~ ET_DYN ]] && _result=0
		fi
	fi

	return $_result
}

# run some test for binary files
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


		if [ "$(__is_object_bin $path)" == "TRUE" ]; then
			echo
			echo "** Analysing $path"

			if [ "$_opt_arch" == "ON" ]; then
				__check_arch "$path" "$_arch" || _result=1
			fi

			case $_flag_relocate in
				YES)
					if [[ "$path" =~ .*dylib.* ]]; then
						__check_install_name_darwin "$path" "RPATH" || _result=1
					fi
					if [ ! "$(__get_extension_from_string $path)" == "a" ]; then
						__check_rpath "$path" "REL_RPATH $_check_rpath_opt" || _result=1
					fi
					;;
				NO)
					if [[ "$path" =~ .*dylib.* ]]; then
						__check_install_name_darwin "$path" "PATH"
					fi
					if [ ! "$(__get_extension_from_string $path)" == "a" ]; then
						__check_rpath "$path" "ABS_RPATH $_check_rpath_opt" || _result=1
					fi
					;;
				DEFAULT)
					if [[ "$path" =~ .*dylib.* ]]; then
						__check_install_name_darwin "$path" || _result=1
					fi
					if [ ! "$(__get_extension_from_string $path)" == "a" ]; then
						__check_rpath "$path" "$_check_rpath_opt" || _result=1
					fi
					;;
			esac

			__check_linked_lib "$path" || _result=1

			echo
		fi

	fi

}























# DARWIN -------------------------------------------------------------------


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

		if [ "$(__is_object_bin $_path)" == "TRUE" ]; then

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
# 		RPATH -- tweak install_name with @rpath [DEFAULT]
# 		PATH -- tweak install_name with current location
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

		if [ "$(__is_object_bin $_path)" == "TRUE" ]; then

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






# LINKED LIB --------------------------------
# return linked libs
function __get_linked_lib() {
	local _file="$1"
	local _opt="$2"

	local _exclude_filter=
	local _invert_filter=
	local _flag_include_filter=OFF
	local _include_filter=
	local _flag_exclude_filter=OFF
	for o in $_opt; do
		[ "$_flag_include_filter" == "ON" ] && _include_filter="$o" && _flag_include_filter=OFF
		[ "$o" == "INCLUDE_FILTER" ] && _flag_include_filter=ON
		[ "$_flag_exclude_filter" == "ON" ] && _exclude_filter="$o" && _flag_exclude_filter=OFF
		[ "$o" == "EXCLUDE_FILTER" ] && _flag_exclude_filter=ON && _invert_filter="-Ev"
	done


	local _linked_lib

	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		_linked_lib="$(otool -l "$_file" | grep -E "LC_LOAD_DYLIB" -A2 | awk '/LC_LOAD_DYLIB/{for(i=2;i;--i)getline; print $0 }' | grep -E "$_include_filter" | grep $_invert_filter "$_exclude_filter" | tr -s ' ' | cut -d ' ' -f 3 |  tr '\n' ' ')"
		echo "$(__trim $_linked_lib)"
		return 0
	fi

	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		_linked_lib="$(objdump -p $_file | grep -E "NEEDED" | grep -E "$_include_filter" | grep $_invert_filter "$_exclude_filter" | tr -s ' ' | cut -d ' ' -f 3 |  tr '\n' ' ')"
		echo "$(__trim $_linked_lib)"
		return 0
	fi
}

# check dynamic link at runtime
# Print out dynamic libraries loaded at runtime when launching a program :
# 		on DARWIN : DYLD_PRINT_LIBRARIES=y program
# 		on LINUX : LD_TRACE_LOADED_OBJECTS=1 program
function __check_linked_lib() {
	local _path="$1"
	local line=
	local linked_lib_list=
	local linked_lib=

	local _result=0

	if [ -d "$_path" ]; then
		for f in  "$_path"/*; do
			__check_linked_lib "$f" || _result=1
		done
	fi

	if [ -f "$_path" ]; then
		if [ "$(__is_object_bin $_path)" == "TRUE" ]; then
			echo "*** Checking missing dynamic library at runtime"
			if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
				__find_linked_lib_darwin "$_path" || _result=1
			fi
		fi
	fi

	return $_result
}


# try to resolve linked libs
function __find_linked_lib_darwin() {
	local _path="$1"

	local _result=0

	local _lib_list="$(__get_linked_lib "$_path")"
	echo "====> Binary : $_path"
	echo "====> Linked libraries : $_lib_list"
	local _rpath=
	_rpath="$(__get_rpath $_path)"
	echo "====> setted binary rpath : $_rpath"
	local loader_path="$(__get_path_from_string "$_path")"
	echo "====> loader path : $loader_path"
	echo "====> install name (not used while resolving libs) : $(__get_install_name_darwin "$_path")"

	local _match, line, linked_lib, p,original_rpath_value

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

	return $_result
}

# try to resolve linked libs
function __find_linked_lib_linux() {
	local _path="$1"

	local _result=0

	local _lib_list="$(__get_linked_lib "$_path")"
	echo "====> Binary : $_path"
	echo "====> Linked libraries : $_lib_list"
	local _rpath=
	_rpath="$(__get_rpath $_path)"
	echo "====> setted binary rpath : $_rpath"
	local loader_path="$(__get_path_from_string "$_path")"
	echo "====> loader path : $loader_path"


	$STELLA_ARTEFACT/lddtree/lddtree.sh -m --no-recursive --no-header $_path || _result=1

	return $_result
}


# fix linked shared lib by modifying LOAD_DYLIB and adding rpath values
# 	-	first choose linked lib to modify path -- you can filter libs by exclude some (EXCLUDE_FILTER) or include some (INCLUDE_FILTER)
#		-	second transform path to linked lib -- you can choose to :
#				-	transform all linked libs with rel path to abs path (ABS_RPATH) (including @loader_path, but do not change @rpath or @executable_path because we cant determine the path)
#				-	transform all linked libs with abs path to rel path (REL_RPATH) (use @rpath and add an RPATH value corresponding to the relative path to the file with @loader_path/)
#				-	force a specific path (FIXED_PATH <path>) -- so each linked lib is registered now with path/linked_lib
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
		if [ "$(__is_object_bin $_path)" == "TRUE" ]; then

			local _new_load_dylib=
			local line=
			local _linked_lib_filename=
			local _filename
			local _linked_lib_list=
			local _flag_existing_rpath=

			# get all linked libs
			local __all_linked_libs="$(__get_linked_lib "$_file" "$OPT")"

			# get existing linked lib
			#while read -r line; do
			for l in $__all_linked_libs; do
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
			done
			#done <<< "$(otool -l "$_file" | grep -E "LC_LOAD_DYLIB" -A2 | awk '/LC_LOAD_DYLIB/{for(i=2;i;--i)getline; print $0 }' | grep -E "$_include_filter" | grep $_invert_filter "$_exclude_filter" | tr -s ' ' | cut -d ' ' -f 3)"


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

					echo "====> Adding RPATH value (if not already exists) : $_new_load_dylib"
					#__set_build_mode "RPATH" "ADD" "$_new_load_dylib"
					__add_rpath "$_file" "$_new_load_dylib"

				fi
			done
		fi
	fi
}

























# RPATH -------------------------------------------------------------------
# RPATH on linux

# return rpath values in search order
function __get_rpath() {
	local _file="$1"
	local _rpath_values

	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		_rpath_values="$(otool -l "$_file" | grep -E "LC_RPATH" -A2 | awk '/LC_RPATH/{for(i=2;i;--i)getline; print $0 }' | tr -s ' ' | cut -d ' ' -f 3 |  tr '\n' ' ')"
		echo "$(__trim $_rpath_values)"
		return 0
	fi

	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		local _field='RUNPATH'
		IFS=':' read -ra _rpath_values <<< $(objdump -p $_file | grep -E "$_field\s" | tr -s ' ' | cut -d ' ' -f 3)
		if [ "$_rpath" == "" ]; then
			_field="RPATH"
			IFS=':' read -ra _rpath_values <<< $(objdump -p $_file | grep -E "$_field\s" | tr -s ' ' | cut -d ' ' -f 3)
		fi
		echo "${_rpath_values[@]}"
		return 0
	fi

}

# modify rpath values
# ABS_RPATH : transform relative rpath values to absolute path - so rpath values turn from ../foo to /path/foo
# REL_RPATH [DEFAULT] : transform absolute rpath values to relative path
#																-	FOR MACOS : rpath values turn from /path/foo to @loader_path/foo
#																-	FOR LINUX : rpath values turn from /path/foo to $ORIGIN/foo
function __tweak_rpath() {
	local _path=$1
	local _OPT="$2"


	if [ -d "$_path" ]; then
		for f in  "$_path"/*; do
			__tweak_rpath "$f" "$_OPT"
		done
	fi

	if [ -f "$_path" ]; then
		if [ "$(__is_object_bin $_path)" == "TRUE" ]; then
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
	fi
}




# remove all rpath values
function __remove_all_rpath() {
	local _path=$1

	local _rpath_list_values
	local msg=

	if [ -d "$_path" ]; then
		for f in  "$_path"/*; do
			__remove_all_rpath "$f"
		done
	fi

	if [ -f "$_path" ]; then

		if [ "$(__is_object_bin $_path)" == "TRUE" ]; then
			_rpath_list_values="$(__get_rpath $_path)"

			if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
				for r in $_rpath_list_values; do
					msg="$msg -- deleting RPATH value : $r"
					install_name_tool -delete_rpath "$r" "$_path"
				done
			fi
			if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
				patchelf --set-rpath "" "$_path"
			fi
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

	return $_result
}


# add rpath values by adding rpath values contained in list _rpath_list_values
# if a rpath value is already setted, it will be just reordered
# 		FIRST (DEFAULT) : rpath values will be put in first order search
#			LAST : rpath values will be put in last order search
function __add_rpath() {
	local _path=$1
	local _rpath_list_values="$2"
	local OPT="$3"

	if [ "$_rpath_list_values" == "" ]; then
		return 0
	fi

	if [ -d "$_path" ]; then
		for f in  "$_path"/*; do
			__add_rpath "$f" "$_rpath_list_values" "$OPT"
		done
	fi

	local msg=

	if [ -f "$_path" ]; then

		if [ "$(__is_object_bin $_path)" == "TRUE" ]; then

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
				patchelf --set-rpath "${_new_rpath// /:}" "$_path"
				msg="$msg -- adding : $_new_rpath"
			fi

			[ ! "$msg" == "" ] && echo "** Adding rpath values to $_path $msg"
		fi
	fi
}


# check rpath values of exexcutable binary and shared lib
# 		NO_RPATH -- must not have any rpath
# 		REL_RPATH -- rpath must be a relative path
# 		ABS_RPATH -- rpath must be an absolute path
#			MISSING_RPATH val1 val2 ... -- check some missing rpath
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
		if [ "$(__is_object_bin $_path)" == "TRUE" ]; then

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
	fi

	return $_result

}






fi
