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


function __get_macos_version() {
	#echo $(sw_vers -productVersion)
	echo $(sw_vers -productVersion | awk -F '.' '{print $1 "." $2}')
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



# PACKAGE SYSTEM ----------------------------

function __install_system() {
	local _package="$1"
	local _package_manager="$(__get_current_package_manager)"

	__install_"$_package"
}

function __get_current_package_manager() {
	local _package_manager=

	local p=
	local plist=

	case $STELLA_CURRENT_PLATFORM in
		linux)
				plist="agt-get yum"
			;;
		darwin)
				plist="brew"
			;;
	esac

	for p in $plist; do
		if [[ -n `which $p 2> /dev/null` ]]; then
			_package_manager="$p"
			break
		fi	
	done

	echo "$_package_manager"
}

# --------- SYSTEM RECIPES--------
function __install_brew() {
	echo " ** Install Homebrew on your system"

	__download "https://raw.githubusercontent.com/Homebrew/install/master/install" "brew-install.rb" "$STELLA_APP_TEMP_DIR"
	
	ruby "$STELLA_APP_TEMP_DIR/brew-install.rb"
	rm -f "$STELLA_APP_CACHE_DIR/brew-install.rb"
	

	echo " ** Check Homebrew"
	if [[ -n `which brew 2> /dev/null` ]]; then
		echo " ** brew doctor"
		brew doctor
		local _brewLocation=`which brew`
		local _appLocation=`brew --prefix`
		echo " ** -------------- **"
		echo "Homebrew is installed in $_brewLocation"
		echo "Homebrew apps are run from $_appLocation"
	else
		echo " ** Error while installing Homebrew"	
	fi
}
function __remove_brew() {
	echo " ** Remove Homebrew from your system"

	rm -rf /usr/local/Cellar /usr/local/.git 2>/dev/null
	brew cleanup 2>/dev/null

	__download "https://raw.githubusercontent.com/Homebrew/install/master/uninstall" "brew-uninstall.rb" "$STELLA_APP_TEMP_DIR"
		
	ruby "$STELLA_APP_TEMP_DIR/brew-uninstall.rb"
	rm -f "$STELLA_APP_CACHE_DIR/brew-uninstall.rb"
}






function __install_build-chain-standard() {
	echo " ** Install build-chain-standard on your system"
	local _package_manager=

	if [ "$STELLA_CURRENT_OS" == "macos" ]; then
		# from https://github.com/lockfale/msf-installer/blob/master/msf_install.sh
		# http://docs.python-guide.org/en/latest/starting/install/osx/
		local PKGS=`pkgutil --pkgs`
		if [[ $PKGS =~ com.apple.pkg.Xcode ]]; then
			echo " ** Xcode detected"
		else
			echo " ** WARN Xcode not detected. Install it from the Apple AppStore."
		fi
		if [[ $PKGS =~ com.apple.pkg.DeveloperToolsCLI || $PKGS =~ com.apple.pkg.CLTools_Executables ]]; then
			echo " ** Command Line Development Tools is already intalled"
		else
			echo " ** WARN Command Line Development Tools not intalled"
		fi

	else
		_package_manager="$(__get_current_package_manager)"
		case $_package_manager in
			apt-get)
				#sudo apt-get -y install bison util-linux build-essential gcc-multilib g++-multilib g++ pkg-config
				sudo apt-get -y install build-essential gcc-multilib g++-multilib
				;;
			*)	echo " ** WARN : dont know how to install it"
				;;
		esac
	fi
}
function __remove_build-chain-standard() {
	if [ "$STELLA_CURRENT_OS" == "macos" ]; then
		echo " ** Remove Xcode and Command Line Development Tools by hand"
	else
		_package_manager="$(__get_current_package_manager)"
		case $_package_manager in
			apt-get)
				sudo apt-get -y purge build-essential gcc-multilib g++-multilib
				;;
			*)	echo " ** WARN : dont know how to remove it"
				;;
		esac
	fi

}





function __install_7z() {
	echo " ** Install 7z on your system"

	local _package_manager="$(__get_current_package_manager)"
	case $_package_manager in
		apt-get)
			sudo apt-get -y install p7zip-full
			;;
		brew)
			brew install p7zip
			;;
		*)	echo " ** WARN : dont know how to install it"
			;;
	esac
}
function __remove_7z() {
	echo " ** Remove 7z from your system"

	local _package_manager="$(__get_current_package_manager)"
	case $_package_manager in
		apt-get)
			sudo apt-get -y purge p7zip-full
			;;
		brew)
			brew uninstall p7zip
			;;
		*)	echo " ** WARN : dont know how to remove it"
			;;
	esac
}



fi
