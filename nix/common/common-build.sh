if [ ! "$_STELLA_COMMON_BUILD_INCLUDED_" == "1" ]; then 
_STELLA_COMMON_BUILD_INCLUDED_=1

# NOTE : homebrew flag setting system : https://github.com/Homebrew/homebrew/blob/master/Library/Homebrew/extend/ENV/super.rb


# BUILD WORKFLOW

# SET SOME DEFAULT BUILD MODE
#	__set_build_mode_default "RELOCATE" "ON"
#  	__set_build_mode_default "DARWIN_STDLIB" "LIBCPP"

# START BUILD SESSION
#	__start_build_session (reset everything to default values or empty)

#		GET SOURCE CODE
#		__get_resource

# 		SET CUSTOM BUILD MODE
#		__set_build_mode ARCH x86
#
#		LINK BUILD TO OTHER LIBRARY
#		__link_feature_library

#		AUTOMATIC BUILD
#		__auto_build

#				SET BUILD ENV AND FLAGS
#				__apply_build_env
#						call __set_standard_build_flags
#						call __set_cmake_build_flags

#				LAUNCH CONFIG TOOL
#				__launch_configure
#				LAUNCH BUILD TOOL
#				__launch_build

#				__inspect_build
#						call __fix_built_files 
#						call __check_built_files


# BUILD ------------------------------------------------------------------------------------------------------------------------------


function __start_build_session() {
	__reset_build_env
}

function __auto_build() {
	
	local NAME
	local SOURCE_DIR
	local BUILD_DIR
	local INSTALL_DIR
	local OPT


	NAME="$1"
	SOURCE_DIR="$2"
	INSTALL_DIR="$3"
	OPT="$4"
	# DEBUG SOURCE_KEEP BUILD_KEEP UNPARALLELIZE NO_CONFIG CONFIG_TOOL xxxx NO_BUILD BUILD_TOOL xxxx ARCH xxxx NO_OUT_OF_TREE_BUILD

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


	echo " ** Auto-building $NAME into $INSTALL_DIR for $STELLA_CURRENT_OS"

	# folder stuff
	BUILD_DIR="$SOURCE_DIR"
	[ "$_opt_out_of_tree_build" == "ON" ] && BUILD_DIR="$(dirname $SOURCE_DIR)/$(basename $SOURCE_DIR)-build"

	mkdir -p "$INSTALL_DIR"

	if [ "$_opt_out_of_tree_build" == "ON" ]; then
		[ "$FORCE" == "1" ] && rm -Rf "$BUILD_DIR"
		[ ! "$_opt_build_keep" == "ON" ] && rm -Rf "$BUILD_DIR"
	fi

	# relocatable mode
	# Copy each linked feature into a folder stella-dep
	# BEFORE building, so rpath values are setted with right path before building

	if [ "$STELLA_BUILD_RELOCATE" == "ON" ]; then
		echo "** RELOCATION mode "
		local LIB_TARGET_FOLDER="$INSTALL_DIR/stella-dep"
		LINKED_LIBS_PATH="$(__trim $LINKED_LIBS_PATH)"
		for j in $LINKED_LIBS_PATH; do
			if [ "$(__is_abs $j)" == "TRUE" ]; then
				echo "*** Moving dependencies from $j to $LIB_TARGET_FOLDER"
				__copy_folder_content_into "$j" "$LIB_TARGET_FOLDER"
				# copy dependencies of dependency
				if [ -d "$j/../stella-dep" ]; then
					echo "*** Moving dependencies of dependency from $j/../stella-dep to $LIB_TARGET_FOLDER"
					__copy_folder_content_into "$j/../stella-dep" "$LIB_TARGET_FOLDER"
				fi
			fi
		done
		if [ ! "$LINKED_LIBS_PATH" == "" ]; then
			if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
				for f in "$LIB_TARGET_FOLDER"/*".dylib"*; do		
					[ -f "$f" ] && __fix_dynamiclib_install_name_darwin "$f" "RPATH"
				done
			fi
			[ "$STELLA_CURRENT_PLATFORM" == "linux" ] && __set_build_mode "RPATH" "ADD_FIRST" '$$ORIGIN/../stella-dep'
			[ "$STELLA_CURRENT_PLATFORM" == "darwin" ] && __set_build_mode "RPATH" "ADD_FIRST" "@loader_path/../stella-dep"
		fi
	fi

	# set build env
	__apply_build_env "$OPT"

	# launch process
	[ "$_opt_configure" == "ON" ] && __launch_configure "$SOURCE_DIR" "$INSTALL_DIR" "$BUILD_DIR" "$OPT"
	[ "$_opt_build" == "ON" ] && __launch_build "$SOURCE_DIR" "$INSTALL_DIR" "$BUILD_DIR" "$OPT"


	# clean workspace
	[ ! "$_opt_source_keep" == "ON" ] && rm -Rf "$SOURCE_DIR"

	if [ "$_opt_out_of_tree_build" == "ON" ]; then
		[ ! "$_opt_build_keep" == "ON" ] && rm -Rf "$BUILD_DIR"
	fi

	cd "$INSTALL_DIR"
	__inspect_build "$INSTALL_DIR"

	echo " ** Done"

}


function __launch_configure() {
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
	local BUILD_TOOL=
	# configure tool
	local _flag_configure=
	local CONFIG_TOOL=

	# debug mode (default : OFF)
	local _debug=
	
	for o in $OPT; do 
		[ "$_flag_configure" == "ON" ] && CONFIG_TOOL=$o && _flag_configure=
		[ "$o" == "CONFIG_TOOL" ] && _flag_configure=ON
		[ "$_flag_build" == "ON" ] && BUILD_TOOL=$o && _flag_build=
		[ "$o" == "BUILD_TOOL" ] && _flag_build=ON
		[ "$o" == "DEBUG" ] && _debug=ON
	done

	# autoselect conf tool
	[ "$CONFIG_TOOL" == "" ] && CONFIG_TOOL="$(__auto_select_conf_tool)"

	# autoselect build tool
	[ "$BUILD_TOOL" == "" ] && BUILD_TOOL="$(__auto_select_build_tool $CONFIG_TOOL)"

	mkdir -p "$AUTO_BUILD_DIR"
	cd "$AUTO_BUILD_DIR"
	
	# GLOBAL FLAGs
	# AUTO_INSTALL_CONF_FLAG_PREFIX
	# AUTO_INSTALL_CONF_FLAG_POSTFIX


	case $CONFIG_TOOL in

		configure)
			chmod +x "$AUTO_SOURCE_DIR/configure"

			if [ "$AUTO_INSTALL_CONF_FLAG_PREFIX" == "" ]; then
				"$AUTO_SOURCE_DIR/configure" --prefix="$AUTO_INSTALL_DIR" $AUTO_INSTALL_CONF_FLAG_POSTFIX
			else
				eval $(echo $AUTO_INSTALL_CONF_FLAG_PREFIX) "$AUTO_SOURCE_DIR/configure" --prefix="$AUTO_INSTALL_DIR" $AUTO_INSTALL_CONF_FLAG_POSTFIX
			fi
		;;



		cmake)
			[ "$BUILD_TOOL" == "make" ] && CMAKE_GENERATOR="Unix Makefiles"
			[ "$BUILD_TOOL" == "ninja" ] && CMAKE_GENERATOR="Ninja"
			[ "$_debug" == "ON" ] && _debug="--debug-output" #--trace --debug-output

			if [ "$AUTO_INSTALL_CONF_FLAG_PREFIX" == "" ]; then
				cmake "$_debug" "$AUTO_SOURCE_DIR" \
				-DCMAKE_C_FLAGS:STRING="$CMAKE_C_FLAGS" -DCMAKE_CXX_FLAGS:STRING="$CMAKE_CXX_FLAGS" $STELLA_CMAKE_EXTRA_FLAGS \
				$AUTO_INSTALL_CONF_FLAG_POSTFIX \
				-DCMAKE_SHARED_LINKER_FLAGS:STRING="$CMAKE_SHARED_LINKER_FLAGS" -DCMAKE_MODULE_LINKER_FLAGS:STRING="$CMAKE_MODULE_LINKER_FLAGS" \
				-DCMAKE_STATIC_LINKER_FLAGS:STRING="$CMAKE_STATIC_LINKER_FLAGS" -DCMAKE_EXE_LINKER_FLAGS:STRING="$CMAKE_EXE_LINKER_FLAGS" \
				-DCMAKE_BUILD_TYPE=Release \
				-DCMAKE_INSTALL_PREFIX="$AUTO_INSTALL_DIR" \
				-DINSTALL_BIN_DIR="$AUTO_INSTALL_DIR/bin" -DINSTALL_LIB_DIR="$AUTO_INSTALL_DIR/lib" \
				-DCMAKE_LIBRARY_PATH="$CMAKE_LIBRARY_PATH" -DCMAKE_INCLUDE_PATH="$CMAKE_INCLUDE_PATH" \
				-DBUILD_STATIC_LIBS:BOOL=TRUE -DBUILD_SHARED_LIBS:BOOL=TRUE \
				-DCMAKE_FIND_FRAMEWORK=LAST -DCMAKE_FIND_APPBUNDLE=LAST \
				-G "$CMAKE_GENERATOR"
				# -DLIB_SUFFIX=$BUILD_SUFFIX -DCMAKE_DEBUG_POSTFIX=$DEBUG_POSTFIX
			else
				eval $(echo $AUTO_INSTALL_CONF_FLAG_PREFIX) cmake "$_debug" "$AUTO_SOURCE_DIR" \
				-DCMAKE_C_FLAGS:STRING="$CMAKE_C_FLAGS" -DCMAKE_CXX_FLAGS:STRING="$CMAKE_CXX_FLAGS" $STELLA_CMAKE_EXTRA_FLAGS \
				$AUTO_INSTALL_CONF_FLAG_POSTFIX \
				-DCMAKE_SHARED_LINKER_FLAGS:STRING="$CMAKE_SHARED_LINKER_FLAGS" -DCMAKE_MODULE_LINKER_FLAGS:STRING="$CMAKE_MODULE_LINKER_FLAGS" \
				-DCMAKE_STATIC_LINKER_FLAGS:STRING="$CMAKE_STATIC_LINKER_FLAGS" -DCMAKE_EXE_LINKER_FLAGS:STRING="$CMAKE_EXE_LINKER_FLAGS" \
				-DCMAKE_BUILD_TYPE=Release \
				-DCMAKE_INSTALL_PREFIX="$AUTO_INSTALL_DIR" \
				-DINSTALL_BIN_DIR="$AUTO_INSTALL_DIR/bin" -DINSTALL_LIB_DIR="$AUTO_INSTALL_DIR/lib" \
				-DCMAKE_LIBRARY_PATH="$CMAKE_LIBRARY_PATH" -DCMAKE_INCLUDE_PATH="$CMAKE_INCLUDE_PATH" \
				-DBUILD_STATIC_LIBS:BOOL=TRUE -DBUILD_SHARED_LIBS:BOOL=TRUE \
				-DCMAKE_FIND_FRAMEWORK=LAST -DCMAKE_FIND_APPBUNDLE=LAST \
				-G "$CMAKE_GENERATOR"
				
				# -DLIB_SUFFIX=$BUILD_SUFFIX -DCMAKE_DEBUG_POSTFIX=$DEBUG_POSTFIX
			fi
		;;

	esac
}


function __launch_build() {
	local AUTO_SOURCE_DIR
	local AUTO_BUILD_DIR
	local AUTO_INSTALL_DIR
	local OPT

	AUTO_SOURCE_DIR="$1"
	AUTO_INSTALL_DIR="$2"
	AUTO_BUILD_DIR="$3"
	OPT="$4"
	# parallelize build
	local _opt_parallelize=$STELLA_BUILD_PARALLELIZE
	# build tool
	local _flag_build=
	local BUILD_TOOL=
	# configure tool
	local _flag_configure=
	local CONFIG_TOOL=
	# debug mode (default : OFF)
	local _debug=
	# configure step activation (default : TRUE)
	local _opt_configure=ON

	for o in $OPT; do
		[ "$_flag_configure" == "ON" ] && CONFIG_TOOL=$o && _flag_configure=
		[ "$o" == "CONFIG_TOOL" ] && _flag_configure=ON
		[ "$_flag_build" == "ON" ] && BUILD_TOOL=$o && _flag_build=
		[ "$o" == "BUILD_TOOL" ] && _flag_build=ON
		[ "$o" == "DEBUG" ] && _debug=ON
		[ "$o" == "NO_CONFIG" ] && _opt_configure=OFF
	done

	# autoselect conf tool
	[ "$CONFIG_TOOL" == "" ] && CONFIG_TOOL="$(__auto_select_conf_tool)"

	# autoselect build tool
	[ "$BUILD_TOOL" == "" ] && BUILD_TOOL="$(__auto_select_build_tool $CONFIG_TOOL)"

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
				if [ "$_opt_configure" == "ON" ]; then
					make $_debug $_FLAG_PARALLEL \
					$AUTO_INSTALL_BUILD_FLAG_POSTFIX
					
					make $_debug \
					$AUTO_INSTALL_BUILD_FLAG_POSTFIX \
					install 
				else
					#make $_debug $_FLAG_PARALLEL \
					#CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS" CPPFLAGS="$CPPFLAGS" LDFLAGS="$LDFLAGS" \
					#PREFIX="$AUTO_INSTALL_DIR" $AUTO_INSTALL_BUILD_FLAG_POSTFIX
					
					make $_debug $_FLAG_PARALLEL \
					PREFIX="$AUTO_INSTALL_DIR" prefix="$AUTO_INSTALL_DIR" \
					$AUTO_INSTALL_BUILD_FLAG_POSTFIX

					#make $_debug \
					#CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS" CPPFLAGS="$CPPFLAGS" LDFLAGS="$LDFLAGS" \
					#PREFIX="$AUTO_INSTALL_DIR" $AUTO_INSTALL_BUILD_FLAG_POSTFIX \
					#install
					make $_debug \
					PREFIX="$AUTO_INSTALL_DIR" prefix="$AUTO_INSTALL_DIR" \
					$AUTO_INSTALL_BUILD_FLAG_POSTFIX \
					install
				fi
			else
				if [ "$_opt_configure" == "ON" ]; then
					eval $(echo $AUTO_INSTALL_BUILD_FLAG_PREFIX) make $_debug $_FLAG_PARALLEL \
					$AUTO_INSTALL_BUILD_FLAG_POSTFIX

					eval $(echo $AUTO_INSTALL_BUILD_FLAG_PREFIX) make $_debug \
					$AUTO_INSTALL_BUILD_FLAG_POSTFIX \
					install
				else
					#eval $(echo $AUTO_INSTALL_BUILD_FLAG_PREFIX) make $_debug  $_FLAG_PARALLEL \
					#CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS" CPPFLAGS="$CPPFLAGS" LDFLAGS="$LDFLAGS" \
					#PREFIX="$AUTO_INSTALL_DIR" $AUTO_INSTALL_BUILD_FLAG_POSTFIX

					eval $(echo $AUTO_INSTALL_BUILD_FLAG_PREFIX) make $_debug $_FLAG_PARALLEL \
					PREFIX="$AUTO_INSTALL_DIR" prefix="$AUTO_INSTALL_DIR" \
					$AUTO_INSTALL_BUILD_FLAG_POSTFIX

					#eval $(echo $AUTO_INSTALL_BUILD_FLAG_PREFIX) make $_debug \
					#CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS" CPPFLAGS="$CPPFLAGS" LDFLAGS="$LDFLAGS" \
					#PREFIX="$AUTO_INSTALL_DIR" $AUTO_INSTALL_BUILD_FLAG_POSTFIX \
					#install

					eval $(echo $AUTO_INSTALL_BUILD_FLAG_PREFIX) make $_debug \
					PREFIX="$AUTO_INSTALL_DIR" prefix="$AUTO_INSTALL_DIR" \
					$AUTO_INSTALL_BUILD_FLAG_POSTFIX \
					install
				fi
			fi
		;;

		ninja)
			if [ "$_opt_parallelize" == "OFF" ]; then
				_FLAG_PARALLEL="-j1"
			else
				# ninja is auto parallelized
				_FLAG_PARALLEL=
			fi
			[ "$_debug" == "ON" ] && _debug="-v"
			if [ "$AUTO_INSTALL_BUILD_FLAG_PREFIX" == "" ]; then
				ninja $_debug $_FLAG_PARALLEL $AUTO_INSTALL_BUILD_FLAG_POSTFIX
				ninja $_debug $AUTO_INSTALL_BUILD_FLAG_POSTFIX install
			else
				eval $(echo $AUTO_INSTALL_BUILD_FLAG_PREFIX) ninja $_debug $_FLAG_PARALLEL $AUTO_INSTALL_BUILD_FLAG_POSTFIX
				eval $(echo $AUTO_INSTALL_BUILD_FLAG_PREFIX) ninja $_debug $AUTO_INSTALL_BUILD_FLAG_POSTFIX install
			fi
		;;

	esac
}






function __dep_choose_origin() {
	local _SCHEMA="$1"
	__translate_schema "$_SCHEMA" "_CHOOSE_ORIGIN_FEATURE_NAME"

	local _origin="STELLA"
	for u in $STELLA_BUILD_DEP_FROM_SYSTEM; do
		[ "$u" == "$_CHOOSE_ORIGIN_FEATURE_NAME" ] && _origin="SYSTEM"
	done

	echo $_origin
}

function __link_feature_library() {
	local SCHEMA="$1"
	local OPT="$2"
	# FORCE_STATIC -- force link to static version of lib (by isolating it)
	# FORCE_DYNAMIC -- force link to dynamic version of lib (by isolating it) 
	# FORCE_LIB_FOLDER <path> -- folder prefix where lib resides, default "/lib"
	# FORCE_INCLUDE_FOLDER <path> -- folder prefix where include resides, default "/include"
	# GET_FLAGS <prefix> -- init prefix_C_CXX_FLAGS, prefix_CPP_FLAGS, prefix_LINK_FLAGS with correct flags
	# GET_FOLDER <prefix> -- init prefix_ROOT, prefix_LIB, prefix_BIN, prefix_INCLUDE with correct path
	# NO_SET_FLAGS -- do not set stella build system flags
	# LIBS_NAME -- libraries name to use with -l arg (so without libprefix) -- you can specify several libraries OR no library at all. so -l flag will not be setted, only -L will be setted

	local _C_CXX_FLAGS=
	local _CPP_FLAGS=
	local _LINK_FLAGS=

	local _ROOT=
	local _BIN=
	local _LIB=
	local _INCLUDE=
	

	local _folders=OFF
	local _var_folders=
	local _flags=OFF
	local _var_flags=
	local _opt_flavour=
	local _flag_lib_folder=OFF
	local _lib_folder=lib
	local _flag_include_folder=OFF
	local _include_folder=include
	local _opt_set_flags=ON
	local _flag_libs_name=OFF
	local _libs_name=
	
	# default mode
	case "$STELLA_BUILD_LINK_MODE" in 
		DEFAULT)
			_opt_flavour=
			;;
		DYNAMIC)
			_opt_flavour="FORCE_DYNAMIC"
			;;
		STATIC)
			_opt_flavour="FORCE_STATIC"
			;;
	esac

	for o in $OPT; do 
		[ "$o" == "FORCE_STATIC" ] && _opt_flavour=$o && _flag_libs_name=OFF
		[ "$o" == "FORCE_DYNAMIC" ] && _opt_flavour=$o && _flag_libs_name=OFF

		[ "$_flag_lib_folder" == "ON" ] && _lib_folder=$o && _flag_lib_folder=OFF
		[ "$o" == "FORCE_LIB_FOLDER" ] && _flag_lib_folder=ON && _flag_libs_name=OFF
		[ "$_flag_include_folder" == "ON" ] && _include_folder=$o && _flag_include_folder=OFF
		[ "$o" == "FORCE_INCLUDE_FOLDER" ] && _flag_include_folder=ON && _flag_libs_name=OFF

		[ "$_flags" == "ON" ] && _var_flags=$o && _flags=OFF
		[ "$o" == "GET_FLAGS" ] && _flags=ON && _flag_libs_name=OFF
		[ "$_folders" == "ON" ] && _var_folders=$o && _folders=OFF
		[ "$o" == "GET_FOLDER" ] && _folders=ON && _flag_libs_name=OFF

		[ "$o" == "NO_SET_FLAGS" ] && _opt_set_flags=OFF && _flag_libs_name=OFF

		[ "$_flag_libs_name" == "ON" ] && _libs_name="$_libs_name $o"
		[ "$o" == "LIBS_NAME" ] && _flag_libs_name=ON
	done


	# check origin for this schema
	local _origin
	case "$SCHEMA" in
		FORCE_ORIGIN_STELLA*)
				_origin="STELLA"
				SCHEMA=${SCHEMA#FORCE_ORIGIN_STELLA}
				;;
		FORCE_ORIGIN_SYSTEM*)
				_origin="SYSTEM"
				SCHEMA=${SCHEMA#FORCE_ORIGIN_SYSTEM}
				;;
		*)
				_origin="$(__dep_choose_origin $SCHEMA)"
				;;
	esac
	
	if [ "$_origin" == "SYSTEM" ]; then
		echo "We do not link against STELLA version of $SCHEMA, but from SYSTEM."
		return
	fi

	echo "** Linked to $SCHEMA"

	# INSPECT required lib through schema
	__push_schema_context
	__feature_inspect $SCHEMA
	if [ "$TEST_FEATURE" == "0" ]; then
		echo " ** ERROR : depend on lib $SCHEMA"
		__pop_schema_context
		return
	fi
	local REQUIRED_LIB_ROOT="$FEAT_INSTALL_ROOT"
	__pop_schema_context


	# ISOLATE LIBS
	# if we want specific static or dynamic linking, we isolate specific version
	# by default, linker use dynamic version first and then static version if dynamic is not found
	local _flag_lib_isolation=FALSE
	[ "$_opt_flavour" == "FORCE_STATIC" ] && _flag_lib_isolation=TRUE
	[ "$_opt_flavour" == "FORCE_DYNAMIC" ] && _flag_lib_isolation=TRUE

	local LIB_TARGET_FOLDER=
	local LIB_EXTENSION=
	
	case $_opt_flavour in
		FORCE_STATIC)
			LIB_TARGET_FOLDER="$REQUIRED_LIB_ROOT/stella-dep-static"
			LIB_EXTENSION=".a"
			;;
		FORCE_DYNAMIC)
			LIB_TARGET_FOLDER="$REQUIRED_LIB_ROOT/stella-dep-dynamic"
			[ "$STELLA_CURRENT_PLATFORM" == "linux" ] && LIB_EXTENSION=".so"
			[ "$STELLA_CURRENT_PLATFORM" == "darwin" ] && LIB_EXTENSION=".dylib"
			;;
		*)	
			LIB_TARGET_FOLDER="$REQUIRED_LIB_ROOT/$_lib_folder"
			;;
	esac

	if [ "$_flag_lib_isolation" == "TRUE" ]; then
		echo "*** Isolate dependent libs to $LIB_TARGET_FOLDER"
		__del_folder "$LIB_TARGET_FOLDER"

		#local _target=

		__copy_folder_content_into "$REQUIRED_LIB_ROOT"/"$_lib_folder" "$LIB_TARGET_FOLDER" "*"$LIB_EXTENSION"*"
		if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
			for f in "$LIB_TARGET_FOLDER"/*".dylib"*; do	
				if [ -f "$f" ]; then	
					[ "$STELLA_BUILD_RELOCATE" == "ON" ] && __fix_dynamiclib_install_name_darwin "$f" "RPATH"
					[ "$STELLA_BUILD_RELOCATE" == "OFF" ] && __fix_dynamiclib_install_name_darwin "$f" "PATH"
				fi
			done
		fi

	fi









	# RESULTS

	# root folder
	_ROOT="$REQUIRED_LIB_ROOT"
	# bin folder
	_BIN="$REQUIRED_LIB_ROOT/bin"
	# include folder
	_INCLUDE="$REQUIRED_LIB_ROOT/$_include_folder"
	# lib folder
	_LIB="$LIB_TARGET_FOLDER"

	# includes used during build
	_CPP_FLAGS="-I$_INCLUDE"
	
	_LINK_FLAGS="-L$_LIB"
	
	for l in $_libs_name; do
		_LINK_FLAGS="$_LINK_FLAGS -l$l"
	done
	




	

	# set stella build system flags ----
	if [ "$_opt_set_flags" == "ON" ]; then
		LINKED_LIBS_C_CXX_FLAGS="$LINKED_LIBS_C_CXX_FLAGS $_C_CXX_FLAGS"
		LINKED_LIBS_CPP_FLAGS="$LINKED_LIBS_CPP_FLAGS $_CPP_FLAGS"
		LINKED_LIBS_LINK_FLAGS="$LINKED_LIBS_LINK_FLAGS $_LINK_FLAGS"

		LINKED_LIBS_PATH="$LINKED_LIBS_PATH $_LIB"

		LINKED_LIBS_CMAKE_LIBRARY_PATH="$LINKED_LIBS_CMAKE_LIBRARY_PATH:$_LIB"
		LINKED_LIBS_CMAKE_INCLUDE_PATH="$LINKED_LIBS_CMAKE_INCLUDE_PATH:$_INCLUDE"
	fi



	# set <var> flags ----
	if [ ! "$_var_flags" == "" ]; then
		eval "$_var_flags"_C_CXX_FLAGS=\"$_C_CXX_FLAGS\"
		eval "$_var_flags"_CPP_FLAGS=\"$_CPP_FLAGS\"
		eval "$_var_flags"_LINK_FLAGS=\"$_LINK_FLAGS\"
	fi

	# set <folder> vars ----
	if [ ! "$_var_folders" == "" ]; then
		eval "$_var_folders"_ROOT=\"$_ROOT\"
		eval "$_var_folders"_LIB=\"$_LIB\"
		eval "$_var_folders"_INCLUDE=\"$_INCLUDE\"
		eval "$_var_folders"_BIN=\"$_BIN\"
	fi

}










# ENV and FLAGS management---------------------------------------------------------------------------------------------------------------------------------------

function __reset_build_env() {
	# BUILD FLAGS
	STELLA_C_CXX_FLAGS=
	STELLA_CPP_FLAGS=
	#STELLA_DYNAMIC_LINK_FLAGS=
	#STELLA_STATIC_LINK_FLAGS=
	STELLA_LINK_FLAGS=
	STELLA_CMAKE_EXTRA_FLAGS=
	STELLA_CMAKE_RPATH_BUILD_PHASE=
	STELLA_CMAKE_RPATH_INSTALL_PHASE=
	STELLA_CMAKE_RPATH=
	STELLA_CMAKE_RPATH_DARWIN=

	# LINKED LIBRARIES
	LINKED_LIBS_C_CXX_FLAGS=
	LINKED_LIBS_CPP_FLAGS=
	LINKED_LIBS_LINK_FLAGS=
	LINKED_LIBS_PATH=
	LINKED_LIBS_CMAKE_LIBRARY_PATH=
	LINKED_LIBS_CMAKE_INCLUDE_PATH=

	# BUILD MODE
	STELLA_BUILD_RELOCATE="$STELLA_BUILD_RELOCATE_DEFAULT"
	STELLA_BUILD_RPATH="$STELLA_BUILD_RPATH_DEFAULT"
	STELLA_BUILD_CPU_INSTRUCTION_SCOPE="$STELLA_BUILD_CPU_INSTRUCTION_SCOPE_DEFAULT"
	STELLA_BUILD_OPTIMIZATION="$STELLA_BUILD_OPTIMIZATION_DEFAULT"
	STELLA_BUILD_PARALLELIZE="$STELLA_BUILD_PARALLELIZE_DEFAULT"
	STELLA_BUILD_LINK_MODE="$STELLA_BUILD_LINK_MODE_DEFAULT"
	STELLA_BUILD_DEP_FROM_SYSTEM="$STELLA_BUILD_DEP_FROM_SYSTEM_DEFAULT"
	STELLA_BUILD_ARCH="$STELLA_BUILD_ARCH_DEFAULT"
	STELLA_BUILD_DARWIN_STDLIB="$STELLA_BUILD_DARWIN_STDLIB"
	STELLA_BUILD_MACOSX_DEPLOYMENT_TARGET="$STELLA_BUILD_MACOSX_DEPLOYMENT_TARGET"

	# EXTERNAL VARIABLE
	# reset variable from outside stella
	# dont need this, they are reaffected when calling set_cmake_flags and set_standard_flags
	unset CFLAGS #flags to pass to the C compiler.
	unset CXXFLAGS #flags to pass to the C++ compiler.
	unset CPPFLAGS #flags to pass to the C preprocessor. Used when compiling C and C++
	unset LDFLAGS #flags to pass to the linker
	unset CMAKE_C_FLAGS
	unset CMAKE_CXX_FLAGS
	unset CMAKE_SHARED_LINKER_FLAGS
	unset CMAKE_MODULE_LINKER_FLAGS
	unset CMAKE_STATIC_LINKER_FLAGS
	unset CMAKE_EXE_LINKER_FLAGS
}



# Convert build mode to build flags with __set_build_env
function __apply_build_env() {
	local OPT="$1"

	# configure tool
	local _flag_configure=
	local CONFIG_TOOL=
	
	for o in $OPT; do 
		[ "$_flag_configure" == "ON" ] && CONFIG_TOOL=$o && _flag_configure=
		[ "$o" == "CONFIG_TOOL" ] && _flag_configure=ON
	done
	
	# autoselect conf tool
	[ "$CONFIG_TOOL" == "" ] && CONFIG_TOOL="$(__auto_select_conf_tool)"


	# set env
	__set_build_env ARCH $STELLA_BUILD_ARCH
	__set_build_env CPU_INSTRUCTION_SCOPE $STELLA_BUILD_CPU_INSTRUCTION_SCOPE
	__set_build_env OPTIMIZATION $STELLA_BUILD_OPTIMIZATION
	__set_build_env PARALLELIZE $STELLA_BUILD_PARALLELIZE
	__set_build_env LINK_MODE $STELLA_BUILD_LINK_MODE
	__set_build_env RELOCATE $STELLA_BUILD_RELOCATE
	__set_build_env MACOSX_DEPLOYMENT_TARGET $STELLA_BUILD_MACOSX_DEPLOYMENT_TARGET
	__set_build_env DARWIN_STDLIB $STELLA_BUILD_DARWIN_STDLIB

	# trim list
	STELLA_BUILD_RPATH="$(__trim $STELLA_BUILD_RPATH)"
	STELLA_C_CXX_FLAGS="$(__trim $STELLA_C_CXX_FLAGS)"
	STELLA_CPP_FLAGS="$(__trim $STELLA_CPP_FLAGS)"
	STELLA_LINK_FLAGS="$(__trim $STELLA_LINK_FLAGS)"

	# set flags -------------
	# by default will set standard build flags
	case $CONFIG_TOOL in
		cmake)
			__set_cmake_build_flags
		;;
		*)
			__set_standard_build_flags
		;;

	esac

}

function __auto_select_conf_tool() {
	# autoselect conf tool
	local _config_tool="configure"
	
	if [[ -n `which cmake 2> /dev/null` ]]; then
		_config_tool="cmake"
	fi

	echo "$_config_tool"
}

function __auto_select_build_tool() {
	local _config_tool="$1"

	# autoselect build tool
	local _build_tool=make
	if [ "$_config_tool" == "cmake" ]; then
		if [[ -n `which ninja 2> /dev/null` ]]; then
			_build_tool=ninja
		fi
	fi

	echo "$_build_tool"
}

# set flags and env for CMAKE
function __set_cmake_build_flags() {


	# RPATH Management
	if [ "$STELLA_BUILD_RELOCATE" == "ON" ]; then
		local _rpath=
		for r in $STELLA_BUILD_RPATH; do
			_rpath="$r;$_rpath"
		done
		# for darwin, will add as rpath current project lib folder ( TODO : need this for linux too ?)
		#[ "$STELLA_CURRENT_PLATFORM" == "darwin" ] && _rpath="$_rpath;\${CMAKE_INSTALL_PREFIX}/lib"

		# all phase
		[ "$STELLA_CURRENT_PLATFORM" == "darwin" ] && __set_build_env "CMAKE_RPATH" "ALL_PHASE_USE_RPATH_DARWIN"
		__set_build_env "CMAKE_RPATH" "ALL_PHASE_USE_RPATH"

		# cmake build phase
		__set_build_env "CMAKE_RPATH" "BUILD_PHASE_USE_BUILD_FOLDER"
		
		# cmake install phase
		__set_build_env "CMAKE_RPATH" "INSTALL_PHASE_USE_FINAL_RPATH"
		#__set_build_env "CMAKE_RPATH" "INSTALL_PHASE_NO_RPATH"
		__set_build_env "CMAKE_RPATH" "INSTALL_PHASE_ADD_FINAL_RPATH" "$_rpath"
		# add dependent lib directories to rpath value. (do not need this, because we merge all dependent libs in the same relative folder stella-dep)
		#__set_build_env "CMAKE_RPATH" "INSTALL_PHASE_ADD_DEPENDENT_LIB"
	else

		if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
			## force install_name with hard path
			__set_build_env "CMAKE_RPATH" "ALL_PHASE_USE_RPATH" # -- we need this for forcing install_name
			__set_build_env "CMAKE_RPATH" "INSTALL_PHASE_DEFAULT_RPATH" # -- we need this for forcing install_name
			# \${CMAKE_INSTALL_PREFIX}/lib is correct because when building we pass INSTALL_LIB_DIR with /lib
			STELLA_CMAKE_EXTRA_FLAGS="$STELLA_CMAKE_EXTRA_FLAGS -DCMAKE_INSTALL_NAME_DIR=\${CMAKE_INSTALL_PREFIX}/lib"
		fi
		if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
			__set_build_env "CMAKE_RPATH" "ALL_PHASE_NO_RPATH"

			# cmake build phase
			__set_build_env "CMAKE_RPATH" "BUILD_PHASE_NO_RPATH"
		
			# cmake install phase
			#__set_build_env "CMAKE_RPATH" "INSTALL_PHASE_USE_FINAL_RPATH"
			#__set_build_env "CMAKE_RPATH" "INSTALL_PHASE_ADD_DEPENDENT_LIB"
			__set_build_env "CMAKE_RPATH" "INSTALL_PHASE_NO_RPATH"
		fi
	fi

	# CMAKE Flags
	# note : 
	#	- these flags have to be passed to the cmake command line, as cmake do not read en var
	#	- list of environment variables read by cmake http://www.cmake.org/Wiki/CMake_Useful_Variables#Environment_Variables
	CMAKE_C_FLAGS="$STELLA_C_CXX_FLAGS"
	CMAKE_CXX_FLAGS="$STELLA_C_CXX_FLAGS"
	#CMAKE_SHARED_LINKER_FLAGS="$STELLA_LINK_FLAGS"
	#CMAKE_MODULE_LINKER_FLAGS="$STELLA_LINK_FLAGS"
	#CMAKE_STATIC_LINKER_FLAGS="$STELLA_STATIC_LINK_FLAGS"
	#CMAKE_EXE_LINKER_FLAGS="$STELLA_STATIC_LINK_FLAGS $STELLA_DYNAMIC_LINK_FLAGS"

	# Linker flags to be used to create shared libraries
	CMAKE_SHARED_LINKER_FLAGS="$STELLA_LINK_FLAGS"
	# Linker flags to be used to create module
	CMAKE_MODULE_LINKER_FLAGS="$STELLA_LINK_FLAGS"
	# Linker flags to be used to create static libraries
	CMAKE_STATIC_LINKER_FLAGS="$STELLA_LINK_FLAGS"
	# Linker flags to be used to create executables
	CMAKE_EXE_LINKER_FLAGS="$STELLA_LINK_FLAGS"

	# Linked libraries
	LINKED_LIBS_CMAKE_LIBRARY_PATH="$(__trim $LINKED_LIBS_CMAKE_LIBRARY_PATH)"
	LINKED_LIBS_CMAKE_INCLUDE_PATH="$(__trim $LINKED_LIBS_CMAKE_INCLUDE_PATH)"
	export CMAKE_LIBRARY_PATH="$LINKED_LIBS_CMAKE_LIBRARY_PATH"
	export CMAKE_INCLUDE_PATH="$LINKED_LIBS_CMAKE_INCLUDE_PATH"
	# -DCMAKE_MODULE_PATH="$CMAKE_MODULE_PATH" 

	# save rpath related flags
	[ "$STELLA_CURRENT_PLATFORM" == "linux" ] && STELLA_CMAKE_EXTRA_FLAGS="$STELLA_CMAKE_EXTRA_FLAGS $STELLA_CMAKE_RPATH $STELLA_CMAKE_RPATH_BUILD_PHASE $STELLA_CMAKE_RPATH_INSTALL_PHASE"
	#[ "$STELLA_CURRENT_PLATFORM" == "darwin" ] && STELLA_CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_NAME_DIR=\${CMAKE_INSTALL_RPATH} $STELLA_CMAKE_EXTRA_FLAGS $STELLA_CMAKE_RPATH $STELLA_CMAKE_RPATH_DARWIN $STELLA_CMAKE_RPATH_BUILD_PHASE $STELLA_CMAKE_RPATH_INSTALL_PHASE"
	[ "$STELLA_CURRENT_PLATFORM" == "darwin" ] && STELLA_CMAKE_EXTRA_FLAGS="$STELLA_CMAKE_EXTRA_FLAGS $STELLA_CMAKE_RPATH $STELLA_CMAKE_RPATH_DARWIN $STELLA_CMAKE_RPATH_BUILD_PHASE $STELLA_CMAKE_RPATH_INSTALL_PHASE"
	
	STELLA_CMAKE_EXTRA_FLAGS="$(__trim $STELLA_CMAKE_EXTRA_FLAGS)"
}


# set flags and env for standard build tools (GNU MAKE,...)
function __set_standard_build_flags() {



	# RPATH Management
	for r in $STELLA_BUILD_RPATH; do
		if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
			STELLA_LINK_FLAGS="$STELLA_LINK_FLAGS -Wl,-rpath='"$r"'"
		fi
		if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then	
			STELLA_LINK_FLAGS="$STELLA_LINK_FLAGS -Wl,-rpath,'"$r"'"
		fi
	done
	

	# ADD linked libraries flags
	LINKED_LIBS_C_CXX_FLAGS="$(__trim $LINKED_LIBS_C_CXX_FLAGS)"
	LINKED_LIBS_CPP_FLAGS="$(__trim $LINKED_LIBS_CPP_FLAGS)"
	LINKED_LIBS_LINK_FLAGS="$(__trim $LINKED_LIBS_LINK_FLAGS)"

	STELLA_C_CXX_FLAGS="$STELLA_C_CXX_FLAGS $LINKED_LIBS_C_CXX_FLAGS"
	STELLA_CPP_FLAGS="$STELLA_CPP_FLAGS $LINKED_LIBS_CPP_FLAGS"
	STELLA_LINK_FLAGS="$LINKED_LIBS_LINK_FLAGS $STELLA_LINK_FLAGS"


 	# flags to pass to the C compiler.
	export CFLAGS="$STELLA_C_CXX_FLAGS"
	# flags to pass to the C++ compiler.
	export CXXFLAGS="$STELLA_C_CXX_FLAGS"
	# flags to pass to the C preprocessor. Used when compiling C and C++ (Used to pass -Iinclude_folder)
	export CPPFLAGS="$STELLA_CPP_FLAGS"
	# flags to pass to the linker
	#export LDFLAGS="$STELLA_STATIC_LINK_FLAGS $STELLA_DYNAMIC_LINK_FLAGS"
	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		# TODO experimental
		# https://sourceware.org/binutils/docs/ld/Options.html
		# http://www.kaizou.org/2015/01/linux-libraries/
		export LDFLAGS="-Wl,--copy-dt-needed-entries -Wl,--as-needed -Wl,--no-allow-shlib-undefined -Wl,--no-undefined $STELLA_LINK_FLAGS"
		export LDFLAGS="-Wl,--enable-new-dtags $LDFLAGS"
	else
		export LDFLAGS="$STELLA_LINK_FLAGS"
	fi
}




function __set_build_mode_default() {
	local c=
	case $1 in
		RPATH|DEP_FROM_SYSTEM)
			eval STELLA_BUILD_"$1"_DEFAULT=\"$2\" \"$3\"
		;;
		*)
			eval STELLA_BUILD_"$1"_DEFAULT=\"$2\"
		;;
	esac
	
}

function __set_build_mode() {

	# STATIC/DYNAMIC LINK -----------------------------------------------------------------
	# force build system to force a linking mode when it is possible
	# STATIC | DYNAMIC | DEFAULT
	[ "$1" == "LINK_MODE" ] && STELLA_BUILD_LINK_MODE=$2

	# CPU_INSTRUCTION_SCOPE -----------------------------------------------------------------
	# http://sdf.org/~riley/blog/2014/10/30/march-mtune/
	[ "$1" == "CPU_INSTRUCTION_SCOPE" ] && STELLA_BUILD_CPU_INSTRUCTION_SCOPE=$2

	# ARCH -----------------------------------------------------------------
	# Setting flags for a specific arch
	[ "$1" == "ARCH" ] && STELLA_BUILD_ARCH=$2

	# BINARIES RELOCATABLE -----------------------------------------------------------------
	# ON | OFF
	#		every dependency will be added to a DT_NEEDED field in elf files 
	# 				on linux : DT_NEEDED contain dependency filename only
	# 				on macos : ????? contain dependency filename only
	#		if OFF : RPATH values will be added for each dependency by absolute path
	#		if ON : RPATH values will contain relative values to a nested lib folder containing dependencies
	[ "$1" == "RELOCATE" ] && STELLA_BUILD_RELOCATE=$2

	# GENERIC RPATH (runtime search path values)
	if [ "$1" == "RPATH" ]; then
		case $2 in
			ADD)
				STELLA_BUILD_RPATH="$STELLA_BUILD_RPATH $3"
			;;
			ADD_FIRST)
				STELLA_BUILD_RPATH="$3 $STELLA_BUILD_RPATH"
			;;
		esac
	fi

	# MACOSX_DEPLOYMENT_TARGET -----------------------------------------------------------------
	[ "$1" == "MACOSX_DEPLOYMENT_TARGET" ] && STELLA_BUILD_MACOSX_DEPLOYMENT_TARGET=$2

	# DARWIN STDLIB -----------------------------------------------------------------
	# http://stackoverflow.com/a/19637199
	# On 10.8 and earlier libstdc++ is chosen by default, on version >= 10.9 libc++ is chosen by default.
	# by default -mmacosx-version-min value is used to choose one of them
	[ "$1" == "DARWIN_STDLIB" ] && STELLA_BUILD_DARWIN_STDLIB=$2

	# OPTIMIZATION LEVEL-----------------------------------------------------------------
	[ "$1" == "OPTIMIZATION" ] && STELLA_BUILD_OPTIMIZATION=$2

	# PARALLELIZATION -----------------------------------------------------------------
	[ "$1" == "PARALLELIZE" ] && STELLA_BUILD_PARALLELIZE=$2

	# DEPENDENCIES FROM SYSTEM -----------------------------------------------------------------
	# these features will be picked from the system
	# have an effect only for feature declared in FEAT_SOURCE_DEPENDENCIES, FEAT_BINARY_DEPENDENCIES or passed to  __link_feature_libray
	if [ "$1" == "DEP_FROM_SYSTEM" ]; then
		case $2 in
			ADD)
				STELLA_BUILD_DEP_FROM_SYSTEM="$STELLA_BUILD_DEP_FROM_SYSTEM $3"
			;;
		esac
	fi
}

# Translate build env to flags
function __set_build_env() {


	# CPU_INSTRUCTION_SCOPE -----------------------------------------------------------------
	# http://sdf.org/~riley/blog/2014/10/30/march-mtune/
	if [ "$1" == "CPU_INSTRUCTION_SCOPE" ]; then
		case $2 in
			CURRENT)
				STELLA_C_CXX_FLAGS="$STELLA_C_CXX_FLAGS -march=native"
				;;
			SAME_FAMILY)
				STELLA_C_CXX_FLAGS="$STELLA_C_CXX_FLAGS -mtune=native"
				;;
			GENERIC)
				STELLA_C_CXX_FLAGS="$STELLA_C_CXX_FLAGS -mtune=generic"
				;;
		esac
	fi

	# set OPTIMIZATION -----------------------------------------------------------------
	if [ "$1" == "OPTIMIZATION" ]; then
		[ ! "$2" == "" ] && STELLA_C_CXX_FLAGS="$STELLA_C_CXX_FLAGS -O$2"
	fi

	# ARCH -----------------------------------------------------------------
	# Setting flags for a specific arch
	if [ "$1" == "ARCH" ]; then
		if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
			case $2 in
				x86)
					STELLA_C_CXX_FLAGS="-m32 $STELLA_C_CXX_FLAGS"
					;;
				x64)
					STELLA_C_CXX_FLAGS="-m64 $STELLA_C_CXX_FLAGS"
					;;
			esac
		fi
		# for darwin -m and -arch are near the same
		# http://stackoverflow.com/questions/1754460/apples-gcc-whats-the-difference-between-arch-i386-and-m32
		if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
			case $2 in
				x86)
					STELLA_C_CXX_FLAGS="-arch i386 $STELLA_C_CXX_FLAGS"
					;;
				x64)
					STELLA_C_CXX_FLAGS="-arch x86_64 $STELLA_C_CXX_FLAGS"
					;;
				universal)
					STELLA_C_CXX_FLAGS="-arch i386 -arch x86_64 $STELLA_C_CXX_FLAGS"
					;;
			esac
		fi
	fi

	# fPIC is usefull when building shared libraries for x64
	# not for x86 : http://stackoverflow.com/questions/7216244/why-is-fpic-absolutely-necessary-on-64-and-not-on-32bit-platforms -- http://stackoverflow.com/questions/6961832/does-32bit-x86-code-need-to-be-specially-pic-compiled-for-shared-library-files
	# On MacOS it is active by default
	if [ "$1" == "ARCH" ]; then
		if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
			case $2 in
				x64)
					STELLA_C_CXX_FLAGS="-fPIC $STELLA_C_CXX_FLAGS"
					;;
			esac
		fi
	fi

	# MACOSX_DEPLOYMENT_TARGET -----------------------------------------------------------------
	if [ "$1" == "MACOSX_DEPLOYMENT_TARGET" ]; then
		if [ ! "$2" == "" ]; then
			export MACOSX_DEPLOYMENT_TARGET=$2
			STELLA_CMAKE_EXTRA_FLAGS="$STELLA_CMAKE_EXTRA_FLAGS -DCMAKE_OSX_DEPLOYMENT_TARGET=$2"
			STELLA_C_CXX_FLAGS="$STELLA_C_CXX_FLAGS -mmacosx-version-min=$2"
		fi
	fi


	# DARWIN STDLIB -----------------------------------------------------------------
	# http://stackoverflow.com/a/19637199
	# On 10.8 and earlier libstdc++ is chosen by default, on version >= 10.9 libc++ is chosen by default.
	# by default -mmacosx-version-min value is used to choose one of them
	if [ "$1" == "DARWIN_STDLIB" ]; then
		#[ "$2" == "LIBCPP" ] && STELLA_LINK_FLAGS="$STELLA_LINK_FLAGS -stdlib=libc++"
		#[ "$2" == "LIBSTDCPP" ] && STELLA_LINK_FLAGS="$STELLA_LINK_FLAGS -stdlib=libstdc++"
		[ "$2" == "LIBCPP" ] && STELLA_C_CXX_FLAGS="$STELLA_C_CXX_FLAGS -stdlib=libc++"
		[ "$2" == "LIBSTDCPP" ] && STELLA_C_CXX_FLAGS="$STELLA_C_CXX_FLAGS -stdlib=libstdc++"
	fi



	# CMAKE_RPATH -----------------------------------------------------------------
	# Change behaviour of cmake about RPATH
	# CMAKE have 2 phases
	# During each phase a rpath value is determined and used
	# On Linux :
	#		1.Build Phase
	#			While building the binary and running tests
	# 				* [DEFAULT] CMAKE set binary RPATH value with the current build path as RPATH value (CMAKE_SKIP_BUILD_RPATH=OFF)
	#				* CMAKE set binary RPATH value with EMPTY VALUE (CMAKE_SKIP_BUILD_RPATH=ON)		
	#				* CMAKE set binary RPATH value with CMAKE_INSTALL_RPATH value (CMAKE_BUILD_WITH_INSTALL_RPATH=ON) - (and so, do not have to re-set it while installing)
	#		2.Install Phase
	#			When installing the binanry
	#				* CMAKE set binary RPATH value with EMPTY VALUE (CMAKE_SKIP_INSTALL_RPATH=ON)
	#				* [DEFAULT] CMAKE add as binary RPATH value CMAKE_INSTALL_RPATH value 
	#				* CMAKE add as binary RPATH value all dependent libraries outside the current build tree folder as RPATH value (CMAKE_INSTALL_RPATH_USE_LINK_PATH=ON)
	#	Note : CMAKE_SKIP_RPATH=ON : CMAKE set binary RPATH value with EMPTY VALUE during both phase (building and installing)
	#	Default : 
	#		CMAKE_SKIP_RPATH : OFF
	#		CMAKE_SKIP_BUILD_RPATH : OFF 
	#		CMAKE_BUILD_WITH_INSTALL_RPATH : OFF 
	#		CMAKE_INSTALL_RPATH "" (empty)
	#		CMAKE_INSTALL_RPATH_USE_LINK_PATH : OFF
	#		CMAKE_SKIP_INSTALL_RPATH : OFF
	# On MacOSX :
	#		http://www.kitware.com/blog/home/post/510
	#		http://matthew-brett.github.io/docosx/mac_runtime_link.html
	#		1.Build Phase
	#			* CMAKE set binary RPATH value with "@rpath" during both phase (CMAKE_MACOSX_RPATH=ON)
	#		2.Install Phase
	#			* CMAKE set binary RPATH value with "@rpath" during both phase (CMAKE_MACOSX_RPATH=ON)
	#			* CMAKE set binary RPATH value with INSTALL_NAME_DIR if it setted
	#	Default : 
	#		CMAKE_MACOSX_RPATH : ON
	if [ "$1" == "CMAKE_RPATH" ]; then
		case $2 in
			
			# no rpath during BUILD PHASE
			BUILD_PHASE_NO_RPATH)
				STELLA_CMAKE_RPATH_BUILD_PHASE="-DCMAKE_SKIP_BUILD_RPATH=ON" # DEFAULT : OFF
				;;
			
			BUILD_PHASE_USE_BUILD_FOLDER)
				STELLA_CMAKE_RPATH_BUILD_PHASE="-DCMAKE_SKIP_BUILD_RPATH=OFF -DCMAKE_BUILD_WITH_INSTALL_RPATH=OFF" # DEFAULT : OFF / OFF
				;;
			
			BUILD_PHASE_USE_FINAL_RPATH)
				STELLA_CMAKE_RPATH_BUILD_PHASE="-DCMAKE_SKIP_BUILD_RPATH=OFF -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON" # DEFAULT :  OFF / OFF
				;;
	


			INSTALL_PHASE_DEFAULT_RPATH)
				STELLA_CMAKE_RPATH_INSTALL_PHASE="-DCMAKE_SKIP_INSTALL_RPATH=OFF" # DEFAULT : OFF
				;;

			INSTALL_PHASE_NO_RPATH)
				STELLA_CMAKE_RPATH_INSTALL_PHASE="-DCMAKE_SKIP_INSTALL_RPATH=ON" # DEFAULT : OFF
				;;

			INSTALL_PHASE_USE_FINAL_RPATH)
				STELLA_CMAKE_RPATH_INSTALL_PHASE="$STELLA_CMAKE_RPATH_INSTALL_PHASE -DCMAKE_SKIP_INSTALL_RPATH=OFF" # DEFAULT : OFF
				;;

			INSTALL_PHASE_ADD_FINAL_RPATH)
				# NOTE : this is a list !
				STELLA_CMAKE_RPATH_INSTALL_PHASE="$STELLA_CMAKE_RPATH_INSTALL_PHASE -DCMAKE_INSTALL_RPATH=$3" # DEFAULT : empty string
				;;
			
			# add folder containing dependent lib, which are outside of the project
			INSTALL_PHASE_ADD_DEPENDENT_LIB)
				STELLA_CMAKE_RPATH_INSTALL_PHASE="$STELLA_CMAKE_RPATH_INSTALL_PHASE -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON" # DEFAULT : OFF
				;;
			

				
			ALL_PHASE_NO_RPATH)
				STELLA_CMAKE_RPATH="-DCMAKE_SKIP_RPATH=ON" # DEFAULT : OFF
			;;
			ALL_PHASE_USE_RPATH)
				STELLA_CMAKE_RPATH="-DCMAKE_SKIP_RPATH=OFF" # DEFAULT : OFF
			;;

			
			# For DARWIN
			ALL_PHASE_NO_RPATH_DARWIN)
				STELLA_CMAKE_RPATH_DARWIN="-DCMAKE_MACOSX_RPATH=OFF" # DEFAULT : ON
			;;
			ALL_PHASE_USE_RPATH_DARWIN)
				# DEFAULT : ON
				# activate @rpath/lib_name as INSTALL_NAME for lib built with CMAKE
				# activate management of rpath values during BUILD and INSTALL phase
				STELLA_CMAKE_RPATH_DARWIN="-DCMAKE_MACOSX_RPATH=ON" # DEFAULT : ON
			;;
			

		esac

	fi




}


function __get_install_name_darwin() {
	local _file=$1
	echo $(otool -l $_file | grep -E "LC_ID_DYLIB" -A2 | grep name | tr -s ' ' | cut -d ' ' -f 3)
}

# CHECK BUILD ------------------------------------------------------------------------------------------------------------------------------
function __inspect_build() {
	local folder="$1"

	# TODO
	# verify architecture of shared or static libs
	#otool -hv -arch 

	[ "$1" == "" ] && return

	# fixing built files
	echo " ** fixing build ----------------"
	__fix_built_files "$folder"

	# checking built files
	echo " ** checking build ----------------"
	__check_built_files "$folder"
}


function __check_built_files() {
	local folder="$1"

	
	#[ "$(basename $1)" == "stella-dep" ] && return

	for f in  "$folder"/*; do
		[ -d "$f" ] && __check_built_files "$f"
		if [ -f "$f" ]; then
			case $STELLA_CURRENT_PLATFORM in 
				linux)
					if [ ! "$(objdump -p "$f" 2>/dev/null)" == "" ]; then
						echo
						echo "** Analysing $f"
						[ ! "$(__get_extension_from_string $f)" == "a" ] && __check_rpath_linux "$f"
						[ ! "$(__get_extension_from_string $f)" == "a" ] && __check_dynamic_linking_linux "$f"
						echo
					fi
				;;
				darwin)
					# test if file is a binary Mach-O file (binary, shared lib or static lib)
					if [ ! "$(otool -h "$f" 2>/dev/null | grep Mach)" == "" ]; then
						echo
						echo "** Analysing $f"
						if [ "$STELLA_BUILD_RELOCATE" == "ON" ]; then
							[ "$(__get_extension_from_string $f)" == "dylib" ] && __check_install_name_darwin "$f" "RPATH"
							[ ! "$(__get_extension_from_string $f)" == "a" ] && __check_rpath_darwin "$f"
						else
							[ "$(__get_extension_from_string $f)" == "dylib" ] && __check_install_name_darwin "$f" "PATH"
						fi

						[ ! "$(__get_extension_from_string $f)" == "a" ] && __check_dynamic_linking_darwin "$f"
						echo
					fi
				;;
			esac
		fi
	done
}

# test rpath values
function __check_rpath_linux() {
	local _file=$1
	local t

	# check rpath values of executable binary and shared lib
	local _err=0
	
	local _rpath_values

	local _field="RPATH"
	[ "$(objdump -p $_file | grep -E "$_field\s")" == "" ] && _field="RUNPATH"

	IFS=':' read -ra _rpath_values <<< "$(objdump -p $_file | grep -E "$_field\s" | tr -s ' ' | cut -d ' ' -f 3)"

	echo "** RPATH values :"
	if [ "$STELLA_BUILD_RELOCATE" == "ON" ]; then
		for i in "${_rpath_values[@]}"; do
			printf %s "		$i"
		 	[ $(__is_abs "$i") == "TRUE" ] && printf %s " -- WARN absolute path"
		 	echo
		done
	else
		for i in "${_rpath_values[@]}"; do
			echo "		$i"
		done
	fi

	echo "** Checking missing RPATH : $r"
	for r in $STELLA_BUILD_RPATH; do
		printf %s "*** Checking RPATH value : $r"
		for i in "${_rpath_values[@]}"; do
		 	[ "$i" == "$r" ] && t=1
		done
		if [ "$t" == "" ]; then
			printf %s " -- WARN RPATH value $r is missing"
			_err=1
		fi
		[ "$_err" == "0" ] && printf %s " -- OK"
		echo
	done
	
}

# check dynamic link at runtime
# Print out dynamic libraries loaded at runtime when launching a program :
# 		LD_TRACE_LOADED_OBJECTS=1 program
# ldd might not work on symlink and other situations
# TODO
function __check_dynamic_linking_linux() {
	local _file=$1
	local t

	echo "*** linked library"
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
		echo "		$t"
	else
		printf %s "-- OK"
	fi
}


# check wanted rpath values of exexcutable binary and shared lib
function __check_rpath_darwin() {
	local _file=$1
	local t
	


	local _err=0

	echo "*** List RPATH values in search order :"
	t=`otool -l $_file | grep -E "LC_RPATH" -A2 | grep -E "path "`
	echo $t

	for r in $STELLA_BUILD_RPATH; do
		printf %s "*** Checking if setted RPATH value is missing : $r"
		t=`otool -l $_file | grep -E "LC_RPATH" -A2 | grep -E "path $r \("`
		if [ "$t" == "" ]; then
			printf %s " -- WARN RPATH value $r is missing"
			_err=1
		fi
		[ "$_err" == "0" ] && printf %s " -- OK"
		echo
	done


}

# check ID/Install Name value
function __check_install_name_darwin() {
	local _file=$1
	local OPT="$2"
	local t		



	# RPATH -- check if install_name has @rpath
	# PATH -- check if install_name is a standard path and is matching current file location

	local _opt_rpath=ON
	local _opt_path=OFF
	for o in $OPT; do 
		[ "$o" == "RPATH" ] && _opt_rpath=ON && _opt_path=OFF
		[ "$o" == "PATH" ] && _opt_rpath=OFF && _opt_path=ON
	done


	printf "*** Checking ID/Install Name value : "
	local _install_name="$(__get_install_name_darwin $_file)"

	if [ "$_install_name" == "" ]; then
		echo
		echo " *** WARN $_file do not have any install name (LC_ID_DYLIB field)"
	else

		if [ "$_opt_rpath" == "ON" ]; then
			t=`echo $_install_name | grep -E "@rpath/"`
			if [ "$t" == "" ]; then
				printf %s " WARN ID/Install Name does not contain @rpath : $_install_name"
			else
				printf %s " $_install_name -- OK"
			fi
		fi
		if [ "$_opt_path" == "ON" ]; then
			if [ "$(dirname $_file)" == "$(dirname $_install_name)" ]; then
				printf %s " $_install_name -- OK"
			else
				if [ "$(dirname $_install_name)" == "." ]; then
					printf %s " WARN ID/Install Name contain only a name : $_install_name"
				else
					printf %s " WARN ID/Install Name does not match location of file : $_install_name"
				fi
			fi
		fi
		
	fi
	echo
}

# check dynamic link at runtime
# Print out dynamic libraries loaded at runtime when launching a program :
# 		DYLD_PRINT_LIBRARIES=y program
function __check_dynamic_linking_darwin() {
	local _file="$1"
	local line=
	local linked_lib=

	echo "*** Checking missing dynamic library at runtime"
	
	local _rpath=
	while read -r line; do
		_rpath="$_rpath $line"
	done <<< "$(otool -l "$_file" | grep -E "LC_RPATH" -A2 | grep path | tr -s ' ' | cut -d ' ' -f 3)"


	local _match=
	local loader_path="$(__get_path_from_string "$_file")"
	local original_rpath_value=
	while read -r line ; do
			printf %s "====> checking linked lib : $line "
			_match=
			
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
				if [ -f "$line" ]; then
					printf %s "-- OK"
					_match=1
				fi 
			fi
			[ "$_match" == "" ] && printf %s "-- WARN not found"
			echo
	done < <(otool -l $_file | grep -E "LC_LOAD_DYLIB" -A2 | grep name | tr -s ' ' | cut -d ' ' -f 3)


}







# FIX BUILD -----------------------------
function __fix_built_files() {
	local folder="$1"
	
	for f in  "$folder"/*; do
		[ -d "$f" ] && __fix_built_files "$f"
		if [ -f "$f" ]; then
			case $STELLA_CURRENT_PLATFORM in 
				linux)
					echo "TODO"
				;;
				darwin)
					# test if file is a binary Mach-O file (binary, shared lib or static lib)
					if [ ! "$(otool -h "$f" 2>/dev/null | grep Mach)" == "" ]; then
							# fix write permission
							chmod +w "$f"
							if [ "$STELLA_BUILD_RELOCATE" == "ON" ]; then
								[ "$(__get_extension_from_string $f)" == "dylib" ] && __fix_dynamiclib_install_name_darwin "$f" "RPATH"
								#[ "$(__get_extension_from_string $f)" == "so" ] && __fix_dynamiclib_install_name_darwin "$f"
								[ ! "$(__get_extension_from_string $f)" == "a" ] && __fix_linked_lib_darwin "$f" "ONLY_ABS_PATH REL_RPATH EXCLUDE_FILTER /System/Library|/usr/lib"
								[ ! "$(__get_extension_from_string $f)" == "a" ] && __fix_rpath_darwin "$f"
							else
								[ "$(__get_extension_from_string $f)" == "dylib" ] && __fix_dynamiclib_install_name_darwin "$f" "PATH"
							fi
					fi
				;;
			esac
		fi
	done





}

# MACOS -----  install_name, rpath, loader_path, executable_path
# https://mikeash.com/pyblog/friday-qa-2009-11-06-linking-and-install-names.html



# rpath ------------------------------
# fix rpath value by adding rpath values contained in list STELLA_BUILD_RPATH
#		reorder all rpath values
function __fix_rpath_darwin() {
	local _file=$1

	local msg=

	for r in $STELLA_BUILD_RPATH; do
		local _flag_rpath=
		local old_rpath=
		local _flag_move=
		local line=

		while read -r line; do
			if [ "$line" == "$r" ]; then
				_flag_rpath=1
			else
				old_rpath="$old_rpath $line"
			fi
		done <<< "$(otool -l "$_file" | grep -E "LC_RPATH" -A2 | grep path | tr -s ' ' | cut -d ' ' -f 3)"


		if [ "$_flag_rpath" == "" ];then
			msg="$msg -- adding RPATH value : $r"
			install_name_tool -add_rpath "$r" "$_file"
			_flag_move=1
		fi

		if [ "$_flag_move" == "1" ];then
			#msg="$msg -- Moving rpath values : $old_rpath"
			for p in $old_rpath; do
				install_name_tool -delete_rpath "$p" "$_file"
				install_name_tool -add_rpath "$p" "$_file"
			done
		fi
	done

	[ ! "$msg" == "" ] && echo "** Fixing rpath values for $_file $msg"

}

# fix linked shared lib with hardcoded path  and replace them with @rpath/libname and adding rpath value 
# sometimes, we have to do this because we did set the install_name of a lib after the build, but too late.
# TODO should exclude linked lib with @rpath/lib
function __fix_linked_lib_darwin() {
	local _file=$1
	local OPT="$2"

	# ONLY_ABS_PATH -- apply only to linked lib registered with an absolute path
	# ABS_RPATH -- add an absolute rpath value to linked lib
	# REL_RPATH -- add an absolute rpath value to linked lib
	# EXCLUDE_FILTER -- ignore these linked libraries

	local _opt_abs_path=OFF
	local _flag_filter=OFF
	local _filter=
	local _invert_filter=
	local _abs_rpath=ON
	local _rel_rpath=OFF
	for o in $OPT; do 
		[ "$o" == "ONLY_ABS_PATH" ] && _opt_abs_path=ON
		[ "$_flag_filter" == "ON" ] && _filter=$o && _flag_filter=OFF
		[ "$o" == "EXCLUDE_FILTER" ] && _flag_filter=ON && _invert_filter="-Ev"
		[ "$o" == "REL_RPATH" ] && _opt_abs_path=ON && _rel_rpath=ON && _abs_rpath=OFF
		[ "$o" == "ABS_RPATH" ] && _opt_abs_path=ON && _rel_rpath=OFF && _abs_rpath=ON
	done



	local _new_load_dylib=
	local line=
	local _linked_lib_filename=
	local _filename

	local _linked_lib_list=

	local _flag_existing_rpath=


	# get existing linked lib
	while read -r line; do
		if [ "$_opt_abs_path" == "ON" ]; then
			if [ "$(__is_abs "$line")" == "TRUE" ]; then
				[ -f "$line" ] && _linked_lib_list="$_linked_lib_list $line"
			fi
		else
			[ -f "$line" ] && _linked_lib_list="$_linked_lib_list $line"
		fi
	done <<< "$(otool -l "$_file" | grep -E "LC_LOAD_DYLIB" -A2 | grep $_invert_filter "$_filter" | tr -s ' ' | cut -d ' ' -f 3)"

	for l in $_linked_lib_list; do

		_filename=$(__get_filename_from_string $_file)
		_new_load_dylib="$(__get_path_from_string $l)"
		[ "$_rel_rpath" == "ON" ] && _new_load_dylib="@loader_path/$(__abs_to_rel_path $_new_load_dylib $(__get_path_from_string $_file))"
		_linked_lib_filename="$(__get_filename_from_string $l)"
		
		echo "** Fixing $_filename linked to $_linked_lib_filename shared lib"
		
		echo "*** setting LOAD_DYLIB : @rpath/$_linked_lib_filename"
		install_name_tool -change "$l" "@rpath/$_linked_lib_filename" "$_file"

		echo "*** adding RPATH value : $_new_load_dylib"
		#__set_build_mode "RPATH" "ADD" "$_new_load_dylib"
		_flag_existing_rpath=0
		while read -r line; do
			[ "$line" == "$_new_load_dylib" ] && _flag_existing_rpath=1
		done <<< "$(otool -l "$_file" | grep -E "LC_RPATH" -A2 | grep path | tr -s ' ' | cut -d ' ' -f 3)"
		
		if [ "$_flag_existing_rpath" == "0" ]; then
			install_name_tool -add_rpath "$_new_load_dylib" "$_file"
		fi
	done

}


# ID/install name ------------------------
# fix install name with @rpath/lib_name OR fix install name replacing @rpath/lib_name with /lib/path/lib_name
# we cannot pass '-Wl,install_name @rpath/library_name' during build time because we do not know the library name yet
function __fix_dynamiclib_install_name_darwin() {
	local _lib=$1
	local OPT="$2"
	local _new_install_name
	local _original_install_name

	# RPATH -- fix install_name with @rpath
	# PATH -- fix install_name with current location

	local _opt_rpath=ON
	local _opt_path=OFF
	for o in $OPT; do 
		[ "$o" == "RPATH" ] && _opt_rpath=ON && _opt_path=OFF
		[ "$o" == "PATH" ] && _opt_rpath=OFF && _opt_path=ON
	done

	_original_install_name="$(__get_install_name_darwin $_lib)"

	if [ "$_original_install_name" == "" ]; then
		echo " ** WARN $_lib do not have any install name (LC_ID_DYLIB field)"
		return
	fi

	case "$_original_install_name" in
		@rpath*)
			if [ "$_opt_path" == "ON" ]; then
				_new_install_name="$(__get_path_from_string $_lib)/$(__get_filename_from_string $_original_install_name)"
				echo "** Fixing install_name for $_lib with value : $_new_install_name"
				install_name_tool -id "$_new_install_name" $_lib
			fi
		;;

		*)
			if [ "$_opt_rpath" == "ON" ]; then
				_new_install_name="@rpath/$(__get_filename_from_string $_original_install_name)"
				echo "** Fixing install_name for $_lib with value : $_new_install_name"
				install_name_tool -id "$_new_install_name" $_lib
			fi
			if [ "$_opt_path" == "ON" ]; then
				# location path is not the good one
				if [ ! "$(dirname $_lib)" == "$(dirname $_original_install_name)" ]; then
					_new_install_name="$(__get_path_from_string $_lib)/$(__get_filename_from_string $_original_install_name)"
					echo "** Fixing install_name for $_lib with value : $_new_install_name"
					install_name_tool -id "$_new_install_name" $_lib
				fi
			fi
		;;

	esac
}


fi