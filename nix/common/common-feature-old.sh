if [ ! "$_STELLA_COMMON_FEATURE_OLD_INCLUDED_" == "1" ]; then 
_STELLA_COMMON_FEATURE_OLD_INCLUDED_=1


# --------------- FEATURES MANAGEMENT ----------------------------

# feature schema name[#version][@arch][/flavour][:os_restriction] in any order
#				@arch could be x86 or x64
#				/flavour could be binary or source
# example: wget:ubuntu#1_2@x86/source
function __translate_feature() {
	local _schema=$1

	local _VAR_FEATURE_NAME=$2
	local _VAR_FEATURE_VER=$3
	local _VAR_FEATURE_ARCH=$4
	local _VAR_FEATURE_FLAVOUR=$5
	local _VAR_FEATURE_OS_RESTRICTION=$6

	[ ! "$_VAR_FEATURE_NAME" == "" ] && unset -v $_VAR_FEATURE_NAME
	[ ! "$_VAR_FEATURE_VER" == "" ] && unset -v $_VAR_FEATURE_VER
	[ ! "$_VAR_FEATURE_ARCH" == "" ] && unset -v $_VAR_FEATURE_ARCH
	[ ! "$_VAR_FEATURE_FLAVOUR" == "" ] && unset -v $_VAR_FEATURE_FLAVOUR
	[ ! "$_VAR_FEATURE_OS_RESTRICTION" == "" ] && unset -v $_VAR_FEATURE_OS_RESTRICTION

	local _char=


	_char=":"
	if [ -z "${_schema##*$_char*}" ]; then
		[ ! "$_VAR_FEATURE_OS_RESTRICTION" == "" ] && eval $_VAR_FEATURE_OS_RESTRICTION=$(echo $_schema | cut -d':' -f 2 | cut -d'#' -f 1 | cut -d'@' -f 1 | cut -d'/' -f 1)
	fi

	_char="#"
	if [ -z "${_schema##*$_char*}" ]; then
		[ ! "$_VAR_FEATURE_VER" == "" ] && eval $_VAR_FEATURE_VER=$(echo $_schema | cut -d'#' -f 2 | cut -d':' -f 1 | cut -d'@' -f 1 | cut -d'/' -f 1)
	fi

	_char="@"
	if [ -z "${_schema##*$_char*}" ]; then
		[ ! "$_VAR_FEATURE_ARCH" == "" ] && eval $_VAR_FEATURE_ARCH=$(echo $_schema | cut -d'@' -f 2 | cut -d':' -f 1 | cut -d'#' -f 1 | cut -d'/' -f 1)
	fi

	_char="/"
	if [ -z "${_schema##*$_char*}" ]; then
		[ ! "$_VAR_FEATURE_FLAVOUR" == "" ] && eval $_VAR_FEATURE_FLAVOUR=$(echo $_schema | cut -d'/' -f 2 | cut -d':' -f 1 | cut -d'#' -f 1 | cut -d'@' -f 1)
	fi

	[ ! "$_VAR_FEATURE_NAME" == "" ] && eval $_VAR_FEATURE_NAME=$(echo $_schema | cut -d'/' -f 1 | cut -d':' -f 1 | cut -d'#' -f 1 | cut -d'@' -f 1)
}


function __list_active_features() {
	echo "$FEATURE_LIST_ENABLED"
}

function __info_feature() {
	local _SCHEMA=$1	
	__translate_feature $_SCHEMA "TR_FEATURE_NAME"

	source $STELLA_FEATURE_RECIPE/feature_$TR_FEATURE_NAME.sh
	
	TEST_FEATURE=0
	__feature_$TR_FEATURE_NAME $_SCHEMA
}


function __list_feature_version() {
	local _SCHEMA=$1
	__translate_feature $_SCHEMA "TR_FEATURE_NAME"
	
	source $STELLA_FEATURE_RECIPE/feature_$TR_FEATURE_NAME.sh
	echo $(__list_"$TR_FEATURE_NAME")
}

function __init_feature() {
	local _SCHEMA=$1
	local _OPT="$2"

	local _opt_hidden_feature=OFF
	local o
	for o in $_OPT; do 
		[ "$o" == "HIDDEN" ] && _opt_hidden_feature=ON
	done

	__translate_feature $_SCHEMA "TR_FEATURE_NAME" "TR_FEATURE_VER"
	

	source $STELLA_FEATURE_RECIPE/feature_$TR_FEATURE_NAME.sh
	_VER=$TR_FEATURE_VER
	if [ "$_VER" == "" ]; then
		_VER="$(__default_$TR_FEATURE_NAME)"
	fi

	_flag=0
	local a
	for a in $FEATURE_LIST_ENABLED; do
		[ "$TR_FEATURE_NAME#$_VER" == "$a" ] && _flag=1
	done
	if [ "$_flag" == "0" ]; then
		TEST_FEATURE=0
		__feature_$TR_FEATURE_NAME $_SCHEMA
		if [ "$TEST_FEATURE" == "1" ]; then
			if [ ! "$_opt_hidden_feature" == "ON" ]; then
				FEATURE_LIST_ENABLED="$FEATURE_LIST_ENABLED $TR_FEATURE_NAME#$FEATURE_VER"
			fi
			if [ ! "$FEATURE_PATH" == "" ]; then
				PATH="$FEATURE_PATH:$PATH"
			fi
		fi
	fi
}


function __init_installed_features() {
	local _flag=
	
	# init internal features
	# internal feature are not prioritary over app features
	if [ ! "$STELLA_APP_FEATURE_ROOT" == "$STELLA_INTERNAL_FEATURE_ROOT" ]; then
		
		_save_app_feature_root=$STELLA_APP_FEATURE_ROOT
		STELLA_APP_FEATURE_ROOT=$STELLA_INTERNAL_FEATURE_ROOT
		local f
		local a
		local v

		for f in  "$STELLA_INTERNAL_FEATURE_ROOT"/*; do
			if [ -d "$f" ]; then
				_flag=0
				# check for official feature
				for a in $__STELLA_FEATURE_LIST; do
					if [ "$a" == "$(__get_filename_from_string $f)" ]; then
						# for each detected version
						for v in  "$f"/*; do
							[ -d "$v" ] && __init_feature "$(__get_filename_from_string $f)#$(__get_filename_from_string $v)" "HIDDEN"
						done
					fi
				done
			fi
		done
		STELLA_APP_FEATURE_ROOT=$_save_app_feature_root
	fi

	for f in  "$STELLA_APP_FEATURE_ROOT"/*; do
		if [ -d "$f" ]; then
			_flag=0
			# check for official feature
			for a in $__STELLA_FEATURE_LIST; do
				if [ "$a" == "$(__get_filename_from_string $f)" ]; then
					# for each detected version
					for v in  "$f"/*; do
						[ -d "$v" ] && __init_feature "$(__get_filename_from_string $f)#$(__get_filename_from_string $v)"
					done
				fi
			done
		fi
	done


	[ ! "$FEATURE_LIST_ENABLED" == "" ] && echo "** Features initialized : $FEATURE_LIST_ENABLED"
}


function __install_feature_list() {
	local _list=$1
	local f

	for f in $_list; do
		__install_feature $f
	done
}



function __install_feature() {
	local _SCHEMA=$1
	local _OPT="$2"

	local o
	local _opt_hidden_feature=OFF
	for o in $_OPT; do 
		[ "$o" == "HIDDEN" ] && _opt_hidden_feature=ON
	done

	__translate_feature $_SCHEMA "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION"
	
	local _save_app_feature_root=

	if [ "$TR_FEATURE_NAME" == "required" ]; then
		__stella_features_requirement_by_os $STELLA_CURRENT_OS
	else

		local _flag=0
		local a
		# check for official feature
		for a in $__STELLA_FEATURE_LIST; do
			[ "$a" == "$TR_FEATURE_NAME" ] && _flag=1
		done

		if [ "$_flag" == "1" ]; then
			if [ ! "$_opt_hidden_feature" == "ON" ]; then
				__add_app_feature $_SCHEMA
			fi

			if [ ! "$TR_FEATURE_OS_RESTRICTION" == "" ]; then
				if [ ! "$TR_FEATURE_OS_RESTRICTION" == "$STELLA_CURRENT_OS" ]; then
					return
				fi
			fi

			if [ "$_opt_hidden_feature" == "ON" ]; then
				_save_app_feature_root=$STELLA_APP_FEATURE_ROOT
				STELLA_APP_FEATURE_ROOT=$STELLA_INTERNAL_FEATURE_ROOT
			fi

			source $STELLA_FEATURE_RECIPE/feature_$TR_FEATURE_NAME.sh

			_VER=$TR_FEATURE_VER
			if [ "$_VER" == "" ]; then
				_VER="$(__default_$TR_FEATURE_NAME)"
			fi

			_flag=0
			if [ ! "$FORCE" == "1" ]; then
				for a in $FEATURE_LIST_ENABLED; do 
					[ "$TR_FEATURE_NAME#$_VER" == "$a" ] && _flag=1
				done
			fi

			if [ "$_flag" == "0" ]; then
				TEST_FEATURE=0
				__install_"$TR_FEATURE_NAME" "$_SCHEMA"
				__init_feature "$_SCHEMA" $_OPT
			else
				echo "** Feature $_SCHEMA already installed"
				__init_feature "$_SCHEMA" $_OPT
			fi

			if [ "$_opt_hidden_feature" == "ON" ]; then
				STELLA_APP_FEATURE_ROOT=$_save_app_feature_root
			fi
		else
			echo " ** WARN : Unknow feature $_SCHEMA"
		fi
	fi
}

function __reinit_installed_features() {
	FEATURE_LIST_ENABLED=
	__init_installed_features
}



#-----------------------------------------
# COMMON FUNCTIONS USED IN RECIPE

function __select_feature() {
	local _SCHEMA=$1
	local _VAR_FULL_FEATURE=$2
	local _VAR_FEATURE_CALLBACK=$3
	local _VAR_FEATURE_FLAVOUR=$4

	local _FEATURE_CALLBACK=
	local _FEATURE_ID=



	[ ! "$_VAR_FULL_FEATURE" == "" ] && unset -v $_VAR_FULL_FEATURE
	[ ! "$_VAR_FEATURE_CALLBACK" == "" ] && unset -v $_VAR_FEATURE_CALLBACK
	[ ! "$_VAR_FEATURE_FLAVOUR" == "" ] && unset -v $_VAR_FEATURE_FLAVOUR


	__translate_feature "$_SCHEMA" "_TR_FEATURE_NAME" "_TR_FEATURE_VER" "_TR_FEATURE_ARCH" "_TR_FEATURE_FLAVOUR"



	[ "$_TR_FEATURE_VER" == "" ] && _TR_FEATURE_VER=$(__default_$_TR_FEATURE_NAME)
	[ "$_TR_FEATURE_ARCH" == "" ] && _TR_FEATURE_ARCH=$(__default_"$_TR_FEATURE_NAME"_arch)
	[ "$_TR_FEATURE_FLAVOUR" == "" ] && _TR_FEATURE_FLAVOUR=$(__default_"$_TR_FEATURE_NAME"_flavour)


	_FEATURE_ID="$_TR_FEATURE_NAME"#"$_TR_FEATURE_VER"
	[ ! "$_TR_FEATURE_ARCH" == "" ] && _FEATURE_ID="$_FEATURE_ID"@"$_TR_FEATURE_ARCH"
	[ ! "$_TR_FEATURE_FLAVOUR" == "" ] && _FEATURE_ID="$_FEATURE_ID"/"$_TR_FEATURE_FLAVOUR"
	
	_FEATURE_CALLBACK=__"$_TR_FEATURE_NAME"_"$_TR_FEATURE_VER"
	[ ! "$_TR_FEATURE_ARCH" == "" ] && _FEATURE_CALLBACK="$_FEATURE_CALLBACK"_"$_TR_FEATURE_ARCH"
	
	local _flag=0
	local l
	for l in $(__list_$_TR_FEATURE_NAME); do
		if [ "$_TR_FEATURE_NAME"#"$l" == "$_FEATURE_ID" ]; then
			[ ! "$_VAR_FULL_FEATURE" == "" ] && eval $_VAR_FULL_FEATURE=$_FEATURE_ID
			[ ! "$_VAR_FEATURE_CALLBACK" == "" ] && eval $_VAR_FEATURE_CALLBACK=$_FEATURE_CALLBACK
			[ ! "$_VAR_FEATURE_FLAVOUR" == "" ] && eval $_VAR_FEATURE_FLAVOUR=$_TR_FEATURE_FLAVOUR
		fi
	done


}


function __init_recipe() {
	FEATURE_RESULT_NAME=
	FEATURE_RESULT_VER=
	FEATURE_RESULT_ARCH=

	FEATURE_RESULT_ROOT=
	FEATURE_TEST=
	FEATURE_RESULT_PATH=

	TEST_FEATURE=0

	FEATURE_NAME=
	FEATURE_VER=
	FEATURE_ARCH=
	FEATURE_PATH=
	FEATURE_ROOT=
}



function __install_internal() {
	local _SCHEMA=$1

	local _callback=
	local _feature_id=
	local _flavour=
	__select_feature $_SCHEMA "_feature_id" "_callback" "_flavour"

	"$_callback"_info

	if [ ! "$_feature_id" == "" ]; then
		
		if [ "$FORCE" ]; then
			TEST_FEATURE=0
			__del_folder $FEATURE_RESULT_ROOT
		else
			__feature_test "$_callback"
		fi

		if [ "$TEST_FEATURE" == "0" ]; then
			mkdir -p $FEATURE_RESULT_ROOT
			[ "$_flavour" == "" ] && __"$FEATURE_RESULT_NAME"_install "$_callback" || __"$FEATURE_RESULT_NAME"_install_$_flavour "$_callback"
		else
			echo " ** Already installed"
		fi

	else
		echo " ** WARN : not found any matching and available feature version $_SCHEMA"
	fi
	
	
}


function __feature_bundle_internal() {
	local _SCHEMA=$1

	local _bundle_callback=
	local _bundle_feature_id=
	local _bundle_flavour=

	__select_feature $_SCHEMA "_bundle_feature_id" "_bundle_callback" "_bundle_flavour"

	"$_bundle_callback"_info

	local BUNDLE_TEST_FEATURE=1
	local l
	for l in $(__bundle_"$FEATURE_RESULT_NAME"_"$FEATURE_RESULT_VER"_"$_bundle_flavour"); do
		__feature_internal $l
		[ "$TEST_FEATURE" == "0" ] && BUNDLE_TEST_FEATURE=0
	done

	"$_bundle_callback"_info

	if [ "$BUNDLE_TEST_FEATURE" == "1" ]; then
		TEST_FEATURE=1
		[ "$VERBOSE_MODE" == "0" ] || echo " ** FEATURE Detected : $FEATURE_RESULT_NAME in $FEATURE_RESULT_ROOT"		
		FEATURE_NAME="$FEATURE_RESULT_NAME"
		FEATURE_VER="$FEATURE_RESULT_VER"
		FEATURE_ARCH="$FEATURE_RESULT_ARCH"
		FEATURE_PATH="$FEATURE_RESULT_PATH"
		FEATURE_ROOT="$FEATURE_RESULT_ROOT"
	fi

}

function __feature_internal() {
	local _SCHEMA="$1"

	local _callback=
	local _feature_id=
	local _flavour=

	__select_feature "$_SCHEMA" "_feature_id" "_callback" "_flavour"

	if [ ! "$_feature_id" == "" ]; then
		__feature_test "$_callback"
	else
		echo " ** WARN : unknow version"
	fi
}

function __feature_test() {
	local _callback=$1
	"$_callback"_info

	TEST_FEATURE=0

	if [ -f "$FEATURE_TEST" ]; then
		TEST_FEATURE=1
		[ "$VERBOSE_MODE" == "0" ] || echo " ** FEATURE Detected : $FEATURE_RESULT_NAME in $FEATURE_RESULT_ROOT"		
		FEATURE_NAME="$FEATURE_RESULT_NAME"
		FEATURE_VER="$FEATURE_RESULT_VER"
		FEATURE_ARCH="$FEATURE_RESULT_ARCH"
		FEATURE_PATH="$FEATURE_RESULT_PATH"
		FEATURE_ROOT="$FEATURE_RESULT_ROOT"
	fi
}








fi
