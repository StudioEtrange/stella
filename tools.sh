#!/bin/bash
_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
source $_CURRENT_FILE_DIR/conf.sh

function __init_tools() {
	echo "** Initialize Tools"
	if [ ! -d "$TOOL_ROOT" ]; then
		mkdir -p "$TOOL_ROOT"
	fi

}





# MAIN ------------------------
PARAMETERS="
ACTION=											'action' 			a						'install list'					Action to compute. 'install' install tools specified by name argument.
ID= 											''					a 						'$TOOL_LIST default all' 	Select tool to install. 'Autotools' means autoconf, automake, libtool, m4. Use 'default' to initialize tools. Use 'list' to list available tools. 
"
OPTIONS="
ARCH='x64'			'a'			''					a			0			'x86 x64 arm'			Select architecture.
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
				__install_feature $ID $VER
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
