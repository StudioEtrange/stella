if [ ! "$_STELLA_COMMON_BUILD_INCLUDED_" == "1" ]; then
_STELLA_COMMON_BUILD_INCLUDED_=1


# BUILD WORKFLOW

# SET SOME DEFAULT BUILD MODE
#		__set_build_mode_default "RELOCATE" "ON"
#  	__set_build_mode_default "DARWIN_STDLIB" "LIBCPP"

# START BUILD SESSION
#	__start_build_session (__reset_build_env : reset every __set_build_mode values to default or empty)

#		GET SOURCE CODE
#		__get_resource

#		SET TOOLSET
#		__set_toolset AUTOTOOLS|STANDARD|CMAKE|CUSTOM ====> MUST BE CALLED

# 		SET CUSTOM BUILD MODE
#		__set_build_mode ARCH x86

#		SET CUSTOM FLAGS
#		STELLA_C_CXX_FLAGS="$STELLA_C_CXX_FLAGS -DFLAG"

#		LINK BUILD TO OTHER LIBRARY
#		__link_feature_library

#		AUTOMATIC BUILD AND INSTALL
#		__auto_build



#				SET BUILD ENV AND FLAGS
#				__prepare_build
#
#						call set_env_vars_for_gcc-clang
#						call set_env_vars_for_cmake


#				LAUNCH CONFIG TOOL
#				__launch_configure
#				LAUNCH BUILD TOOL
#				__launch_build

#				__inspect_and_fix_build
#						call __fix_built_files
#						call __check_built_files


function __start_build_session() {
	__reset_build_env
	local OPT="$1"
	for o in $OPT; do
		# TODO : this OPT is never used when calling __start_build_session - useless, to supress ?
		[ "$o" == "RELOCATE" ] && __set_build_mode "RELOCATE" "ON"
	done
}

# TOOLSET ------------------------------------------------------------------------------------------------------------------------------
function __set_toolset() {
	# CUSTOM | STANDARD | CMAKE | AUTOTOOLS
	local MODE="$1"
	local OPT="$2"

	# configure tool
	local _flag_configure=
	local CONFIG_TOOL=$STELLA_BUILD_DEFAULT_CONFIG_TOOL

	# build tool
	local _flag_build=
	local BUILD_TOOL=$STELLA_BUILD_DEFAULT_BUILD_TOOL

	# compiler frontend
	local _flag_frontend=
	local COMPIL_FRONTEND=$STELLA_BUILD_DEFAULT_COMPIL_FRONTEND

	case $MODE in
		CUSTOM)
			for o in $OPT; do
				[ "$_flag_configure" == "ON" ] && CONFIG_TOOL=$o && _flag_configure=FORCE
				[ "$o" == "CONFIG_TOOL" ] && _flag_configure=ON
				[ "$_flag_build" == "ON" ] && BUILD_TOOL=$o && _flag_build=FORCE
				[ "$o" == "BUILD_TOOL" ] && _flag_build=ON
				[ "$_flag_frontend" == "ON" ] && COMPIL_FRONTEND=$o && _flag_frontend=FORCE
				[ "$o" == "COMPIL_FRONTEND" ] && _flag_frontend=ON
			done

			;;
		AUTOTOOLS)
			STELLA_BUILD_TOOLSET=AUTOTOOLS
			_flag_configure=FORCE
			CONFIG_TOOL=configure

			BUILD_TOOL=make

			_flag_frontend=FORCE
			COMPIL_FRONTEND=gcc-clang
			;;

		STANDARD)
			STELLA_BUILD_TOOLSET=STANDARD

			_flag_configure=FORCE
			CONFIG_TOOL=configure

			BUILD_TOOL=make

			_flag_frontend=FORCE
			COMPIL_FRONTEND=gcc-clang
			;;
		CMAKE)
			STELLA_BUILD_TOOLSET=CMAKE

			_flag_configure=FORCE
			CONFIG_TOOL=cmake

			BUILD_TOOL=make

			_flag_frontend=FORCE
			COMPIL_FRONTEND=gcc-clang
			;;
	esac

	# autoselect ninja instead of make
	if [ "$CONFIG_TOOL" == "cmake" ]; then
		if [ ! "$_flag_build" == "FORCE" ]; then
			if [[ -n `which ninja 2> /dev/null` ]]; then
				BUILD_TOOL=ninja
			fi
		fi
	fi

	STELLA_BUILD_CONFIG_TOOL=$CONFIG_TOOL
	STELLA_BUILD_BUILD_TOOL=$BUILD_TOOL
	STELLA_BUILD_COMPIL_FRONTEND=$COMPIL_FRONTEND


}


function __require_current_toolset() {
	echo "** Require build toolset : $STELLA_BUILD_TOOLSET"
	[ "$STELLA_BUILD_TOOLSET" == "AUTOTOOLS" ] && __require "autoconf" "autotools-bundle#1" "PREFER_STELLA"
	[ "$STELLA_BUILD_BUILD_TOOL" == "cmake" ] &&  __require "cmake" "cmake" "PREFER_STELLA"
	[ "$STELLA_BUILD_CONFIG_TOOL" == "cmake" ] && __require "cmake" "cmake" "PREFER_STELLA"
	[ "$STELLA_BUILD_BUILD_TOOL" == "make" ] && __require "make" "build-chain-standard" "PREFER_SYSTEM"
	[ "$STELLA_BUILD_COMPIL_FRONTEND" == "gcc-clang" ] &&  __require "gcc" "build-chain-standard" "PREFER_SYSTEM"
	echo "** Require build toolset : $STELLA_BUILD_TOOLSET"
	echo
}

# BUILD ------------------------------------------------------------------------------------------------------------------------------
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
	# DEBUG
	# SOURCE_KEEP
	# BUILD_KEEP
	# AUTOTOOLS <bootstrap|autogen|autoreconf>
	# NO_CONFIG
	# NO_BUILD
	# NO_OUT_OF_TREE_BUILD
	# NO_INSPECT
	# NO_INSTALL
	# POST_BUILD_STEP
	# INCLUDE_FILTER <expr> -- include these files for inspect and fix
	# EXCLUDE_FILTER <expr> -- exclude these files for inspect and fix
	# INCLUDE_FILTER is apply first, before EXCLUDE_FILTER
	# BUILD_ACTION <action1> <action2>
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
	# disable fix & check build (default : ON)
	local _opt_inspect_and_fix_build=ON
	for o in $OPT; do
		[ "$o" == "SOURCE_KEEP" ] && _opt_source_keep=ON
		[ "$o" == "BUILD_KEEP" ] && _opt_build_keep=ON
		[ "$o" == "NO_CONFIG" ] && _opt_configure=OFF
		[ "$o" == "NO_BUILD" ] && _opt_build=OFF
		[ "$o" == "NO_OUT_OF_TREE_BUILD" ] && _opt_out_of_tree_build=OFF
		[ "$o" == "NO_INSPECT" ] && _opt_inspect_and_fix_build=OFF
	done

	# can not build out of tree without configure first
	[ "$_opt_configure" == "OFF" ] && _opt_out_of_tree_build=OFF



	echo " ** Auto-building $NAME into $INSTALL_DIR for $STELLA_CURRENT_OS"

	echo " ** buildset tools checking"
	__require_current_toolset
	#local _check=
	#[ "$_opt_configure" == "ON" ] && _check=1
	#[ "$_opt_build" == "ON" ] && _check=1
	#[ "$_check" == "1" ] && __require_current_toolset

	# folder stuff
	BUILD_DIR="$SOURCE_DIR"
	[ "$_opt_out_of_tree_build" == "ON" ] && BUILD_DIR="$(dirname $SOURCE_DIR)/$(basename $SOURCE_DIR)-build"

	mkdir -p "$INSTALL_DIR"

	if [ "$_opt_out_of_tree_build" == "ON" ]; then
		echo "** Out of tree build is active"
		[ "$FORCE" == "1" ] && rm -Rf "$BUILD_DIR"
		[ ! "$_opt_build_keep" == "ON" ] && rm -Rf "$BUILD_DIR"
	else
		echo "** Out of tree build is not active"
	fi

	mkdir -p "$BUILD_DIR"



	# set build env
	__prepare_build "$INSTALL_DIR" "$SOURCE_DIR" "$BUILD_DIR"

	# launch process
	[ "$_opt_configure" == "ON" ] && __launch_configure "$SOURCE_DIR" "$INSTALL_DIR" "$BUILD_DIR" "$OPT"
	[ "$_opt_build" == "ON" ] && __launch_build "$SOURCE_DIR" "$INSTALL_DIR" "$BUILD_DIR" "$OPT"


	cd "$INSTALL_DIR"

	# clean workspace
	[ ! "$_opt_source_keep" == "ON" ] && rm -Rf "$SOURCE_DIR"

	if [ "$_opt_out_of_tree_build" == "ON" ]; then
		[ ! "$_opt_build_keep" == "ON" ] && rm -Rf "$BUILD_DIR"
	fi


	[ "$_opt_inspect_and_fix_build" == "ON" ] && __inspect_and_fix_build "$INSTALL_DIR" "$OPT"

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

	# debug mode (default : OFF)
	local _debug=
	# AUTOTOOLS <bootstrap|autogen|autoreconf>
	local _opt_autotools=OFF
	local _flag_opt_autotools=OFF
	local _autotools=
	for o in $OPT; do
		[ "$o" == "DEBUG" ] && _debug=ON
		[ "$_flag_opt_autotools" == "ON" ] && _autotools="$o" && _flag_opt_autotools=OFF
		[ "$o" == "AUTOTOOLS" ] && _flag_opt_autotools=ON && _opt_autotools=ON
	done

	mkdir -p "$AUTO_BUILD_DIR"
	cd "$AUTO_BUILD_DIR"

	if [ "$_opt_autotools" == "ON" ]; then
		case $_autotools in
			bootstrap)
				[ -f "$AUTO_SOURCE_DIR/bootstrap" ] && "$AUTO_SOURCE_DIR/bootstrap"
			;;
			autogen)
				[ -f "$AUTO_SOURCE_DIR/autogen.sh" ] && "$AUTO_SOURCE_DIR/autogen.sh"
			;;
			autoreconf)
				autoreconf --force --verbose --install $AUTO_SOURCE_DIR
			;;
		esac
	fi


	# GLOBAL FLAGs
	# AUTO_INSTALL_CONF_FLAG_PREFIX
	# AUTO_INSTALL_CONF_FLAG_POSTFIX

	case $STELLA_BUILD_CONFIG_TOOL in

		configure)
			chmod +x "$AUTO_SOURCE_DIR/configure"

			if [ "$AUTO_INSTALL_CONF_FLAG_PREFIX" == "" ]; then
				"$AUTO_SOURCE_DIR/configure" --prefix="$AUTO_INSTALL_DIR" $AUTO_INSTALL_CONF_FLAG_POSTFIX
			else
				eval $(echo $AUTO_INSTALL_CONF_FLAG_PREFIX) "$AUTO_SOURCE_DIR/configure" --prefix="$AUTO_INSTALL_DIR" $AUTO_INSTALL_CONF_FLAG_POSTFIX
			fi
		;;



		cmake)
			[ "$STELLA_BUILD_BUILD_TOOL" == "make" ] && CMAKE_GENERATOR="Unix Makefiles"
			[ "$STELLA_BUILD_BUILD_TOOL" == "ninja" ] && CMAKE_GENERATOR="Ninja"
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
				-DCMAKE_FIND_FRAMEWORK=LAST -DCMAKE_FIND_APPBUNDLE=LAST \
				-G "$CMAKE_GENERATOR"
				# -DCMAKE_DEBUG_POSTFIX=$DEBUG_POSTFIX
				#-DBUILD_STATIC_LIBS:BOOL=TRUE -DBUILD_SHARED_LIBS:BOOL=TRUE \
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
				-DCMAKE_FIND_FRAMEWORK=LAST -DCMAKE_FIND_APPBUNDLE=LAST \
				-G "$CMAKE_GENERATOR"
				#  -DCMAKE_DEBUG_POSTFIX=$DEBUG_POSTFIX
				# -DBUILD_STATIC_LIBS:BOOL=TRUE -DBUILD_SHARED_LIBS:BOOL=TRUE \
			fi
		;;

	esac
}


function __launch_build() {
	local AUTO_SOURCE_DIR
	local AUTO_INSTALL_DIR
	local AUTO_BUILD_DIR
	local OPT

	AUTO_SOURCE_DIR="$1"
	AUTO_INSTALL_DIR="$2"
	AUTO_BUILD_DIR="$3"
	OPT="$4"
	# parallelize build
	local _opt_parallelize="$STELLA_BUILD_PARALLELIZE"

	# debug mode (default : OFF)
	local _debug=
	# configure step activation (default : TRUE)
	local _opt_configure=ON
	# install step activation (default : TRUE)
	local _opt_install=ON
	# build steps after building (in order)
	local _flag_opt_post_build_step=OFF
	local _post_build_step=
	for o in $OPT; do
		[ "$o" == "DEBUG" ] && _debug=ON && _flag_opt_post_build_step=OFF
		[ "$o" == "NO_CONFIG" ] && _opt_configure=OFF && _flag_opt_post_build_step=OFF
		[ "$o" == "NO_INSTALL" ] && _opt_install=OFF && _flag_opt_post_build_step=OFF
		[ "$_flag_opt_post_build_step" == "ON" ] && _post_build_step="$o $_post_build_step"
		[ "$o" == "POST_BUILD_STEP" ] && _flag_opt_post_build_step=ON
	done

	# FLAGS (declared as global)
	# AUTO_INSTALL_BUILD_FLAG_PREFIX
	# AUTO_INSTALL_BUILD_FLAG_POSTFIX

	local _FLAG_PARALLEL=

	mkdir -p "$AUTO_BUILD_DIR"
	cd "$AUTO_BUILD_DIR"

	# POST_BUILD_STEP
	if __string_contains "$_post_build_step" "install"; then
		if [ "$_opt_install" == "OFF" ]; then
			_post_build_step=$(echo "$_post_build_step" | sed 's/^install$//' | sed 's/^install //' | sed 's/ install$//' | sed 's/ install / /g' )
		fi
	else
		if [ "$_opt_install" == "ON" ]; then
			# we add install in first place if not alread present
			_post_build_step="install $_post_build_step"
		fi
	fi

	local _step
	case $STELLA_BUILD_BUILD_TOOL in

		make)
			[ "$_opt_parallelize" == "ON" ] && _FLAG_PARALLEL="-j$STELLA_NB_CPU"
			[ "$_debug" == "ON" ] && _debug="--debug=b" #--debug=a
			if [ "$AUTO_INSTALL_BUILD_FLAG_PREFIX" == "" ]; then
				if [ "$_opt_configure" == "ON" ]; then
					# First step : build
					make $_debug $_FLAG_PARALLEL \
					$AUTO_INSTALL_BUILD_FLAG_POSTFIX

					# Other build step
					for _step in $_post_build_step; do
						make $_debug \
						$AUTO_INSTALL_BUILD_FLAG_POSTFIX \
						$_step
					done
				else
					#make $_debug $_FLAG_PARALLEL \
					#CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS" CPPFLAGS="$CPPFLAGS" LDFLAGS="$LDFLAGS" \
					#PREFIX="$AUTO_INSTALL_DIR" $AUTO_INSTALL_BUILD_FLAG_POSTFIX

					# First step : build
					make $_debug $_FLAG_PARALLEL \
					PREFIX="$AUTO_INSTALL_DIR" prefix="$AUTO_INSTALL_DIR" \
					$AUTO_INSTALL_BUILD_FLAG_POSTFIX

					#for _step in $_post_build_step; do
						#make $_debug \
						#CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS" CPPFLAGS="$CPPFLAGS" LDFLAGS="$LDFLAGS" \
						#PREFIX="$AUTO_INSTALL_DIR" $AUTO_INSTALL_BUILD_FLAG_POSTFIX \
						#$_step
					#done

					# Other build step
					for _step in $_post_build_step; do
						make $_debug \
						PREFIX="$AUTO_INSTALL_DIR" prefix="$AUTO_INSTALL_DIR" \
						$AUTO_INSTALL_BUILD_FLAG_POSTFIX \
						$_step
					done
				fi
			else
				if [ "$_opt_configure" == "ON" ]; then
					# First step : build
					eval $(echo $AUTO_INSTALL_BUILD_FLAG_PREFIX) make $_debug $_FLAG_PARALLEL \
					$AUTO_INSTALL_BUILD_FLAG_POSTFIX

					# Other build step
					for _step in $_post_build_step; do
						eval $(echo $AUTO_INSTALL_BUILD_FLAG_PREFIX) make $_debug \
						$AUTO_INSTALL_BUILD_FLAG_POSTFIX \
						$_step
					done
				else
					#eval $(echo $AUTO_INSTALL_BUILD_FLAG_PREFIX) make $_debug  $_FLAG_PARALLEL \
					#CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS" CPPFLAGS="$CPPFLAGS" LDFLAGS="$LDFLAGS" \
					#PREFIX="$AUTO_INSTALL_DIR" $AUTO_INSTALL_BUILD_FLAG_POSTFIX

					# First step : build
					eval $(echo $AUTO_INSTALL_BUILD_FLAG_PREFIX) make $_debug $_FLAG_PARALLEL \
					PREFIX="$AUTO_INSTALL_DIR" prefix="$AUTO_INSTALL_DIR" \
					$AUTO_INSTALL_BUILD_FLAG_POSTFIX

					#for _step in $_post_build_step; do
						#eval $(echo $AUTO_INSTALL_BUILD_FLAG_PREFIX) make $_debug \
						#CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS" CPPFLAGS="$CPPFLAGS" LDFLAGS="$LDFLAGS" \
						#PREFIX="$AUTO_INSTALL_DIR" $AUTO_INSTALL_BUILD_FLAG_POSTFIX \
						#$_step
					#done

					# Other build step
					for _step in $_post_build_step; do
						eval $(echo $AUTO_INSTALL_BUILD_FLAG_PREFIX) make $_debug \
						PREFIX="$AUTO_INSTALL_DIR" prefix="$AUTO_INSTALL_DIR" \
						$AUTO_INSTALL_BUILD_FLAG_POSTFIX \
						$_step
					done
				fi
			fi
		;;

		ninja)
			if [ ! "$_opt_parallelize" == "ON" ]; then
				_FLAG_PARALLEL="-j1"
			else
				# ninja is auto parallelized
				_FLAG_PARALLEL=
			fi
			[ "$_debug" == "ON" ] && _debug="-v"
			if [ "$AUTO_INSTALL_BUILD_FLAG_PREFIX" == "" ]; then
				# First step : build
				ninja $_debug $_FLAG_PARALLEL $AUTO_INSTALL_BUILD_FLAG_POSTFIX
				# Other build step
				for _step in $_post_build_step; do
					ninja $_debug $AUTO_INSTALL_BUILD_FLAG_POSTFIX $_step
				done
			else
				# First step : build
				eval $(echo $AUTO_INSTALL_BUILD_FLAG_PREFIX) ninja $_debug $_FLAG_PARALLEL $AUTO_INSTALL_BUILD_FLAG_POSTFIX
				# Other build step
				for _step in $_post_build_step; do
					eval $(echo $AUTO_INSTALL_BUILD_FLAG_PREFIX) ninja $_debug $AUTO_INSTALL_BUILD_FLAG_POSTFIX $_step
				done
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
	# TODO (see windows impl.) : FORCE_RENAME -- rename files when isolating files -- only apply when FORCE_STATIC or FORCE_DYNAMIC is ON
	# FORCE_LIB_FOLDER <path> -- folder prefix where lib resides, default "/lib"
	# FORCE_BIN_FOLDER <path> -- folder prefix where bin resides, default "/bin"
	# FORCE_INCLUDE_FOLDER <path> -- folder prefix where include resides, default "/include"
	# GET_FLAGS <prefix> -- init prefix_C_CXX_FLAGS, prefix_CPP_FLAGS, prefix_LINK_FLAGS with correct flags
	# GET_FOLDER <prefix> -- init prefix_ROOT, prefix_LIB, prefix_BIN, prefix_INCLUDE with correct path
	# NO_SET_FLAGS -- do not set stella build system flags
	# LIBS_NAME -- libraries name to use with -l arg -- you can specify several libraries. If you do not use LIBS_NAME -l flag will not be setted, only -L will be setted


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
	local _flag_bin_folder=OFF
	local _bin_folder=bin
	local _flag_include_folder=OFF
	local _include_folder=include
	local _opt_set_flags=ON
	local _flag_libs_name=OFF
	local _libs_name=

	# default mode
	case "$STELLA_BUILD_LINK_MODE" in
		DEFAULT)
			_opt_flavour="DEFAULT"
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
		[ "$_flag_bin_folder" == "ON" ] && _bin_folder=$o && _flag_bin_folder=OFF
		[ "$o" == "FORCE_BIN_FOLDER" ] && _flag_bin_folder=ON && _flag_libs_name=OFF
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

	echo "** Linking to $SCHEMA"

	[ "$STELLA_BUILD_COMPIL_FRONTEND" == "" ] && echo "** WARN : compil frontend empty - did you set a toolset ?"



	# INSPECT required lib through schema
	__push_schema_context
	__feature_inspect $SCHEMA
	if [ "$TEST_FEATURE" == "0" ]; then
		echo " ** ERROR : depend on lib $SCHEMA"
		__pop_schema_context
		return
	fi
	# TODO here : full reinit (or call of FEAT_ENV_CALLBACK) of the feature to override other versions of the feature

	LINKED_LIBS_LIST="$LINKED_LIBS_LIST $SCHEMA"
	local REQUIRED_LIB_ROOT="$FEAT_INSTALL_ROOT"
	local REQUIRED_LIB_NAME="$FEAT_NAME"
	__pop_schema_context

	# TODO useless ?
	# 	REQUIRED_LIB_ROOT="$FEAT_INSTALL_ROOT/stella-dep/$REQUIRED_LIB_NAME"
	# 	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
	# 		[ "$STELLA_BUILD_RELOCATE" == "ON" ] && __tweak_install_name_darwin "$REQUIRED_LIB_ROOT" "RPATH"
	# 		[ "$STELLA_BUILD_RELOCATE" == "OFF" ] && __tweak_install_name_darwin "$REQUIRED_LIB_ROOT" "PATH"
	# 	fi

	# ISOLATE STATIC OR DYNAMIC LIBS
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
		DEFAULT)
			LIB_TARGET_FOLDER="$REQUIRED_LIB_ROOT/$_lib_folder"
			;;
	esac

	# TODO do not base lib isolation on file extension but on result of function __is_*__bin from lib-parse-bin
	if [ "$_flag_lib_isolation" == "TRUE" ]; then
		echo "*** Isolate dependencies into $LIB_TARGET_FOLDER"
		__del_folder "$LIB_TARGET_FOLDER"
		echo "*** Copying items from $REQUIRED_LIB_ROOT/$_lib_folder to $LIB_TARGET_FOLDER"
		__copy_folder_content_into "$REQUIRED_LIB_ROOT"/"$_lib_folder" "$LIB_TARGET_FOLDER" "*"$LIB_EXTENSION"*"

		if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
			[ "$STELLA_BUILD_RELOCATE" == "ON" ] && __tweak_install_name_darwin "$LIB_TARGET_FOLDER" "RPATH"
			[ "$STELLA_BUILD_RELOCATE" == "OFF" ] && __tweak_install_name_darwin "$LIB_TARGET_FOLDER" "PATH"
		fi
	fi




	# RETURN RESULTS

	# root folder
	_ROOT="$REQUIRED_LIB_ROOT"
	# bin folder
	_BIN="$REQUIRED_LIB_ROOT/bin"
	# include folder
	_INCLUDE="$REQUIRED_LIB_ROOT/$_include_folder"
	# lib folder
	_LIB="$LIB_TARGET_FOLDER"


	#LINKED_LIBS_PATH="$LINKED_LIBS_PATH $_opt_flavour $_LIB"

	# set stella build system flags ----
	if [ "$_opt_set_flags" == "ON" ]; then
		__set_link_flags "$_LIB" "$_INCLUDE" "$_libs_name"

		# NOTE : we cannot really set rpath now, each built binary may have a different path, so rpath might be false
		# if [ "$STELLA_BUILD_RELOCATE" == "ON" ]; then
		# 	local p="$(__abs_to_rel_path "$_LIB" "$FEAT_INSTALL_ROOT")"
		# 	# NOTE : $ORIGIN may have problem on some systems, see : http://www.cmake.org/pipermail/cmake/2008-January/019290.html
		# 	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		# 		# from root
		# 		__set_build_mode "RPATH" "ADD_FIRST" '$ORIGIN/'$p
		# 		# from lib or bin folder
		# 		__set_build_mode "RPATH" "ADD_FIRST" '$ORIGIN/../'$p
		# 	fi
		# 	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		# 		# from root
		# 		__set_build_mode "RPATH" "ADD_FIRST" "@loader_path/$p"
		# 		# from lib or bin folder
		# 		__set_build_mode "RPATH" "ADD_FIRST" "@loader_path/../$p"
		# 	fi
		# fi
	fi


	# RESULT
	# set <var> flags ----
	if [ ! "$_var_flags" == "" ]; then
		__link_flags "$STELLA_BUILD_COMPIL_FRONTEND" "$_var_flags" "$_LIB" "$_INCLUDE" "$_libs_name"
	fi

	# set <folder> vars ----
	if [ ! "$_var_folders" == "" ]; then
		eval "$_var_folders"_ROOT=\"$_ROOT\"
		eval "$_var_folders"_LIB=\"$_LIB\"
		eval "$_var_folders"_INCLUDE=\"$_INCLUDE\"
		eval "$_var_folders"_BIN=\"$_BIN\"
	fi

	echo "** Linked to $SCHEMA"
}

function __set_link_flags() {
	local _lib_path="$1"
	local _include_path="$2"
	local _libs_name="$3"

	if [ ! "$STELLA_BUILD_CONFIG_TOOL" == "cmake" ]; then
		if [ "$STELLA_BUILD_COMPIL_FRONTEND" == "gcc-clang" ]; then
			__link_flags_gcc-clang "_flags" "$_lib_path" "$_include_path" "$_libs_name"
			LINKED_LIBS_C_CXX_FLAGS="$LINKED_LIBS_C_CXX_FLAGS $_flags_C_CXX_FLAGS"
			LINKED_LIBS_CPP_FLAGS="$LINKED_LIBS_CPP_FLAGS $_flags_CPP_FLAGS"
			LINKED_LIBS_LINK_FLAGS="$LINKED_LIBS_LINK_FLAGS $_flags_LINK_FLAGS"
		fi
	else
		LINKED_LIBS_CMAKE_LIBRARY_PATH="$LINKED_LIBS_CMAKE_LIBRARY_PATH:$_lib_path"
		LINKED_LIBS_CMAKE_INCLUDE_PATH="$LINKED_LIBS_CMAKE_INCLUDE_PATH:$_include_path"
	fi

}

function __link_flags() {
	local _frontend="$1"
	local _var_flags="$2"
	local _lib_path="$3"
	local _include_path="$4"
	local _libs_name="$5"

	if [ "$_frontend" == "gcc-clang" ]; then
		__link_flags_gcc-clang "$_var_flags" "$_lib_path" "$_include_path" "$_libs_name"
	fi
}

function __link_flags_gcc-clang() {
	local _var_flags="$1"
	local _lib_path="$2"
	local _include_path="$3"
	local _libs_name="$4"

	# for configure/make/gcc-clang OR NULL/make/gcc-clang
	local _C_CXX_FLAGS=
	local _CPP_FLAGS="-I$_include_path"
	local _LINK_FLAGS="-L$_lib_path"

	for l in $_libs_name; do
		_LINK_FLAGS="$_LINK_FLAGS -l$l"
	done

	eval "$_var_flags"_C_CXX_FLAGS=\"$_C_CXX_FLAGS\"
	eval "$_var_flags"_CPP_FLAGS=\"$_CPP_FLAGS\"
	eval "$_var_flags"_LINK_FLAGS=\"$_LINK_FLAGS\"

}

# NOTE : NOT USED
function __link_rpath_flags() {
	local _frontend="$1"
	local _var_flags="$2"
	local _linked_target_path="$3"
	local _linked_lib_path="$4"
	if [ "$_frontend" == "gcc-clang" ]; then
		__link_rpath_flags_gcc-clang "$_var_flags" "$_linked_target_path" "$_linked_lib_path"
	fi
}

# NOTE : NOT USED
function __link_rpath_flags_gcc-clang() {
	local _var_flags="$1"
	local _linked_target_path="$2"
	local _linked_lib_path="$3"

	local _p="$(__abs_to_rel_path "$_linked_lib_path" "$_linked_target_path")"
	local _LINK_RPATH_FLAGS
	local _rpath

	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		# to avoid problem with $$ORIGIN -- only usefull with standard build tools (do not need this with cmake)
		# relative to /lib or /root folder
		_rpath='$ORIGIN/../'$p
		_rpath=${_rpath/\$ORIGIN/\$\$ORIGIN}
		_LINK_RPATH_FLAGS="-Wl,-rpath='"$_rpath"'"
		# relative to root folder
		_rpath='$ORIGIN/'$p
		_rpath=${_rpath/\$ORIGIN/\$\$ORIGIN}
		_LINK_RPATH_FLAGS="$_LINK_RPATH_FLAGS -Wl,-rpath='"$_rpath"'"
	fi
	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		# NOTE : if we use ' or " around $r, it will be used as rpath value
		_LINK_RPATH_FLAGS="-Wl,-rpath,@loader_path/$p -Wl,-rpath,@loader_path/../$p"
	fi

	eval "$_var_flags"_LINK_RPATH_FLAGS=\"$_LINK_RPATH_FLAGS\"
}




# ENV and FLAGS management---------------------------------------------------------------------------------------------------------------------------------------

function __reset_build_env() {
	# BUILD FLAGS
	STELLA_C_CXX_FLAGS=
	STELLA_CPP_FLAGS=
	STELLA_DYNAMIC_LINK_FLAGS=
	STELLA_STATIC_LINK_FLAGS=
	STELLA_LINK_FLAGS=
	STELLA_CMAKE_EXTRA_FLAGS=
	STELLA_CMAKE_RPATH_BUILD_PHASE=
	STELLA_CMAKE_RPATH_INSTALL_PHASE=
	STELLA_CMAKE_RPATH=
	STELLA_CMAKE_RPATH_DARWIN=

	# LINKED LIBRARIES
	LINKED_LIBS_LIST=
	LINKED_LIBS_C_CXX_FLAGS=
	LINKED_LIBS_CPP_FLAGS=
	LINKED_LIBS_LINK_FLAGS=
	#LINKED_LIBS_PATH=
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
	# NOTE : STELLA_BUILD_DARWIN_STDLIB_DEFAULT is never initialized by a set_build_mode_default call
	STELLA_BUILD_DARWIN_STDLIB="$STELLA_BUILD_DARWIN_STDLIB_DEFAULT"
	STELLA_BUILD_MACOSX_DEPLOYMENT_TARGET="$STELLA_BUILD_MACOSX_DEPLOYMENT_TARGET_DEFAULT"
	STELLA_BUILD_MIX_CPP_C_FLAGS="$STELLA_BUILD_MIX_CPP_C_FLAGS_DEFAULT"
	STELLA_BUILD_LINK_FLAGS_DEFAULT="$STELLA_BUILD_LINK_FLAGS_DEFAULT_DEFAULT"

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


	# TOOLSET
	STELLA_BUILD_TOOLSET=
	STELLA_BUILD_CONFIG_TOOL=
	STELLA_BUILD_BUILD_TOOL=
	STELLA_BUILD_COMPIL_FRONTEND=
}



function __prepare_build() {
	local INSTALL_DIR="$1"
	local SOURCE_DIR="$2"
	local BUILD_DIR="$3"



	# set env
	__set_build_env ARCH $STELLA_BUILD_ARCH
	__set_build_env CPU_INSTRUCTION_SCOPE $STELLA_BUILD_CPU_INSTRUCTION_SCOPE
	__set_build_env OPTIMIZATION $STELLA_BUILD_OPTIMIZATION
	__set_build_env MACOSX_DEPLOYMENT_TARGET $STELLA_BUILD_MACOSX_DEPLOYMENT_TARGET
	__set_build_env DARWIN_STDLIB $STELLA_BUILD_DARWIN_STDLIB
	__set_build_env LINK_FLAGS_DEFAULT $STELLA_BUILD_LINK_FLAGS_DEFAULT

	[ "$STELLA_CURRENT_PLATFORM" == "linux" ] && __set_build_env RUNPATH_OVER_RPATH

	# trim list
	STELLA_BUILD_RPATH="$(__trim $STELLA_BUILD_RPATH)"
	STELLA_C_CXX_FLAGS="$(__trim $STELLA_C_CXX_FLAGS)"
	STELLA_CPP_FLAGS="$(__trim $STELLA_CPP_FLAGS)"
	STELLA_LINK_FLAGS="$(__trim $STELLA_LINK_FLAGS)"

	# set flags -------------
	case $STELLA_BUILD_CONFIG_TOOL in
		cmake)
			__set_env_vars_for_cmake
		;;
		configure)
			[ "$STELLA_BUILD_COMPIL_FRONTEND" == "gcc-clang" ] && __set_env_vars_for_gcc-clang
		;;
		*)
			[ "$STELLA_BUILD_COMPIL_FRONTEND" == "gcc-clang" ] && __set_env_vars_for_gcc-clang
		;;

	esac


	# print info ----------
	echo "** BUILD TOOLSET"
	echo "====> Configuration Tool : $STELLA_BUILD_CONFIG_TOOL"
	echo "====> Build management Tool : $STELLA_BUILD_BUILD_TOOL"
	echo "====> Compiler Frontend : $STELLA_BUILD_COMPIL_FRONTEND"
	echo "** BUILD INFO"
	echo "====> Build arch directive : $STELLA_BUILD_ARCH"
	echo "====> Parallelized (if supported) : $STELLA_BUILD_PARALLELIZE"
	echo "====> Relocatable : $STELLA_BUILD_RELOCATE"
	echo "====> Linked lib from stella features : $LINKED_LIBS_LIST"
	echo "** FOLDERS"
	echo "====> Install directory : $INSTALL_DIR"
	echo "====> Source directory : $SOURCE_DIR"
	echo "====> Build directory : $BUILD_DIR"
	echo "** SOME FLAGS"
	echo "====> STELLA_C_CXX_FLAGS : $STELLA_C_CXX_FLAGS"
	echo "====> STELLA_CPP_FLAGS : $STELLA_CPP_FLAGS"
	echo "====> STELLA_LINK_FLAGS : $STELLA_LINK_FLAGS"
	echo "====> STELLA_DYNAMIC_LINK_FLAGS : $STELLA_DYNAMIC_LINK_FLAGS"
	echo "====> STELLA_STATIC_LINK_FLAGS : $STELLA_STATIC_LINK_FLAGS"
	echo "====> CMAKE_LIBRARY_PATH : $CMAKE_LIBRARY_PATH"
	echo "====> CMAKE_INCLUDE_PATH : $CMAKE_INCLUDE_PATH"
	echo "====> STELLA_CMAKE_EXTRA_FLAGS : $STELLA_CMAKE_EXTRA_FLAGS"




}

# set flags and env for CMAKE
function __set_env_vars_for_cmake() {

	# RPATH Management
	local _rpath=
	for r in $STELLA_BUILD_RPATH; do
		_rpath="$r;$_rpath"
	done

	if [ "$STELLA_BUILD_RELOCATE" == "ON" ]; then

		# all phase
		[ "$STELLA_CURRENT_PLATFORM" == "darwin" ] && __set_build_env "CMAKE_RPATH" "ALL_PHASE_USE_RPATH_DARWIN"
		__set_build_env "CMAKE_RPATH" "ALL_PHASE_USE_RPATH"

		# cmake build phase
		__set_build_env "CMAKE_RPATH" "BUILD_PHASE_USE_BUILD_FOLDER"

		# cmake install phase
		__set_build_env "CMAKE_RPATH" "INSTALL_PHASE_USE_FINAL_RPATH"

		[ ! "$_rpath" == "" ] && __set_build_env "CMAKE_RPATH" "INSTALL_PHASE_ADD_FINAL_RPATH" "$_rpath"
	else

		if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
			# force install_name with hard path
			__set_build_env "CMAKE_RPATH" "ALL_PHASE_USE_RPATH" # -- we need this for forcing install_name
			__set_build_env "CMAKE_RPATH" "INSTALL_PHASE_USE_FINAL_RPATH" # -- we need this for forcing install_name
			# \${CMAKE_INSTALL_PREFIX}/lib is correct because when building we pass INSTALL_LIB_DIR with /lib
			STELLA_CMAKE_EXTRA_FLAGS="$STELLA_CMAKE_EXTRA_FLAGS -DCMAKE_INSTALL_NAME_DIR=\${CMAKE_INSTALL_PREFIX}/lib"

			[ ! "$_rpath" == "" ] && __set_build_env "CMAKE_RPATH" "INSTALL_PHASE_ADD_FINAL_RPATH" "$_rpath"
		fi
		if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then

			__set_build_env "CMAKE_RPATH" "ALL_PHASE_USE_RPATH"

			# cmake build phase
			__set_build_env "CMAKE_RPATH" "BUILD_PHASE_NO_RPATH"

			# cmake install phase
			__set_build_env "CMAKE_RPATH" "INSTALL_PHASE_USE_FINAL_RPATH"
			# add dependent lib directories to rpath value.
			__set_build_env "CMAKE_RPATH" "INSTALL_PHASE_ADD_DEPENDENT_LIB"
			[ ! "$_rpath" == "" ] && __set_build_env "CMAKE_RPATH" "INSTALL_PHASE_ADD_FINAL_RPATH" "$_rpath"
		fi
	fi



	# CMAKE Flags
	# note :
	#	- these flags have to be passed to the cmake command line, as cmake do not read en var
	#	- list of environment variables read by cmake http://www.cmake.org/Wiki/CMake_Useful_Variables#Environment_Variables
	CMAKE_C_FLAGS="$STELLA_C_CXX_FLAGS"
	CMAKE_CXX_FLAGS="$STELLA_C_CXX_FLAGS"

	# Linker flags to be used to create shared libraries
	CMAKE_SHARED_LINKER_FLAGS="$STELLA_LINK_FLAGS $STELLA_DYNAMIC_LINK_FLAGS"
	# Linker flags to be used to create module
	CMAKE_MODULE_LINKER_FLAGS="$STELLA_LINK_FLAGS $STELLA_DYNAMIC_LINK_FLAGS"
	# Linker flags to be used to create static libraries
	CMAKE_STATIC_LINKER_FLAGS="$STELLA_LINK_FLAGS $STELLA_STATIC_LINK_FLAGS"
	# Linker flags to be used to create executables
	CMAKE_EXE_LINKER_FLAGS="$STELLA_LINK_FLAGS $STELLA_DYNAMIC_LINK_FLAGS"

	# Linked libraries
	LINKED_LIBS_CMAKE_LIBRARY_PATH="$(__trim $LINKED_LIBS_CMAKE_LIBRARY_PATH)"
	LINKED_LIBS_CMAKE_INCLUDE_PATH="$(__trim $LINKED_LIBS_CMAKE_INCLUDE_PATH)"
	export CMAKE_LIBRARY_PATH="$LINKED_LIBS_CMAKE_LIBRARY_PATH"
	export CMAKE_INCLUDE_PATH="$LINKED_LIBS_CMAKE_INCLUDE_PATH"
	# -DCMAKE_MODULE_PATH="$CMAKE_MODULE_PATH"

	# save rpath related flags
	[ "$STELLA_CURRENT_PLATFORM" == "linux" ] && STELLA_CMAKE_EXTRA_FLAGS="$STELLA_CMAKE_EXTRA_FLAGS $STELLA_CMAKE_RPATH $STELLA_CMAKE_RPATH_BUILD_PHASE $STELLA_CMAKE_RPATH_INSTALL_PHASE"
	[ "$STELLA_CURRENT_PLATFORM" == "darwin" ] && STELLA_CMAKE_EXTRA_FLAGS="$STELLA_CMAKE_EXTRA_FLAGS $STELLA_CMAKE_RPATH $STELLA_CMAKE_RPATH_DARWIN $STELLA_CMAKE_RPATH_BUILD_PHASE $STELLA_CMAKE_RPATH_INSTALL_PHASE"

	STELLA_CMAKE_EXTRA_FLAGS="$(__trim $STELLA_CMAKE_EXTRA_FLAGS)"
}


# set flags and env for standard build tools (GNU MAKE,...)
function __set_env_vars_for_gcc-clang() {

	# RPATH Management
	for r in $STELLA_BUILD_RPATH; do

		if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
			# to avoid problem with $$ORIGIN -- only usefull with standard build tools (do not need this with cmake)
			r=${r/\$ORIGIN/\$\$ORIGIN}
			STELLA_LINK_FLAGS="$STELLA_LINK_FLAGS -Wl,-rpath='"$r"'"
		fi
		if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
			# NOTE : if we use ' or " around $r, it will be used as rpath value
			STELLA_LINK_FLAGS="$STELLA_LINK_FLAGS -Wl,-rpath,$r"
		fi
	done


	# ADD linked libraries flags
	LINKED_LIBS_C_CXX_FLAGS="$(__trim $LINKED_LIBS_C_CXX_FLAGS)"
	LINKED_LIBS_CPP_FLAGS="$(__trim $LINKED_LIBS_CPP_FLAGS)"
	LINKED_LIBS_LINK_FLAGS="$(__trim $LINKED_LIBS_LINK_FLAGS)"

	STELLA_C_CXX_FLAGS="$STELLA_C_CXX_FLAGS $LINKED_LIBS_C_CXX_FLAGS"
	STELLA_CPP_FLAGS="$STELLA_CPP_FLAGS $LINKED_LIBS_CPP_FLAGS"
	STELLA_LINK_FLAGS="$LINKED_LIBS_LINK_FLAGS $STELLA_LINK_FLAGS $STELLA_DYNAMIC_LINK_FLAGS $STELLA_STATIC_LINK_FLAGS"


 	if [ "$STELLA_BUILD_MIX_CPP_C_FLAGS" == "ON" ]; then
 		# flags to pass to the C compiler.
		export CFLAGS="$STELLA_C_CXX_FLAGS $STELLA_CPP_FLAGS"
		# flags to pass to the C++ compiler
		export CXXFLAGS="$STELLA_C_CXX_FLAGS $STELLA_CPP_FLAGS"
	else
		export CFLAGS="$STELLA_C_CXX_FLAGS"
		export CXXFLAGS="$STELLA_C_CXX_FLAGS"
	fi
	# flags to pass to the C preprocessor. Used when compiling C and C++ (Used to pass -Iinclude_folder)
	export CPPFLAGS="$STELLA_CPP_FLAGS"
	# flags to pass to the linker
	export LDFLAGS="$STELLA_LINK_FLAGS"
}




function __set_build_mode_default() {
	case $1 in
		RPATH|DEP_FROM_SYSTEM)
			eval STELLA_BUILD_"$1"_DEFAULT=\"$2\" \"$3\"
		;;
		*)
			eval STELLA_BUILD_"$1"_DEFAULT=\"$2\"
		;;
	esac

}

# TOOLSET agnostic
function __set_build_mode() {

	# LINK_FLAGS_DEFAULT -----------------------------------------------------------------
	# activate default link flags
	[ "$1" == "LINK_FLAGS_DEFAULT" ] && STELLA_BUILD_LINK_FLAGS_DEFAULT=$2

	# MIX_CPP_C_FLAGS -----------------------------------------------------------------
	# set CFLAGS and CXXFLAGS with CPPFLAGS
	[ "$1" == "MIX_CPP_C_FLAGS" ] && STELLA_BUILD_MIX_CPP_C_FLAGS=$2

	# STATIC/DYNAMIC LINK -----------------------------------------------------------------
	# force build system to force a linking mode when it is possible
	# STATIC | DYNAMIC | DEFAULT
	[ "$1" == "LINK_MODE" ] && STELLA_BUILD_LINK_MODE=$2

	# CPU_INSTRUCTION_SCOPE -----------------------------------------------------------------
	# http://sdf.org/~riley/blog/2014/10/30/march-mtune/
	# CURRENT | SAME_FAMILY | GENERIC
	[ "$1" == "CPU_INSTRUCTION_SCOPE" ] && STELLA_BUILD_CPU_INSTRUCTION_SCOPE=$2

	# ARCH -----------------------------------------------------------------
	# Setting flags for a specific arch
	[ "$1" == "ARCH" ] && STELLA_BUILD_ARCH=$2

	# BINARIES RELOCATABLE -----------------------------------------------------------------
	# ON | OFF
	#		every dependency will be added to a DT_NEEDED field in elf files
	# 				on linux : DT_NEEDED contain dependency filename only
	# 				on macos : LC_LOAD_DYLIB contain a dependency with using couple of values : @rpath and @loader_path
	#		if OFF : RPATH values will be added for each dependency by absolute path
	#		if ON : RPATH values will contain relative values to a nested lib folder containing dependencies
	[ "$1" == "RELOCATE" ] && STELLA_BUILD_RELOCATE=$2


	# GENERIC RPATH (runtime search path values) -----------------------------------------------------------------
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

# settings compiler flags -- depend on toolset (configure tool, build tool, compiler frontend)
function __set_build_env() {

	# LINK_FLAGS_DEFAULT -----------------------------------------------------------------
	# Activate some default link flags
	# TODO experimental new flags ===> transform into set_build_env
	# https://sourceware.org/binutils/docs/ld/Options.html
	# http://www.kaizou.org/2015/01/linux-libraries/
	if [ "$1" == "LINK_FLAGS_DEFAULT" ]; then
		if [ "$STELLA_BUILD_COMPIL_FRONTEND" == "gcc-clang" ]; then
			if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
				case $2 in
					ON)
						STELLA_LINK_FLAGS="-Wl,--copy-dt-needed-entries -Wl,--as-needed -Wl,--no-allow-shlib-undefined -Wl,--no-undefined $STELLA_LINK_FLAGS"
					;;
				esac
			fi
		fi
	fi

	# CPU_INSTRUCTION_SCOPE -----------------------------------------------------------------
	# http://sdf.org/~riley/blog/2014/10/30/march-mtune/
	if [ "$1" == "CPU_INSTRUCTION_SCOPE" ]; then
		if [ "$STELLA_BUILD_COMPIL_FRONTEND" == "gcc-clang" ]; then
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
	fi

	# set OPTIMIZATION -----------------------------------------------------------------
	if [ "$1" == "OPTIMIZATION" ]; then
		if [ "$STELLA_BUILD_COMPIL_FRONTEND" == "gcc-clang" ]; then
			[ ! "$2" == "" ] && STELLA_C_CXX_FLAGS="$STELLA_C_CXX_FLAGS -O$2"
		fi
	fi

	# ARCH -----------------------------------------------------------------
	# Setting flags for a specific arch
	if [ "$1" == "ARCH" ]; then
		if [ "$STELLA_BUILD_COMPIL_FRONTEND" == "gcc-clang" ]; then
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
	fi

	# fPIC is usefull when building shared libraries for x64
	# not for x86 : http://stackoverflow.com/questions/7216244/why-is-fpic-absolutely-necessary-on-64-and-not-on-32bit-platforms -- http://stackoverflow.com/questions/6961832/does-32bit-x86-code-need-to-be-specially-pic-compiled-for-shared-library-files
	# On MacOS it is active by default
	if [ "$1" == "ARCH" ]; then
		if [ "$STELLA_BUILD_COMPIL_FRONTEND" == "gcc-clang" ]; then
			if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
				case $2 in
					x64)
						STELLA_C_CXX_FLAGS="-fPIC $STELLA_C_CXX_FLAGS"
						;;
				esac
			fi
		fi
	fi

	# MACOSX_DEPLOYMENT_TARGET -----------------------------------------------------------------
	if [ "$1" == "MACOSX_DEPLOYMENT_TARGET" ]; then
		if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
			if [ ! "$2" == "" ]; then
				export MACOSX_DEPLOYMENT_TARGET=$2
				STELLA_CMAKE_EXTRA_FLAGS="$STELLA_CMAKE_EXTRA_FLAGS -DCMAKE_OSX_DEPLOYMENT_TARGET=$2"
				STELLA_C_CXX_FLAGS="$STELLA_C_CXX_FLAGS -mmacosx-version-min=$2"
			fi
		fi
	fi


	# DARWIN STDLIB -----------------------------------------------------------------
	# http://stackoverflow.com/a/19637199
	# On 10.8 and earlier libstdc++ is chosen by default, on version >= 10.9 libc++ is chosen by default.
	# by default -mmacosx-version-min value is used to choose one of them
	if [ "$1" == "DARWIN_STDLIB" ]; then
		if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
			# we seems to need this on both cflags and ldflags (i.e for openttd)
			[ "$2" == "LIBCPP" ] && STELLA_LINK_FLAGS="$STELLA_LINK_FLAGS -stdlib=libc++"
			[ "$2" == "LIBSTDCPP" ] && STELLA_LINK_FLAGS="$STELLA_LINK_FLAGS -stdlib=libstdc++"
			[ "$2" == "LIBCPP" ] && STELLA_C_CXX_FLAGS="$STELLA_C_CXX_FLAGS -stdlib=libc++"
			[ "$2" == "LIBSTDCPP" ] && STELLA_C_CXX_FLAGS="$STELLA_C_CXX_FLAGS -stdlib=libstdc++"
		fi
	fi


	# RUNPATH/RPATH
	# prefer setting RUNPATH over setting RPATH
	# enable-new-dtags : http://blog.tremily.us/posts/rpath/
	if [ "$1" == "RUNPATH_OVER_RPATH" ]; then
		if [ "$STELLA_BUILD_COMPIL_FRONTEND" == "gcc-clang" ]; then
			if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
				STELLA_DYNAMIC_LINK_FLAGS="$STELLA_DYNAMIC_LINK_FLAGS -Wl,--enable-new-dtags"
			fi
		fi
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


# INSPECT CHECK and FIX BUILT FILES ------------------------------------------------------------------------------------------------------------------------------
# inspect and fix files built by stella
function __inspect_and_fix_build() {
	local path="$1"
	local OPT="$2"
	local _result=0

	# INCLUDE_LINKED_LIB <expr> -- include these linked libs
	# EXCLUDE_LINKED_LIB <expr> -- exclude these linked libs
	# INCLUDE_LINKED_LIB is apply first, before EXCLUDE_LINKED_LIB
	# INCLUDE_FILTER <expr> -- include these files
	# EXCLUDE_FILTER <expr> -- exclude these files
	# INCLUDE_FILTER is apply first, before EXCLUDE_FILTER

	[ "$1" == "" ] && return

	[ -z "$(__filter_list "$path" "INCLUDE_TAG INCLUDE_FILTER EXCLUDE_TAG EXCLUDE_FILTER $OPT")" ] && return $_result


	local f=
	if [ -d "$path" ]; then
		for f in  "$path"/*; do
			__inspect_and_fix_build "$f" "$OPT"
		done
	fi

	if [ -f "$path" ]; then
		# fixing built files
		__fix_built_files "$path" "$OPT"
		# checking built files
		__check_built_files "$path" "$OPT" || _result=1
	fi

	return $_result
}

function __fix_built_files() {
	local path="$1"
	local OPT="$2"
	if [ "$STELLA_BUILD_RELOCATE" == "ON" ]; then
		__tweak_binary_file "$path" "$OPT RELOCATE WANTED_RPATH $STELLA_BUILD_RPATH"
	fi
	if [ "$STELLA_BUILD_RELOCATE" == "OFF" ]; then
		# TODO NON_RELOCATE will change binary, maybe we dont want that...
		#__tweak_binary_file "$path" "$OPT NON_RELOCATE WANTED_RPATH $STELLA_BUILD_RPATH"
		__tweak_binary_file "$path" "$OPT WANTED_RPATH $STELLA_BUILD_RPATH"
	fi
}

function __check_built_files() {
	local path="$1"
	local OPT="$2"
	local _result=0
	local _check_arch=
	[ ! "$STELLA_BUILD_ARCH" == "" ] && _check_arch="ARCH $STELLA_BUILD_ARCH"
	if [ "$STELLA_BUILD_RELOCATE" == "ON" ]; then
		__check_binary_file "$path" "$OPT RELOCATE $_check_arch WANTED_RPATH $STELLA_BUILD_RPATH" || _result=1
	fi
	if [ "$STELLA_BUILD_RELOCATE" == "OFF" ]; then
		# if we are in export mode or in default mode, linked libs should be relocatable
		__check_binary_file "$path" "$OPT NON_RELOCATE $_check_arch WANTED_RPATH $STELLA_BUILD_RPATH" || _result=1
	fi

	return $_result
}


fi
