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


# INIT STELLA -------------

# by OS
function __stella_env_ubuntu() {
	echo " ** INFO : Needs sudouser rights" 
	sudo apt-get -y install mercurial unzip p7zip-full git wget
	sudo apt-get -y install bison util-linux build-essential gcc-multilib g++-multilib g++ pkg-config
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
	brew install gnu-getopt
	brew install p7zip
}

function __stella_env_debian() {
	echo " ** INFO : Needs sudouser rights" 
	sudo apt-get -y install mercurial unzip p7zip-full git wget
	sudo apt-get -y install bison util-linux build-essential gcc-multilib g++-multilib g++ pkg-config
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

#TODO
# from https://github.com/darkoperator/MSF-Installer/blob/master/msf_install.sh
function check_dependencies_osx
{
    # Get a list of all the packages installed on the system
    PKGS=`pkgutil --pkgs`
    print_status "Verifying that Development Tools and Java are installed:"
    if [[ $PKGS =~ 'com.apple.pkg.JavaForMacOSX' || $PKGS =~ com.oracle.jdk* ]] ; then
        print_good "Java is installed."
    else
        print_error "Java is not installed on this system."
        print_error "Run the command java in Terminal and install Java"
        exit 1
    fi

    if [[ $PKGS =~ com.apple.pkg.XcodeMAS ]] ; then
        print_good "Xcode is installed."
    else
        print_error "Xcode is not installed on this system. Install from the Apple AppStore."
        exit 1
    fi

    if [[ $PKGS =~ com.apple.pkg.DeveloperToolsCLI || $PKGS =~ com.apple.pkg.CLTools_Executables ]] ; then
        print_good "Command Line Development Tools is intalled."
    else
        print_error "Command Line Development Tools is not installed on this system."
        exit 1
    fi
}



fi
