#!/bin/bash
_STELLA_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $_STELLA_CURRENT_FILE_DIR/../../conf.sh


function usage() {
	echo "USAGE :"
	echo "----------------"
	echo "List of commands"
	echo " o-- Feature management :"
	echo " L     install <feature schema> [--depforce] [--depignore] [--buildarch=x86|x64] [--export=<path>] [--portable=<path>] : install a feature. [--depforce] will force to reinstall all dependencies.[--depignore] will ignore dependencies. schema = feature_name[#version][@arch][:binary|source][/os_restriction][\\os_exclusion]"
	echo " L     remove <feature schema> : remove a feature"
	echo " L     list <all|feature name|active> : list all available features OR available versions of a feature OR current active features"

}




# MAIN ------------------------
PARAMETERS="
ACTION=											'action' 			a						'remove install list'					Action to compute. 'install' install feature specified by name argument.
ID= 											''					s 						'' 	Select feature to install.
"
OPTIONS="
FORCE=''                       	'f'    		''            		b     		0     		'1'           			Force operation.
DEPFORCE=''						''    		''            		b     		0     		'1'           			Force reinstallation of all dependencies.
DEPIGNORE=''						''    		''            		b     		0     		'1'           		Will not process any dependencies.
EXPORT=''                     ''          'path'              s           0           ''                      	Export feature to this dir.
PORTABLE=''                   ''          'path'              s           0           ''                      Make a portable version of this feature in this dir
BUILDARCH=''				'a'				'arch'			a 			0 			 'x86 x64'
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
		[ ! "$BUILDARCH" == "" ] && __set_build_mode_default "ARCH" "$BUILDARCH"
		case $ID in
			*)
				[ "$DEPFORCE" == "1" ] && _OPT="$_OPT DEP_FORCE"
				[ "$DEPIGNORE" == "1" ] && _OPT="$_OPT DEP_IGNORE"
				[ ! "$EXPORT" == "" ] && _OPT="$_OPT EXPORT $EXPORT"
				[ ! "$PORTABLE" == "" ] && _OPT="$_OPT PORTABLE $PORTABLE"
				__feature_install $ID "$_OPT"
				;;
		esac
		;;
	list)
		case $ID in
			all)
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
