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
		"Red Hat Enterprise Linux")
			echo "rhel"
			;;
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
			echo "linuxgeneric"
			;;
	esac	
}

function __get_platform_from_os() {
	local _os=$1

	case $_os in
		centos|archlinux|ubuntu|debian|linuxgeneric|rhel)
			echo "linux"
			;;
		macos)
			echo "darwin"
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
		darwin)
			echo "darwin"
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
	

	



	



	detectdistro
	STELLA_CURRENT_OS=$(__get_os_from_distro "$distro")
	STELLA_CURRENT_PLATFORM=$(__get_platform_from_os "$STELLA_CURRENT_OS")
	STELLA_CURRENT_PLATFORM_SUFFIX=$(__get_platform_suffix "$STELLA_CURRENT_PLATFORM")

	
	# linux
	if [[ -n `which nproc 2> /dev/null` ]]; then
		STELLA_NB_CPU=`nproc`
	# Darwin
	elif [[ -n `which sysctl 2> /dev/null` ]]; then
		STELLA_NB_CPU=`sysctl hw.ncpu 2> /dev/null | awk '{print $NF}'`
	else
		STELLA_NB_CPU=1
	fi


	# http://stackoverflow.com/questions/246007/how-to-determine-whether-a-given-linux-is-32-bit-or-64-bit
	# http://stackoverflow.com/a/10140985
	# http://unix.stackexchange.com/a/24772

	# CPU 64Bits capable
	# Linux
	if [[ -n `which lscpu 2> /dev/null` ]]; then
		_cpu=`lscpu | awk 'NR== 1 {print $2}' | grep 64`
		if [ "$_cpu" == "" ]; then
			STELLA_CPU_ARCH=32
		else
			STELLA_CPU_ARCH=64
		fi

	# Darwin
	elif [[ -n `which sysctl 2> /dev/null` ]]; then
		_cpu=`sysctl hw.cpu64bit_capable | egrep -i 'hw.cpu64bit_capable' | awk '{print $NF}'`
		STELLA_CPU_ARCH=32
		[ "$_cpu" == "1" ] && STELLA_CPU_ARCH=64
	else
		STELLA_CPU_ARCH=
	fi


	if [ "$(uname -m | grep 64)" == "" ]; then
		STELLA_KERNEL_ARCH=32
	else
		STELLA_KERNEL_ARCH=64
	fi

	# The getconf LONG_BIT get the default bit size of the C library
	STELLA_C_ARCH=$(getconf LONG_BIT)
	STELLA_USERSPACE_ARCH=unknown
	



	__override_platform_command

}


function __override_platform_command() {
	#http://unix.stackexchange.com/questions/30091/fix-or-alternative-for-mktemp-in-os-x
	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
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

	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		GETOPT_CMD=PURE_BASH
	else
		GETOPT_CMD=getopt
	fi


}


# REQUIREMENTS STELLA -------------

function __ask_install_requirements() {
	echo "Do you wish to auto-install requirements for stella (may ask for sudo password)?"
	select yn in "Yes" "No"; do
	    case $yn in
	        Yes )
				__stella_requirement
				break;;
	        No ) break;;
	    esac
	done
}


function __stella_requirement() {
	__install_minimal_system_requirement
	__install_minimal_feature_requirement
}

function __install_minimal_system_requirement() {
	case $STELLA_CURRENT_OS in
		*);;
	esac
}

function __install_minimal_feature_requirement() {
	case $STELLA_CURRENT_OS in
		*);;
	esac
}


function __require() {
	local _file=$1
	local _OPT=$2

	# OPTIONS
	# MANDATORY : will stop execution if requirement is not found
	# OPTIONAL : will not exit if requirement is not found
	# SPECIFIC : will check for a specific requirement (not just test a file)
	_opt_mandatory=OFF
	_opt_optional=ON
	_opt_specific=OFF
	for o in $_OPT; do
		[ "$o" == "MANDATORY" ] && _opt_mandatory=ON
		[ "$o" == "OPTIONAL" ] && _opt_optional=ON
		[ "$o" == "SPECIFIC" ] && _opt_specific=ON
	done

	if [ "$_opt_specific" == "ON" ]; then
		__require_specific $_file $_OPT
	else
		if [[ ! -n `which $_file 2> /dev/null` ]]; then
			echo "****** WARN $_file is missing ******"
			if [ "$_opt_mandatory" == "ON" ]; then
				echo "****** ERROR Please install $_file and re-launch your app"
				exit 1
			fi
		fi
	fi
}

# TODO not finished
function __require_specific() {
	local _requirement=$1
	local _OPT=$2

	# OPTIONS
	# MANDATORY : will stop execution if requirement is not found
	# OPTIONAL : will not exit if requirement is not found
	_opt_mandatory=OFF
	_opt_optional=ON
	for o in $_OPT; do
		[ "$o" == "MANDATORY" ] && _opt_mandatory=ON
		[ "$o" == "OPTIONAL" ] && _opt_optional=ON
	done

	case $_requirement in 
		build-system)
			
			case $STELLA_CURRENT_OS in
				macos)
					# from https://github.com/darkoperator/MSF-Installer/blob/master/msf_install.sh
					# http://docs.python-guide.org/en/latest/starting/install/osx/
					PKGS=`pkgutil --pkgs`
					if [[ $PKGS =~ com.apple.pkg.Xcode ]]; then
						echo " ** Xcode detected"
					else
						echo " ** WARN Xcode not detected"
						[ "$_opt_mandatory" == "ON" ] && exit 1
					fi
					if [[ $PKGS =~ com.apple.pkg.DeveloperToolsCLI || $PKGS =~ com.apple.pkg.CLTools_Executables ]]; then
						echo " ** Command Line Development Tools is intalled"
					else
						echo " ** WARN Command Line Development Tools not intalled"
					fi
					;;
			esac
		;;
	esac
}


function __install_system_requirement() {
	local _id_list=$1

	case $STELLA_CURRENT_OS in
		ubuntu|debian)
				__install_system_requirement_deb "$_id_list"
			;;
		macos)
				__install_system_requirement_macos "$_id_list"
			;;
	esac
}

function __install_system_requirement_deb() {
	local _id_list=$1

	for _id in $_id_list; do
		case $_id in
			git) sudo apt-get -y install git
				;;
			7z) sudo apt-get -y install p7zip-full
				;;
			unzip)
				sudo apt-get -y install unzip
				;;
			wget) sudo apt-get -y install wget
				;;
			build-system)
				#sudo apt-get -y install bison util-linux build-essential gcc-multilib g++-multilib g++ pkg-config
				sudo apt-get -y install build-essential gcc-multilib g++-multilib
				;;
		esac
	done
}

function __install_system_requirement_macos() {
	local _id_list=$1

	for _id in $_id_list; do
		case $_id in
			7z) brew install p7zip
				;;
			brew)
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
			;;
		esac
	done
}













#TODO
# from https://github.com/darkoperator/MSF-Installer/blob/master/msf_install.sh
# http://docs.python-guide.org/en/latest/starting/install/osx/
function check_dependencies_macos
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

    if [[ $PKGS =~ com.apple.pkg.Xcode ]] ; then
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
