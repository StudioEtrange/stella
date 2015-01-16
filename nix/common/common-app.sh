if [ ! "$_STELLA_COMMON_APP_INCLUDED_" == "1" ]; then 
_STELLA_COMMON_APP_INCLUDED_=1




# APP RESSOURCES & ENV MANAGEMENT ---------------


# ARG 1 optional : specify an app path
# return properties file path
function __select_app() {
	local _app_path=$1

	local _properties_file=

	if [ "$_app_path" == "" ]; then
		_app_path=$_STELLA_CURRENT_RUNNING_DIR
	fi

	if [ -f "$_app_path/$STELLA_APP_PROPERTIES_FILENAME" ]; then
		_properties_file="$_app_path/$STELLA_APP_PROPERTIES_FILENAME"
		STELLA_APP_ROOT=$_app_path
	fi
	
	echo "$_properties_file"

}


function __create_app_samples() {
	local _approot=$1

	cp -f "$STELLA_POOL/sample-app.sh" "$_approot/sample-app.sh"
	chmod +x $_approot/sample-app.sh

	cp -f "$STELLA_POOL/sample-stella.properties" "$_approot/sample-stella.properties"
}

function __init_app() {
	local _app_name=$1
	local _approot=$2
	local _workroot=$3
	local _cachedir=$4

	if [ "$(__is_abs "$_approot")" == "FALSE" ]; then
		mkdir -p $_STELLA_CURRENT_RUNNING_DIR/$_approot
		_approot=$(__rel_to_abs_path "$_approot" "$_STELLA_CURRENT_RUNNING_DIR")
	else
		mkdir -p $_approot
	fi

	_stella_root=$(__abs_to_rel_path "$STELLA_ROOT" "$_approot")

	echo "_STELLA_LINK_CURRENT_FILE_DIR=\"\$( cd \"\$( dirname \"\${BASH_SOURCE[0]}\" )\" && pwd )\"" >$_approot/.stella-link.sh
	echo "STELLA_ROOT=\$_STELLA_LINK_CURRENT_FILE_DIR/$_stella_root" >>$_approot/.stella-link.sh
	# echo "STELLA_ROOT=$_stella_root" >$_approot/.stella-link.sh

	cp -f "$STELLA_POOL/stella-bridge.sh" "$_approot/stella-bridge.sh"
	chmod +x $_approot/stella-bridge.sh

	_STELLA_APP_PROPERTIES_FILE="$_approot/$STELLA_APP_PROPERTIES_FILENAME"
	if [ -f "$_STELLA_APP_PROPERTIES_FILE" ]; then
		echo " ** Properties file already exist"
	else
		__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_NAME" "$_app_name"
		__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_WORK_ROOT" "$_workroot"
		__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_CACHE_DIR" "$_cachedir"
		__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "DATA_LIST"
		__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "ASSETS_LIST"
		__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "ENV_LIST"
		__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "INFRA_LIST"
		__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_FEATURE_LIST"
	fi
}

# extract APP properties
function __get_all_properties() {
	local _properties_file=$1

	if [ -f "$_properties_file" ]; then

		# STELLA VARs
		__get_key "$_properties_file" "STELLA" "APP_NAME" "PREFIX"
		__get_key "$_properties_file" "STELLA" "APP_WORK_ROOT" "PREFIX"
		__get_key "$_properties_file" "STELLA" "APP_CACHE_DIR" "PREFIX"
		__get_key "$_properties_file" "STELLA" "DATA_LIST" "PREFIX"
		__get_key "$_properties_file" "STELLA" "ASSETS_LIST" "PREFIX"
		__get_key "$_properties_file" "STELLA" "ENV_LIST" "PREFIX"
		__get_key "$_properties_file" "STELLA" "INFRA_LIST" "PREFIX"
		__get_key "$_properties_file" "STELLA" "APP_FEATURE_LIST" "PREFIX"

		__get_data_properties "$_properties_file" "$STELLA_DATA_LIST"
		__get_assets_properties "$_properties_file" "$STELLA_ASSETS_LIST"
		__get_infra_properties "$_properties_file" "$STELLA_INFRA_LIST"
		__get_env_properties "$_properties_file" "$STELLA_ENV_LIST"
	fi
}

function __get_data_properties() {
		local _properties_file=$1
		local _list=$2

		if [ -f "$_properties_file" ]; then

			# DATA
			for a in $_list; do
				__get_key "$_properties_file" "$a" DATA_NAMESPACE "PREFIX"
				__get_key "$_properties_file" "$a" DATA_ROOT "PREFIX"
				__get_key "$_properties_file" "$a" DATA_OPTIONS "PREFIX"
				__get_key "$_properties_file" "$a" DATA_NAME "PREFIX"
				__get_key "$_properties_file" "$a" DATA_URI "PREFIX"
				__get_key "$_properties_file" "$a" DATA_GET_PROTOCOL "PREFIX"
			done
		fi
}

function __get_assets_properties() {
	local _properties_file=$1
	local _list=$2

	if [ -f "$_properties_file" ]; then

		# ASSETS
		for a in $_list; do
			__get_key "$_properties_file" "$a" ASSETS_MAIN_PACKAGE "PREFIX"
			__get_key "$_properties_file" "$a" ASSETS_OPTIONS "PREFIX"
			__get_key "$_properties_file" "$a" ASSETS_NAME "PREFIX"
			__get_key "$_properties_file" "$a" ASSETS_URI "PREFIX"
			__get_key "$_properties_file" "$a" ASSETS_GET_PROTOCOL "PREFIX"
		done
	fi
}

function __get_infra_properties() {
	local _properties_file=$1
	local _list=$2

	if [ -f "$_properties_file" ]; then

		# INFRA
		for a in $_list; do
			__get_key "$_properties_file" "$a" INFRA_NAME "PREFIX"
			__get_key "$_properties_file" "$a" INFRA_DISTRIB "PREFIX"
			__get_key "$_properties_file" "$a" INFRA_CPU "PREFIX"
			__get_key "$_properties_file" "$a" INFRA_MEM "PREFIX"
		done
	fi
}

# NOTE : call __get_infra_properties first
function __get_env_properties() {
	local _properties_file=$1
	local _list=$2

	if [ -f "$_properties_file" ]; then
		# ENV
		for a in $_list; do
			__get_key "$_properties_file" "$a" ENV_NAME "PREFIX"
			__get_key "$_properties_file" "$a" INFRA_ID "PREFIX"
		done

		# INFRA-ENV
		for a in $_list; do
			_artefact_infra_id="$a"_INFRA_ID
			_artefact_infra_id=${!_artefact_infra_id}
			# eval "$a"_INFRA_ID=$_artefact_infra_id
			if [ "$_artefact_infra_id" == "current" ]; then
				eval "$a"_OS=\$STELLA_CURRENT_OS
				eval "$a"_PLATFORM=\$STELLA_CURRENT_PLATFORM
				eval "$a"_PLATFORM_SUFFIX=\$STELLA_CURRENT_PLATFORM_SUFFIX
			else
				_artefact_distrib="$_artefact_infra_id"_INFRA_DISTRIB
				eval "$a"_DISTRIB=${!_artefact_distrib}
				eval "$a"_OS='$(__get_os_from_distro ${!_artefact_distrib})'
				eval "$a"_PLATFORM='$(__get_platform_from_os ${!_artefact_os})'
				_artefact_platform="$a"_PLATFORM
				eval "$a"_PLATFORM_SUFFIX='$(__get_platform_suffix ${!_artefact_platform})'
				_artefact_cpu="$_artefact_infra_id"_INFRA_CPU
				eval "$a"_CPU=${!_artefact_cpu}
				_artefact_mem="$_artefact_infra_id"_INFRA_MEM
				eval "$a"_MEM=${!_artefact_mem}
			fi
		done
	fi
}



function __add_app_feature() {
	if [ -f "$_STELLA_APP_PROPERTIES_FILE" ]; then
		__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_FEATURE_LIST" "$(echo $FEATURE_LIST_ENABLED | sed -e 's/^ *//' -e 's/ *$//')"
	fi
}

function __get_features() {
	__install_feature_list "$STELLA_APP_FEATURE_LIST"
}

function __get_data() {
	local _list_id=$1
	
	__get_app_ressources "DATA" "GET" "$_list_id"

}

function __get_assets() {
	local _list_id=$1
	
	mkdir -p "$ASSETS_ROOT"
	mkdir -p "$ASSETS_REPOSITORY"
	
	__get_app_ressources "ASSETS" "GET" "$_list_id"
}

function __update_data() {
	local _list_id=$1
	
	__get_app_ressources "DATA" "UPDATE" "$_list_id"

}

function __update_assets() {
	local _list_id=$1
	
	__get_app_ressources "ASSETS" "UPDATE" "$_list_id"
}

function __revert_data() {
	local _list_id=$1
	
	__get_app_ressources "DATA" "REVERT" "$_list_id"

}

function __revert_assets() {
	local _list_id=$1
	
	__get_app_ressources "ASSETS" "REVERT" "$_list_id"
}

function __get_all_data() {
	__get_data $STELLA_DATA_LIST
}

function __get_all_assets() {
	__get_assets $STELLA_ASSETS_LIST
}

# ARG1 ressource mode is DATA or ASSET
# ARG2 operation is GET or UPDATE or REVERT (UPDATE or REVERT if applicable)
# ARG3 list of ressource ID
function __get_app_ressources() {
	local _mode=$1
	local _operation=$2
	local _list_id=$3

	for a in $_list_id; do
		_artefact_namespace="$a"_"$_mode"_NAMESPACE
		_artefact_namespace=${!_artefact_namespace}
		
		_artefact_link=0
		if [ "$_mode" == "DATA" ]; then
			_artefact_root="$a"_"$_mode"_ROOT
			_artefact_root=${!_artefact_root}
			_artefact_dest=$(__rel_to_abs_path "$_artefact_root" "$STELLA_APP_WORK_ROOT")
			_artefact_link=0; 
		fi
		if [ "$_mode" == "ASSETS" ]; then _artefact_dest="$ASSETS_REPOSITORY"; _artefact_link=1; _artefact_link_target="$ASSETS_ROOT"; fi
		

		_opt="$a"_"$_mode"_OPTIONS
		_opt=${!_opt}
		_uri="$a"_"$_mode"_URI
		_uri=${!_uri}
		_prot="$a"_"$_mode"_GET_PROTOCOL
		_prot=${!_prot}
		_name="$a"_"$_mode"_NAME
		_name=${!_name}

		if [ "$_name" == "" ]; then
			echo "** Error : $a does not exist"
		fi

		_merge=
		_strip=
		for o in $_opt; do 
			[ "$o" == "MERGE" ] && _merge=MERGE
			[ "$o" == "STRIP" ] && _strip=STRIP
		done


		echo "* $_operation $_name [$a] ressources"

		if [ "$_merge" == "MERGE" ]; then 
			echo "* Main package of [$a] is $_artefact_namespace"
		fi

		
		__get_ressource "$_mode : $_name [$_artefact_namespace]" "$_uri" "$_prot" "$_artefact_dest/$_artefact_namespace" "$_merge $_strip $_operation"
		if [ "$_merge" == "MERGE" ]; then echo "* $_name merged into $_artefact_namespace"; fi
		if [ "$_artefact_link" == "1" ]; then
			if [ "$FORCE" == "1" ]; then rm -f "$_artefact_link_target/$_artefact_namespace"; fi
			[ ! -L "$_artefact_link_target/$_artefact_namespace" ] && (
				echo "** Make symbolic link for $_artefact_namespace"
				ln -s "$_artefact_dest/$_artefact_namespace" "$_artefact_link_target/$_artefact_namespace"
			)
		fi
	
	done
}

# VIRTUAL MANAGEMENT ---------------------------
function __setup_all_env() {
	__setup_env $STELLA_ENV_LIST
}

function __setup_env() {
	local _list_id=$1
	
	for a in $_list_id; do
		_env_infra_id="$a"_INFRA_ID
		_env_infra_id=${!_env_infra_id}
		_env_distrib="$a"_DISTRIB
		_env_distrib=${!_env_distrib}
		_env_os="$a"_OS
		_env_os=${!_env_os}
		_env_name="$a"_ENV_NAME
		_env_name=${!_env_name}
		_env_cpu="$a"_CPU
		_env_cpu=${!_env_cpu}
		_env_mem="$a"_MEM
		_env_mem=${!_env_mem}


		if [ ! "$_env_infra_id" == "current" ]; then
			echo" * Setting up env '$_env_name [$a]' with infra '[$_env_infra_id]' - using $_env_cpu cpu and $_env_mem Mo - built with '$_env_distrib', a $_env_os operating system"

			$STELLA_BIN/virtual.sh get-box $_env_distrib
			$STELLA_BIN/virtual.sh create-box $_env_distrib
			$STELLA_BIN/virtual.sh create-env $a#$_env_distrib --vcpu=$_env_cpu --vmem=$_env_mem

			echo " * Now you can use your env using $STELLA_BIN/virtual.sh OR with Vagrant"
		else
			echo "* Env '$_env_name [$a]' is the default current system"
		fi
	done

	
}


fi