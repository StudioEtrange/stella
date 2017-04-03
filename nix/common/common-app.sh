#!sh
if [ ! "$_STELLA_COMMON_APP_INCLUDED_" = "1" ]; then
_STELLA_COMMON_APP_INCLUDED_=1




# APP RESSOURCES & ENV MANAGEMENT ---------------

__transfert_app(){
	# target form is [USER@]HOST:[DEST]
	local _target=$1

	local _OPT=$2
	local _opt_ex_cache="EXCLUDE /$(__abs_to_rel_path $STELLA_APP_CACHE_DIR $STELLA_APP_ROOT)/"
	local _opt_ex_workspace="EXCLUDE /$(__abs_to_rel_path $STELLA_APP_WORK_ROOT $STELLA_APP_ROOT)/"
	for o in $_OPT; do
		[ "$o" = "CACHE" ] && _opt_ex_cache=
		[ "$o" = "WORKSPACE" ] && _opt_ex_workspace=
	done

	__transfert_folder_rsync "$STELLA_APP_ROOT" "$_target" "$_opt_ex_cache $_opt_ex_workspace"
}


# ARG 1 optional : specify an app path
# return properties file path
__select_app() {
	local _app_path=$1

	local _properties_file=

	if [ "$_app_path" = "" ]; then
		_app_path=$STELLA_CURRENT_RUNNING_DIR
	fi

	if [ -f "$_app_path/$STELLA_APP_PROPERTIES_FILENAME" ]; then
		_properties_file="$_app_path/$STELLA_APP_PROPERTIES_FILENAME"
		#STELLA_APP_ROOT=$_app_path
	fi

	echo "$_properties_file"
}


__create_app_samples() {
	local _approot=$1

	cp -f "$STELLA_TEMPLATE/sample-app.sh" "$_approot/sample-app.sh"
	chmod +x $_approot/sample-app.sh

	cp -f "$STELLA_TEMPLATE/sample-stella.properties" "$_approot/sample-stella.properties"
}



# align stella installation to current app one (recreate stella-link file)
# align workspace and cache folder paths of the current one (change stella properties path)
__link_app() {
	local _target_approot="$1"
	#local _stella_root=$2

	local _OPT="$2"
	local _opt_share_cache=OFF
	local _opt_share_workspace=OFF
	local _flag_stella_root=OFF
	local _stella_root=$STELLA_ROOT
	for o in $_OPT; do
		[ "$o" = "CACHE" ] && _opt_share_cache=ON
		[ "$o" = "WORKSPACE" ] && _opt_share_workspace=ON
		[ "$_flag_stella_root" = "ON" ] && _stella_root="$o" && _flag_stella_root=OFF
		[ "$o" = "STELLA_ROOT" ] && _flag_stella_root=ON
	done

	_target_approot=$(__rel_to_abs_path $_target_approot $STELLA_CURRENT_RUNNING_DIR)

	#[ "$_stella_root" = "" ] && _stella_root=$STELLA_ROOT
	[ "$(__is_abs "$_stella_root")" = "FALSE" ] && _stella_root=$(__rel_to_abs_path "$_stella_root" "$_target_approot")

	_s_ver=$(__get_stella_version "$_stella_root")
	_s_flavour=$(__get_stella_flavour "$_stella_root")

	_stella_root=$(__abs_to_rel_path "$_stella_root" "$_target_approot")

	echo "#!/usr/bin/env bash" >$_target_approot/stella-link.sh.temp
	echo "_STELLA_LINK_CURRENT_FILE_DIR=\"\$( cd \"\$( dirname \"\${BASH_SOURCE[0]}\" )\" && pwd )\"" >>$_target_approot/stella-link.sh.temp
	echo "export STELLA_ROOT=\$_STELLA_LINK_CURRENT_FILE_DIR/$_stella_root" >>$_target_approot/stella-link.sh.temp
	echo "STELLA_DEP_FLAVOUR=$_s_flavour" >>$_target_approot/stella-link.sh.temp
	echo "STELLA_DEP_VERSION=$_s_ver" >>$_target_approot/stella-link.sh.temp

	cat $_target_approot/stella-link.sh.temp $STELLA_TEMPLATE/sample-stella-link.sh > $_target_approot/stella-link.sh
	chmod +x $_target_approot/stella-link.sh
	rm -f $_target_approot/stella-link.sh.temp


	# tweak stella properties file
	_target_STELLA_APP_PROPERTIES_FILE="$_target_approot/$STELLA_APP_PROPERTIES_FILENAME"

	[ "$_opt_share_cache" = "ON" ] && __add_key "$_target_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_CACHE_DIR" "$STELLA_APP_CACHE_DIR"
	[ "$_opt_share_workspace" = "ON" ] && __add_key "$_target_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_WORK_ROOT" "$STELLA_APP_WORK_ROOT"


}

__init_app() {
	local _app_name=$1
	local _approot=$2
	local _workroot=$3
	local _cachedir=$4


	if [ "$(__is_abs "$_approot")" = "FALSE" ]; then
		mkdir -p $STELLA_CURRENT_RUNNING_DIR/$_approot
		_approot=$(__rel_to_abs_path "$_approot" "$STELLA_CURRENT_RUNNING_DIR")
	else
		mkdir -p $_approot
	fi


    [ "$_workroot" = "" ] && _workroot=$_approot/workspace
  	[ "$_cachedir" = "" ] && _cachedir=$_approot/cache


	[ "$(__is_abs "$_workroot")" = "FALSE" ] && _workroot=$(__rel_to_abs_path "$_workroot" "$_approot")
	[ "$(__is_abs "$_cachedir")" = "FALSE" ] && _cachedir=$(__rel_to_abs_path "$_cachedir" "$_approot")
	# [ "$(__is_abs "$_stella_root")" = "FALSE" ] && _stella_root=$(__rel_to_abs_path "$STELLA_ROOT" "$_approot")


	_s_ver=$(__get_stella_version "$_stella_root")
	_s_flavour=$(__get_stella_flavour "$_stella_root")

	_workroot=$(__abs_to_rel_path "$_workroot" "$_approot")
	_cachedir=$(__abs_to_rel_path "$_cachedir" "$_approot")
	_stella_root=$(__abs_to_rel_path "$STELLA_ROOT" "$_approot")



	echo "#!/usr/bin/env bash" >$_approot/stella-link.sh.temp
	echo "_STELLA_LINK_CURRENT_FILE_DIR=\"\$( cd \"\$( dirname \"\${BASH_SOURCE[0]}\" )\" && pwd )\"" >>$_approot/stella-link.sh.temp
	echo "export STELLA_ROOT=\$_STELLA_LINK_CURRENT_FILE_DIR/$_stella_root" >>$_approot/stella-link.sh.temp
	echo "STELLA_DEP_FLAVOUR=$_s_flavour" >>$_approot/stella-link.sh.temp
	echo "STELLA_DEP_VERSION=$_s_ver" >>$_approot/stella-link.sh.temp




	cat $_approot/stella-link.sh.temp $STELLA_TEMPLATE/sample-stella-link.sh > $_approot/stella-link.sh
	chmod +x $_approot/stella-link.sh
	rm -f $_approot/stella-link.sh.temp

	_STELLA_APP_PROPERTIES_FILE="$_approot/$STELLA_APP_PROPERTIES_FILENAME"
	if [ -f "$_STELLA_APP_PROPERTIES_FILE" ]; then
		echo " ** Properties file already exist"
	else
		__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_NAME" "$_app_name"
		__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_WORK_ROOT" "$_workroot"
		__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_CACHE_DIR" "$_cachedir"
		#__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "DATA_LIST"
		#__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "ASSETS_LIST"
		#__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "ENV_LIST"
		#__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "INFRA_LIST"
		__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_FEATURE_LIST"
	fi
}

# extract APP properties
# STELLA_APP_PROPERTIES are all evaluated
__get_all_properties() {
	local _properties_file=$1

	if [ -f "$_properties_file" ]; then

		# STELLA VARs
		__get_key "$_properties_file" "STELLA" "APP_NAME" "PREFIX"
		STELLA_APP_NAME=$(eval echo "$STELLA_APP_NAME")
		__get_key "$_properties_file" "STELLA" "APP_WORK_ROOT" "PREFIX"
		STELLA_APP_WORK_ROOT=$(eval echo "$STELLA_APP_WORK_ROOT")
		# so that nested stella application will use the same cache folder
		#[ "$STELLA_APP_CACHE_DIR" = "" ] && __get_key "$_properties_file" "STELLA" "APP_CACHE_DIR" "PREFIX"
		__get_key "$_properties_file" "STELLA" "APP_CACHE_DIR" "PREFIX"
		STELLA_APP_CACHE_DIR=$(eval echo "$STELLA_APP_CACHE_DIR")

		__get_key "$_properties_file" "STELLA" "APP_FEATURE_LIST" "PREFIX"
		STELLA_APP_FEATURE_LIST=$(eval echo "$STELLA_APP_FEATURE_LIST")
		__get_key "$_properties_file" "STELLA" "APP_ENV_FILE" "PREFIX"
		STELLA_APP_ENV_FILE=$(eval echo "$STELLA_APP_ENV_FILE")

	fi
}

__get_app_property() {
	local _SECTION=$1
	local _KEY=$2
	__get_key "$_STELLA_APP_PROPERTIES_FILE" "$_SECTION" "$_KEY" "PREFIX"
}

__get_data_properties() {
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

__get_assets_properties() {
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


__remove_app_feature() {
	local _SCHEMA=$1

	__app_feature "REMOVE" $_SCHEMA
}

__add_app_feature() {
	local _SCHEMA=$1

	__app_feature "ADD" $_SCHEMA
}

__app_feature() {
	# ADD or REMOVE
	local _MODE=$1
	local _SCHEMA=$2
	local _APP_FEATURE_LIST=

	local _flag=0

	__translate_schema $_SCHEMA "_TR_FEATURE_NAME" "_TR_FEATURE_VER" "_TR_FEATURE_ARCH" "_TR_FEATURE_FLAVOUR" "_TR_FEATURE_OS_RESTRICTION" "_TR_FEATURE_OS_EXCLUSION"


	if [ -f "$_STELLA_APP_PROPERTIES_FILE" ]; then

		if [ "$STELLA_APP_FEATURE_LIST" = "" ]; then
			[ "$_MODE" = "ADD" ] && _APP_FEATURE_LIST="$_APP_FEATURE_LIST $_SCHEMA"
		else
			# scan if feature exist in app feature list
			for f in $STELLA_APP_FEATURE_LIST; do

				__translate_schema $f "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" "TR_FEATURE_OS_EXCLUSION"

				if [ "$_TR_FEATURE_OS_EXCLUSION" = "$TR_FEATURE_OS_EXCLUSION" ]; then
					if [ "$_TR_FEATURE_OS_RESTRICTION" = "$TR_FEATURE_OS_RESTRICTION" ]; then
						if [ "$_TR_FEATURE_VER" = "$TR_FEATURE_VER" ]; then
							if [ "$_TR_FEATURE_NAME" = "$TR_FEATURE_NAME" ]; then
								if [ "$_TR_FEATURE_ARCH" = "$TR_FEATURE_ARCH" ]; then
									if [ "$_TR_FEATURE_FLAVOUR" = "$TR_FEATURE_FLAVOUR" ]; then
										_flag=1
									fi
								fi
							fi
						fi
					fi
				fi
				if [ "$_MODE" = "REMOVE" ]; then
					[ ! "$_flag" = "1" ] && _APP_FEATURE_LIST="$_APP_FEATURE_LIST $f"
					_flag=0
				fi
				[ "$_MODE" = "ADD" ] && _APP_FEATURE_LIST="$_APP_FEATURE_LIST $f"
			done

			if [ "$_MODE" = "ADD" ]; then
				# This is a new feature
				if [ "$_flag" = "0" ]; then
					_APP_FEATURE_LIST="$_APP_FEATURE_LIST $_SCHEMA"
				fi
			fi
		fi

		_APP_FEATURE_LIST=$(echo $_APP_FEATURE_LIST | sed -e 's/^ *//' -e 's/ *$//')
		STELLA_APP_FEATURE_LIST=$(echo $STELLA_APP_FEATURE_LIST | sed -e 's/^ *//' -e 's/ *$//')

		if [ ! "$STELLA_APP_FEATURE_LIST" = "$_APP_FEATURE_LIST" ]; then
			__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_FEATURE_LIST" "$_APP_FEATURE_LIST"
			# refresh value
			STELLA_APP_FEATURE_LIST=$_APP_FEATURE_LIST
		fi
	fi
}


__get_features() {
	__feature_install_list "$STELLA_APP_FEATURE_LIST"
}

# install a feature listed in app feature list. Look for matching version in app feature list, so could match several version
__get_feature() {
	local _SCHEMA=$1

	local _flag=0

	__translate_schema $_SCHEMA "_TR_FEATURE_NAME" "_TR_FEATURE_VER" "_TR_FEATURE_ARCH" "_TR_FEATURE_FLAVOUR" "_TR_FEATURE_OS_RESTRICTION" "_TR_FEATURE_OS_EXCLUSION"

	if [ ! "$STELLA_APP_FEATURE_LIST" = "" ]; then

		for f in $STELLA_APP_FEATURE_LIST; do

			__translate_schema $f "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" "TR_FEATURE_OS_EXCLUSION"

			_flag=1
			[ ! "$_TR_FEATURE_NAME" = "$TR_FEATURE_NAME" ] && _flag=0
			[ ! "$_TR_FEATURE_FLAVOUR" = "" ] && [ ! "$_TR_FEATURE_FLAVOUR" = "$TR_FEATURE_FLAVOUR" ] && _flag=0
			[ ! "$_TR_FEATURE_ARCH" = "" ] && [ ! "$_TR_FEATURE_ARCH" = "$TR_FEATURE_ARCH" ] && _flag=0
			[ ! "$_TR_FEATURE_VER" = "" ] && [ ! "$_TR_FEATURE_VER" = "$TR_FEATURE_VER" ] && _flag=0


			if [ "$_flag" = "1" ]; then
				__feature_install $f
			fi
		done
	fi

}





# get a list of data by id
__get_data() {
	local _list_id=$1
	__app_resources "DATA" "GET" "$_list_id"
}

# get a list of assets by id
__get_assets() {
	local _list_id=$1
	mkdir -p "$ASSETS_ROOT"
	mkdir -p "$ASSETS_REPOSITORY"

	__app_resources "ASSETS" "GET" "$_list_id"
}

__delete_data() {
	local _list_id=$1
	__app_resources "DATA" "DELETE" "$_list_id"
}

__delete_assets() {
	local _list_id=$1
	__app_resources "ASSETS" "DELETE" "$_list_id"
}

__update_data() {
	local _list_id=$1
	__app_resources "DATA" "UPDATE" "$_list_id"
}

__update_assets() {
	local _list_id=$1
	__app_resources "ASSETS" "UPDATE" "$_list_id"
}

__revert_data() {
	local _list_id=$1
	__app_resources "DATA" "REVERT" "$_list_id"

}

__revert_assets() {
	local _list_id=$1
	__app_resources "ASSETS" "REVERT" "$_list_id"
}


__get_data_pack() {
	local _list_name=$1

	__get_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "$_list_name" ""

	local _list_pack="$(eval echo "$"$(echo $_list_name))"
	__get_data "$_list_pack"
}

__get_assets_pack() {
	local _list_name=$1

	__get_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "$_list_name" ""

	local _list_pack="$(eval echo "$"$(echo $_list_name))"
	__get_assets "$_list_pack"
}

__delete_data_pack() {
	local _list_name=$1

	__get_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "$_list_name" ""

	local _list_pack="$(eval echo "$"$(echo $_list_name))"
	__delete_data "$_list_pack"
}

__delete_assets_pack() {
	local _list_name=$1

	__get_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "$_list_name" ""

	local _list_pack="$(eval echo "$"$(echo $_list_name))"
	__delete_assets "$_list_pack"
}

__update_data_pack() {
	local _list_name=$1

	__get_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "$_list_name" ""

	local _list_pack="$(eval echo "$"$(echo $_list_name))"
	__update_data "$_list_pack"
}

__update_assets_pack() {
	local _list_name=$1

	__get_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "$_list_name" ""

	local _list_pack="$(eval echo "$"$(echo $_list_name))"
	__update_assets "$_list_pack"
}

__revert_data_pack() {
	local _list_name=$1

	__get_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "$_list_name" ""

	local _list_pack="$(eval echo "$"$(echo $_list_name))"
	__revert_data "$_list_pack"
}

__revert_assets_pack() {
	local _list_name=$1

	__get_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "$_list_name" ""

	local _list_pack="$(eval echo "$"$(echo $_list_name))"
	__revert_assets "$_list_pack"
}

# ARG1 resource mode is DATA or ASSET
# ARG2 operation is GET or UPDATE or REVERT or DELETE (UPDATE or REVERT if applicable)
# ARG3 list of resource ID
__app_resources() {
	local _mode=$1
	local _operation=$2
	local _list_id=$3

	if [ "$_mode" = "DATA" ]; then
		__get_data_properties "$_STELLA_APP_PROPERTIES_FILE" "$_list_id"
	fi

	if [ "$_mode" = "ASSETS" ]; then
		__get_assets_properties "$_STELLA_APP_PROPERTIES_FILE" "$_list_id"
	fi

	for a in $_list_id; do
		_artefact_namespace="$a"_"$_mode"_NAMESPACE
		_artefact_namespace=${!_artefact_namespace}

		_artefact_link=0
		if [ "$_mode" = "DATA" ]; then
			_artefact_root="$a"_"$_mode"_ROOT
			_artefact_root=${!_artefact_root}
			_artefact_dest=$(__rel_to_abs_path "$_artefact_root" "$STELLA_APP_WORK_ROOT")
			_artefact_link=0;
		fi
		if [ "$_mode" = "ASSETS" ]; then _artefact_dest="$ASSETS_REPOSITORY"; _artefact_link=1; _artefact_link_target="$ASSETS_ROOT"; fi


		_opt="$a"_"$_mode"_OPTIONS
		_opt=${!_opt}
		_uri="$a"_"$_mode"_URI
		_uri=${!_uri}
		_prot="$a"_"$_mode"_GET_PROTOCOL
		_prot=${!_prot}
		_name="$a"_"$_mode"_NAME
		_name=${!_name}

		if [ "$_name" = "" ]; then
			echo "** Error : $a does not exist"
		fi

		_merge=
		for o in $_opt; do
			[ "$o" = "MERGE" ] && _merge=MERGE
		done


		echo "* $_operation $_name [$a] resources"

		if [ "$_merge" = "MERGE" ]; then
			echo "* Main package of [$a] is $_artefact_namespace"
		fi


		__resource "$_mode : $_name [$_artefact_namespace]" "$_uri" "$_prot" "$_artefact_dest/$_artefact_namespace" "$_opt $_operation"
		if [ "$_merge" = "MERGE" ]; then echo "* $_name merged into $_artefact_namespace"; fi
		if [ "$_artefact_link" = "1" ]; then
			if [ "$FORCE" = "1" ]; then rm -f "$_artefact_link_target/$_artefact_namespace"; fi
			[ ! -L "$_artefact_link_target/$_artefact_namespace" ] && (
				echo "** Make symbolic link for $_artefact_namespace"
				ln -s "$_artefact_dest/$_artefact_namespace" "$_artefact_link_target/$_artefact_namespace"
			)
		fi

	done
}




__ask_init_app() {
		echo "Do you wish to init your stella app (create properties files, link app to stella...) ?"
		select yn in "Yes" "No"; do
		    case $yn in
		        Yes )
					_project_name=$(basename $STELLA_CURRENT_RUNNING_DIR)
					read -p "What is your project name ? [$_project_name]" _temp_project_name
					if [ ! "$_temp_project_name" = "" ]; then
						_project_name=$_temp_project_name
					fi

					echo "Do you wish to generate a sample app for your project ?"
					select sample in "Yes" "No"; do
						case $sample in
							Yes )
								# using default values for app paths (because we didnt ask them)
								__init_app $_project_name $STELLA_CURRENT_RUNNING_DIR
								__create_app_samples $STELLA_CURRENT_RUNNING_DIR
								break;;
							No )
								__init_app $_project_name $STELLA_CURRENT_RUNNING_DIR
								break;;
						esac
					done
					break;;

		        No ) break;;
		    esac
		done
}


fi
