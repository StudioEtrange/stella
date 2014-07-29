#!/bin/bash
_STELLA_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_STELLA_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
source $_STELLA_CURRENT_FILE_DIR/conf.sh

function __init_tools() {
	echo "** Initialize Tools"
	if [ ! -d "$STELLA_APP_TOOL_ROOT" ]; then
		mkdir -p "$STELLA_APP_TOOL_ROOT"
	fi

}





# MAIN ------------------------
PARAMETERS="
ACTION=											'action' 			a						'install list'					Action to compute. 'install' install tools specified by name argument.
ID= 											''					a 						'$TOOL_LIST default all' 	Select tool to install. 'Autotools' means autoconf, automake, libtool, m4. Use 'default' to initialize tools. Use 'list' to list available tools. 
"
OPTIONS="
FORCE=''                       	'f'    		''            		b     		0     		'1'           			Force operation.
VERS=''				''			''					s 			0			'' 						tool version
JOB='1'				'j'			'nb_job'			i			0			'1:100'					Number of jobs used by build tool. (Only for supported build tool)
"

__argparse "$0" "$OPTIONS" "$PARAMETERS" "Stella tools management" "Stella tools management" "" "$@"



# common initializations
__init_stella_env

BUILD_JOB=$JOB

case $ACTION in
    install)
		case $ID in
			default)
				__init_tools
				;;

			*)
				__install_feature $ID $VERS
				;;
		esac
		;;
	list)
		case $ID in
			all)
				echo "default $TOOL_LIST"
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
