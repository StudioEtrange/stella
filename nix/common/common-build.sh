if [ ! "$_STELLA_COMMON_BUILD_INCLUDED_" == "1" ]; then 
_STELLA_COMMON_BUILD_INCLUDED_=1

# NOTE : homebrew flag setting system : https://github.com/Homebrew/homebrew/blob/master/Library/Homebrew/extend/ENV/super.rb





# BUILD ------------------------------------------------------------------------------------------------------------------------------


function __auto_install() {
	
	local NAME
	local FILE_NAME
	local URL
	local PROTOCOL
	local SOURCE_DIR
	local BUILD_DIR
	local INSTALL_DIR
	local OPT


	NAME="$1"
	FILE_NAME="$2"
	URL="$3"
	PROTOCOL="$4"
	SOURCE_DIR="$5"
	INSTALL_DIR="$6"
	OPT="$7"
	# DEBUG SOURCE_KEEP BUILD_KEEP UNPARALLELIZE NO_CONFIG CONFIG_TOOL xxxx NO_BUILD BUILD_TOOL xxxx

	# keep source code after build (default : FALSE)
	local _opt_source_keep=
	# keep build dir after build (default : FALSE)
	local _opt_build_keep=
	# configure step activation (default : TRUE)
	local _opt_configure=ON
	# build step activation (default : TRUE)
	local _opt_build=ON
	# build from another folder (default : TRUE)
	local _opt_out_of_tree_build=ON

	for o in $OPT; do 
		[ "$o" == "SOURCE_KEEP" ] && _opt_source_keep=ON
		[ "$o" == "BUILD_KEEP" ] && _opt_build_keep=ON
		[ "$o" == "NO_CONFIG" ] && _opt_configure=OFF 
		[ "$o" == "NO_BUILD" ] && _opt_build=OFF
		[ "$o" == "NO_OUT_OF_TREE_BUILD" ] && _opt_out_of_tree_build=OFF
	done

	# can not build out of tree without configure first
	[ "$_opt_configure" == "OFF" ] && _opt_out_of_tree_build=OFF

	BUILD_DIR="$SOURCE_DIR"
	[ "$_opt_out_of_tree_build" == "ON" ] && BUILD_DIR="$(dirname $SOURCE_DIR)/$(basename $SOURCE_DIR)-build"

	# TODO arch option && __set_build_mode SET_ARCH $ARCH
	echo " ** Auto-installing $NAME in $INSTALL_DIR"

	# install dir could be deleted only at feature_install
	#rm -Rf "$INSTALL_DIR"
	mkdir -p "$INSTALL_DIR"

	__get_resource "$NAME" "$URL" "$PROTOCOL" "$SOURCE_DIR" "STRIP FORCE_NAME $FILE_NAME"
	
	
	[ "$_opt_configure" == "ON" ] && __auto_configure "$SOURCE_DIR" "$INSTALL_DIR" "$BUILD_DIR" "$OPT"
	[ "$_opt_build" == "ON" ] && __auto_build "$SOURCE_DIR" "$INSTALL_DIR" "$BUILD_DIR" "$OPT"

	[ ! "$_opt_source_keep" == "ON" ] && rm -Rf "$SOURCE_DIR"

	if [ "$_opt_out_of_tree_build" == "ON" ]; then
		[ ! "$_opt_build_keep" == "ON" ] && rm -Rf "$BUILD_DIR"
	fi

	echo " ** Done"

}




function __auto_configure() {
	local AUTO_SOURCE_DIR
	local AUTO_BUILD_DIR
	local AUTO_INSTALL_DIR
	local OPT

	AUTO_SOURCE_DIR="$1"
	AUTO_INSTALL_DIR="$2"
	AUTO_BUILD_DIR="$3"
	OPT="$4"
	# build tool
	local _flag_build=
	local BUILD_TOOL=make
	# configure tool
	local _flag_configure=
	local CONFIG_TOOL=configure
	# debug mode (default : FALSE)
	local _debug=
	
	for o in $OPT; do 
		[ "$_flag_configure" == "ON" ] && CONFIG_TOOL=$o && _flag_configure=
		[ "$o" == "CONFIG_TOOL" ] && _flag_configure=ON
		[ "$_flag_build" == "ON" ] && BUILD_TOOL=$o && _flag_build=
		[ "$o" == "BUILD_TOOL" ] && _flag_build=ON
		[ "$o" == "DEBUG" ] && _debug=ON
	done

	mkdir -p "$AUTO_BUILD_DIR"
	cd "$AUTO_BUILD_DIR"
	
	# GLOBAL FLAGs
	# AUTO_INSTALL_CONF_FLAG_PREFIX
	# AUTO_INSTALL_CONF_FLAG_POSTFIX


	case $CONFIG_TOOL in

		configure)
			if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
				STELLA_DYNAMIC_LINK_FLAGS="$STELLA_DYNAMIC_LINK_FLAGS -Wl,-rpath,."
			fi
			if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
				STELLA_DYNAMIC_LINK_FLAGS="$STELLA_DYNAMIC_LINK_FLAGS -Wl,-rpath,. -Wl,-rpath,@loader_path/"
			fi

			__set_standard_build_flags

			chmod +x "$AUTO_SOURCE_DIR/configure"

			if [ "$AUTO_INSTALL_CONF_FLAG_PREFIX" == "" ]; then
				"$AUTO_SOURCE_DIR/configure" --prefix="$AUTO_INSTALL_DIR" $AUTO_INSTALL_CONF_FLAG_POSTFIX
			else
				$AUTO_INSTALL_CONF_FLAG_PREFIX "$AUTO_SOURCE_DIR/configure" --prefix="$AUTO_INSTALL_DIR" $AUTO_INSTALL_CONF_FLAG_POSTFIX
			fi
		;;




		cmake)
			if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
				__set_build_mode CMAKE_RPATH INSTALL_PHASE_ADD_FINAL_RPATH "."
			fi
			if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
				__set_build_mode CMAKE_RPATH MACOS_DEFAULT_RPATH ON
				__set_build_mode CMAKE_RPATH MACOS_ADD_FINAL_RPATH "@loader_path/"
			fi

			__set_cmake_build_flags

			[ "$BUILD_TOOL" == "make" ] && CMAKE_GENERATOR="Unix Makefiles"
			[ "$BUILD_TOOL" == "ninja" ] && CMAKE_GENERATOR="Ninja"
			[ "$_debug" == "ON" ] && _debug="--debug-output" #--trace --debug-output

			if [ "$AUTO_INSTALL_CONF_FLAG_PREFIX" == "" ]; then

				cmake "$_debug" "$AUTO_SOURCE_DIR" \
				-DCMAKE_C_FLAGS:STRING="$CMAKE_C_FLAGS" -DCMAKE_CXX_FLAGS:STRING="$CMAKE_CXX_FLAGS" $STELLA_CMAKE_EXTRA_FLAGS \
				-DCMAKE_SHARED_LINKER_FLAGS:STRING="$CMAKE_SHARED_LINKER_FLAGS" -DCMAKE_MODULE_LINKER_FLAGS:STRING="$CMAKE_MODULE_LINKER_FLAGS" \
				-DCMAKE_STATIC_LINKER_FLAGS:STRING="$CMAKE_STATIC_LINKER_FLAGS" -DCMAKE_EXE_LINKER_FLAGS:STRING="$CMAKE_EXE_LINKER_FLAGS" \
				-DCMAKE_BUILD_TYPE=Release \
				-DCMAKE_INSTALL_PREFIX="$AUTO_INSTALL_DIR" \
				-DINSTALL_BIN_DIR="$AUTO_INSTALL_DIR/bin" -DINSTALL_LIB_DIR="$AUTO_INSTALL_DIR/lib" \
				-G "$CMAKE_GENERATOR" $AUTO_INSTALL_CONF_FLAG_POSTFIX
				# -DCMAKE_MODULE_PATH="$CMAKE_MODULE_PATH" -DCMAKE_LIBRARY_PATH="$CMAKE_LIBRARY_PATH" -DCMAKE_INCLUDE_PATH="$CMAKE_INCLUDE_PATH"
				# -DLIB_SUFFIX=$BUILD_SUFFIX -DCMAKE_DEBUG_POSTFIX=$DEBUG_POSTFIX
			else
				$AUTO_INSTALL_CONF_FLAG_PREFIX cmake "$_debug" "$AUTO_SOURCE_DIR" \
				-DCMAKE_C_FLAGS:STRING="$CMAKE_C_FLAGS" -DCMAKE_CXX_FLAGS:STRING="$CMAKE_CXX_FLAGS" $STELLA_CMAKE_EXTRA_FLAGS \
				-DCMAKE_SHARED_LINKER_FLAGS:STRING="$CMAKE_SHARED_LINKER_FLAGS" -DCMAKE_MODULE_LINKER_FLAGS:STRING="$CMAKE_MODULE_LINKER_FLAGS" \
				-DCMAKE_STATIC_LINKER_FLAGS:STRING="$CMAKE_STATIC_LINKER_FLAGS" -DCMAKE_EXE_LINKER_FLAGS:STRING="$CMAKE_EXE_LINKER_FLAGS" \
				-DCMAKE_BUILD_TYPE=Release \
				-DCMAKE_INSTALL_PREFIX="$AUTO_INSTALL_DIR" \
				-DINSTALL_BIN_DIR="$AUTO_INSTALL_DIR/bin" -DINSTALL_LIB_DIR="$AUTO_INSTALL_DIR/lib" \
				-G "$CMAKE_GENERATOR" $AUTO_INSTALL_CONF_FLAG_POSTFIX
				# -DCMAKE_MODULE_PATH="$CMAKE_MODULE_PATH" -DCMAKE_LIBRARY_PATH="$CMAKE_LIBRARY_PATH" -DCMAKE_INCLUDE_PATH="$CMAKE_INCLUDE_PATH"
				# -DLIB_SUFFIX=$BUILD_SUFFIX -DCMAKE_DEBUG_POSTFIX=$DEBUG_POSTFIX

			fi
		;;

	esac
}


function __auto_build() {
	local AUTO_SOURCE_DIR
	local AUTO_BUILD_DIR
	local AUTO_INSTALL_DIR
	local OPT

	AUTO_SOURCE_DIR="$1"
	AUTO_INSTALL_DIR="$2"
	AUTO_BUILD_DIR="$3"
	OPT="$4"
	# parallelize build (default : TRUE)
	local _opt_parallelize=ON
	# build tool
	local _flag_build=
	local BUILD_TOOL=make
	# debug mode (default : FALSE)
	local _debug=

	for o in $OPT; do 
		[ "$_flag_build" == "ON" ] && BUILD_TOOL=$o && _flag_build=
		[ "$o" == "BUILD_TOOL" ] && _flag_build=ON
		[ "$o" == "UNPARALLELIZE" ] && _opt_parallelize=OFF
		[ "$o" == "DEBUG" ] && _debug=ON
	done

	# FLAGs
	# AUTO_INSTALL_BUILD_FLAG_PREFIX
	# AUTO_INSTALL_BUILD_FLAG_POSTFIX

	local _FLAG_PARALLEL=
	
	mkdir -p "$AUTO_BUILD_DIR"
	cd "$AUTO_BUILD_DIR"
	
	case $BUILD_TOOL in

		make)
			[ "$_opt_parallelize" == "ON" ] && _FLAG_PARALLEL="-j$STELLA_NB_CPU"
			[ "$_debug" == "ON" ] && _debug="--debug=b" #--debug=a
			if [ "$AUTO_INSTALL_BUILD_FLAG_PREFIX" == "" ]; then
				make $_debug $_FLAG_PARALLEL PREFIX="$AUTO_INSTALL_DIR" $AUTO_INSTALL_BUILD_FLAG_POSTFIX install
			else
				$AUTO_INSTALL_BUILD_FLAG_PREFIX make $_debug $_FLAG_PARALLEL PREFIX="$AUTO_INSTALL_DIR" $AUTO_INSTALL_BUILD_FLAG_POSTFIX install
			fi
		;;

		ninja)
			[ "$_opt_parallelize" == "OFF" ] && _FLAG_PARALLEL="-j1"
			[ "$_debug" == "ON" ] && _debug="-v"
			if [ "$AUTO_INSTALL_BUILD_FLAG_PREFIX" == "" ]; then
				ninja $_debug $_FLAG_PARALLEL $AUTO_INSTALL_BUILD_FLAG_POSTFIX
			else
				$AUTO_INSTALL_BUILD_FLAG_PREFIX ninja $_debug $_FLAG_PARALLEL $AUTO_INSTALL_BUILD_FLAG_POSTFIX install
			fi
		;;

	esac
}






# CHECK BUILD ------------------------------------------------------------------------------------------------------------------------------
# TODO - to finish

# simple test with boost lib : _check_lib "$STELLA_APP_WORK_ROOT/feature_darwin/macos/boost/1_58_0/lib/*.dylib"
function __check_lib() {
	local _path=$1

	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		for files in $1; do
			if [ -f "$files" ]; then
				# check rpath
				echo "** $files : Checking RPATH value"
				test=`objdump -p $files | grep -E "RPATH\s*\.:?|RPATH.*:\.:?"`
				[ $VERBOSE_MODE -gt 0 ] && objdump -p $files | grep RPATH
				if [ "$test" == "" ]; then
					echo "** WARN checking RPATH value" "warning : RPATH value '.' is missing"
				else
					echo "** OK"
				fi

				# check dynamic link at runtime
				echo "** $files : Checking dynamic linking at runtime"
				_CUR_DIR=`pwd`
				cd "$DEST/lib$BUILD_SUFFIX"
				test=`ldd $files | grep "not found"`
				cd $_CUR_DIR
				[ $VERBOSE_MODE -gt 0 ] && ldd $files
				if [ ! "$test" == "" ]; then
					echo "** WARN checking missing dynamic library at runtime" "$test"
				else
					echo "** OK"
				fi
			fi
		done
	fi

	# https://github.com/auriamg/macdylibbundler (PACKAGING TOOL)
	# https://mikeash.com/pyblog/friday-qa-2009-11-06-linking-and-install-names.html (explain search path)
	# http://matthew-brett.github.io/docosx/mac_runtime_link.html (explain search path)
	# http://www.kitware.com/blog/home/post/510 (CMAKE and RPATH)
	# Print out dynamic libraries loaded at runtime when launching a program :
	# 		DYLD_PRINT_LIBRARIES=y program
	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		for files in $1; do
			if [ -f "$files" ]; then
				echo
				echo "** Analysing $files"
				# check rpath
				#  otool -l 
				printf %s "*** Checking RPATH values : "
				test=`otool -l $files | grep -E "LC_RPATH" -A2 | grep -E "path\s\.\s"`
				[ $VERBOSE_MODE -gt 0 ] && otool -l $files | grep path
				_err=0
				if [ "$test" == "" ]; then
					printf %s "-- WARN RPATH value '.' is missing"
					_err=1
				fi
				test=`otool -l $files | grep -E "LC_RPATH" -A2 | grep -E "path\s@loader_path/"`
				[ $VERBOSE_MODE -gt 0 ] && otool -l $files | grep path
				if [ "$test" == "" ]; then
					printf %s " -- WARN RPATH value '@loader_path/' is missing"
					_err=1
				fi
				[ "$_err" == "0" ] && printf "-- OK"
				echo


				# check ID/Install Name value
				#  otool -l 
				printf "*** Checking ID/Install Name value : "
				test=`otool -l $files | grep -E "LC_ID_DYLIB" -A2 | grep -E "name\s@rpath/"`
				[ $VERBOSE_MODE -gt 0 ] && otool -l $files | grep name
				if [ "$test" == "" ]; then
					printf %s "-- WARN ID/Install Name value '@rpath/' is missing"
				else
					printf %s "-- OK"
				fi
				echo

				# check dynamic link at runtime
				echo "*** Checking missing dynamic library at runtime"
				local linked_lib=
				while read -r line ; do
   					printf %s "====> checking linked lib : $line "
   					# TODO replace with containing folder ?
   					linked_lib="${line//@rpath/$DEST/lib$BUILD_SUFFIX}"
   					if [ ! -f "$linked_lib" ]; then
   						printf %s "-- WARN not found"
   					else
   						printf %s "-- OK"
   					fi
   					echo
				done < <(otool -l $files | grep -E "LC_LOAD_DYLIB" -A2 | grep name | tr -s ' ' | cut -d ' ' -f 3)
			fi
		done
	fi
}

















# ENV and FLAGS management---------------------------------------------------------------------------------------------------------------------------------------

# TODO NOT USED
# TODO call reset before recipe launch ?
function __reset_build_flags() {
	# these are default build flags for everything (cmake, make, ...)
	STELLA_C_CXX_FLAGS=
	STELLA_DYNAMIC_LINK_FLAGS=
	STELLA_STATIC_LINK_FLAGS=

	# reset standard flags
	unset CFLAGS #flags to pass to the C compiler.
	unset CXXFLAGS #flags to pass to the C++ compiler.
	unset CPPFLAGS #flags to pass to the C preprocessor. Used when compiling C and C++
	unset LDFLAGS #flags to pass to the linker

	# reset cmake flags
	unset CMAKE_C_FLAGS
	unset CMAKE_CXX_FLAGS
	unset CMAKE_SHARED_LINKER_FLAGS
	unset CMAKE_MODULE_LINKER_FLAGS
	unset CMAKE_STATIC_LINKER_FLAGS
	unset CMAKE_EXE_LINKER_FLAGS

	STELLA_CMAKE_EXTRA_FLAGS=
}


# set flags and env for CMAKE
function __set_cmake_build_flags() {
	# CMAKE Flags
	# note : 
	#	- these flags have to be passed to the cmake command line, as cmake do not read en var
	#	- list of environment variables read by cmake http://www.cmake.org/Wiki/CMake_Useful_Variables#Environment_Variables
	CMAKE_C_FLAGS="$STELLA_C_CXX_FLAGS"
	CMAKE_CXX_FLAGS="$STELLA_C_CXX_FLAGS"
	CMAKE_SHARED_LINKER_FLAGS="$STELLA_DYNAMIC_LINK_FLAGS"
	CMAKE_MODULE_LINKER_FLAGS="$STELLA_DYNAMIC_LINK_FLAGS"
	CMAKE_STATIC_LINKER_FLAGS="$STELLA_STATIC_LINK_FLAGS"
	CMAKE_EXE_LINKER_FLAGS="$STELLA_STATIC_LINK_FLAGS $STELLA_DYNAMIC_LINK_FLAGS"

	STELLA_CMAKE_EXTRA_FLAGS="$STELLA_CMAKE_EXTRA_FLAGS"

	# save rpath related flags
	[ "$STELLA_CURRENT_PLATFORM" == "linux" ] && STELLA_CMAKE_EXTRA_FLAGS="$STELLA_CMAKE_EXTRA_FLAGS $CMAKE_RPATH $CMAKE_RPATH_BUILD_PHASE $CMAKE_RPATH_INSTALL_PHASE"
	[ "$STELLA_CURRENT_PLATFORM" == "darwin" ] && STELLA_CMAKE_EXTRA_FLAGS="$STELLA_CMAKE_EXTRA_FLAGS $CMAKE_RPATH_MACOS" 
}


# set flags and env for standard build tools (GNU MAKE,...)
function __set_standard_build_flags() {

 	# flags to pass to the C compiler.
	export CFLAGS="$STELLA_C_CXX_FLAGS"
	# flags to pass to the C++ compiler.
	export CXXFLAGS="$STELLA_C_CXX_FLAGS"
	# flags to pass to the C preprocessor. Used when compiling C and C++
	export CPPFLAGS=
	# flags to pass to the linker
	export LDFLAGS="$STELLA_STATIC_LINK_FLAGS $STELLA_DYNAMIC_LINK_FLAGS"
}




function __set_build_mode() {

	# Setting flags for a specific arch
	if [ "$1" == "SET_ARCH" ]; then
		if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
			case $2 in
				x86)
					STELLA_C_CXX_FLAGS="-m32 -march=i686 -mtune=generic $STELLA_C_CXX_FLAG"
					;;
				x64)
					STELLA_C_CXX_FLAGS="-m64 $STELLA_C_CXX_FLAG"
					;;
			esac
		fi
		# for darwin -m and -arch are near the same
		# http://stackoverflow.com/questions/1754460/apples-gcc-whats-the-difference-between-arch-i386-and-m32
		if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
			case $2 in
				x86)
					STELLA_C_CXX_FLAGS="-arch i386 $STELLA_C_CXX_FLAG"
					;;
				x64)
					STELLA_C_CXX_FLAGS="-arch x86_64 $STELLA_C_CXX_FLAG"
					;;
			esac
		fi
	fi

	# fPIC is usefull when building shared libraries for x64
	# not for x86 : http://stackoverflow.com/questions/7216244/why-is-fpic-absolutely-necessary-on-64-and-not-on-32bit-platforms -- http://stackoverflow.com/questions/6961832/does-32bit-x86-code-need-to-be-specially-pic-compiled-for-shared-library-files
	# On MacOS it is active by default
	if [ "$1" == "SET_ARCH" ]; then
		if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
			case $2 in
				x64)
					STELLA_C_CXX_FLAGS="-fPIC $STELLA_C_CXX_FLAGS"
					;;
			esac
		fi
	fi



	# Change behaviour of cmake about RPATH
	# CMAKE have 2 phases
	# During each phase a rpath value is determined and used
	# On Linux :
	#		1.Build Phase
	#			While building the binary and running tests
	#				* CMAKE set binary RPATH value with EMPTY VALUE (CMAKE_SKIP_BUILD_RPATH=ON)
	#				* CMAKE set binary RPATH value with the current build path as RPATH value (CMAKE_SKIP_BUILD_RPATH=OFF)
	#				* CMAKE set binary RPATH value with CMAKE_INSTALL_RPATH value (CMAKE_BUILD_WITH_INSTALL_RPATH=ON) - (and so, do not have to re-set it while installing)
	#		2.Install Phase
	#			When installing the binanry
	#				* CMAKE set binary RPATH value with EMPTY VALUE (CMAKE_SKIP_INSTALL_RPATH=ON)
	#				* CMAKE add as binary RPATH value CMAKE_INSTALL_RPATH value 
	#				* CMAKE add as binary RPATH value all dependent libraries outside the current build tree folder as RPATH value (CMAKE_INSTALL_RPATH_USE_LINK_PATH=ON)
	#	Note : CMAKE_SKIP_RPATH=ON : CMAKE set binary RPATH value with EMPTY VALUE during both phase (building and installing)
	#	Default : 
	#		CMAKE_SKIP_RPATH : OFF
	#		CMAKE_SKIP_BUILD_RPATH : OFF 
	#		CMAKE_BUILD_WITH_INSTALL_RPATH : OFF 
	#		CMAKE_INSTALL_RPATH "" 
	#		CMAKE_INSTALL_RPATH_USE_LINK_PATH : OFF
	#		CMAKE_SKIP_INSTALL_RPATH : 
	# On MacOSX :
	#		http://www.kitware.com/blog/home/post/510
	#		http://matthew-brett.github.io/docosx/mac_runtime_link.html
	#		1.Build Phase
	#			* CMAKE set binary RPATH value with "@rpath" during both phase (CMAKE_MACOSX_RPATH=ON)
	#		2.Install Phase
	#			* CMAKE set binary RPATH value with "@rpath" during both phase (CMAKE_MACOSX_RPATH=ON)
	#			* CMAKE set binary RPATH value with NSTALL_NAME_DIR if it setted
	#	Default : 
	#		CMAKE_MACOSX_RPATH : ON
	if [ "$1" == "CMAKE_RPATH" ]; then
		case $2 in
			
			BUILD_PHASE_NO_RPATH)
				CMAKE_RPATH_BUILD_PHASE="-DCMAKE_SKIP_BUILD_RPATH=ON" # DEFAULT : OFF
				;;
			
			BUILD_PHASE_USE_BUILD_FOLDER)
				CMAKE_RPATH_BUILD_PHASE="-DCMAKE_SKIP_BUILD_RPATH=OFF" # DEFAULT : ON
				;;
			
			BUILD_PHASE_USE_FINAL_RPATH)
				CMAKE_RPATH_BUILD_PHASE="-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON" # DEFAULT : OFF
				;;
	


			INSTALL_PHASE_NO_RPATH)
				CMAKE_RPATH_INSTALL_PHASE="-DCMAKE_SKIP_INSTALL_RPATH=ON" # DEFAULT : OFF
				;;

			INSTALL_PHASE_ADD_FINAL_RPATH)
				CMAKE_RPATH_INSTALL_PHASE="$CMAKE_RPATH_INSTALL_PHASE -DCMAKE_INSTALL_RPATH=$3" # DEFAULT : empty string
				;;
			
			INSTALL_PHASE_ADD_EXTERNAL_LIB)
				CMAKE_RPATH_INSTALL_PHASE="$CMAKE_RPATH_INSTALL_PHASE -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON" # DEFAULT : OFF
				;;
			
			INSTALL_PHASE_USE_FINAL_RPATH)
				CMAKE_RPATH_INSTALL_PHASE="-DCMAKE_SKIP_INSTALL_RPATH=OFF" # DEFAULT : OFF
				;;

				
			ALL_PHASE_NO_RPATH)
				CMAKE_RPATH="-DCMAKE_SKIP_RPATH=ON" # DEFAULT : OFF
			;;




			# FOR MACOS

			# DEFAULT : ON
			# activate @rpath/lib_name as INSTALL_NAME for lib built with CMAKE
			MACOS_DEFAULT_RPATH)
				CMAKE_RPATH_MACOS="-DCMAKE_MACOSX_RPATH=$3"
				;;
			
			MACOS_ADD_FINAL_RPATH)
				CMAKE_RPATH_MACOS="$CMAKE_RPATH_MACOS -DCMAKE_INSTALL_RPATH=$3"
				;;


		esac

	fi




}





# MACOS -----  install_name, rpath, loader_path, executable_path ------------------------------------------------------------------------------------------------------------

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
# we cannot pass -Wl,install_name library_name during build time because we do not know the library name yet
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
function __fix_dynamiclib_install_name_darwin_by_name() {
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





fi