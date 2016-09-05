#!/bin/bash
_STELLA_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $_STELLA_CURRENT_FILE_DIR/conf.sh

# NOTE : use this with source command only
# NOTE : warn some env var (like PATH) are cumulative
if [ "$1" == "env" ]; then
	__init_stella_env
	echo "** Current env is setted/refreshed with stella env"
else

function usage() {
	echo "USAGE :"
	echo "----------------"
	echo "List of commands"
	echo " o-- application management :"
	echo " L     app init <application name> [--approot=<path>] [--workroot=<abs or relative path to approot>] [--cachedir=<abs or relative path to approot>] [--samples]"
	echo " L     app get-data|get-assets|delete-data|delete-assets|update-data|update-assets|revert-data|revert-assets <data id|assets id>"
	echo " L     app get-data-pack|get-assets-pack|update-data-pack|update-assets-pack|revert-data-pack|revert-assets-pack|delete-data-pack|delete-assets-pack <data pack name|assets pack name>"
	echo " L     app get-feature <all|feature schema> : install all features defined in app properties file or install a matching one"
	echo " L     app link <app-path> [--stellaroot=<path>] : link an app to a specific stella path"
	echo " L     app deploy user@host:path [--cache] [--workspace] : : deploy current app version to an other target via ssh. [--cache] : include app cache folder. [--workspace] : include app workspace folder"
	echo " o-- feature management :"
	echo " L     feature install <feature schema> [--depforce] [--depignore] [--buildarch=x86|x64] [--export=<path>] [--portable=<path>] : install a feature. [--depforce] will force to reinstall all dependencies. [--depignore] will ignore dependencies. schema = feature_name[#version][@arch][:binary|source][/os_restriction][\\os_exclusion]"
	echo " L     feature remove <feature schema> : remove a feature"
	echo " L     feature list <all|feature name|active> : list all available feature OR available versions of a feature OR current active features"
	echo " o-- various :"
	echo " L     stella api list : list public functions of stella api"
	echo " L     stella install dep : install all features and systems requirements if any, for the current OS ($STELLA_CURRENT_OS)"
	echo " L     stella version print : print stella version"
	echo " L     stella search path : print current system search path"
	echo " L     stella deploy <user@host:path> [--cache] [--workspace] : deploy current stella version to an other target via ssh. [--cache] : include stella cache folder. [--workspace] : include stella workspace folder"
	echo " o-- network management :"
	echo " L     proxy on <name> : active a registered proxy"
	echo " L     proxy off now : disable proxy"
	echo " L     proxy register <name> --proxy=<user:password@host:port> : register a web proxy"
	echo " L     proxy bypass <host> : register a host that will not use proxy"
	echo " L		 proxy tunnel <name> --bridge=<user:password@host> : set a ssh tunnel from localhost to registered proxy <name> through a bridge, and set web traffic to use this tunnel as web proxy"
	echo " o-- bootstrap management :"
	echo " L     boot shell <uri> : launch an interactive new shell with all stella env var setted inside an <uri> (use 'local' for current host)"
	echo " L     boot cmd <uri> -- <command> : execute a command with all stella env var setted inside an <uri> (use 'local' for current host)"
	echo " L     boot script <uri> -- <script_path>"
	echo " o-- system package management : WARN This will affect your system"
	echo " L     sys install <package name> : install  a system package"
	echo " L     sys remove <package name> : remove a system package"
	echo " L     sys list all : list all available system package name"
	echo ""
	echo "Special Usage"
	echo " o-- env management :"
	echo " L     source <stella.sh|stella-link.sh> env : set the current shell env with all stella env var setted"


}


# MAIN -----------------------------------------------------------------------------------

# arguments
PARAMETERS="
DOMAIN=                          'domain'     		a           'app feature stella proxy sys boot'         										   				Action domain.
ACTION=                         'action'   					a           'deploy script shell cmd version search remove on off register link api install init get-data get-assets get-data-pack get-assets-pack delete-data delete-data-pack delete-assets delete-assets-pack update-data update-assets revert-data revert-assets update-data-pack update-assets-pack revert-data-pack revert-assets-pack get-feature install list'         	Action to compute.
ID=							 								''								s 						''
"
OPTIONS="
FORCE=''                       	'f'    		''            		b     		0     		'1'           			Force operation.
APPROOT=''						'' 			'path'				s 			0			'' 						App path (default current)
WORKROOT='' 					'' 			'path'				s 			0			''						Work app path (default equal to app path)
CACHEDIR=''						'' 			'path'				s 			0			''						Cache folder path
STELLAROOT=''                   ''          'path'              s           0           ''                      Stella path to link.
SAMPLES=''                      ''         ''                  b           0       '1'                     Generate app samples.
BRIDGE='' 						'' 			'uri'				s 			0			''					bridge uri in case of a web proxy tunnel
PROXY='' 					'' 			'uri'				s 			0			''					proxy uri
DEPFORCE=''						''    		''            		b     		0     		'1'           			Force reinstallation of all dependencies.
DEPIGNORE=''					''    		''            		b     		0     		'1'           		Will not process any dependencies.
EXPORT=''                     ''          'path'              s           0           ''                      	Export feature to this dir.
PORTABLE=''                   ''          'path'              s           0           ''                      Make a portable version of this feature in this dir
BUILDARCH=''				'a'				'arch'			a 			0 			 'x86 x64'
CACHE=''                       	''    		''            		b     		0     		'1'           			Include cache folder when deploying.
WORKSPACE=''                       	''    		''            		b     		0     		'1'           			Include workspace folder when deploying.
"

__argparse "$0" "$OPTIONS" "$PARAMETERS" "Stella" "$(usage)" "OTHERARG" "$@"


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
	if [ ! "$STELLAROOT" == "" ]; then
		_app_options="$_app_options --stellaroot=$STELLAROOT"
	fi


	$STELLA_BIN/app.sh $ACTION $ID $_app_options
fi



# --------------- FEATURE ----------------------------
if [ "$DOMAIN" == "feature" ]; then
	_feature_options=
	if [ "$FORCE" == "1" ]; then
		_feature_options="$_feature_options -f"
	fi
	if [ ! "$BUILDARCH" == "" ]; then
		_feature_options="$_feature_options --buildarch=$BUILDARCH"
	fi
	if [ ! "$EXPORT" == "" ]; then
		_feature_options="$_feature_options --export=$EXPORT"
	fi
	if [ ! "$PORTABLE" == "" ]; then
		_feature_options="$_feature_options --portable=$PORTABLE"
	fi
	$STELLA_BIN/feature.sh $ACTION $ID $_feature_options

fi


# --------------- SYS ----------------------------
if [ "$DOMAIN" == "sys" ]; then
	__init_stella_env
	if [ "$ACTION" == "install" ]; then
		__sys_install "$ID"
	fi
	if [ "$ACTION" == "remove" ]; then
		__sys_remove "$ID"
	fi
	if [ "$ACTION" == "list" ]; then
		echo "$STELLA_SYS_PACKAGE_LIST"
	fi
fi

# --------------- BOOT ----------------------------
if [ "$DOMAIN" == "boot" ]; then
	__init_stella_env

	if [ "$ACTION" == "cmd" ]; then
		__boot_cmd "$ID" "$OTHERARG"
	fi

	if [ "$ACTION" == "shell" ]; then
		__boot_shell "$ID"
	fi


	if [ "$ACTION" == "script" ]; then
		__boot_script "$ID" "$OTHERARG"
	fi
fi

# --------------- PROXY ----------------------------
if [ "$DOMAIN" == "proxy" ]; then
	__init_stella_env

	if [ "$ACTION" == "tunnel" ]; then
		__proxy_tunnel "$ID" "$BRIDGE"
	fi
	if [ "$ACTION" == "on" ]; then
		__enable_proxy "$ID"
	fi

	if [ "$ACTION" == "off" ]; then
		__disable_proxy
	fi
	if [ "$ACTION" == "bypass" ]; then
		__register_no_proxy "$ID"
	fi
	if [ "$ACTION" == "register" ]; then
		__register_proxy "$ID" "$PROXY"
	fi
fi

# --------------- STELLA ----------------------------
if [ "$DOMAIN" == "stella" ]; then
	__init_stella_env

	if [ "$ACTION" == "api" ]; then
		if [ "$ID" == "list" ]; then
			echo "$(__api_list)"
		fi
	fi



	if [ "$ACTION" == "install" ]; then
		if [ "$ID" == "dep" ]; then
			__stella_requirement
		fi
	fi

	if [ "$ACTION" == "version" ]; then
		if [ "$ID" == "print" ]; then
			v1=$(__get_stella_flavour)
			v2=$(__get_stella_version)
			echo $v1 -- $v2
		fi

	fi


	if [ "$ACTION" == "search" ]; then
	    if [ "$ID" == "path" ]; then
	        echo "$(__get_active_path)"
	    fi
	fi

	if [ "$ACTION" == "deploy" ]; then
		_deploy_options=
		[ "$CACHE" == "1" ] && _deploy_options="CACHE"
		[ "$WORKSPACE" == "1" ] && _deploy_options="$_deploy_options WORKSPACE"
		__transfert_stella "$ID" "$_deploy_options"
	fi

fi





echo "** END **"
fi
