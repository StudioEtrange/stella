#!/bin/bash
# Usage :
# stella-bridge.sh include
# stella-bridge.sh standalone [install path] --- Path where to install STELLA the system. If not provided use ./lib-stella by default
# stella-bridge.sh bootstrap [install path] --- boostrap a project based on stella. Provide an absolute or relative to app path where to install STELLA the system. If not provided, use setted value in link file (.-stella-link.sh) or in ./lib-stella by default
#										after installing stella, it will set the project for use stella (if not already done)
# stella.sh <standard stella command>

_STELLA_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_STELLA_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"

function ___rel_to_abs_path() {
	local _rel_path=$1
	local _abs_root_path=$2


	case $_rel_path in
		/*)
			# path is already absolute
			echo "$_rel_path"
			;;
		*)
			if [ "$_abs_root_path" == "" ]; then
				# relative to current path
				if [ -f "$_rel_path" ]; then
					echo "$(cd "$_rel_path" && pwd )"
				else
					echo "$_rel_path"
				fi
			else
				# relative to a given absolute path
				if [ -f "$_abs_root_path/$_rel_path" ]; then
					echo "$(cd "$_abs_root_path/$_rel_path" && pwd )"
				else
					echo "$_abs_root_path/$_rel_path"
				fi
			fi
			;;
	esac
}

function __get_stella() {
	local _ver=$1
	local _path=$2

	if [ "$_ver" == "git" ]; then
		git clone https://bitbucket.org/StudioEtrange/lib-stella.git "$_path"
	else
		curl -L -o "$_path"/$stella-nix-"$_ver".gz.sh http://studio-etrange.org/stella/stella-nix-"$_ver".gz.sh
		chmod +x "$_path"/$stella-nix-"$_ver".gz.sh
		./"$_path"/$stella-nix-"$_ver".gz.sh
		rm -f "$_path"/$stella-nix-"$_ver".gz.sh
	fi
}

function __ask_install_system_requirements() {
	echo "Do you wish to auto-install system requirements for stella ?"
	select yn in "Yes" "No"; do
	    case $yn in
	        Yes )
				__stella_system_requirement_by_os $STELLA_CURRENT_OS
				$STELLA_BIN/feature.sh install required
				break;;
	        No ) break;;
	    esac
	done
}

function __ask_init_app() {
		echo "Do you wish to init your stella app (create properties files, link app to stella...) ?"
		select yn in "Yes" "No"; do
		    case $yn in
		        Yes )
					_project_name=$(basename $_STELLA_CURRENT_RUNNING_DIR)
					read -p "What is your project name ? [$_project_name]" _temp_project_name
					if [ ! "$_temp_project_name" == "" ]; then
						_project_name=$_temp_project_name
					fi

					echo "Do you wish to generate a sample app for your project ?"
					select sample in "Yes" "No"; do
						case $sample in
							Yes )
								$STELLA_BIN/app.sh init $_project_name --samples
								break;;
							No )
								$STELLA_BIN/app.sh init $_project_name
								break;;
						esac
					done
					break;;

		        No ) break;;
		    esac
		done
}

# Install stella in standalone ------------------
function standalone() {
	# Try to determine install path of STELLA
	if [ "$PROVIDED_PATH" == "" ]; then
		# install STELLA into default path
		_STELLA_INSTALL_PATH=$(___rel_to_abs_path "./lib-stella" "$_STELLA_CURRENT_RUNNING_DIR")
	else
		# install STELLA into ARG#2
		_STELLA_INSTALL_PATH=$(___rel_to_abs_path "$PROVIDED_PATH" "$_STELLA_CURRENT_RUNNING_DIR")
	fi

	if [ -f "$_STELLA_INSTALL_PATH/stella.sh" ]; then
		# STELLA already installed, update it
		(cd "$_STELLA_INSTALL_PATH" && git pull)
	else
		__get_stella "git" "$_STELLA_INSTALL_PATH"
	fi

	source "$_STELLA_INSTALL_PATH/conf.sh"
	
	__ask_install_system_requirements
}


# Bootstrap a stella project ------------------
function bootstrap() {
	if [ "$IS_STELLA_LINKED" == "TRUE" ]; then
		echo "** This app/project is linked to a STELLA installation located in $STELLA_ROOT"
		
		source "$STELLA_ROOT/conf.sh"
		
		__ask_install_system_requirements
		__ask_init_app
	else

		# Try to determine install path of STELLA
		if [ "$PROVIDED_PATH" == "" ]; then
			if [ ! "$STELLA_ROOT" == "" ]; then
				# install STELLA into STELLA_ROOT, and re-link it to the project
				_STELLA_INSTALL_PATH=$(___rel_to_abs_path "$STELLA_ROOT" "$STELLA_APP_ROOT")
				#echo "STELLA_ROOT=$STELLA_ROOT" >$STELLA_APP_ROOT/.stella-link.sh
			else
				# install STELLA into default path, and link to the project
				_STELLA_INSTALL_PATH=$(___rel_to_abs_path "./lib-stella" "$STELLA_APP_ROOT")
				#echo "STELLA_ROOT=./lib-stella" >$STELLA_APP_ROOT/.stella-link.sh
			fi
			__get_stella "git" "$_STELLA_INSTALL_PATH"
		else
			# install STELLA into ARG#2, and linked to the app
			_STELLA_INSTALL_PATH=$(___rel_to_abs_path "$PROVIDED_PATH" "$STELLA_APP_ROOT")
			if [ -f "$_STELLA_INSTALL_PATH/stella.sh" ]; then
				# STELLA already installed, update it
				(cd "$_STELLA_INSTALL_PATH" && git pull)
			else
				# install STELLA into arg #2
				__get_stella "git" "$_STELLA_INSTALL_PATH"
			fi
		fi
		
		source "$_STELLA_INSTALL_PATH/conf.sh"

		__ask_install_system_requirements
		__ask_init_app

	fi
}


# Include mode ------------------
function include() {
	if [ "$IS_STELLA_LINKED" == "TRUE" ]; then
		source "$STELLA_ROOT/conf.sh"

		__init_stella_env
	else
		echo "** ERROR This app is not linked to a STELLA install path"
	fi
}


# MAIN ------------------
IS_STELLA_LINKED="FALSE"
STELLA_ROOT=

STELLA_APP_ROOT=$_STELLA_CURRENT_RUNNING_DIR

# Check if APP/PROJECT in current dir is linked to STELLA -------------------------
if [ -f "$STELLA_APP_ROOT/.stella-link.sh" ]; then
	source "$STELLA_APP_ROOT/.stella-link.sh"
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
	standalone)
		standalone
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


