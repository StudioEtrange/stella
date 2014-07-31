if [ ! "$_STELLA_COMMON_VIRTUAL_INCLUDED_" == "1" ]; then 
_STELLA_COMMON_VIRTUAL_INCLUDED_=1

function __virtual_init_folder() {
	[ ! -d "$VIRTUAL_WORK_ROOT" ] && mkdir -p "$VIRTUAL_WORK_ROOT"
	[ ! -d "$VIRTUAL_ENV_ROOT" ] && mkdir -p "$VIRTUAL_ENV_ROOT"
	[ ! -d "$VIRTUAL_TEMPLATE_ROOT" ] && mkdir -p "$VIRTUAL_TEMPLATE_ROOT"	
}


function __set_matrix() {
	local _distrib=$1

	PACKER_TEMPLATE=
	PACKER_TEMPLATE_URI=
	PACKER_TEMPLATE_URI_PROTOCOL=
	PACKER_BUILDER=
	PACKER_PREBUILD_CALLBACK=
	PACKER_POSTBUILD_CALLBACK=
	VAGRANT_BOX_NAME=
	VAGRANT_BOX_FILENAME=
	VAGRANT_BOX_URI=
	VAGRANT_BOX_URI_PROTOCOL=
	VAGRANT_BOX_OUTPUT_DIR=
	VAGRANT_BOX_USERNAME=
	VAGRANT_BOX_PASSWORD=

	__get_key "$VIRTUAL_CONF_FILE" "$_distrib" "PACKER_TEMPLATE"
	__get_key "$VIRTUAL_CONF_FILE" "$_distrib" "PACKER_TEMPLATE_URI"
	__get_key "$VIRTUAL_CONF_FILE" "$_distrib" "PACKER_TEMPLATE_URI_PROTOCOL"

	__get_key "$VIRTUAL_CONF_FILE" "$_distrib" "PACKER_BUILDER"
	__get_key "$VIRTUAL_CONF_FILE" "$_distrib" "PACKER_PREBUILD_CALLBACK"
	__get_key "$VIRTUAL_CONF_FILE" "$_distrib" "PACKER_POSTBUILD_CALLBACK"

	__get_key "$VIRTUAL_CONF_FILE" "$_distrib" "VAGRANT_BOX_NAME"
	__get_key "$VIRTUAL_CONF_FILE" "$_distrib" "VAGRANT_BOX_FILENAME"
	__get_key "$VIRTUAL_CONF_FILE" "$_distrib" "VAGRANT_BOX_URI"
	__get_key "$VIRTUAL_CONF_FILE" "$_distrib" "VAGRANT_BOX_URI_PROTOCOL"
	__get_key "$VIRTUAL_CONF_FILE" "$_distrib" "VAGRANT_BOX_OUTPUT_DIR"

	__get_key "$VIRTUAL_CONF_FILE" "$_distrib" "VAGRANT_BOX_USERNAME"
	__get_key "$VIRTUAL_CONF_FILE" "$_distrib" "VAGRANT_BOX_PASSWORD"
}



function __prebuilt_boot2docker() {
	"$VAGRANT_CMD" up
	"$VAGRANT_CMD" ssh -c "cd /vagrant && sudo ./build-iso.sh"
	"$VAGRANT_CMD" destroy --force
}


# ------------------------------------ ADMINISTRATION OF ENV WITH VAGRANT -----------------------
function __list_env() {
	"$VAGRANT_CMD" global-status
}


function __info_env() {
	local _env_id=$1
	if [ "$_env_id" == "" ]; then
		echo "** ERROR Please specify an env id"
		return
	fi
	__virtual_init_folder

	cd "$VIRTUAL_ENV_ROOT/$_env_id"
	"$VAGRANT_CMD" status
	"$VAGRANT_CMD" ssh-config
}

# ARG3 : option
#	HEAD : hypervisor with gui ON (default OFF)
#	MEM XXXX : size of memory in Mo
#	CPU XX : nb of cpu
function __create_env() {
	local _env_id=$1
	local _distrib_id=$2
	local _opt=$3

	local _opt_head=OFF
	local _flag_mem=OFF
	local _flag_cpu=OFF
	local _mem=
	local _cpu=
	for o in $OPT; do 
		if [ "$_flag_mem" == "ON" ]; then
			_mem=$o
			_flag_mem=OFF
		fi
		if [ "$_flag_cpu" == "ON" ]; then
			_cpu=$o
			_mem=$o
		fi
		[ "$o" == "HEAD" ] && _opt_head=ON
		[ "$o" == "MEM" ] && _flag_mem=ON
		[ "$o" == "CPU" ] && _flag_cpu=ON
	done


	if [ "$_env_id" == "" ]; then
		echo "** ERROR Please specify an env id"
		return
	fi

	__set_matrix $_distrib_id

	if [ "$VAGRANT_BOX_NAME" == "" ]; then
		echo "** Error please select a distribution id"
		return
	fi

	__virtual_init_folder

	if [ "$FORCE" == "1" ]; then
		__destroy_env $_env_id
	fi

	if [ -d "$VIRTUAL_ENV_ROOT/$_env_id" ]; then
		echo "** Env $_env_id already exist"
	else

		# Re importing box into vagrant in case of
		if [ -f "$STELLA_APP_CACHE_DIR/$VAGRANT_BOX_FILENAME" ]; then
			__import_box_into_vagrant $VAGRANT_BOX_NAME "$STELLA_APP_CACHE_DIR/$VAGRANT_BOX_FILENAME"
		fi

		[ ! -d "$VIRTUAL_ENV_ROOT/$_env_id" ] && mkdir -p "$VIRTUAL_ENV_ROOT/$_env_id"
		
		cd "$VIRTUAL_ENV_ROOT/$_env_id"
		"$VAGRANT_CMD" init "$VAGRANT_BOX_NAME"

		echo "Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|" >> Vagrantfile
		echo 'config.vm.synced_folder "../../../.", "/stella"' >> Vagrantfile
		echo 'config.vm.provider "virtualbox" do |vb|' >> Vagrantfile
		[ "$_opt_head" == "ON" ] && echo 'vb.gui = true' >> Vagrantfile
		[ "$_opt_head" == "OFF" ] && echo 'vb.gui = false' >> Vagrantfile
		[ ! "$_mem" == "" ] && echo 'vb.customize ["modifyvm", :id, "--memory", "'$_mem'"]' >> Vagrantfile
		[ ! "$_cpu" == "" ] && echo 'vb.customize ["modifyvm", :id, "--cpus", "'$_cpu'"]' >> Vagrantfile
		echo "end" >> Vagrantfile
		echo "end" >> Vagrantfile

		echo "** Env $_env_id is initialized"

	fi
}


function __run_env() {
	local _env_id=$1
	local _login_into=$2

	if [ "$_env_id" == "" ]; then
		echo "** ERROR Please specify an env id"
		return
	fi

	__virtual_init_folder

	if [ ! -d "$VIRTUAL_ENV_ROOT/$_env_id" ]; then
		echo "** ERROR Env $_env_id does not exist"
		return
	fi
	

	cd "$VIRTUAL_ENV_ROOT/$_env_id"
	"$VAGRANT_CMD" up --provider $VIRTUAL_DEFAULT_HYPERVISOR

	echo "** Env $_env_id is running"
	__info_env

	echo "** Now you can CD into $VIRTUAL_ENV_ROOT/$_env_id"
	echo "** and do vagrant ssh"
	if [ "$_login_into" == "TRUE" ]; then
		cd "$VIRTUAL_ENV_ROOT/$_env_id"
		"$VAGRANT_CMD" ssh
	fi
}



function __destroy_env() {
	local _env_id=$1

	if [ -d "$VIRTUAL_ENV_ROOT/$_env_id" ]; then
		cd "$VIRTUAL_ENV_ROOT/$_env_id"
		"$VAGRANT_CMD" destroy -f
		cd "$VIRTUAL_ENV_ROOT"
		__del_folder "$VIRTUAL_ENV_ROOT/$_env_id"
		echo "** Env $_env_id is destroyed"
	fi
}


function __stop_env() {
	local _env_id=$1

	if [ "$_env_id" == "" ]; then
		echo "** ERROR Please specify an env id"
		return
	fi
	__virtual_init_folder

	if [ ! -d "$VIRTUAL_ENV_ROOT/$_env_id" ]; then
		echo "** ERROR Env $_env_id does not exist"
		return
	fi

	cd "$VIRTUAL_ENV_ROOT/$_env_id"
	"$VAGRANT_CMD" halt

	echo " ** Env $_env_id is stopped"
}






# ------------------------------------ ADMINISTRATION OF BOX WITH PACKER -----------------------

function __import_box_into_vagrant() {
	local _BOX_NAME=$1
	local _BOX_FILEPATH="$2"

	if [ -f "$_BOX_FILEPATH" ]; then
		"$VAGRANT_CMD" box add $_BOX_NAME "$_BOX_FILEPATH"
		echo "** Box imported into vagrant under name $_BOX_NAME"
	else
		echo "** ERROR : Box $_BOX_FILEPATH does not exist"
	fi
}

function __list_distrib() {
	echo "$__STELLA_DISTRIB_LIST"
}

function __get_box() {
	local _distrib_id=$1

	__set_matrix $_distrib_id

	if [ "$VAGRANT_BOX_URI" == "" ]; then
		echo "** Error We do not have any URL for a prebuilt box corresponding to this distribution"
		return
	fi
	[ "$FORCE" ] && (
		rm -f "$STELLA_APP_CACHE_DIR/$VAGRANT_BOX_FILENAME"
	)
	__get_ressource "$_distrib_id" "$VAGRANT_BOX_URI" "$VAGRANT_BOX_URI_PROTOCOL"
	__import_box_into_vagrant $VAGRANT_BOX_NAME "$STELLA_APP_CACHE_DIR/$VAGRANT_BOX_FILENAME"
}

function __list_box() {
	"$VAGRANT_CMD" box list	
}

function __create_box() {
	local _distrib_id=$1

	__set_matrix $_distrib_id
	


	if [ "$PACKER_TEMPLATE" == "" ]; then
		echo "** Error please select a distribution"
		return
	fi

	__virtual_init_folder

	echo "** Packing a vagrant box for $VIRTUAL_DEFAULT_HYPERVISOR with Packer"
		
	if [ "$FORCE" == "1" ]; then
		rm -f "$STELLA_APP_CACHE_DIR/$VAGRANT_BOX_FILENAME"
	fi

	if [ ! -f "$STELLA_APP_CACHE_DIR/$VAGRANT_BOX_FILENAME" ]; then

		if [ ! "$PACKER_TEMPLATE_URI_PROTOCOL" == "_INTERNAL_" ]; then
			__get_ressource "$DISTRIB" "$PACKER_TEMPLATE_URI" "$PACKER_TEMPLATE_URI_PROTOCOL" "$VIRTUAL_TEMPLATE_ROOT/$DISTRIB" "$STELLA_APP_CACHE_DIR"
			PACKER_TEMPLATE_URI="$VIRTUAL_TEMPLATE_ROOT/$DISTRIB/$PACKER_TEMPLATE"
		else
			PACKER_TEMPLATE_URI="$VIRTUAL_INTERNAL_TEMPLATE_ROOT/$PACKER_TEMPLATE_URI/$PACKER_TEMPLATE"
		fi
		
		PACKER_TEMPLATE=$(__get_filename_from_string "$PACKER_TEMPLATE_URI")
		PACKER_TEMPLATE_URI=$(__get_path_from_string "$PACKER_TEMPLATE_URI")

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

		__copy_folder_content_into "$VAGRANT_BOX_OUTPUT_DIR" "$STELLA_APP_CACHE_DIR" "*.box"
		rm -f "$VAGRANT_BOX_OUTPUT_DIR/*.box"

		if [  -d "$STELLA_APP_CACHE_DIR/$VAGRANT_BOX_FILENAME" ]; then
			echo "** Box created"
		fi
	else
		echo "** Box already created"
	fi

	__import_box_into_vagrant $VAGRANT_BOX_NAME "$STELLA_APP_CACHE_DIR/$VAGRANT_BOX_FILENAME"

}

fi
