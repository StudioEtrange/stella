#!/bin/bash
_INCLUDED_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_CALLING_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
source $_INCLUDED_FILE_DIR/conf.sh


function usage() {
	echo "USAGE :"
	echo "----------------"
	echo "List of commands"
	echo " o-- application management :"
	echo " L     app init <application name> [-approot=<path>] [-workroot=<path>] [-cachedir=<path>]"
	echo " L     app get-data get-assets <data OR assets id OR all>"
	echo " L     app setup-env <env id OR all>"
	echo " o-- tools management :"
	echo " L     tools install default : install default tools"
	echo " L     tools install <tool name> : install a tools"
	echo " L     tools install list : list available tools"
	echo " o-- virtual management :"
	echo " L     virtual create-env run-env stop-env destroy-env <env id>"
	echo " L     virtual create-box get-box destroy-box <distrib id>"
}


# MAIN -----------------------------------------------------------------------------------

# arguments
PARAMETERS="
DOMAIN=                          'domain'     		a           'app tools virtual'         										   				Action domain.
ACTION=                         'action'   					a           'init get-data get-assets setup-env install create-env run-env stop-env destroy-env create-box get-box destroy-box'         	Action to compute.
ID=							 ''								s 			'' 						Data or Assets or Env or Box ID.
"
OPTIONS="	
FORCE=''                       	'f'    		''            		b     		0     		'1'           			Force operation.
ARCH='x64'						'a'			''					a			0			'x86 x64 arm'			Select architecture.
VERBOSE=$DEFAULT_VERBOSE_MODE		'v'			'level'				i		0			'0:2'					Verbose level : 0 (default) no verbose, 1 verbose, 2 ultraverbose.
APPROOT=''						'' 			'path'				s 			0			'' 						App path (default current)
WORKROOT='' 					'' 			'path'				s 			0			''						Work app path (default equal to app path)
CACHEDIR=''						'' 			'path'				s 			0			''						Cache folder path
"

argparse "$0" "$OPTIONS" "$PARAMETERS" "Lib Stella" "$(usage)" "" "$@"

# common initializations
init_env



# --------------- APP ----------------------------
if [ "$DOMAIN" == "app" ]; then

	if [ "$ACTION" == "init" ]; then
		sudo $STELLA_ROOT/init.sh
		if [ "$APPROOT" == "" ]; then
			APPROOT=$PROJECT_ROOT
		fi
		if [ "$WORKROOT" == "" ]; then
			WORKROOT=$APPROOT
		fi
		init_app $ID $APPROOT $WORKROOT

		cd $APPROOT
		$STELLA_ROOT/tools.sh install default
	else
		#select_app_properties
		if [ ! -f "$PROPERTIES" ]; then
			echo "** ERROR properties file does not exist"
			exit
		fi

		#get_all_properties

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
	#select_app_properties
	#get_all_properties

	if [ "$ACTION" == "install" ]; then
		$STELLA_ROOT/tools.sh install $ID $_tools_options
	fi
fi


# --------------- VIRTUAL ----------------------------
# TODO



echo "** END **"