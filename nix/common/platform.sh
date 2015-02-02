if [ ! "$_STELLA_PLATFORM_INCLUDED_" == "1" ]; then
_STELLA_PLATFORM_INCLUDED_=1


# DISTRIB/OS/PLATFORM INFO ---------------------------

# NOTE :
# classification :
# 	platform <--- os <---- distrib
# 		example :
#			linux <----- ubuntu <---- ubuntu 14.04
#			linux <----- centos <---- centos 6
#			windows <--- windows <---- windows 7
# suffix platform :
# 	each platform have a suffix
#		example :
#			windows <---> win
#			linux <---> linux

function __get_os_from_distro() {
	local _os=$1

	case $_os in
		Ubuntu|ubuntu*)
			echo "ubuntu"
			;;
		Debian|debian*)
			echo "debian"
			;;
		centos*)
			echo "centos"
			;;
		archlinux*)
			echo "archlinux"
			;;
		boot2docker*)
			echo "linuxgeneric"
			;;
		"Mac OS X"|macos)
			echo "macos"
			;;
		windows*)
			echo "windows"
			;;
		*)
			echo "unknown"
			;;
	esac	
}

function __get_platform_from_os() {
	local _os=$1

	case $_os in
		centos*|archlinux*|ubuntu*|debian*|linuxgeneric*)
			echo "linux"
			;;
		macos)
			echo "macos"
			;;
		windows)
			echo "windows"
			;;
		*)
			echo "unknown"
			;;
	esac	
}

function __get_platform_suffix() {
	local _platform=$1

	case $_platform in
		linux)
			echo "linux"
			;;
		macos)
			echo "macos"
			;;
		windows)
			echo "win"
			;;
		*)
			echo "unknown"
			;;
	esac	
}

function __set_current_platform_info() {
	# Linux
	if [[ -n `which lscpu 2> /dev/null` ]]; then
		STELLA_HOST_CPU=`lscpu | awk 'NR== 1 {print $2}'`
	# MacOS
	elif [[ -n `which sysctl 2> /dev/null` ]]; then
		STELLA_HOST_CPU=`sysctl hw 2> /dev/null | egrep -i 'hw.machine' | awk '{print $NF}'`
	else
		STELLA_HOST_CPU="cannot determine cpu"
	fi

	# linux
	if [[ -n `which nproc 2> /dev/null` ]]; then
		STELLA_NB_CPU=`nproc`
	# MacOs
	elif [[ -n `which sysctl 2> /dev/null` ]]; then
		STELLA_NB_CPU=`sysctl hw.ncpu 2> /dev/null | awk '{print $NF}'`
	else
		STELLA_NB_CPU=0
	fi


	detectdistro
	STELLA_CURRENT_OS=$(__get_os_from_distro "$distro")
	STELLA_CURRENT_PLATFORM=$(__get_platform_from_os "$STELLA_CURRENT_OS")
	STELLA_CURRENT_PLATFORM_SUFFIX=$(__get_platform_suffix "$STELLA_CURRENT_PLATFORM")

	
	
	__override_platform_command



}


function __override_platform_command() {
	#http://unix.stackexchange.com/questions/30091/fix-or-alternative-for-mktemp-in-os-x
	if [ "$STELLA_CURRENT_PLATFORM" == "macos" ]; then
		function mktmp() {
			local tempfile=$(mktemp -t stella)
	    	echo "$tempfile"
		}
		function mktmpdir(){
			local tempdir=$(mktemp -d -t stella)
	    	echo "$tempdir"
		}
	else
		function mktmp() {
			local tempfile=$(mktemp)
	    	echo "$tempfile"
		}
		function mktmpdir() {
			local tempdir=$(mktemp -d)
	    	echo "$tempdir"
		}
	fi

	if [ "$STELLA_CURRENT_PLATFORM" == "macos" ]; then
		GETOPT_CMD="$(brew --prefix)/opt/gnu-getopt/bin/getopt"
	else
		GETOPT_CMD=getopt
	fi


}


# MACOS specific build : install_name, rpath, loader_path, executable_path ---------------------------

# we dont use this for feature, because feature are installed inside stella app and do not need rpath or loader path
function __fix_dynamiclib_rpath_macos() {
	echo "TODO"
	# use install_name_tool to add "@loader_path/" as rpath (and maybe "." too)

}

function __fix_dynamiclib_install_name_macos() {
	local _lib=$1

	if [ -f "$_lib" ]; then
		_original_install_name=$(otool -l $_lib | grep -E "LC_ID_DYLIB" -A2 | grep name | tr -s ' ' | cut -d ' ' -f 3)

		case $_original_install_name in
			@rpath*)
			;;

			*)
				_new_install_name=@rpath/$(__get_filename_from_string $_original_install_name)
				install_name_tool -id "$_new_install_name" $_lib
			;;

		esac
	fi

}


function __fix_all_dynamiclib_install_name_macos() {
	for f in  "$1"/*; do
		[ -d "$f" ] && __fix_all_dynamiclib_install_name_macos "$f"
		if [ -f "$f" ]; then
			case $f in
				*.dylib) __fix_dynamiclib_install_name_macos "$f"
				;;
			esac
		fi
	done
}


# INIT STELLA -------------

# by OS
function __stella_env_ubuntu() {
	echo " ** INFO : Needs sudouser rights" 
	apt-get -y install mercurial unzip p7zip-full git wget
	apt-get -y install bison util-linux build-essential gcc-multilib g++-multilib g++ pkg-config
}

function __stella_env_macos() {
	
	echo " ** Check Homebrew"
	if which brew 2> /dev/null; then
    	local _brewLocation=`which brew`
    	local _appLocation=`brew --prefix`
    	echo "Homebrew is installed in $_brewLocation"
    	echo "Homebrew apps are run from $_appLocation"
	else
   		echo "** Can't find Homebrew, so install it"
   		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	fi

	echo " ** Install system requirements with brew"
	brew install getopt
	brew install p7zip
}

function __stella_env_debian() {
	echo " ** INFO : Needs sudouser rights" 
	apt-get -y install mercurial unzip p7zip-full git wget
	apt-get -y install bison util-linux build-essential gcc-multilib g++-multilib g++ pkg-config
}




function __stella_system_requirement_by_os() {
	local _os=$1

	echo "** Install Stella system requirements for $_os"
	case $_os in
		ubuntu)
			__stella_env_ubuntu
			;;
		debian)
			__stella_env_debian
			;;
		macos)
			__stella_env_macos
			;;
		*)
			echo "OS unknown"
			;;
	esac	
}



function __stella_features_requirement_by_os() {
	local _os=$1
	echo "** Install required features for $_os"
	case $_os in
		ubuntu)
			# __install_feature "test" "Z" "HIDDEN"
			;;
		debian)
			;;
		macos)
			# TODO feature getopt ? instead of macport ?
			;;
		*)
			echo "OS unknown"
			;;
	esac	
}




fi
