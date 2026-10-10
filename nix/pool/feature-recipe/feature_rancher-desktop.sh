if [ ! "$_RANCHER_DESKTOP_INCLUDED_" = "1" ]; then
_RANCHER_DESKTOP_INCLUDED_=1

feature_rancher-desktop() {
	FEAT_NAME="rancher-desktop"
	FEAT_LIST_SCHEMA=""
	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ] && [ "$STELLA_CURRENT_CPU_FAMILY" = "intel" ]; then
		FEAT_LIST_SCHEMA="1_24_0@x64:binary"
	fi
	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		FEAT_LIST_SCHEMA="1_24_0@x64:binary"
	fi
	FEAT_DEFAULT_FLAVOUR="binary"
	FEAT_DESC="Rancher Desktop provides local Kubernetes and container management"
	FEAT_LINK="https://rancherdesktop.io https://github.com/rancher-sandbox/rancher-desktop"
}

feature_rancher-desktop_1_24_0() {
	FEAT_VERSION="1_24_0"

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ] && [ "$STELLA_CURRENT_CPU_FAMILY" = "intel" ]; then
		FEAT_BINARY_URL_x64="https://github.com/rancher-sandbox/rancher-desktop/releases/download/v1.24.0/rancher-desktop-linux-v1.24.0.zip"
		FEAT_BINARY_URL_FILENAME_x64="rancher-desktop-linux-v1.24.0.zip"
		FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
	fi
	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "intel" ]; then
			FEAT_BINARY_URL_x64="https://github.com/rancher-sandbox/rancher-desktop/releases/download/v1.24.0/Rancher.Desktop-1.24.0-mac.x86_64.zip"
			FEAT_BINARY_URL_FILENAME_x64="Rancher.Desktop-1.24.0-mac.x86_64.zip"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
		fi
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "arm" ]; then
			FEAT_BINARY_URL_x64="https://github.com/rancher-sandbox/rancher-desktop/releases/download/v1.24.0/Rancher.Desktop-1.24.0-mac.aarch64.zip"
			FEAT_BINARY_URL_FILENAME_x64="Rancher.Desktop-1.24.0-mac.aarch64.zip"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP_ZIP"
		fi
	fi

	FEAT_INSTALL_TEST="${FEAT_INSTALL_ROOT}/bin/rdctl"
	FEAT_SEARCH_PATH="${FEAT_INSTALL_ROOT}/bin"
}

feature_rancher-desktop_install_binary() {
	local FEAT_UNCOMPRESSED_APP_ROOT="${FEAT_INSTALL_ROOT}/app"
	local FEAT_RDCTL FEAT_DESKTOP

	# Do not strip the archive root: macOS bundles must remain intact.
	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "${FEAT_UNCOMPRESSED_APP_ROOT}" "DEST_ERASE FORCE_NAME $FEAT_BINARY_URL_FILENAME"


	case "$STELLA_CURRENT_PLATFORM" in
		"darwin")
			# Path to uncompressed rdctl binary
			FEAT_RDCTL="${FEAT_UNCOMPRESSED_APP_ROOT}/Rancher Desktop.app/Contents/Resources/resources/darwin/bin/rdctl"
			# Path to uncompressed desktop app launcher (do not exists in darwin)
			FEAT_DESKTOP=""
		;;
		"linux")
			# Path to uncompressed rdctl binary
			FEAT_RDCTL="${FEAT_UNCOMPRESSED_APP_ROOT}/resources/resources/linux/bin/rdctl"
			# Path to uncompressed desktop app launcher
			FEAT_DESKTOP="${FEAT_UNCOMPRESSED_APP_ROOT}/rancher-desktop"
		;;
	esac

	if [ -x "$FEAT_RDCTL" ]; then
		mkdir -p "${FEAT_INSTALL_ROOT}/bin"
		# link rdctl cli
		ln -sf "$FEAT_RDCTL" "${FEAT_INSTALL_ROOT}/bin/rdctl"

		# link desktop app launcher for linux
		if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
			ln -sf "$FEAT_DESKTOP" "${FEAT_INSTALL_ROOT}/bin/rancher-desktop"
		fi

		# create a desktop app launcher for macos
		if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
			cat > "${FEAT_INSTALL_ROOT}/bin/rancher-desktop" <<'EOF'
#!/bin/bash
APP_ROOT="$(cd "$(dirname "$0")/../app" && pwd)" || exit 1
exec /usr/bin/open "$APP_ROOT/Rancher Desktop.app" --args "$@"
EOF
			chmod +x "${FEAT_INSTALL_ROOT}/bin/rancher-desktop"
		fi


		if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
			__log_stella "INFO" "Rancher Desktop requires a graphical session, hardware virtualization and read/write access to /dev/kvm"
			__log_stella "INFO" "Install the system GTK/NSS libraries, SSH client and certificate tools required by Rancher Desktop separately"
			__log_stella "INFO" "Electron requires a working user-namespace sandbox; this recipe does not set root ownership, setuid permissions or disable the sandbox"
			__log_stella "INFO" "Configure pass and GPG separately if registry credential storage is needed"
			__log_stella "INFO" ""
		fi
		__log_stella "INFO" "Rancher Desktop was not started; VM and user data are shared outside Stella, and automatic updates may change the installed version"
		__log_stella "INFO" "use rdctl command as cli, and rancher-desktop command to launch desktop app"

	fi



}

fi
