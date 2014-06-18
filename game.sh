#!/bin/bash
FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $FILE_DIR/include.sh

function init_folder() {
	# Tree folder
	


	mkdir -p $DEST
	# R:\
	mkdir -p $DEST/pipeline
	mkdir -p $DEST/client
	mkdir -p $DEST/server
	mkdir -p $DEST/tools/ryzom
	mkdir -p $DEST/tools/nel
	# TODO External tools from lib ?
	# L:\
	mkdir -p $DEST/data
	# W:\
	mkdir -p $DEST/assets
	# T:\
	mkdir -p $DEST/build
	mkdir -p $DEST/build/export
	

	# where to extract binaries
	case $OUTPUT in
		Debug)
		  ROOT_SUFFIX=_dbg
	  	;;
		Release)
		  ROOT_SUFFIX=_rel
		;;
	esac

	case $EXTERNLIB in
		Debug)
		  ROOT_SUFFIX="$ROOT_SUFFIX"_libdbg
		  ;;
		Release)
		  ROOT_SUFFIX="$ROOT_SUFFIX"_librel
		  ;;
	esac

	CLIENT_BUILD_ROOT="$PROJECT_ROOT/build_$CLIENT_PLATFORM_SUFFIX/$CLIENT_OS/rc/client_$CLIENT_ARCH$ROOT_SUFFIX"
	SERVER_BUILD_ROOT="$PROJECT_ROOT/build_$SERVER_PLATFORM_SUFFIX/$SERVER_OS/rc/server_$SERVER_ARCH$ROOT_SUFFIX"
	RYZOM_TOOLS_BUILD_ROOT="$PROJECT_ROOT/build_$TOOLS_PLATFORM_SUFFIX/$TOOLS_OS/rc/rytool_$TOOLS_ARCH$ROOT_SUFFIX"
	NEL_TOOLS_BUILD_ROOT="$PROJECT_ROOT/build_$TOOLS_PLATFORM_SUFFIX/$TOOLS_OS/rc/nltool_$TOOLS_ARCH$ROOT_SUFFIX"
	

}


# extract game properties
function get_properties() {

	# ASSETS
	for a in DATA RAW_ASSETS EXPORTED_ASSETS; do
		get_key "$PROPERTIES" "$a" "$a"_MAIN_PACKAGE
		get_key "$PROPERTIES" "$a" "$a"_NUMBER
		_artefact_number="$a"_NUMBER
		_artefact_number=${!_artefact_number}
		[ "$_artefact_number" == "" ] && _artefact_number=0
		i=1
		while [ $i -le $_artefact_number ]; do
			get_key "$PROPERTIES" "$a" "$a"_OPTIONS_"$i"
			get_key "$PROPERTIES" "$a" "$a"_NAME_"$i"
			get_key "$PROPERTIES" "$a" "$a"_URI_"$i"
			get_key "$PROPERTIES" "$a" "$a"_GET_PROTOCOL_"$i"
			true $(( i++ ))
		done
	done

	
	# CLIENT
	get_key "$PROPERTIES" "CLIENT" "ARCH" "PREFIX"
	get_key "$PROPERTIES" "CLIENT" "ENV_ID" "PREFIX"

	# SERVER
	get_key "$PROPERTIES" "SERVER" "ARCH" "PREFIX"
	get_key "$PROPERTIES" "SERVER" "ENV_ID" "PREFIX"
	get_key "$PROPERTIES" "SERVER" "FRONTEND_IP" "PREFIX"

	# TOOLS
	get_key "$PROPERTIES" "TOOLS" "ARCH" "PREFIX"
	get_key "$PROPERTIES" "TOOLS" "ENV_ID" "PREFIX"

	# ENV
	get_key "$PROPERTIES" "ENV" ENV_NUMBER
	[ "$ENV_NUMBER" == "" ] && ENV_NUMBER=0
	i=1
	while [ $i -le $ENV_NUMBER ]; do
		get_key "$PROPERTIES" "ENV" ENV_NAME_"$i"
		get_key "$PROPERTIES" "ENV" ENV_OS_"$i"
		get_key "$PROPERTIES" "ENV" ENV_CPU_"$i"
		get_key "$PROPERTIES" "ENV" ENV_MEM_"$i"
		true $(( i++ ))
	done


	for a in TOOLS SERVER CLIENT; do
		_artefact_env_id="$a"_ENV_ID
		_artefact_env_id=${!_artefact_env_id}
		if [ "$_artefact_env_id" == "default" ]; then
			eval "$a"_OS=\$CURRENT_OS
			eval "$a"_PLATFORM=\$CURRENT_PLATFORM
			eval "$a"_PLATFORM_SUFFIX=\$CURRENT_PLATFORM_SUFFIX
		else
			_artefact_env_os=ENV_OS_"$_artefact_env_id"
			eval "$a"_OS='$(get_os_from_distro ${!_artefact_env_os})'
			eval "$a"_PLATFORM='$(get_platform_from_os ${!_artefact_env_os})'
			_artefact_platform="$a"_PLATFORM
			eval "$a"_PLATFORM_SUFFIX='$(get_platform_suffix ${!_artefact_platform})'
		fi
	done
}

# RESSOURCES ---------------------------------------
function get_ressources() {
	echo "* Grabbing media and data ressources"

	[ "$FORCE" == "1" ] && (
		del_folder "$DEST/data"
		del_folder "$DEST/assets"
	)
	mkdir -p "$DEST/data"
	mkdir -p "$DEST/assets"
	mkdir -p "$DEST/build/export"

	for a in DATA RAW_ASSETS EXPORTED_ASSETS; do
		_artefact_number="$a"_NUMBER
		_artefact_number=${!_artefact_number}
		_artefact_main_package="$a"_MAIN_PACKAGE
		_artefact_main_package=${!_artefact_main_package}
		_artefact_link=0
		if [ "$a" == "DATA" ]; then _artefact_dest="$DEST/data"; _artefact_link=0; fi
		if [ "$a" == "RAW_ASSETS" ]; then _artefact_dest="$ASSETS_REPOSITORY/RAW"; _artefact_link=1; _artefact_link_target="$DEST/assets"; fi
		if [ "$a" == "EXPORTED_ASSETS" ]; then _artefact_dest="$ASSETS_REPOSITORY/EXPORTED"; _artefact_link=1; _artefact_link_target="$DEST/build/export"; fi

		echo "* Get $a ressources"
		echo "* Main $a package is $_artefact_main_package"
		x=1
		while [ $x -le $_artefact_number ]; do
			_opt="$a"_OPTIONS_$x
			_opt=${!_opt}
			_uri="$a"_URI_$x
			_uri=${!_uri}
			_prot="$a"_GET_PROTOCOL_$x
			_prot=${!_prot}
			_name="$a"_NAME_$x
			_name=${!_name}
			
			_merge=
			_strip=
			for o in $_opt; do 
				[ "$o" == "MERGE" ] && _merge=MERGE
				[ "$o" == "STRIP" ] && _strip=STRIP
			done

			if [ "$_merge" == "MERGE" ]; then
				get_ressource "$a #$x [$_artefact_main_package - $_name]" "$_uri" "$_prot" "$_artefact_dest/$_artefact_main_package" "$_merge $_strip"
				echo "* $_name merged into $_artefact_main_package"
				if [ "$_artefact_link" == "1" ]; then
					if [ "$FORCE" == "1" ]; then rm -f "$_artefact_link_target/$_artefact_main_package"; fi
					[ ! -L "$_artefact_link_target/$_artefact_main_package" ] && (
						echo "** Make symbolic link for $_artefact_main_package"
						ln -s "$_artefact_dest/$_artefact_main_package" "$_artefact_link_target/$_artefact_main_package"
					)
				fi
			else
				get_ressource "DATA #$x [$_name]" "$_uri" "$_prot" "$_artefact_dest/$_name" "$_strip"
				if [ "$_artefact_link" == "1" ]; then
					if [ "$FORCE" == "1" ]; then rm -f "$_artefact_link_target/$_name"; fi
					[ ! -L "$_artefact_link_target/$_name" ] && (
						echo " ** Make symbolic link for $_name"
						ln -s "$_artefact_dest/$_name" "$_artefact_link_target/$_name"
					)
				fi
			fi
			true $(( x++ ))
		done
	done
}



# ENV MANAGEMENT ---------------------------
function create_envs() {
	i=1
	echo "** NOTE : set 1024M for each CPU"
	while [ $i -le $ENV_NUMBER ]; do
		_env_os=ENV_OS_$i
		_env_os=${!_env_os}
		_env_name=ENV_NAME_$i
		_env_name=${!_env_name}
		_env_cpu=ENV_CPU_$i
		_env_cpu=${!_env_cpu}
		_env_mem=ENV_MEM_$i
		_env_mem=${!_env_mem}
		$SCRIPT_ROOT/virtual.sh get-box --os=$_env_os
		$SCRIPT_ROOT/virtual.sh create-box --os=$_env_os
		$SCRIPT_ROOT/virtual.sh create-env --os=$_env_os --envname=$_env_name --envcpu=$_env_cpu --envmem=$_env_mem
		true $(( i++ ))
	done
}


function init_rcs_envs() {
	# log into envs and init rcs tools
	i=1
	while [ $i -le $ENV_NUMBER ]; do
		_env_os=ENV_OS_$i
		_env_os=$(get_os_from_distro "${!_env_os}")
		_env_name=ENV_NAME_$i
		_env_name=${!_env_name}
		_env_platform=$(get_platform_from_os "$_env_os")

		$SCRIPT_ROOT/virtual.sh run-env --envname=$_env_name

		cd "$VIRTUAL_ENV_ROOT/$_env_name"


		if [ "$_env_platform" == "windows" ]; then
			echo "TODO"
			#"$VAGRANT_CMD" ssh -c '/rcs/ryzomcore-script/linux/rcs.sh install'
		else
			"$VAGRANT_CMD" ssh -c "sudo /rcs/ryzomcore-script/linux/rcs.sh init"
		fi

		true $(( i++ ))
	done
}

function init_local_env() {
	sudo $SCRIPT_ROOT/rcs.sh init
	$SCRIPT_ROOT/rcs.sh install-rc
}

# BUILD ---------------------------------------
function build_client() {
	# execute RCS inside CLIENT_ENV
	if [ "$CLIENT_ENV_ID" == "default" ]; then
		$SCRIPT_ROOT/rcs.sh build --topic=lib --arch=$CLIENT_ARCH
		$SCRIPT_ROOT/rcs.sh build --topic=client --arch=$CLIENT_ARCH
	else
		if [ "$CLIENT_PLATFORM" == "windows" ]; then
			echo "TODO"
		else # platform linux OR macos
			_env_name=ENV_NAME_"$CLIENT_ENV_ID"
			_env_name=${!_env_name}
			_env_cpu=ENV_CPU_"$CLIENT_ENV_ID"
			_env_cpu=${!_env_cpu}
			cd "$VIRTUAL_ENV_ROOT/$_env_name"
			"$VAGRANT_CMD" ssh -c "/rcs/ryzomcore-script/linux/rcs.sh build --topic=lib --arch=$CLIENT_ARCH -j$_env_cpu"
			"$VAGRANT_CMD" ssh -c "/rcs/ryzomcore-script/linux/rcs.sh build --topic=client --arch=$CLIENT_ARCH -j$_env_cpu"
		fi
	fi
}

function build_server() {
	# execute RCS inside SERVER_ENV
	if [ "$SERVER_ENV_ID" == "default" ]; then
		$SCRIPT_ROOT/rcs.sh build --topic=lib --arch=$SERVER_ARCH
		$SCRIPT_ROOT/rcs.sh build --topic=server --arch=$SERVER_ARCH
	else
		if [ "$SERVER_PLATFORM" == "windows" ]; then
			echo "TODO"
		else # platform linux OR macos
			_env_name=ENV_NAME_"$SERVER_ENV_ID"
			_env_name=${!_env_name}
			_env_cpu=ENV_CPU_"$SERVER_ENV_ID"
			_env_cpu=${!_env_cpu}
			cd "$VIRTUAL_ENV_ROOT/$_env_name"
			"$VAGRANT_CMD" ssh -c "/rcs/ryzomcore-script/linux/rcs.sh build --topic=lib --arch=$SERVER_ARCH -j$_env_cpu"
			"$VAGRANT_CMD" ssh -c "/rcs/ryzomcore-script/linux/rcs.sh build --topic=server --arch=$SERVER_ARCH -j$_env_cpu"
		fi
	fi
}

function build_tools() {
	# execute RCS inside TOOLS_ENV
	if [ "$TOOLS_ENV_ID" == "default" ]; then
		$SCRIPT_ROOT/rcs.sh build --topic=lib --arch=$TOOLS_ARCH
		$SCRIPT_ROOT/rcs.sh build --topic=nel_tool --arch=$TOOLS_ARCH
		$SCRIPT_ROOT/rcs.sh build --topic=ryzom_tool --arch=$TOOLS_ARCH
	else
		if [ "$TOOLS_PLATFORM" == "windows" ]; then
			echo "TODO"
		else # platform linux OR macos
			_env_name=ENV_NAME_"$TOOLS_ENV_ID"
			_env_name=${!_env_name}
			_env_cpu=ENV_CPU_"$TOOLS_ENV_ID"
			_env_cpu=${!_env_cpu}
			cd "$VIRTUAL_ENV_ROOT/$_env_name"
			"$VAGRANT_CMD" ssh -c "/rcs/ryzomcore-script/linux/rcs.sh build --topic=lib --arch=$TOOLS_ARCH -j$_env_cpu"
			"$VAGRANT_CMD" ssh -c "/rcs/ryzomcore-script/linux/rcs.sh build --topic=nel_tool --arch=$TOOLS_ARCH -j$_env_cpu"
			"$VAGRANT_CMD" ssh -c "/rcs/ryzomcore-script/linux/rcs.sh build --topic=ryzom_tool --arch=$TOOLS_ARCH -j$_env_cpu"
		fi
	fi
}

# MAIN -----------------------------------------------------------------------------------

# arguments
PARAMETERS="
ACTION=                                   'action'   		a           'init-game build-tools build-client build-server deploy-server get-ressources'         	Action to compute.
GAME=                                     'name'     		s           ''         										   	Name of the game.
PROPERTIES=                               'file'     		s           ''         											Path to the game properties file.
"
OPTIONS="
FORCE=''                         	'f'    		''            		b     		0     		'1'           			Force.
OUTPUT='$DEFAULT_OUTPUT'			'o'			''					a			0			'release debug'			Select output mode
EXTERNLIB='$DEFAULT_EXTERNLIB'		''			''					a			0			'release debug'			Use external lib in release or debug version.
EXTERNLIBARCH=''					''			''					a			0			'x86 x64 arm'			Pick an arch for external (default same as targeted ARCH).
INITRCS=''							'i' 		'' 					b 			0 			'1'						Do we init rcs in local env while we init virtual env.
"

argparse "$0" "$OPTIONS" "$PARAMETERS" "RyzomCore Game" "RyzomCore Game" "" "$@"

# common initializations
init_arg
init_env
set_verbose_mode $VERBOSE_MODE


[ ! -f $PROPERTIES ] && (
	echo " ** ERROR game properties file does not exist"
	exit 
)

DEST="$GAMES_ROOT/$GAME"

get_properties


if [ "$ACTION" == "get-ressources" ]; then
	get_ressources
fi

if [ "$ACTION" == "init-game" ]; then
	
	init_folder
	if [ "$INITRCS" == "1" ]; then
		init_local_env
	fi
	create_envs
	init_rcs_envs
fi

if [ "$ACTION" == "build-server" ]; then
	build_server
	#get_rc "server"
fi

if [ "$ACTION" == "deploy-server" ]; then
	echo "TODO"
	#setup_server
fi

if [ "$ACTION" == "build-client" ]; then
	build_client
	#get_rc "client"
fi

if [ "$ACTION" == "build-tools" ]; then
	build_tool
	get_rc "tools"
	#setup_pipeline
fi

echo "** END **"