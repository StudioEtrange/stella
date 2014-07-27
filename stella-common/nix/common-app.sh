if [ ! "$_COMMON_APP_INCLUDED_" == "1" ]; then 
_COMMON_APP_INCLUDED_=1




# APP RESSOURCES & ENV MANAGEMENT ---------------


function __select_app() {
	local _app_path=

	PROPERTIES=

	if [ "$_app_path" == "" ]; then
		_app_path=$_CURRENT_RUNNING_DIR
	fi

	if [ -f "$_app_path/.stella" ]; then
		PROPERTIES="$_app_path/.stella"
		STELLA_APP_ROOT=$_app_path
	fi
	

}

function __init_app() {
	local _app_name=$1
	local _approot=$2
	local _workroot=$3
	local _cachedir=$4

	_approot=$(__rel_to_abs_path "$_approot" "$_CURRENT_RUNNING_DIR")
	mkdir -p $_approot

	_stella_root=$(__abs_to_rel_path "$STELLA_ROOT" "$_approot")
	echo "_STELLA_LINK_CURRENT_FILE_DIR=\"\$( cd \"\$( dirname \"\${BASH_SOURCE[0]}\" )\" && pwd )\"" >$_approot/.stella-link.sh
	echo "STELLA_ROOT=\$_STELLA_LINK_CURRENT_FILE_DIR/$_stella_root" >>$_approot/.stella-link.sh
	# echo "STELLA_ROOT=$_stella_root" >$_approot/.stella-link.sh

	cp -f "$STELLA_POOL/stella-template.sh" "$_approot/stella.sh"
	chmod +x $_approot/stella.sh

	cp -f "$STELLA_POOL/example-app.sh" "$_approot/example-app.sh"
	chmod +x $_approot/example-app.sh

	cp -f "$STELLA_ROOT/example-app-properties.stella" "$_approot/example-app-properties.stella"

	PROPERTIES="$_approot/.stella"
	if [ -f "$PROPERTIES" ]; then
		echo " ** Properties file already exist"
	else
		__add_key "$PROPERTIES" "STELLA" "APP_NAME" "$_app_name"
		__add_key "$PROPERTIES" "STELLA" "APP_WORK_ROOT" "$_workroot"
		__add_key "$PROPERTIES" "STELLA" "APP_CACHE_DIR" "$_cachedir"
		__add_key "$PROPERTIES" "STELLA" "DATA_LIST"
		__add_key "$PROPERTIES" "STELLA" "ASSETS_LIST"
		__add_key "$PROPERTIES" "STELLA" "ENV_LIST"
		__add_key "$PROPERTIES" "STELLA" "INFRA_LIST"
	fi
}

# extract APP properties
function __get_all_properties() {

	if [ -f "$PROPERTIES" ]; then
			
		# STELLA VARs
		__get_key "$PROPERTIES" "STELLA" "APP_NAME"
		__get_key "$PROPERTIES" "STELLA" "APP_WORK_ROOT" "PREFIX"
		__get_key "$PROPERTIES" "STELLA" "APP_CACHE_DIR" "PREFIX"
		__get_key "$PROPERTIES" "STELLA" "DATA_LIST" "PREFIX"
		__get_key "$PROPERTIES" "STELLA" "ASSETS_LIST" "PREFIX"
		__get_key "$PROPERTIES" "STELLA" "ENV_LIST" "PREFIX"
		__get_key "$PROPERTIES" "STELLA" "INFRA_LIST" "PREFIX"

		# DATA
		for a in $STELLA_DATA_LIST; do
			__get_key "$PROPERTIES" "$a" DATA_MAIN_PACKAGE "PREFIX"
			__get_key "$PROPERTIES" "$a" DATA_OPTIONS "PREFIX"
			__get_key "$PROPERTIES" "$a" DATA_NAME "PREFIX"
			__get_key "$PROPERTIES" "$a" DATA_URI "PREFIX"
			__get_key "$PROPERTIES" "$a" DATA_GET_PROTOCOL "PREFIX"
		done

		# ASSETS
		for a in $STELLA_ASSETS_LIST; do
			__get_key "$PROPERTIES" "$a" ASSETS_MAIN_PACKAGE "PREFIX"
			__get_key "$PROPERTIES" "$a" ASSETS_OPTIONS "PREFIX"
			__get_key "$PROPERTIES" "$a" ASSETS_NAME "PREFIX"
			__get_key "$PROPERTIES" "$a" ASSETS_URI "PREFIX"
			__get_key "$PROPERTIES" "$a" ASSETS_GET_PROTOCOL "PREFIX"
		done

		# ENV
		for a in $STELLA_ENV_LIST; do
			__get_key "$PROPERTIES" "$a" ENV_NAME "PREFIX"
			__get_key "$PROPERTIES" "$a" INFRA_ID "PREFIX"
		done
		
		# INFRA
		for a in $STELLA_INFRA_LIST; do
			__get_key "$PROPERTIES" "$a" INFRA_NAME "PREFIX"
			__get_key "$PROPERTIES" "$a" INFRA_DISTRIB "PREFIX"
			__get_key "$PROPERTIES" "$a" INFRA_CPU "PREFIX"
			__get_key "$PROPERTIES" "$a" INFRA_MEM "PREFIX"
		done

		# INFRA-ENV
		for a in $STELLA_ENV_LIST; do
			_artefact_infra_id="$a"_INFRA_ID
			_artefact_infra_id=${!_artefact_infra_id}
			# eval "$a"_INFRA_ID=$_artefact_infra_id
			if [ "$_artefact_infra_id" == "default" ]; then
				eval "$a"_OS=\$STELLA_CURRENT_OS
				eval "$a"_PLATFORM=\$STELLA_CURRENT_PLATFORM
				eval "$a"_PLATFORM_SUFFIX=\$STELLA_CURRENT_PLATFORM_SUFFIX
			else
				_artefact_distrib="$_artefact_infra_id"_INFRA_DISTRIB
				eval "$a"_DISTRIB=${!_artefact_distrib}
				eval "$a"_OS='$(get_os_from_distro ${!_artefact_distrib})'
				eval "$a"_PLATFORM='$(get_platform_from_os ${!_artefact_os})'
				_artefact_platform="$a"_PLATFORM
				eval "$a"_PLATFORM_SUFFIX='$(get_platform_suffix ${!_artefact_platform})'
				_artefact_cpu="$_artefact_infra_id"_INFRA_CPU
				eval "$a"_CPU=${!_artefact_cpu}
				_artefact_mem="$_artefact_infra_id"_INFRA_MEM
				eval "$a"_MEM=${!_artefact_mem}
			fi
		done
	fi
}


function __get_data() {
	local _list_id=$1
	
	mkdir -p "$DATA_ROOT"
	
	__get_stella_ressources "DATA" "$_list_id"

}

function __get_assets() {
	local _list_id=$1
	
	mkdir -p "$ASSETS_ROOT"
	mkdir -p "$ASSETS_REPOSITORY"
	
	__get_stella_ressources "ASSETS" "$_list_id"
}

function __get_all_data() {
	__get_data $STELLA_DATA_LIST
}

function __get_all_assets() {
	__get_assets $STELLA_ASSETS_LIST
}

function __get_stella_ressources() {
	local _mode=$1
	local _list_id=$2

	for a in $_list_id; do
		_artefact_main_package="$a"_"$_mode"_MAIN_PACKAGE
		_artefact_main_package=${!_artefact_main_package}
		_artefact_link=0
		if [ "$_mode" == "DATA" ]; then _artefact_dest="$DATA_ROOT"; _artefact_link=0; fi
		if [ "$_mode" == "ASSETS" ]; then _artefact_dest="$ASSETS_REPOSITORY"; _artefact_link=1; _artefact_link_target="$ASSETS_ROOT"; fi
		

		_opt="$a"_"$_mode"_OPTIONS
		_opt=${!_opt}
		_uri="$a"_"$_mode"_URI
		_uri=${!_uri}
		_prot="$a"_"$_mode"_GET_PROTOCOL
		_prot=${!_prot}
		_name="$a"_"$_mode"_NAME
		_name=${!_name}
		
		_merge=
		_strip=
		for o in $_opt; do 
			[ "$o" == "MERGE" ] && _merge=MERGE
			[ "$o" == "STRIP" ] && _strip=STRIP
		done


		echo "* Get $_name [$a] ressources"

		if [ "$_merge" == "MERGE" ]; then 
			echo "* Main package of [$a] is $_artefact_main_package"
		fi

		if [ "$_merge" == "MERGE" ]; then
			__get_ressource "$_mode : $_name [$_artefact_main_package]" "$_uri" "$_prot" "$_artefact_dest/$_artefact_main_package" "$_merge $_strip"
			echo "* $_name merged into $_artefact_main_package"
			if [ "$_artefact_link" == "1" ]; then
				if [ "$FORCE" == "1" ]; then rm -f "$_artefact_link_target/$_artefact_main_package"; fi
				[ ! -L "$_artefact_link_target/$_artefact_main_package" ] && (
					echo "** Make symbolic link for $_artefact_main_package"
					ln -s "$_artefact_dest/$_artefact_main_package" "$_artefact_link_target/$_artefact_main_package"
				)
			fi
		else
			__get_ressource "$_mode : $_name" "$_uri" "$_prot" "$_artefact_dest/$_name" "$_strip"
			if [ "$_artefact_link" == "1" ]; then
				if [ "$FORCE" == "1" ]; then rm -f "$_artefact_link_target/$_name"; fi
				[ ! -L "$_artefact_link_target/$_name" ] && (
					echo " ** Make symbolic link for $_name"
					ln -s "$_artefact_dest/$_name" "$_artefact_link_target/$_name"
				)
			fi
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


		if [ ! "$_env_infra_id" == "default" ]; then
			echo" * Setting up env '$_env_name [$a]' with infra '[$_env_infra_id]' - using $_env_cpu cpu and $_env_mem Mo - built with '$_env_distrib', a $_env_os operating system"

			$STELLA_ROOT/virtual.sh get-box --distrib=$_env_distrib
			$STELLA_ROOT/virtual.sh create-box --distrib=$_env_distrib
			$STELLA_ROOT/virtual.sh create-env --distrib=$_env_distrib --envname=$a --envcpu=$_env_cpu --envmem=$_env_mem

			echo " * Now you can use your env using $STELLA_ROOT/virtual.sh OR with Vagrant"
		else
			echo "* Env '$_env_name [$a]' is the default current system"
		fi
	done

	
}


fi