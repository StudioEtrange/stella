#!/bin/bash
_STELLA_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_STELLA_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
source $_STELLA_CURRENT_FILE_DIR/../../conf.sh


function usage() {
	echo "USAGE :"
	echo "----------------"
	echo "List of commands"
	echo " o-- Feature management :"
	echo " L     install default : install minimal default features for Stella"
	echo " L     install <feature name> --vers=<version> : install a feature. Version is optional"
	echo " L     <all|feature name> : list all available features OR available versions of a feature"
}

function __features_requirement() {
	echo "** Install required features"
	if [ ! -d "$STELLA_APP_FEATURE_ROOT" ]; then
		mkdir -p "$STELLA_APP_FEATURE_ROOT"
	fi
}





# MAIN ------------------------
PARAMETERS="
ACTION=											'action' 			a						'install list'					Action to compute. 'install' install feature specified by name argument.
ID= 											''					a 						'$__STELLA_FEATURE_LIST default all' 	Select feature to install. 'Autotools' means autoconf, automake, libtool, m4. Use 'default' to initialize minimal features for Stella. Use 'list' to list available features. 
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
			default)
				__features_requirement
				;;

			*)
				__install_feature $ID $VERS
				;;
		esac
		;;
	list)
		case $ID in
			all)
				echo "default all $__STELLA_FEATURE_LIST"
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
