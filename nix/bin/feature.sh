#!/bin/bash
_STELLA_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_STELLA_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
source $_STELLA_CURRENT_FILE_DIR/../../conf.sh


function usage() {
	echo "USAGE :"
	echo "----------------"
	echo "List of commands"
	echo " o-- Feature management :"
	echo " L     install required : install minimal required features for Stella"
	echo " L     install <feature name> --vers=<version> : install a feature. Version is optional"
	echo " L     <all|feature name> : list all available features OR available versions of a feature"
}




# MAIN ------------------------
PARAMETERS="
ACTION=											'action' 			a						'install list'					Action to compute. 'install' install feature specified by name argument.
ID= 											''					a 						'$__STELLA_FEATURE_LIST required all' 	Select feature to install. 'Autotools' means autoconf, automake, libtool, m4. Use 'required' to install required features for Stella. Use 'list' to list available features. 
"
OPTIONS="
FORCE=''                       	'f'    		''            		b     		0     		'1'           			Force operation.
VERS=''							''			'version'			s 			0 		''						Feature version.
"

__argparse "$0" "$OPTIONS" "$PARAMETERS" "Stella feature management" "$(usage)" "" "$@"



# common initializations
__init_stella_env

#BUILD_JOB=$JOB

case $ACTION in
    install)
		case $ID in
			required)
				__stella_features_requirement_by_os $STELLA_CURRENT_OS
				;;

			*)
				__install_feature $ID $VERS
				;;
		esac
		;;
	list)
		case $ID in
			all)
				echo "required all $__STELLA_FEATURE_LIST"
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
