
function __get_package_manager() {
	local _package_manager=

	case $STELLA_CURRENT_OS in
		ubuntu|debian)
				_package_manager="agt-get"
			;;
		macos)
				_package_manager="brew"
			;;
		centos|rhel)
				_package_manager="yum"
			;;
	esac

	echo "$_package_manager"
}


function __install_build-system_apt-get() {
	#sudo apt-get -y install bison util-linux build-essential gcc-multilib g++-multilib g++ pkg-config
	sudo apt-get -y install build-essential gcc-multilib g++-multilib
}

function __install_7z_apt-get() {
	sudo apt-get -y install p7zip-full
}

function __install_7z_brew() {
	brew install p7zip
}
