#!/bin/bash
_SOURCE_ORIGIN_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_CALL_ORIGIN_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
source $_SOURCE_ORIGIN_FILE_DIR/conf.sh


function list_env() {
	"$VAGRANT_CMD" global-status
}


function info_env() {
	if [ "$ENVNAME" == "" ]; then
		echo "** ERROR Please specify an env name"
		return
	fi

	cd "$VIRTUAL_ENV_ROOT/$ENVNAME"
	"$VAGRANT_CMD" status
	"$VAGRANT_CMD" ssh-config
}


function create_env() {
	if [ "$ENVNAME" == "" ]; then
		echo "** ERROR Please specify an env name"
		return
	fi

	if [ "$VAGRANT_BOX_NAME" == "" ]; then
		echo "** Error please select a distribution"
		return
	fi

	if [ "$FORCE" == "1" ]; then
		destroy_env
	fi

	if [ -d "$VIRTUAL_ENV_ROOT/$ENVNAME" ]; then
		echo "** Env $ENVNAME already exist"
	else

		# Re importing box into vagrant in case of
		if [ -f "$CACHE_DIR/$VAGRANT_BOX_FILENAME" ]; then
			_import_box_into_vagrant $VAGRANT_BOX_NAME "$CACHE_DIR/$VAGRANT_BOX_FILENAME"
		fi

		[ ! -d "$VIRTUAL_ENV_ROOT/$ENVNAME" ] && mkdir -p "$VIRTUAL_ENV_ROOT/$ENVNAME"
		
		cd "$VIRTUAL_ENV_ROOT/$ENVNAME"
		"$VAGRANT_CMD" init "$VAGRANT_BOX_NAME"

		echo "Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|" >> Vagrantfile
		echo 'config.vm.synced_folder "../../../.", "/stella"' >> Vagrantfile
		echo 'config.vm.provider "virtualbox" do |vb|' >> Vagrantfile
		[ ! "$ENVMEM" == "" ] && echo 'vb.customize ["modifyvm", :id, "--memory", "'$ENVMEM'"]' >> Vagrantfile
		[ ! "$ENVCPU" == "" ] && echo 'vb.customize ["modifyvm", :id, "--cpus", "'$ENVCPU'"]' >> Vagrantfile
		echo "end" >> Vagrantfile
		echo "end" >> Vagrantfile

		echo "** Env $ENVNAME is initialized"

	fi

	#echo "** Now starting it ..."

	#run_env
}


function run_env() {
	if [ "$ENVNAME" == "" ]; then
		echo "** ERROR Please specify an env name"
		return
	fi
	if [ ! -d "$VIRTUAL_ENV_ROOT/$ENVNAME" ]; then
		echo "** ERROR Env $ENVNAME does not exist"
		return
	fi
	

	cd "$VIRTUAL_ENV_ROOT/$ENVNAME"
	"$VAGRANT_CMD" up --provider $VIRTUAL_DEFAULT_HYPERVISOR

	echo "** Env $ENVNAME is running"
	info_env

	echo "** Now you can CD into $VIRTUAL_ENV_ROOT/$ENVNAME"
	echo "** and do vagrant ssh"
	if [ "$LOGIN" == "1" ]; then
		echo "** You should type 'vagrant ssh' in the new opened command line to get into your VM"
	fi
}



function destroy_env() {
	if [ -d "$VIRTUAL_ENV_ROOT/$ENVNAME" ]; then
		cd "$VIRTUAL_ENV_ROOT/$ENVNAME"
		"$VAGRANT_CMD" destroy -f
		cd "$VIRTUAL_ENV_ROOT"
		del_folder "$VIRTUAL_ENV_ROOT/$ENVNAME"
		echo "** Env $ENVNAME is destroyed"
	fi
}


function stop_env() {
	if [ "$ENVNAME" == "" ]; then
		echo "** ERROR Please specify an env name"
		return
	fi
	if [ ! -d "$VIRTUAL_ENV_ROOT/$ENVNAME" ]; then
		echo "** ERROR Env $ENVNAME does not exist"
		return
	fi

	cd "$VIRTUAL_ENV_ROOT/$ENVNAME"
	"$VAGRANT_CMD" halt

	echo " ** Env ENVNAME is stopped"
}


function _set_box_matrix() {
	
	
	get_key "$VIRTUAL_CONF_FILE" "$DISTRIB" "PACKER_TEMPLATE"
	get_key "$VIRTUAL_CONF_FILE" "$DISTRIB" "PACKER_TEMPLATE_URI"
	get_key "$VIRTUAL_CONF_FILE" "$DISTRIB" "PACKER_TEMPLATE_URI_PROTOCOL"

	get_key "$VIRTUAL_CONF_FILE" "$DISTRIB" "PACKER_BUILDER"
	get_key "$VIRTUAL_CONF_FILE" "$DISTRIB" "PACKER_PREBUILD_CALLBACK"
	get_key "$VIRTUAL_CONF_FILE" "$DISTRIB" "PACKER_POSTBUILD_CALLBACK"

	get_key "$VIRTUAL_CONF_FILE" "$DISTRIB" "VAGRANT_BOX_NAME"
	get_key "$VIRTUAL_CONF_FILE" "$DISTRIB" "VAGRANT_BOX_FILENAME"
	get_key "$VIRTUAL_CONF_FILE" "$DISTRIB" "VAGRANT_BOX_URI"
	get_key "$VIRTUAL_CONF_FILE" "$DISTRIB" "VAGRANT_BOX_URI_PROTOCOL"
	get_key "$VIRTUAL_CONF_FILE" "$DISTRIB" "VAGRANT_BOX_OUTPUT_DIR"

	get_key "$VIRTUAL_CONF_FILE" "$DISTRIB" "VAGRANT_BOX_USERNAME"
	get_key "$VIRTUAL_CONF_FILE" "$DISTRIB" "VAGRANT_BOX_PASSWORD"
}



function _prebuilt_boot2docker() {
	"$VAGRANT_CMD" up
	"$VAGRANT_CMD" ssh -c "cd /vagrant && sudo ./build-iso.sh"
	"$VAGRANT_CMD" destroy --force
}

function _import_box_into_vagrant() {
	local _BOX_NAME=$1
	local _BOX_FILEPATH="$2"

	if [ -f "$_BOX_FILEPATH" ]; then
		"$VAGRANT_CMD" box add $_BOX_NAME "$_BOX_FILEPATH"
		echo "** Box imported into vagrant under name $_BOX_NAME"
	else
		echo "** ERROR : Box $_BOX_FILEPATH does not exist"
	fi
}

function get_box() {
	if [ "$VAGRANT_BOX_URI" == "" ]; then
		echo "** Error We do not have any URL for a prebuilt box corresponding to this distribution"
		return
	fi
	[ "$FORCE" ] && (
		rm -f "$CACHE_DIR/$VAGRANT_BOX_FILENAME"
	)
	get_ressource "$DISTRIB" "$VAGRANT_BOX_URI" "$VAGRANT_BOX_URI_PROTOCOL"
	_import_box_into_vagrant $VAGRANT_BOX_NAME "$CACHE_DIR/$VAGRANT_BOX_FILENAME"
}

function list_box() {
	"$VAGRANT_CMD" box list	
}

function create_box() {
	
	if [ "$PACKER_TEMPLATE" == "" ]; then
		echo "** Error please select a distribution"
		return
	fi

	echo "** Packing a vagrant box for $VIRTUAL_DEFAULT_HYPERVISOR with Packer"
		
	if [ "$FORCE" == "1" ]; then
		rm -f "$CACHE_DIR/$VAGRANT_BOX_FILENAME"
	fi

	if [ ! -f "$CACHE_DIR/$VAGRANT_BOX_FILENAME" ]; then

		if [ ! "$PACKER_TEMPLATE_URI_PROTOCOL" == "_INTERNAL_" ]; then
			get_ressource "$DISTRIB" "$PACKER_TEMPLATE_URI" "$PACKER_TEMPLATE_URI_PROTOCOL" "$VIRTUAL_TEMPLATE_ROOT/$DISTRIB"
			PACKER_TEMPLATE_URI="$VIRTUAL_TEMPLATE_ROOT/$DISTRIB/$PACKER_TEMPLATE"
		else
			PACKER_TEMPLATE_URI="$VIRTUAL_INTERNAL_TEMPLATE_ROOT/$PACKER_TEMPLATE_URI/$PACKER_TEMPLATE"
		fi
		
		PACKER_TEMPLATE=$(get_filename_from_string "$PACKER_TEMPLATE_URI")
		PACKER_TEMPLATE_URI=$(get_path_from_string "$PACKER_TEMPLATE_URI")

		VAGRANT_BOX_OUTPUT_DIR="$PACKER_TEMPLATE_URI/$VAGRANT_BOX_OUTPUT_DIR"

	
				
		cd "$PACKER_TEMPLATE_URI"
		
		if [ ! "$PACKER_PREBUILD_CALLBACK%" == "" ]; then
			$PACKER_PREBUILD_CALLBACK
			PACKER_PREBUILD_CALLBACK=
		fi

		echo "$PACKER_CMD" validate -only=$PACKER_BUILDER "$PACKER_TEMPLATE"
		"$PACKER_CMD" build -only=$PACKER_BUILDER $PACKER_TEMPLATE

		if [ ! "$PACKER_POSTBUILD_CALLBACK%" == "" ]; then
			$PACKER_POSTBUILD_CALLBACK
			PACKER_POSTBUILD_CALLBACK=
		fi

		copy_folder_content_into "$VAGRANT_BOX_OUTPUT_DIR" "$CACHE_DIR" "*.box"
		rm -f "$VAGRANT_BOX_OUTPUT_DIR/*.box"

		if [  -d "$CACHE_DIR/$VAGRANT_BOX_FILENAME" ]; then
			echo "** Box created"
		fi
	else
		echo "** Box already created"
	fi

	_import_box_into_vagrant $VAGRANT_BOX_NAME "$CACHE_DIR/$VAGRANT_BOX_FILENAME"

}

# MAIN ------------------------
PARAMETERS="
ACTION=											'action' 			a			'create-env run-env stop-env info-env list-env destroy-env create-box get-box list-box'		Action to compute.
"
OPTIONS="
DISTRIB=''    						'd'     	'distribution' 		a 			0		'ubuntu64 debian64 centos64 archlinux boot2docker'		select a distribution.
VERBOSE=0							'v'			'level'				i			0		'0:2'					Verbose level : 0 (default) no verbose, 1 verbose, 2 ultraverbose.
FORCE=''							'f'			''					b			0		'1'						Force.
ENVNAME=''							'e'			''					s			0		''						Environment name.
LOGIN=''							'l'			''					b			0		'1'						Autologin in env.
ENVCPU=''							''			''					i 			0		''						Nb CPU attributed to the virtual env.
ENVMEM=''							''			''					i 			0		''						Memory attributed to the virtual env.
"


argparse "$0" "$OPTIONS" "$PARAMETERS" "Stella virtualization management" "Stella virtualization management" "" "$@"

# common initializations
init_env

_set_box_matrix


[ ! -d "$VIRTUAL_WORK_ROOT" ] && mkdir -p "$VIRTUAL_WORK_ROOT"
[ ! -d "$VIRTUAL_ENV_ROOT" ] && mkdir -p "$VIRTUAL_ENV_ROOT"
[ ! -d "$VIRTUAL_TEMPLATE_ROOT" ] && mkdir -p "$VIRTUAL_TEMPLATE_ROOT"


case $ACTION in
    create-box)
    	create_box
    	;;
	get-box)
    	get_box
    	;;
    list-box)
    	list_box
    	;;
    create-env)
    	create_env
    	;;
    run-env)
    	run_env
    	;;
    stop-env)
    	stop_env
    	;;
    list-env)
    	list_env
    	;;
    info-env)
    	info_env
    	;;
    destroy-env)
    	destroy_env
    	;;
	*)
		echo "use option --help for help"
	;;
esac


echo "** END **"
