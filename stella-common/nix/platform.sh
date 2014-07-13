if [ ! "$_PLATFORM_INCLUDED_" == "1" ]; then
_PLATFORM_INCLUDED_=1


# PLATFORM INFO ---------------------------


function get_os_from_distro() {
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

function get_platform_from_os() {
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

function get_platform_suffix() {
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

function set_current_platform_info() {
	# Linux
	if [[ -n `which lscpu 2> /dev/null` ]]; then
		HOST_CPU=`lscpu | awk 'NR== 1 {print $2}'`
	# MacOS
	elif [[ -n `which sysctl 2> /dev/null` ]]; then
		HOST_CPU=`sysctl hw 2> /dev/null | egrep -i 'hw.machine' | awk '{print $NF}'`
	else
		HOST_CPU="cannot determine cpu"
	fi

	# linux
	if [[ -n `which nproc 2> /dev/null` ]]; then
		NB_CPU=`nproc`
	# MacOs
	elif [[ -n `which sysctl 2> /dev/null` ]]; then
		NB_CPU=`sysctl hw.ncpu 2> /dev/null | awk '{print $NF}'`
	else
		NB_CPU=0
	fi


	detectdistro
	STELLA_CURRENT_OS=$(get_os_from_distro "$distro")
	STELLA_CURRENT_PLATFORM=$(get_platform_from_os "$STELLA_CURRENT_OS")
	STELLA_CURRENT_PLATFORM_SUFFIX=$(get_platform_suffix "$STELLA_CURRENT_PLATFORM")

	
	if [ "$STELLA_CURRENT_PLATFORM" == "macos" ]; then
		function wget() {
			"$TOOL_ROOT/wget/bin/wget" "$@"
		}
	fi
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
}

# INIT OS PACKAGES -------------

function _stella_env_ubuntu() {
	echo " ** INFO : Needs sudouser rights" 
	apt-get -y install mercurial unzip p7zip-full git wget
	apt-get -y install bison util-linux build-essential gcc-multilib g++-multilib g++ pkg-config
}

function _stella_env_macos() {
	echo " ** INFO : Needs sudouser rights and macport installed"
	port install getopt p7zip
}

function _stella_env_debian() {
	echo " ** INFO : Needs sudouser rights" 
	apt-get -y install mercurial unzip p7zip-full git wget
	apt-get -y install bison util-linux build-essential gcc-multilib g++-multilib g++ pkg-config
}




function init_stella_by_os() {
	local _os=$1

	echo "** Initializing Stella for $_os"
	case $_os in
		ubuntu)
			_stella_env_ubuntu
			;;
		debian)
			_stella_env_debian
			;;
		macos)
			_stella_env_macos
			;;
		*)
			echo "unknown"
			;;
	esac	
}

fi
