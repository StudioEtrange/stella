#!/bin/bash
# Usage :
# stella.sh include
# stella.sh bootstrap [install path] --- By default, use value setted in .-stella-link.sh
# stella.sh <standard stella command>

_SOURCE_ORIGIN_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_CALL_ORIGIN_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"



# Bootstrap/auto install mode ------------------
function bootstrap() {
	if [ "$IS_STELLA_LINKED" == "TRUE" ]; then
		echo "** This app is already linked to a STELLA installation located in $STELLA_ROOT"
		$STELLA_ROOT/tools.sh install default
	else

		# Try to determine install path of STELLA
		if [ "$ARG" == "" ]; then
			if [ ! "$STELLA_ROOT" == "" ]; then
				# install STELLA into STELLA_ROOT, and linked to the app
				git clone https://bitbucket.org/StudioEtrange/lib-stella.git "$STELLA_ROOT"
				echo "STELLA_ROOT=$STELLA_ROOT" >$_SOURCE_ORIGIN_FILE_DIR/.stella-link.sh
				$STELLA_ROOT/tools.sh install default
			else
				echo "** ERROR please specify an install path for STELLA"
			fi
		else
			# install path is specified in arg #2
			if [ -f "$ARG/stella.sh" ]; then
				# STELLA already installed, update it
				(cd "$ARG" && git pull)
				$STELLA_ROOT/tools.sh install default
			else
				# install STELLA into arg #2, and linked to the app
				git clone https://bitbucket.org/StudioEtrange/lib-stella.git "$ARG"
				echo "STELLA_ROOT=$ARG" >$_SOURCE_ORIGIN_FILE_DIR/.stella-link.sh
				$STELLA_ROOT/tools.sh install default
			fi
		fi
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


# Check if APP is linked to STELLA -------------------------
if [ -f "$_SOURCE_ORIGIN_FILE_DIR/.stella-link.sh" ]; then
	source "$_SOURCE_ORIGIN_FILE_DIR/.stella-link.sh"
	if [ ! "$STELLA_ROOT" == "" ]; then
		if [ -f "$STELLA_ROOT/stella.sh" ]; then
			IS_STELLA_LINKED="TRUE"
		fi
	fi
fi

# Switch mode ------------------
ACTION=$1
ARG=$2
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


