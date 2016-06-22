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
		Alpine*|alpine*)
			echo "alpine"
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
		centos|archlinux|ubuntu|debian|linuxgeneric|rhel|alpine)
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

	# call screenFetch
	# https://github.com/KittyKatt/screenFetch
	exit() {
	:
	}
	source $STELLA_ARTEFACT/screenFetch/screenfetch-dev -n -E 1>/dev/null 2>&1
	unset exit

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
	# http://www.cyberciti.biz/faq/linux-how-to-find-if-processor-is-64-bit-or-not/

	# CPU 64Bits capable
	STELLA_CPU_ARCH=
	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		grep -q -o -w 'lm' /proc/cpuinfo && STELLA_CPU_ARCH=64 || echo STELLA_CPU_ARCH=32
	fi

	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		local _cpu=`sysctl hw.cpu64bit_capable | egrep -i 'hw.cpu64bit_capable' | awk '{print $NF}'`
		STELLA_CPU_ARCH=32
		[ "$_cpu" == "1" ] && STELLA_CPU_ARCH=64
	fi


	if [ "$(uname -m | grep 64)" == "" ]; then
		STELLA_KERNEL_ARCH=32
	else
		STELLA_KERNEL_ARCH=64
	fi

	# The getconf LONG_BIT get the default bit size of the C library
	STELLA_C_ARCH=$(getconf LONG_BIT)
	STELLA_USERSPACE_ARCH=unknown



	STELLA_DEFAULT_INTERFACE=$(netstat -rn | awk '/^0.0.0.0/ {thif=substr($0,74,10); print thif;} /^default.*UG/ {thif=substr($0,65,10); print thif;}')
	STELLA_HOST_DEFAULT_IP=$(ifconfig ${STELLA_DEFAULT_INTERFACE} | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*')
	STELLA_HOST_IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*')


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


# TODO
function __stella_requirement() {
	case $STELLA_CURRENT_OS in
		*);;
	esac
}



# REQUIRE -------------------------
# require a feature.
# By default the required feature is MANDATORY
# Test if feature is present
#		if feature is not OPTIONAL may install it from STELLA  or provide guideline to install it FROM SYSTEM
function __require() {
	local _artefact="$1" # binary to test
	local _id="$2" # feature name (for stella) or sys name (for package manager)
	local _OPT="$3"

	local _result=0

	# OPTIONAL
	# PREFER_SYSTEM
	# PREFER_STELLA
	local _opt_optional=OFF
	local _opt_prefer_system=ON
	local _opt_prefer_stella=OFF


	for o in $_OPT; do
		[ "$o" == "OPTIONAL" ] && _opt_optional=ON
		[ "$o" == "PREFER_SYSTEM" ] && _opt_prefer_system=ON && _opt_prefer_stella=OFF
		[ "$o" == "PREFER_STELLA" ] && _opt_prefer_system=OFF && _opt_prefer_stella=ON
	done

	echo "** REQUIRE $_id"
	local _err=
	# if [[ ! -n `which $_artefact 2> /dev/null` ]]; then
	# 	_err=1
	# fi

	type $_artefact &>/dev/null || _err=1

	if [ "$_err" == "1" ]; then
		if [ "$_opt_optional" == "ON" ]; then
			if [ "$_opt_prefer_system" == "ON" ]; then
				echo "** WARN -- You should install $_artefact -- Try stella.sh sys install $_id OR your regular OS package manager"
			else
				if [ "$_opt_prefer_stella" == "ON" ]; then
					echo "** WARN -- You should install $_artefact -- Try stella.sh feature install $_id"
				else
					echo "** WARN -- You should install $_artefact"
					echo "-- For a system install : try stella.sh sys install $_id OR your regular OS package manager"
					echo "-- For an install from Stella : try stella.sh feature install $_id"
				fi
			fi
		else
			if [ "$_opt_prefer_system" == "ON" ]; then
				echo "** ERROR -- Please install $_artefact"
				echo "** Try stella.sh sys install $_id OR your regular OS package manager"
				_result=1
				exit 1
			else
				if [ "$_opt_prefer_stella" == "ON" ]; then
					echo "** REQUIRE $_id : installing it from stella"
					(__feature_install "$_id" "INTERNAL HIDDEN")
					__feature_init "$_id"
				else
					echo "** ERROR -- Please install $_artefact"
					echo "-- For a system install : try stella.sh sys install $_id OR your regular OS package manager"
					echo "-- For an install from Stella : try stella.sh feature install $_id"
					_result=1
					exit 1
				fi
			fi
		fi
	fi

	return $_result
}

# PACKAGE SYSTEM ----------------------------


function __get_current_package_manager() {
	local _package_manager=

	local p=
	local plist=

	case $STELLA_CURRENT_PLATFORM in
		linux)
				plist="apt-get yum apk"
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

function __sys_install() {
	__sys_install_$1
}

function __sys_remove() {
	__sys_remove_$1
}

function __sys_package_manager() {
	# INSTALL or REMOVE
	local _action="$1"
	local _id="$2"
	local _packages_list="$3"

	echo " ** $_action $_id on your system"

	local _package_manager="$(__get_current_package_manager)"


	local _flag_package_manager=OFF
	local _packages=
	for o in $_packages_list; do
		[ "$o" == "|" ] && _flag_package_manager=OFF
		[ "$_flag_package_manager" == "ON" ] && _packages="$_packages $o"
		[ "$o" == "$_package_manager" ] && _flag_package_manager=ON
	done

	if [ "$_action" == "INSTALL" ]; then
		case $_package_manager in
			apt-get)
				type sudo &>/dev/null && \
					sudo -E apt-get update && \
					sudo -E apt-get -y install $_packages || \
					apt-get update && \
					apt-get -y install $_packages
				;;
			brew)
				brew install $_packages
				;;
			yum)
				sudo -E yum install -y $_packages
				;;
			apk)
				type sudo &>/dev/null && \
					sudo -E apk update && \
					sudo -E apk add $_packages || \
					apk update && \
					apk add $_packages
				;;
			*)	echo " ** WARN : dont know how to install $_id"
				;;
		esac
	fi
	if [ "$_action" == "REMOVE" ]; then
		case $_package_manager in
			apt-get)
				type sudo &>/dev/null && \
					sudo -E apt-get update && \
					sudo -E apt-get -y autoremove --purge $_packages || \
					apt-get update && \
					apt-get -y autoremove --purge $_packages
				;;
			brew)
				brew uninstall $_packages
				;;
			yum)
				sudo -E yum remove -y $_packages
				;;
			apk)
					type sudo &>/dev/null && \
					sudo -E apk del $_packages || \
					apk del $_packages
				;;
			*)	echo " ** WARN : dont know how to remove $_id"
				;;
		esac
	fi
}

# --------- SYSTEM RECIPES--------
function __sys_install_brew() {
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
function __sys_remove_brew() {
	echo " ** Remove Homebrew from your system"

	rm -rf /usr/local/Cellar /usr/local/.git 2>/dev/null
	brew cleanup 2>/dev/null

	__download "https://raw.githubusercontent.com/Homebrew/install/master/uninstall" "brew-uninstall.rb" "$STELLA_APP_TEMP_DIR"

	ruby "$STELLA_APP_TEMP_DIR/brew-uninstall.rb"
	rm -f "$STELLA_APP_CACHE_DIR/brew-uninstall.rb"
}


function __sys_install_build-chain-standard() {
	local _package_manager=

	if [ "$STELLA_CURRENT_OS" == "macos" ]; then
		echo " ** Install build-chain-standard on your system"
		# from https://github.com/lockfale/msf-installer/blob/master/msf_install.sh
		# http://docs.python-guide.org/en/latest/starting/install/osx/
		local PKGS=`pkgutil --pkgs`
		if [[ $PKGS =~ com.apple.pkg.Xcode ]]; then
			echo " ** Xcode detected"
		else
			echo " ** WARN Xcode not detected."
			echo " It is NOT mandatory but you may want to install it from the Apple AppStore"
			echo " or download it from https://developer.apple.com/downloads."
			# difference between appstore and download site
			# http://apple.stackexchange.com/questions/62201/download-xcode-from-developer-site-vs-install-from-app-store

			# TODO make a separate script to install xcode
			# http://stackoverflow.com/questions/4081568/downloading-xcode-with-wget-or-curl
		fi
		if [[ $PKGS =~ com.apple.pkg.DeveloperToolsCLI || $PKGS =~ com.apple.pkg.CLTools_Executables ]]; then
			echo " ** Command Line Development Tools is already intalled"
		else
			echo " ** WARN Command Line Development Tools not intalled. See https://developer.apple.com/downloads"
			xcode-select --install
		fi

	else
		#bison util-linux build-essential gcc-multilib g++-multilib g++ pkg-config
		__sys_package_manager "INSTALL" "build-chain-standard" "apt-get build-essential gcc-multilib g++-multilib | yum gcc gcc-c++ make kernel-devel | apk gcc g++ make"
	fi
}
function __sys_remove_build-chain-standard() {
	if [ "$STELLA_CURRENT_OS" == "macos" ]; then
		echo " ** Remove Xcode and Command Line Development Tools by hand"
	else
		__sys_package_manager "REMOVE" "build-chain-standard" "apt-get build-essential gcc-multilib g++-multilib | yum gcc gcc-c++ make kernel-devel | apk gcc g++ make"
	fi

}



function __sys_install_x11() {
	brew install caskroom/cask/brew-cask
	brew cask install xquartz
}
function __sys_remove_x11() {
	brew cask uninstall xquartz
}

function __sys_install_sevenzip() {
	__sys_package_manager "INSTALL" "7z" "apt-get p7zip-full | brew p7zip | yum p7zip | apk p7zip"
}
function __sys_remove_sevenzip() {
	__sys_package_manager "REMOVE" "7z" "apt-get p7zip-full | brew p7zip | yum p7zip | apk p7zip"
}

function __sys_install_curl() {
	__sys_package_manager "INSTALL" "curl" "apt-get curl | brew curl | yum curl | apk curl"
}
function __sys_remove_curl() {
	__sys_package_manager "REMOVE" "curl" "apt-get curl | brew curl | yum curl | apk curl"
}

function __sys_install_wget() {
	__sys_package_manager "INSTALL" "wget" "apt-get wget | brew wget | yum wget | apk get"
}
function __sys_remove_wget() {
	__sys_package_manager "REMOVE" "wget" "apt-get wget | brew wget | yum wget | apk get"
}

function __sys_install_unzip() {
	__sys_package_manager "INSTALL" "unzip" "apt-get unzip | brew unzip | yum unzip"
}
function __sys_remove_unzip() {
	__sys_package_manager "REMOVE" "unzip" "apt-get unzip | brew unzip | yum unzip"
}

function __sys_install_cmake() {
	__sys_package_manager "INSTALL" "cmake" "apt-get cmake | brew cmake | yum cmake | apk cmake"
}
function __sys_remove_cmake() {
	__sys_package_manager "REMOVE" "cmake" "apt-get cmake | brew cmake | yum cmake | apk cmake"
}

function __sys_install_git() {
	__sys_package_manager "INSTALL" "git" "apt-get git | brew git | yum git | apk git"
}
function __sys_remove_git() {
	__sys_package_manager "REMOVE" "git" "apt-get git | brew git | yum git | apk git"
}


fi
