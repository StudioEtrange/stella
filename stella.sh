#!/bin/bash
_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
source $_CURRENT_FILE_DIR/conf.sh

function usage() {
	echo "USAGE :"
	echo "----------------"
	echo "List of commands"
	echo " o-- application management :"
	echo " L     app init <application name> [-approot=<path>] [-workroot=<abs or relative path to approot>] [-cachedir=<abs or relative path to approot>]"
	echo " L     app get-data get-assets <data OR assets id OR all>"
	echo " L     app setup-env <env id OR all> : download, build, deploy and run virtual environment based on app properties"
	echo " o-- tools management :"
	echo " L     tools install default : install default tools"
	echo " L     tools install <tool name> : install a tools"
	echo " L     tools install list : list available tools"
	echo " o-- virtual management :"
	echo " L     virtual create-env <env id> --distrib=<id> : create a new environment from a generic box prebuilt with a specific distribution"
	echo " L     virtual run-env stop-env destroy-env <env id> : manage environment"
	echo " L     virtual create-box get-box destroy-box <distrib id> : manage generic boxes built with a specific distribution"
	echo " L     virtual list <env|box> : list existing environment and box"
}


# MAIN -----------------------------------------------------------------------------------

# arguments
PARAMETERS="
DOMAIN=                          'domain'     		a           'app tools virtual'         										   				Action domain.
ACTION=                         'action'   					a           'init get-data get-assets setup-env install list create-env run-env stop-env destroy-env create-box get-box destroy-box'         	Action to compute.
ID=							 ''								s 			'' 						Data or Assets or Env or Box ID.
"
OPTIONS="
FORCE=''                       	'f'    		''            		b     		0     		'1'           			Force operation.
ARCH='x64'						'a'			''					a			0			'x86 x64'			Select architecture.
VERBOSE=$DEFAULT_VERBOSE_MODE		'v'			'level'				i		0			'0:2'					Verbose level : 0 (default) no verbose, 1 verbose, 2 ultraverbose.
APPROOT=''						'' 			'path'				s 			0			'' 						App path (default current)
WORKROOT='' 					'' 			'path'				s 			0			''						Work app path (default equal to app path)
CACHEDIR=''						'' 			'path'				s 			0			''						Cache folder path
ENVCPU=''						''			''					i 			0		''						Nb CPU attributed to the virtual env.
ENVMEM=''							''			''					i 			0		''						Memory attributed to the virtual env.
DISTRIB=''    						'd'     	'distribution' 		a 			0		'ubuntu64 debian64 centos64 archlinux boot2docker'		select a distribution.
VMGUI=''							''			''					b			0		'1'						Hyperviser head.
LOGIN=''							'l'			''					b			0		'1'						Autologin in env.
"

argparse "$0" "$OPTIONS" "$PARAMETERS" "Lib Stella" "$(usage)" "" "$@"

# common initializations
init_env



# --------------- APP ----------------------------
if [ "$DOMAIN" == "app" ]; then

	if [ "$ACTION" == "init" ]; then
		# first init STELLA
		# TODO init stella when creating each app ?
		sudo $STELLA_ROOT/init.sh
		if [ "$APPROOT" == "" ]; then
			APPROOT=$_CURRENT_RUNNING_DIR
		fi
		if [ "$WORKROOT" == "" ]; then
			WORKROOT=.
		fi
		if [ "$CACHEDIR" == "" ]; then
			CACHEDIR=$WORKROOT/cache
		fi

		init_app $ID $APPROOT $WORKROOT $CACHEDIR

		cd $APPROOT
		$STELLA_ROOT/tools.sh install default
	else

		if [ ! -f "$PROPERTIES" ]; then
			echo "** ERROR properties file does not exist"
			exit
		fi

		case $ACTION in
		    get-data)
				if [ "$ID" == "all" ]; then
					get_all_data
				else
					get_data $ID
				fi
				;;
			get-assets)
				if [ "$ID" == "all" ]; then
					get_all_assets
				else
					get_assets $ID
				fi
				;;
			setup-env)
				if [ "$ID" == "all" ]; then
					setup_all_env
				else
					setup_env $ID
				fi
				;;
			*)
				echo "use option --help for help"
				;;
		esac
	fi
fi


# --------------- TOOLS ----------------------------
if [ "$DOMAIN" == "tools" ]; then
	_tools_options="--arch=$ARCH -v $VERBOSE_MODE"
	if [ "$FORCE" == "1" ]; then
		_tools_options="$_tools_options -f"
	fi
	
	if [ "$ACTION" == "install" ]; then
		$STELLA_ROOT/tools.sh install $ID $_tools_options
	fi
fi


# --------------- VIRTUAL ----------------------------
if [ "$DOMAIN" == "virtual" ]; then
	_virtual_options="-v $VERBOSE_MODE"
	if [ "$FORCE" == "1" ]; then
		_virtual_options="$_virtual_options -f"
	fi
	if [ "$VMGUI" == "1" ]; then
		_virtual_options="$_virtual_options --vmgui"
	fi
	if [ "$LOGIN" == "1" ]; then
		_virtual_options="$_virtual_options -l"
	fi
	if [ ! "$ENVCPU" == "" ]; then
		_virtual_options="$_virtual_options --envcpu=$ENVCPU"
	fi
	if [ ! "$ENVMEM" == "" ]; then
		_virtual_options="$_virtual_options --envmem=$ENVMEM"
	fi

	if [ "$ACTION" == "list" ]; then
		if [ "$ID" == "env" ]; then
			$STELLA_ROOT/virtual.sh list-env $_virtual_options
		fi
		if [ "$ID" == "box" ]; then
			$STELLA_ROOT/virtual.sh list-box $_virtual_options
		fi
	fi

	if [ "$ACTION" == "create-env" ]; then
		$STELLA_ROOT/virtual.sh create-env --envname=$ID --distrib=$DISTRIB $_virtual_options
	fi

	if [ "$ACTION" == "run-env" ]; then
		$STELLA_ROOT/virtual.sh run-env --envname=$ID $_virtual_options
	fi

	if [ "$ACTION" == "stop-env" ]; then
		$STELLA_ROOT/virtual.sh stop-env --envname=$ID $_virtual_options
	fi

	if [ "$ACTION" == "destroy-env" ]; then
		$STELLA_ROOT/virtual.sh destroy-env --envname=$ID $_virtual_options
	fi

	if [ "$ACTION" == "info-env" ]; then
		$STELLA_ROOT/virtual.sh info-env --envname=$ID $_virtual_options
	fi

	if [ "$ACTION" == "create-box" ]; then
		$STELLA_ROOT/virtual.sh create-box --distrib=$ID $_virtual_options
	fi

	if [ "$ACTION" == "get-box" ]; then
		$STELLA_ROOT/virtual.sh get-box --distrib=$ID $_virtual_options
	fi

	if [ "$ACTION" == "destroy-box" ]; then
		$STELLA_ROOT/virtual.sh destroy-box --distrib=$ID $_virtual_options
	fi
fi



echo "** END **"