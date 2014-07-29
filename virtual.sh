#!/bin/bash
_STELLA_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_STELLA_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
source $_STELLA_CURRENT_FILE_DIR/conf.sh


function __virtual_init_folder() {

	[ ! -d "$VIRTUAL_WORK_ROOT" ] && mkdir -p "$VIRTUAL_WORK_ROOT"
	[ ! -d "$VIRTUAL_ENV_ROOT" ] && mkdir -p "$VIRTUAL_ENV_ROOT"
	[ ! -d "$VIRTUAL_TEMPLATE_ROOT" ] && mkdir -p "$VIRTUAL_TEMPLATE_ROOT"	
}


# MAIN ------------------------
PARAMETERS="
ACTION=											'action' 			a			'create-env run-env stop-env info-env list-env destroy-env create-box get-box list-box list-distrib'		Action to compute.
"
OPTIONS="
DISTRIB=''    						'd'     	'distribution' 		a 			0		'$DISTRIB_LIST'		select a distribution.
FORCE=''							'f'			''					b			0		'1'						Force.
ENVNAME=''							'e'			''					s			0		''						Environment name.
LOGIN=''							'l'			''					b			0		'1'						Autologin in env.
ENVCPU=''							''			''					i 			0		''						Nb CPU attributed to the virtual env.
ENVMEM=''							''			''					i 			0		''						Memory attributed to the virtual env.
VMGUI=''							''			''					b			0		'1'						Hyperviser head.
"


__argparse "$0" "$OPTIONS" "$PARAMETERS" "Stella virtualization management" "Stella virtualization management" "" "$@"

# common initializations
__init_stella_env


if [ ! "$DISTRIB" == "" ]; then
	__set_matrix $DISTRIB
fi



case $ACTION in
	list-distrib)
		__list_distrib
		;;
    create-box)
		__virtual_init_folder
    	__create_box
    	;;
	get-box)
    	__get_box
    	;;
    list-box)
    	__list_box
    	;;
    create-env)
		__virtual_init_folder
    	__create_env
    	;;
    run-env)
		__virtual_init_folder
    	__run_env
    	;;
    stop-env)
		__virtual_init_folder
    	__stop_env
    	;;
    list-env)
    	__list_env
    	;;
    info-env)
		__virtual_init_folder
    	__info_env
    	;;
    destroy-env)
		__virtual_init_folder
    	__destroy_env
    	;;
	*)
		echo "use option --help for help"
	;;
esac


echo "** END **"
