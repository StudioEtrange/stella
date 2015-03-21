#!/bin/bash
_STELLA_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $_STELLA_CURRENT_FILE_DIR/conf.sh






function usage() {
	echo "USAGE :"
	echo "----------------"
	echo "List of commands"
	echo " o-- application management :"
	echo " L     app init <application name> [--approot=<path>] [--workroot=<abs or relative path to approot>] [--cachedir=<abs or relative path to approot>] [--samples]"
	echo " L     app get-data|get-assets|update-data|update-assets|revert-data|revert-assets <data id|assets id|all>"
	echo " L     app get-features all : install all features defined in app properties file"
	echo " L     app setup-env <env id|all> : download, build, deploy and run virtual environment based on app properties"
	echo " o-- feature management :"
	echo " L     feature install required : install required features for Stella"
	echo " L     feature install <feature schema|required>: install a feature. schema = feature_name[#version][@arch][/binary|source][:os_restriction]"
	echo " L     feature list <all|feature name|active> : list all available feature OR available versions of a feature OR current active features"
	echo " o-- virtual management :"
	echo " L     virtual create-env <env id#distrib id> [--head] [--vmem=xxxx] [--vcpu=xx] : create a new environment from a generic box prebuilt with a specific distribution"
    echo " L     virtual run-env <env id> [--login] : manage environment"
    echo " L     virtual stop-env|destroy-env <env id> : manage environment"
    echo " L     virtual create-box|get-box <distrib id> : manage generic boxes built with a specific distribution"
    echo " L     virtual list <env|box|distrib> : list existing available environment, box and distribution"
	echo " o-- stella various :"
	echo " L     stella api list : list public functions of stella api"
	echo " L     stella bootstrap env : launch a shell with all stella env var setted"
	echo " L  	 stella install dep : install all features and systems requirements for the current OS ($STELLA_CURRENT_OS)"
}


# MAIN -----------------------------------------------------------------------------------

# arguments
PARAMETERS="
DOMAIN=                          'domain'     		a           'app feature virtual stella'         										   				Action domain.
ACTION=                         'action'   					a           'api bootstrap install init get-data get-assets update-data update-assets revert-data revert-assets get-features setup-env install list create-env run-env stop-env destroy-env create-box get-box'         	Action to compute.
ID=							 ''								s 			'' 						Feature ID or Data or Assets or Env or Distrib ID.
"
OPTIONS="
FORCE=''                       	'f'    		''            		b     		0     		'1'           			Force operation.
APPROOT=''						'' 			'path'				s 			0			'' 						App path (default current)
WORKROOT='' 					'' 			'path'				s 			0			''						Work app path (default equal to app path)
CACHEDIR=''						'' 			'path'				s 			0			''						Cache folder path
VCPU=''							''			''					i 			0		''						Nb CPU attributed to the virtual env.
VMEM=''							''			''					i 			0		''						Memory attributed to the virtual env.
HEAD=''							''			''					b			0		'1'						Active hyperviser head.
LOGIN=''						'l'			''					b			0		'1'						Autologin in env.
SAMPLES=''                      ''         ''                  b           0       '1'                     Generate app samples.
"

__argparse "$0" "$OPTIONS" "$PARAMETERS" "Lib Stella" "$(usage)" "" "$@"


# --------------- APP ----------------------------
if [ "$DOMAIN" == "app" ]; then
	_app_options=
	if [ "$FORCE" == "1" ]; then
		_app_options="$_app_options -f"
	fi
	if [ ! "$APPROOT" == "" ]; then
		_app_options="$_app_options --approot=$APPROOT"
	fi
	if [ ! "$WORKROOT" == "" ]; then
		_app_options="$_app_options --workroot=$WORKROOT"
	fi
	if [ ! "$CACHEDIR" == "" ]; then
		_app_options="$_app_options --cachedir=$CACHEDIR"
	fi


	$STELLA_BIN/app.sh $ACTION $ID $_app_options
fi


# --------------- ENV ----------------------------
if [ "$DOMAIN" == "env" ]; then
	if [ "$ACTION" == "pop" ]; then
		if [ "$ID" == "stella" ]; then
			__init_stella_env
			__clone_stella_env
		fi
	fi
fi


# --------------- FEATURE ----------------------------
if [ "$DOMAIN" == "feature" ]; then
	_feature_options=
	if [ "$FORCE" == "1" ]; then
		_feature_options="$_feature_options -f"
	fi
	$STELLA_BIN/feature.sh $ACTION $ID $_feature_options

fi


# --------------- STELLA ----------------------------
if [ "$DOMAIN" == "stella" ]; then

	if [ "$ACTION" == "api" ]; then
		if [ "$ID" == "list" ]; then
			echo $(__api_list)
		fi
	fi

	if [ "$ACTION" == "bootstrap" ]; then
		if [ "$ID" == "env" ]; then
			__bootstrap_stella_env
		fi
	fi

	if [ "$ACTION" == "install" ]; then
		if [ "$ID" == "dep" ]; then
			__stella_requirement
		fi
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

	$STELLA_BIN/virtual.sh $ACTION $ID $_virtual_options
	
fi



echo "** END **"