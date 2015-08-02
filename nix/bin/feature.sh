#!/bin/bash
_STELLA_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $_STELLA_CURRENT_FILE_DIR/../../conf.sh


function usage() {
	echo "USAGE :"
	echo "----------------"
	echo "List of commands"
	echo " o-- Feature management :"
	echo " L     install required : install minimal required features for Stella"
	echo " L     install <feature schema|required> : install a feature. schema = feature_name[#version][@arch][:binary|source][/os_restriction][\os_exclusion]"
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
"

__argparse "$0" "$OPTIONS" "$PARAMETERS" "Stella feature management" "$(usage)" "" "$@"



# common initializations
__init_stella_env

#BUILD_JOB=$JOB

case $ACTION in
	remove)
		__feature_remove $ID
		;;
    install)
		case $ID in
			required)
				__stella_features_requirement_by_os $STELLA_CURRENT_OS
				;;

			*)
				__feature_install $ID
				;;
		esac
		;;
	list)
		case $ID in
			all)
				echo "all required -- $__STELLA_FEATURE_LIST"
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
