#!/bin/bash
_STELLA_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_STELLA_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
source $_STELLA_CURRENT_FILE_DIR/conf.sh


function usage() {
	echo "USAGE :"
	echo "----------------"
	echo "List of commands"
	echo " o-- application management :"
	echo " L     app init <application name> [--approot=<path>] [--workroot=<abs or relative path to approot>] [--cachedir=<abs or relative path to approot>]"
	echo " L     app get-data get-assets update-data update-assets revert-data revert-assets <data id|assets id|all>"
	echo " L     app setup-env <env id|all> : download, build, deploy and run virtual environment based on app properties"
	echo " o-- tools management :"
	echo " L     tools install default : install default tools"
	echo " L     tools install <tool name#version> : install a tools. version is optionnal"
	echo " L     tools list <all|tool name> : list all available tools OR available versions of a tool"
	echo " o-- virtual management :"
	echo " L     virtual create-env <env id#distrib id> : create a new environment from a generic box prebuilt with a specific distribution"
	echo " L     virtual run-env stop-env destroy-env <env id> : manage environment"
	echo " L     virtual create-box get-box destroy-box <distrib id> : manage generic boxes built with a specific distribution"
	echo " L     virtual list <env|box|distrib> : list existing available environment, box and distribution"
	echo " o-- stella api :"
	echo " L     api list all : list public functions of stella api"
}


# MAIN -----------------------------------------------------------------------------------

# arguments
PARAMETERS="
DOMAIN=                          'domain'     		a           'app tools virtual api'         										   				Action domain.
ACTION=                         'action'   					a           'init get-data get-assets update-data update-assets revert-data revert-assets setup-env install list create-env run-env stop-env destroy-env create-box get-box destroy-box'         	Action to compute.
ID=							 ''								s 			'' 						Data or Assets or Env or Box ID.
"
OPTIONS="
FORCE=''                       	'f'    		''            		b     		0     		'1'           			Force operation.
ARCH='x64'						'a'			''					a			0			'x86 x64'			Select architecture.
APPROOT=''						'' 			'path'				s 			0			'' 						App path (default current)
WORKROOT='' 					'' 			'path'				s 			0			''						Work app path (default equal to app path)
CACHEDIR=''						'' 			'path'				s 			0			''						Cache folder path
ENVCPU=''						''			''					i 			0		''						Nb CPU attributed to the virtual env.
ENVMEM=''							''			''					i 			0		''						Memory attributed to the virtual env.
VMGUI=''							''			''					b			0		'1'						Hyperviser head.
LOGIN=''							'l'			''					b			0		'1'						Autologin in env.
"

__argparse "$0" "$OPTIONS" "$PARAMETERS" "Lib Stella" "$(usage)" "" "$@"

# common initializations
__init_stella_env

# --------------- APP ----------------------------
if [ "$DOMAIN" == "app" ]; then

	if [ "$ACTION" == "init" ]; then

		if [ "$APPROOT" == "" ]; then
			APPROOT=$_CURRENT_RUNNING_DIR
		fi
		if [ "$WORKROOT" == "" ]; then
			WORKROOT=.
		fi
		if [ "$CACHEDIR" == "" ]; then
			CACHEDIR=$WORKROOT/cache
		fi

		__init_app $ID $APPROOT $WORKROOT $CACHEDIR

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
					__get_all_data
				else
					__get_data $ID
				fi
				;;
			get-assets)
				if [ "$ID" == "all" ]; then
					__get_all_assets
				else
					__get_assets $ID
				fi
				;;
			udpate-data)
				__update_data $ID
				;;
			update-assets)
				__update_assets $ID
				;;
			revert-data)
				__revert_data $ID
				;;
			revert-assets)
				__revert_assets $ID
				;;
			setup-env)
				if [ "$ID" == "all" ]; then
					__setup_all_env
				else
					__setup_env $ID
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
	_tools_options="--arch=$ARCH"
	if [ "$FORCE" == "1" ]; then
		_tools_options="$_tools_options -f"
	fi
	
	if [ "$ACTION" == "install" ]; then
		VERS=
		if [[ ${ID} =~ "#" ]]; then
			VERS=${ID##*#}
			ID=${ID%#*}
		fi
		$STELLA_ROOT/tools.sh install $ID --vers=$VERS $_tools_options
	fi

	if [ "$ACTION" == "list" ]; then
		$STELLA_ROOT/tools.sh list $ID $_tools_options
	fi
fi


# --------------- API ----------------------------
if [ "$DOMAIN" == "api" ]; then

	if [ "$ACTION" == "list" ]; then
		echo $(__api_list)
	fi
fi


# --------------- VIRTUAL ----------------------------
if [ "$DOMAIN" == "virtual" ]; then
	_virtual_options=
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
		if [ "$ID" == "distrib" ]; then
			$STELLA_ROOT/virtual.sh list-distrib $_virtual_options
		fi
	fi

	if [ "$ACTION" == "create-env" ]; then
		DISTRIB=
		if [[ ${ID} =~ "#" ]]; then
			DISTRIB=${ID##*#}
			ID=${ID%#*}
		fi
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