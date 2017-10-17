#!sh
if [ ! "$_STELLA_PLATFORM_INCLUDED_" = "1" ]; then
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

__get_os_from_distro() {
	local _distro=$1

	case $_distro in
		"Red Hat Enterprise Linux")
			echo "rhel"
			;;
		Ubuntu|ubuntu*)
			echo "ubuntu"
			;;
		Debian|debian*)
			echo "debian"
			;;
		CentOS*|centos*)
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
		*Windows*|*windows*)
			echo "windows"
			;;
		*)
			echo "linuxgeneric"
			;;
	esac
}





__get_platform_from_os() {
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

__get_platform_suffix() {
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


__get_os_env_from_kernel() {
	local _kernel=$1

	case $kernel in
		*MINGW64*)
			echo "msys2-mingw64"
			;;
		*MINGW32*)
			echo "msys2-mingw32"
			;;
		*MSYS*)
			echo "msys2"
			;;
		*CYGWIN*)
			echo "cygwin"
			;;
	esac
}

__set_current_platform_info() {

	# call screenFetch
	# https://github.com/KittyKatt/screenFetch
	exit() {
	:
	}
	. $STELLA_ARTEFACT/screenFetch/screenfetch-dev -n -E 1>/dev/null 2>&1
	unset exit


	STELLA_CURRENT_OS=$(__get_os_from_distro "$distro")
	STELLA_CURRENT_OS_ENV=$(__get_os_env_from_kernel "$kernel")
	STELLA_CURRENT_PLATFORM=$(__get_platform_from_os "$STELLA_CURRENT_OS")
	STELLA_CURRENT_PLATFORM_SUFFIX=$(__get_platform_suffix "$STELLA_CURRENT_PLATFORM")


	if [[ -n `which nproc 2> /dev/null` ]]; then
		STELLA_NB_CPU=`nproc`
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
	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		grep -q -o -w 'lm' /proc/cpuinfo && STELLA_CPU_ARCH=64 || echo STELLA_CPU_ARCH=32
	fi

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		local _cpu=`sysctl hw.cpu64bit_capable | egrep -i 'hw.cpu64bit_capable' | awk '{print $NF}'`
		STELLA_CPU_ARCH=32
		[ "$_cpu" = "1" ] && STELLA_CPU_ARCH=64
	fi

	if [ "$(uname -m | grep 64)" = "" ]; then
		STELLA_KERNEL_ARCH=32
	else
		STELLA_KERNEL_ARCH=64
	fi

	# The getconf LONG_BIT get the default bit size of the C library
	STELLA_C_ARCH=$(getconf LONG_BIT)
	STELLA_USERSPACE_ARCH=unknown

	local _err=
	type netstat &>/dev/null || _err=1
	if [ "$_err" = "" ]; then
		# NOTE : we pick the first default interface if we have more than one
		STELLA_DEFAULT_INTERFACE=$(netstat -rn | awk '/^0.0.0.0/ {thif=substr($0,74,10); print thif;} /^default.*UG/ {thif=substr($0,65,10); print thif;}' | head -1)
	fi

	_err=
	type ifconfig &>/dev/null || _err=1
	if [ "$_err" = "" ]; then
		STELLA_HOST_DEFAULT_IP=$(ifconfig ${STELLA_DEFAULT_INTERFACE} | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*')
		STELLA_HOST_IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*')
	fi

	__override_platform_command

}


__get_macos_version() {
	#echo $(sw_vers -productVersion)
	echo $(sw_vers -productVersion | awk -F '.' '{print $1 "." $2}')
}


__override_platform_command() {
	#http://unix.stackexchange.com/questions/30091/fix-or-alternative-for-mktemp-in-os-x
	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
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

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		GETOPT_CMD=PURE_BASH
	else
		GETOPT_CMD=getopt
	fi


}


# REQUIREMENTS STELLA -------------
__ask_install_requirements() {
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
__stella_requirement() {
	case $STELLA_CURRENT_OS in
		*);;
	esac
}



# REQUIRE -------------------------
# require a specific binary.
# By default the required binary is MANDATORY
# Test if binary is present, if not :
#		if binary is OPTIONAL, just print warn and guidelines to install it as a STELLA_FEATURE or as a package SYSTEM
#		if binary is not OPTIONAL, it will install it as a STELLA_FEATURE or provide guideline to install it as a package SYSTEM
__require() {
	local _artefact="$1" # binary to test
	local _id="$2" # feature name (for stella) or sys name (for package manager)
	local _OPT="$3"

	local _result=0

	# OPTIONAL
	# SYSTEM
	# STELLA_FEATURE
	local _opt_optional=OFF
	local _opt_system=ON
	local _opt_stella_feature=OFF


	for o in $_OPT; do
		[ "$o" = "OPTIONAL" ] && _opt_optional=ON
		[ "$o" = "SYSTEM" ] && _opt_system=ON && _opt_stella_feature=OFF && _opt_stella_toolset=OFF
		[ "$o" = "STELLA_FEATURE" ] && _opt_system=OFF && _opt_stella_feature=ON && _opt_stella_toolset=OFF
	done

	echo "** REQUIRE $_id ($_artefact)"
	local _err=
	# if [[ ! -n `which $_artefact 2> /dev/null` ]]; then
	# 	_err=1
	# fi

	type $_artefact &>/dev/null || _err=1

	if [ "$_err" = "1" ]; then
		if [ "$_opt_optional" = "ON" ]; then
			if [ "$_opt_system" = "ON" ]; then
				echo "** WARN -- You should install $_artefact -- Try stella.sh sys install $_id OR your regular OS package manager"
			else
				if [ "$_opt_stella_feature" = "ON" ]; then
					echo "** WARN -- You should install $_artefact -- Try stella.sh feature install $_id"
				else
					if [ "$_opt_stella_toolset" = "ON" ]; then
						# TODO optionnal toolset ? it shoud not exist -- CHANGE warn message
						echo "** WARN -- You should install $_artefact -- Try stella.sh toolset install $_id"
					else
						echo "** WARN -- You should install $_artefact"
						echo "-- For a system install : try stella.sh sys install $_id OR your regular OS package manager"
						echo "-- For an install from Stella : try stella.sh feature install $_id"
					fi
				fi
			fi
		else
			if [ "$_opt_system" = "ON" ]; then
				echo "** ERROR -- Please install $_artefact"
				echo "** Try stella.sh sys install $_id OR your regular OS package manager"
				_result=1
				exit 1
			else
				if [ "$_opt_stella_feature" = "ON" ]; then
					echo "** REQUIRE $_id : installing it from stella"
					(__feature_install "$_id" "INTERNAL HIDDEN")
					__feature_init "$_id" "HIDDEN"
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

# TOOLSET specific ----------------------------

# http://stackoverflow.com/questions/5188267/checking-the-gcc-version-in-a-makefile
# return X.Y.Z as version of current gcc
# ex : 4.4.7
__gcc_version() {
	gcc -dumpversion
}

# return an int representation of current gcc version
# ex : 40407
__gcc_version_int() {
	gcc -dumpversion | sed -e 's/\.\([0-9][0-9]\)/\1/g' -e 's/\.\([0-9]\)/0\1/g' -e 's/^[0-9]\{3,4\}$/&00/'
}

# check if current gcc version hit the minimal version required
# first param : X_Y_Z (or X_Y)
# return 1 if required minimal version is fullfilled
__gcc_check_min_version() {
	local _required_ver=$1
	expr $(__gcc_version_int) \<= $(echo $_required_ver | sed -e 's/_\([0-9][0-9]\)/\1/g' -e 's/_\([0-9]\)/0\1/g' -e 's/^[0-9]\{3,4\}$/&00/')
}

# detect if current gcc binary is in fact clang (mainly for MacOS)
# return 1 if gcc is clang
__gcc_is_clang() {
	if [ "$(echo | gcc -dM -E - | grep __clang__)" = "" ]; then
		echo "0"
	else
		echo "1"
	fi
}

# RUNTIME specific ----------------------------


# retrieve current pyconfig.h
__python_get_pyconfig() {
	# /Library/Frameworks/Python.framework/Versions/2.7/include/python2.7/pyconfig.h
	python -c 'import sysconfig;print(sysconfig.get_config_h_filename());'
}

# get python lib folder
__python_get_lib_path() {
	# /Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7
	python -c 'import sysconfig;print(sysconfig.get_path("stdlib"));'
}


# get python version on 1 digits (2, 3, ...)
__python_major_version() {
	# 2.7
	python -c 'import sys;print(str(sys.version_info.major));'
}

# get python version on 2 digits (2.7, 3.4, ...)
__python_short_version() {
	# 2.7
	python -c 'import sys;print(str(sys.version_info.major) + "." + str(sys.version_info.minor));'
}

# NOTE python-config symbolic link do not exist on python 3.x
__python_get_libs() {
	# -lpython2.7 -ldl -framework CoreFoundation
	python$(__python_short_version)-config --libs
}

__python_get_ldflags() {
	#-L/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/config -lpython2.7 -ldl -framework CoreFoundation
	python$(__python_short_version)-config --ldflags
}

__python_get_clags() {
	#-I/Library/Frameworks/Python.framework/Versions/2.7/include/python2.7 -I/Library/Frameworks/Python.framework/Versions/2.7/include/python2.7 -fno-strict-aliasing -fno-common -dynamic -arch i386 -arch x86_64 -g -DNDEBUG -g -fwrapv -O3 -Wall -Wstrict-prototypes
	python$(__python_short_version)-config --cflags
}

__python_get_prefix() {
	# /Library/Frameworks/Python.framework/Versions/2.7
	python$(__python_short_version)-config --prefix
}
__python_get_includes() {
	#-I/Library/Frameworks/Python.framework/Versions/2.7/include/python2.7 -I/Library/Frameworks/Python.framework/Versions/2.7/include/python2.7
	python$(__python_short_version)-config --includes
}

# PACKAGE SYSTEM ----------------------------


__get_current_package_manager() {
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

__sys_install() {
	# _item package name
	# other args : optionnal arguments
	local _item=$1
	shift
	__sys_install_$_item $@
}

__sys_remove() {
	__sys_remove_$1
}


# use a package manager
# arg _package_manager is optionnal - if not set, try to autodetect
__use_package_manager() {
	# INSTALL or REMOVE
	local _action="$1"
	local _id="$2"
	local _packages_list="$3"
	local _package_manager="$4"

	echo " ** $_action $_id on your system"

	if [ "$_package_manager" = "" ]; then
		_package_manager="$(__get_current_package_manager)"
	fi

	echo " ** use $_package_manager as package manager"

	local _flag_package_manager=OFF
	local _packages=
	for o in $_packages_list; do
		[ "$o" = "|" ] && _flag_package_manager=OFF
		[ "$_flag_package_manager" = "ON" ] && _packages="$_packages $o"
		[ "$o" = "$_package_manager" ] && _flag_package_manager=ON
	done

	if [ "$_action" = "INSTALL" ]; then
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
	if [ "$_action" = "REMOVE" ]; then
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
__sys_install_docker() {
	# NOTE install with ansible : https://medium.com/@tedchength/installing-docker-using-ansible-script-c182787f2fa1
	# NOTE install specific version : https://forums.docker.com/t/how-can-i-install-a-specific-version-of-the-docker-engine/1993/6
	#																	http://www.hashjoin.com/t/upgrade-docker-engine-specific-version.html
	local _version=$1
	echo " ** Install Docker $_version on your system"
	if [ "$STELLA_CURRENT_OS" = "macos" ]; then
		echo "ERROR : Docker is not directly available on macos"
		return
	fi

	echo "WARN : it may modify your system config and ask you sudo/root access"
	__download "https://get.docker.com" "docker-install.sh" "$STELLA_APP_TEMP_DIR"
	chmod +x "$STELLA_APP_TEMP_DIR"/docker-install.sh
	"$STELLA_APP_TEMP_DIR"/docker-install.sh

	# override last default version
	if [ ! -z "$_version" ]; then
		__use_package_manager "INSTALL" "docker" "apt-get docker-ce=$_version | yum docker-ce-$_version"
	fi

	echo "NOTE : you should add a user to docker group, to use docker without sudo"
	echo "			sudo usermod -aG docker USER"
}

__sys_install_brew() {
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
__sys_remove_brew() {
	echo " ** Remove Homebrew from your system"

	rm -rf /usr/local/Cellar /usr/local/.git 2>/dev/null
	brew cleanup 2>/dev/null

	__download "https://raw.githubusercontent.com/Homebrew/install/master/uninstall" "brew-uninstall.rb" "$STELLA_APP_TEMP_DIR"

	ruby "$STELLA_APP_TEMP_DIR/brew-uninstall.rb"
	rm -f "$STELLA_APP_CACHE_DIR/brew-uninstall.rb"
}


__sys_install_build-chain-standard() {
	local _package_manager=

	if [ "$STELLA_CURRENT_OS" = "macos" ]; then
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
		__use_package_manager "INSTALL" "build-chain-standard" "apt-get build-essential gcc-multilib g++-multilib | yum gcc gcc-c++ make kernel-devel | apk gcc g++ make"
	fi
}
__sys_remove_build-chain-standard() {
	if [ "$STELLA_CURRENT_OS" = "macos" ]; then
		echo " ** Remove Xcode and Command Line Development Tools by hand"
	else
		__use_package_manager "REMOVE" "build-chain-standard" "apt-get build-essential gcc-multilib g++-multilib | yum gcc gcc-c++ make kernel-devel | apk gcc g++ make"
	fi

}



__sys_install_x11() {
	brew install caskroom/cask/brew-cask
	brew cask install xquartz
}
__sys_remove_x11() {
	brew cask uninstall xquartz
}

__sys_install_sevenzip() {
	__use_package_manager "INSTALL" "7z" "apt-get p7zip-full | brew p7zip | yum p7zip | apk p7zip"
}
__sys_remove_sevenzip() {
	__use_package_manager "REMOVE" "7z" "apt-get p7zip-full | brew p7zip | yum p7zip | apk p7zip"
}

__sys_install_curl() {
	__use_package_manager "INSTALL" "curl" "apt-get curl | brew curl | yum curl | apk curl"
}
__sys_remove_curl() {
	__use_package_manager "REMOVE" "curl" "apt-get curl | brew curl | yum curl | apk curl"
}

__sys_install_wget() {
	__use_package_manager "INSTALL" "wget" "apt-get wget | brew wget | yum wget | apk get"
}
__sys_remove_wget() {
	__use_package_manager "REMOVE" "wget" "apt-get wget | brew wget | yum wget | apk get"
}

__sys_install_unzip() {
	__use_package_manager "INSTALL" "unzip" "apt-get unzip | brew unzip | yum unzip"
}
__sys_remove_unzip() {
	__use_package_manager "REMOVE" "unzip" "apt-get unzip | brew unzip | yum unzip"
}

__sys_install_cmake() {
	__use_package_manager "INSTALL" "cmake" "apt-get cmake | brew cmake | yum cmake | apk cmake"
}
__sys_remove_cmake() {
	__use_package_manager "REMOVE" "cmake" "apt-get cmake | brew cmake | yum cmake | apk cmake"
}

__sys_install_git() {
	__use_package_manager "INSTALL" "git" "apt-get git | brew git | yum git | apk git"
}
__sys_remove_git() {
	__use_package_manager "REMOVE" "git" "apt-get git | brew git | yum git | apk git"
}


fi
