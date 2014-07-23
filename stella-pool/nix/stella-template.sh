#!/bin/bash
# Usage :
# stella.sh include
# stella.sh bootstrap [install path] --- absolute or relative to app path where to install STELLA the system. If not provided, use setted value in link file (.-stella-link.sh) or in ../lib-stella by default
# stella.sh <standard stella command>

_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"



# Bootstrap/auto install mode ------------------
function bootstrap() {
	if [ "$IS_STELLA_LINKED" == "TRUE" ]; then
		echo "** This app is already linked to a STELLA installation located in $STELLA_ROOT"
		$STELLA_ROOT/tools.sh install default
	else

		# Try to determine install path of STELLA
		if [ "$PROVIDED_PATH" == "" ]; then
			if [ ! "$STELLA_ROOT" == "" ]; then
				# install STELLA into STELLA_ROOT, and linked to the app
				_STELLA_INSTALL_PATH=$(rel_to_abs_path "$STELLA_ROOT" "$APP_ROOT")
				echo "STELLA_ROOT=$STELLA_ROOT" >$APP_ROOT/.stella-link.sh
			else
				# install STELLA into default path, and linked to the app
				_STELLA_INSTALL_PATH=$(rel_to_abs_path "../lib-stella" "$APP_ROOT")
				echo "STELLA_ROOT=../lib-stella" >$APP_ROOT/.stella-link.sh
			fi
			git clone https://bitbucket.org/StudioEtrange/lib-stella.git "$_STELLA_INSTALL_PATH"
		else
			# install STELLA into ARG#2, and linked to the app
			_STELLA_INSTALL_PATH=$(rel_to_abs_path "$PROVIDED_PATH" "$APP_ROOT")
			if [ -f "$_STELLA_INSTALL_PATH/stella.sh" ]; then
				# STELLA already installed, update it
				(cd "$_STELLA_INSTALL_PATH" && git pull)
			else
				# install STELLA into arg #2, and linked to the app
				git clone https://bitbucket.org/StudioEtrange/lib-stella.git "$_STELLA_INSTALL_PATH"
			fi
			echo "PROVIDED_PATH=$ARG" >$APP_ROOT/.stella-link.sh
		fi
		$_STELLA_INSTALL_PATH/tools.sh install default
	fi
}


# Include mode ------------------
function include() {
	if [ "$IS_STELLA_LINKED" == "TRUE" ]; then
		source "$STELLA_ROOT/include.sh"
	else
		echo "** ERROR This app is not linked to a STELLA install path"
	fi
}


# MAIN ------------------
IS_STELLA_LINKED="FALSE"
STELLA_ROOT=

APP_ROOT=$_CURRENT_FILE_DIR

# Check if APP is linked to STELLA -------------------------
if [ -f "$APP_ROOT/.stella-link.sh" ]; then
	source "$APP_ROOT/.stella-link.sh"
	if [ ! "$STELLA_ROOT" == "" ]; then
		if [ -f "$STELLA_ROOT/stella.sh" ]; then
			IS_STELLA_LINKED="TRUE"
		fi
	fi
fi

# Switch mode ------------------
ACTION=$1
PROVIDED_PATH=$2
case $ACTION in
	include)
		include
		;;
	bootstrap)
		bootstrap
		;;
	*)
		# Standard mode
		if [ "$IS_STELLA_LINKED" == "FALSE" ]; then
			echo "** ERROR This app is not linked to a STELLA installation path"
		else
			$STELLA_ROOT/stella.sh $*
		fi
		;;
esac


