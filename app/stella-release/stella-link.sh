#!/bin/bash
_STELLA_LINK_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export STELLA_ROOT=$_STELLA_LINK_CURRENT_FILE_DIR/../../../../stella
STELLA_DEP_FLAVOUR=DEV
STELLA_DEP_VERSION=LATEST
[ ! "$1" = "chaining" ] && export STELLA_APP_ROOT=$_STELLA_LINK_CURRENT_FILE_DIR

if [ ! "$1" = "nothing" ]; then
	if [ ! "$1" = "bootstrap" ]; then
		if [ ! -f "$STELLA_ROOT/stella.sh" ]; then
			if [ -f "$(dirname $_STELLA_LINK_CURRENT_FILE_DIR)/stella-link.sh" ]; then
				echo " ** Try to chain link stella from $(dirname $_STELLA_LINK_CURRENT_FILE_DIR)"
				source $(dirname $_STELLA_LINK_CURRENT_FILE_DIR)/stella-link.sh chaining
			else
				echo "** WARNING Stella is missing -- bootstraping stella"
				$_STELLA_LINK_CURRENT_FILE_DIR/stella-link.sh bootstrap
			fi
		fi
	fi
fi

ACTION=$1
case $ACTION in
	include)
		source "$STELLA_ROOT/conf.sh"
		__init_stella_env
		;;
	env)
		source "$STELLA_ROOT/conf.sh"
		__init_stella_env
		echo "** Current env is setted/refreshed with stella env"
		;;
	bootstrap)
		cd "$_STELLA_LINK_CURRENT_FILE_DIR"
		curl -sSL https://raw.githubusercontent.com/StudioEtrange/stella/master/nix/pool/stella-bridge.sh -o stella-bridge.sh
		chmod +x stella-bridge.sh
		./stella-bridge.sh bootstrap
		rm -f stella-bridge.sh
		;;
	nothing|chaining)
		;;
	*)
		$STELLA_ROOT/stella.sh $*
		;;
esac
