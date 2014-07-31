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
	echo " L     app get-data|get-assets|update-data|update-assets|revert-data|revert-assets <data id|assets id|all>"
	echo " L     app setup-env <env id|all> : download, build, deploy and run virtual environment based on app properties"
	echo " o-- feature management :"
	echo " L     feature install default : install minimal default feature for Stella"
	echo " L     feature install <feature name> [--vers=<version>] : install a feature. Version is optional"
	echo " L     feature list <all|feature name> : list all available feature OR available versions of a feature"
	echo " o-- virtual management :"
	echo " L     virtual create-env <env id#distrib id> [--head] [--vmem=xxxx] [--vcpu=xx] : create a new environment from a generic box prebuilt with a specific distribution"
    echo " L     virtual run-env <env id> [--login] : manage environment"
    echo " L     virtual stop-env|destroy-env <env id> : manage environment"
    echo " L     virtual create-box|get-box <distrib id> : manage generic boxes built with a specific distribution"
    echo " L     virtual list <env|box|distrib> : list existing available environment, box and distribution"
	echo " o-- stella api :"
	echo " L     api list all : list public functions of stella api"
}


# MAIN -----------------------------------------------------------------------------------

# arguments
PARAMETERS="
DOMAIN=                          'domain'     		a           'app feature virtual api'         										   				Action domain.
ACTION=                         'action'   					a           'init get-data get-assets update-data update-assets revert-data revert-assets setup-env install list create-env run-env stop-env destroy-env create-box get-box'         	Action to compute.
ID=							 ''								s 			'' 						Feature ID or Data or Assets or Env or Distrib ID.
"
OPTIONS="
FORCE=''                       	'f'    		''            		b     		0     		'1'           			Force operation.
ARCH='x64'						'a'			''					a			0			'x86 x64'			Select architecture.
APPROOT=''						'' 			'path'				s 			0			'' 						App path (default current)
WORKROOT='' 					'' 			'path'				s 			0			''						Work app path (default equal to app path)
CACHEDIR=''						'' 			'path'				s 			0			''						Cache folder path
VCPU=''							''			''					i 			0		''						Nb CPU attributed to the virtual env.
VMEM=''							''			''					i 			0		''						Memory attributed to the virtual env.
HEAD=''							''			''					b			0		'1'						Active hyperviser head.
LOGIN=''						'l'			''					b			0		'1'						Autologin in env.
VERS=''							''			'version'			s 			0 		''						Feature version.
"

__argparse "$0" "$OPTIONS" "$PARAMETERS" "Lib Stella" "$(usage)" "" "$@"

# common initializations
__init_stella_env

# --------------- APP ----------------------------
if [ "$DOMAIN" == "app" ]; then

	if [ "$ACTION" == "init" ]; then

		if [ "$APPROOT" == "" ]; then
			APPROOT=$_STELLA_CURRENT_RUNNING_DIR
		fi
		if [ "$WORKROOT" == "" ]; then
			WORKROOT=.
		fi
		if [ "$CACHEDIR" == "" ]; then
			CACHEDIR=$WORKROOT/cache
		fi

		__init_app $ID $APPROOT $WORKROOT $CACHEDIR

		cd $APPROOT
		#$STELLA_ROOT/feature.sh install default
		./stella.sh feature install default
	else

		if [ ! -f "$_STELLA_APP_PROPERTIES_FILE" ]; then
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


# --------------- FEATURE ----------------------------
if [ "$DOMAIN" == "feature" ]; then
	_feature_options=
	if [ "$FORCE" == "1" ]; then
		_feature_options="$_feature_options -f"
	fi
	if [ ! "$VERS" == "" ]; then
		_feature_options="$_feature_options $VERS"
	fi
	
	$STELLA_ROOT/feature.sh $ACTION $ID $_feature_options

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
	if [ "$HEAD" == "1" ]; then
		_virtual_options="$_virtual_options --head"
	fi
	if [ "$LOGIN" == "1" ]; then
		_virtual_options="$_virtual_options -l"
	fi
	if [ ! "$VCPU" == "" ]; then
		_virtual_options="$_virtual_options --vcpu=$VCPU"
	fi
	if [ ! "$VMEM" == "" ]; then
		_virtual_options="$_virtual_options --vmem=$VMEM"
	fi

	$STELLA_ROOT/virtual.sh $ACTION $ID $_virtual_options
	
fi



echo "** END **"