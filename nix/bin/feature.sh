#!/bin/bash
_STELLA_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $_STELLA_CURRENT_FILE_DIR/../../conf.sh


function usage() {
	echo "USAGE :"
	echo "----------------"
	echo "List of commands"
	echo " o-- Feature management :"
	echo " L     install <feature schema> [--depforce] [--depignore] : install a feature. [--depforce] will force to reinstall all dependencies.[--depignore] will ignore dependencies. schema = feature_name[#version][@arch][:binary|source][/os_restriction][\os_exclusion]"
	echo " L     remove <feature schema> : remove a feature"
	echo " L     list <all|feature name|active> : list all available features OR available versions of a feature OR current active features"
}




# MAIN ------------------------
PARAMETERS="
ACTION=											'action' 			a						'remove install list'					Action to compute. 'install' install feature specified by name argument.
ID= 											''					s 						'' 	Select feature to install. Use 'required' to install required features for Stella. 
"
OPTIONS="
FORCE=''                       	'f'    		''            		b     		0     		'1'           			Force operation.
DEPFORCE=''						''    		''            		b     		0     		'1'           			Force reinstallation of all dependencies.
DEPIGNORE=''						''    		''            		b     		0     		'1'           		Will not process any dependencies.
"

__argparse "$0" "$OPTIONS" "$PARAMETERS" "Stella feature management" "$(usage)" "" "$@"



# common initializations
__init_stella_env

_OPT=

case $ACTION in
	remove)
		__feature_remove $ID
		;;
    install)
		case $ID in
			*)
				[ "$DEPFORCE" == "1" ] && _OPT="$_OPT DEP_FORCE"
				[ "$DEPIGNORE" == "1" ] && _OPT="$_OPT DEP_IGNORE"
				__feature_install $ID "$_OPT"
				;;
		esac
		;;
	list)
		case $ID in
			all)
				#echo "all required -- $__STELLA_FEATURE_LIST"
				echo "all -- $__STELLA_FEATURE_LIST"
				;;
			active)
				echo $(__list_active_features)
				;;
			*)
				echo $(__list_feature_version $ID)
				;;
		esac
		;;
	*)
		echo "use option --help for help"
		;;
esac


echo "** END **"
