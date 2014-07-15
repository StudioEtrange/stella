if [ ! "$_COMMON_APP_INCLUDED_" == "1" ]; then 
_COMMON_APP_INCLUDED_=1




# APP RESSOURCES & ENV MANAGEMENT ---------------


function select_app_properties() {
	local _app_path=$1

	PROPERTIES=

	if [ "$_app_path" == "" ]; then
		_app_path=$PROJECT_ROOT
	fi

	if [ -f "$_app_path/.stella" ]; then
		PROPERTIES="$_app_path/.stella"
	fi
	
}

function init_app() {
	local _app_name=$1
	local _approot=$2
	local _workroot=$3
	local _cachedir=$4

	mkdir -p $_approot

	# TODO : review stella.sh see stella-template.bat
	echo "#!/bin/bash" >$_approot/stella.sh
	echo "$STELLA_ROOT/stella.sh \$*" >>$_approot/stella.sh
	chmod +x $_approot/stella.sh
	
	echo "#!/bin/bash" >$_approot/stella-include.sh
	echo "source $STELLA_ROOT/include.sh" >>$_approot/stella-include.sh


	PROPERTIES="$_approot/.stella"
	if [ -f "$PROPERTIES" ]; then
		echo " ** Properties file already exist"
	else
		add_key "$PROPERTIES" "STELLA" "APP_ROOT" "$_approot"
		add_key "$PROPERTIES" "STELLA" "APP_WORK_ROOT" "$_workroot"
		add_key "$PROPERTIES" "STELLA" "CACHE_DIR" "$_cachedir"
		add_key "$PROPERTIES" "STELLA" "DATA_LIST"
		add_key "$PROPERTIES" "STELLA" "ASSETS_LIST"
		add_key "$PROPERTIES" "STELLA" "ENV_LIST"
		add_key "$PROPERTIES" "STELLA" "INFRA_LIST"
	fi
}

# extract APP properties
function get_all_properties() {

	if [ -f "$PROPERTIES" ]; then
			
		# STELLA VARs
		get_key "$PROPERTIES" "STELLA" "APP_ROOT"
		get_key "$PROPERTIES" "STELLA" "APP_WORK_ROOT"
		get_key "$PROPERTIES" "STELLA" "CACHE_DIR"
		get_key "$PROPERTIES" "STELLA" "DATA_LIST" "PREFIX"
		get_key "$PROPERTIES" "STELLA" "ASSETS_LIST" "PREFIX"
		get_key "$PROPERTIES" "STELLA" "ENV_LIST" "PREFIX"
		get_key "$PROPERTIES" "STELLA" "INFRA_LIST" "PREFIX"

		# DATA
		for a in $STELLA_DATA_LIST; do
			get_key "$PROPERTIES" "$a" DATA_MAIN_PACKAGE "PREFIX"
			get_key "$PROPERTIES" "$a" DATA_OPTIONS "PREFIX"
			get_key "$PROPERTIES" "$a" DATA_NAME "PREFIX"
			get_key "$PROPERTIES" "$a" DATA_URI "PREFIX"
			get_key "$PROPERTIES" "$a" DATA_GET_PROTOCOL "PREFIX"
		done

		# ASSETS
		for a in $STELLA_ASSETS_LIST; do
			get_key "$PROPERTIES" "$a" ASSETS_MAIN_PACKAGE "PREFIX"
			get_key "$PROPERTIES" "$a" ASSETS_OPTIONS "PREFIX"
			get_key "$PROPERTIES" "$a" ASSETS_NAME "PREFIX"
			get_key "$PROPERTIES" "$a" ASSETS_URI "PREFIX"
			get_key "$PROPERTIES" "$a" ASSETS_GET_PROTOCOL "PREFIX"
		done

		# ENV
		for a in $STELLA_ENV_LIST; do
			get_key "$PROPERTIES" "$a" ENV_NAME "PREFIX"
			get_key "$PROPERTIES" "$a" INFRA_ID "PREFIX"
		done
		
		# INFRA
		for a in $STELLA_INFRA_LIST; do
			get_key "$PROPERTIES" "$a" INFRA_NAME "PREFIX"
			get_key "$PROPERTIES" "$a" INFRA_DISTRIB "PREFIX"
			get_key "$PROPERTIES" "$a" INFRA_CPU "PREFIX"
			get_key "$PROPERTIES" "$a" INFRA_MEM "PREFIX"
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


function get_data() {
	local _list_id=$1
	
	mkdir -p "$DATA_ROOT"
	
	_get_stella_ressources "DATA" "$_list_id"

}

function get_assets() {
	local _list_id=$1
	
	mkdir -p "$ASSETS_ROOT"
	mkdir -p "$ASSETS_REPOSITORY"
	
	_get_stella_ressources "ASSETS" "$_list_id"
}

function get_all_data() {
	get_data $STELLA_DATA_LIST
}

function get_all_assets() {
	get_assets $STELLA_ASSETS_LIST
}

function _get_stella_ressources() {
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
			get_ressource "$_mode : $_name [$_artefact_main_package]" "$_uri" "$_prot" "$_artefact_dest/$_artefact_main_package" "$_merge $_strip"
			echo "* $_name merged into $_artefact_main_package"
			if [ "$_artefact_link" == "1" ]; then
				if [ "$FORCE" == "1" ]; then rm -f "$_artefact_link_target/$_artefact_main_package"; fi
				[ ! -L "$_artefact_link_target/$_artefact_main_package" ] && (
					echo "** Make symbolic link for $_artefact_main_package"
					ln -s "$_artefact_dest/$_artefact_main_package" "$_artefact_link_target/$_artefact_main_package"
				)
			fi
		else
			get_ressource "$_mode : $_name" "$_uri" "$_prot" "$_artefact_dest/$_name" "$_strip"
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
function setup_all_env() {
	setup_env $STELLA_ENV_LIST
}

function setup_env() {
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
			$STELLA_ROOT/virtual.sh get-box --distrib=$_env_distrib
			$STELLA_ROOT/virtual.sh create-box --distrib=$_env_distrib
			$STELLA_ROOT/virtual.sh create-env --distrib=$_env_distrib --envname=$_env_name --envcpu=$_env_cpu --envmem=$_env_mem

			echo " * Now you can use your env using $STELLA_ROOT/virtual.sh OR with Vagrant"
		else
			echo "* ENV [$a] use default current env"
		fi
	done

	
}


fi