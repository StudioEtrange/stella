if [ ! "$_STELLA_COMMON_VIRTUAL_INCLUDED_" == "1" ]; then 
_STELLA_COMMON_VIRTUAL_INCLUDED_=1

function __list_distrib() {
	echo "$DISTRIB_LIST"
}

function __list_env() {
	"$VAGRANT_CMD" global-status
}


function __info_env() {
	if [ "$ENVNAME" == "" ]; then
		echo "** ERROR Please specify an env name"
		return
	fi

	cd "$VIRTUAL_ENV_ROOT/$ENVNAME"
	"$VAGRANT_CMD" status
	"$VAGRANT_CMD" ssh-config
}


function __create_env() {
	if [ "$ENVNAME" == "" ]; then
		echo "** ERROR Please specify an env name"
		return
	fi

	if [ "$VAGRANT_BOX_NAME" == "" ]; then
		echo "** Error please select a distribution"
		return
	fi

	if [ "$FORCE" == "1" ]; then
		__destroy_env
	fi

	if [ -d "$VIRTUAL_ENV_ROOT/$ENVNAME" ]; then
		echo "** Env $ENVNAME already exist"
	else

		# Re importing box into vagrant in case of
		if [ -f "$STELLA_APP_CACHE_DIR/$VAGRANT_BOX_FILENAME" ]; then
			__import_box_into_vagrant $VAGRANT_BOX_NAME "$STELLA_APP_CACHE_DIR/$VAGRANT_BOX_FILENAME"
		fi

		[ ! -d "$VIRTUAL_ENV_ROOT/$ENVNAME" ] && mkdir -p "$VIRTUAL_ENV_ROOT/$ENVNAME"
		
		cd "$VIRTUAL_ENV_ROOT/$ENVNAME"
		"$VAGRANT_CMD" init "$VAGRANT_BOX_NAME"

		echo "Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|" >> Vagrantfile
		echo 'config.vm.synced_folder "../../../.", "/stella"' >> Vagrantfile
		echo 'config.vm.provider "virtualbox" do |vb|' >> Vagrantfile
		[ "$VMGUI" == "1" ] && echo 'vb.gui = true' >> Vagrantfile
		[ ! "$VMGUI" == "1" ] && echo 'vb.gui = false' >> Vagrantfile
		[ ! "$ENVMEM" == "" ] && echo 'vb.customize ["modifyvm", :id, "--memory", "'$ENVMEM'"]' >> Vagrantfile
		[ ! "$ENVCPU" == "" ] && echo 'vb.customize ["modifyvm", :id, "--cpus", "'$ENVCPU'"]' >> Vagrantfile
		echo "end" >> Vagrantfile
		echo "end" >> Vagrantfile

		echo "** Env $ENVNAME is initialized"

	fi
}


function __run_env() {
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
	__info_env

	echo "** Now you can CD into $VIRTUAL_ENV_ROOT/$ENVNAME"
	echo "** and do vagrant ssh"
	if [ "$LOGIN" == "1" ]; then
		echo "** You should type 'vagrant ssh' in the new opened command line to get into your VM"
	fi
}



function __destroy_env() {
	if [ -d "$VIRTUAL_ENV_ROOT/$ENVNAME" ]; then
		cd "$VIRTUAL_ENV_ROOT/$ENVNAME"
		"$VAGRANT_CMD" destroy -f
		cd "$VIRTUAL_ENV_ROOT"
		__del_folder "$VIRTUAL_ENV_ROOT/$ENVNAME"
		echo "** Env $ENVNAME is destroyed"
	fi
}


function __stop_env() {
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


function __set_matrix() {
	local _distrib=$1
	
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

function __get_box() {
	if [ "$VAGRANT_BOX_URI" == "" ]; then
		echo "** Error We do not have any URL for a prebuilt box corresponding to this distribution"
		return
	fi
	[ "$FORCE" ] && (
		rm -f "$STELLA_APP_CACHE_DIR/$VAGRANT_BOX_FILENAME"
	)
	__get_ressource "$DISTRIB" "$VAGRANT_BOX_URI" "$VAGRANT_BOX_URI_PROTOCOL"
	__import_box_into_vagrant $VAGRANT_BOX_NAME "$STELLA_APP_CACHE_DIR/$VAGRANT_BOX_FILENAME"
}

function __list_box() {
	"$VAGRANT_CMD" box list	
}

function __create_box() {
	
	if [ "$PACKER_TEMPLATE" == "" ]; then
		echo "** Error please select a distribution"
		return
	fi

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
