#!/bin/bash
_STELLA_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_STELLA_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
source $_STELLA_CURRENT_FILE_DIR/conf.sh

function usage() {
    echo "USAGE :"
    echo "----------------"
    echo "List of commands"
    echo " o-- virtual management :"
    echo " L     create-env <env id#distrib id> [--head] [--vmem=xxxx] [--vcpu=xx] : create a new environment from a generic box prebuilt with a specific distribution"
    echo " L     run-env <env id> [--login] : manage environment"
    echo " L     stop-env destroy-env <env id> : manage environment"
    echo " L     create-box get-box <distrib id> : manage generic boxes built with a specific distribution"
    echo " L     list <env|box|distrib> : list existing available environment, box and distribution"

}




# MAIN ------------------------
PARAMETERS="
ACTION=											'action' 			a			'create-env run-env stop-env info-env destroy-env list create-box get-box'		Action to compute.
ID=                                              ''                 s           ''                    Distrib ID or Env ID or Box ID or List target.
"
OPTIONS="
FORCE=''							'f'			''					b			0		'1'						Force.
LOGIN=''							'l'			''					b			0		'1'						Autologin in env.
VCPU=''							''			''					i 			0		''						Nb CPU attributed to the virtual env.
VMEM=''							''			''					i 			0		''						Memory attributed to the virtual env.
HEAD=''						       	''			''					b			0		'1'						Active hyperviser head.
"


__argparse "$0" "$OPTIONS" "$PARAMETERS" "Stella virtualization management" "$(usage)" "" "$@"

# common initializations
__init_stella_env



case $ACTION in
	list)
        case $ID in
            distrib)
                __list_distrib
                ;;
            box)
                __list_box
                ;;
            env)
                __list_env
                ;;
            *)
                echo " ** Error : list env or list box or list distrib"
                ;;
        esac
		;;
    create-box)
    	__create_box $ID
    	;;
	get-box)
    	__get_box $ID
    	;;
    create-env)
        local _distrib_id=
        if [[ ${ID} =~ "#" ]]; then
            _distrib_id=${ID##*#}
            ID=${ID%#*}
        fi
        local _opt=
        [ "$HEAD" ] && _opt="HEAD"
        [ ! "$VMEM" == "" ] && _opt="$_opt MEM $VMEM"
        [ ! "$VCPU" == "" ] && _opt="$_opt CPU $VCPU"
    	__create_env $ID $_distrib_id "$_opt"
    	;;
    run-env)
        if [ "$LOGIN" ]; then
    	   __run_env $ID "TRUE"
        else
           __run_env $ID
    	;;
    stop-env)
    	__stop_env $ID
    	;;
    info-env)
    	__info_env $ID
    	;;
    destroy-env)
    	__destroy_env $ID
    	;;
	*)
		echo "use option --help for help"
	;;
esac


echo "** END **"
