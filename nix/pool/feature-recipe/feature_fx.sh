if [ ! "$_FX_INCLUDED_" = "1" ]; then
_FX_INCLUDED_=1


feature_fx() {
	FEAT_NAME="fx"
	FEAT_LIST_SCHEMA="39_2_0@x64:binary"

	FEAT_DEFAULT_FLAVOUR="binary"

	FEAT_DESC="fx is a terminal JSON viewer and processor"
	FEAT_LINK="https://fx.wtf https://github.com/antonmedv/fx"
}


feature_fx_39_2_0() {
	FEAT_VERSION="39_2_0"

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "intel" ]; then
			FEAT_BINARY_URL_x64="https://github.com/antonmedv/fx/releases/download/39.2.0/fx_linux_amd64"
			FEAT_BINARY_URL_FILENAME_x64="fx_linux_amd64_${FEAT_VERSION}"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP"
		fi
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "arm" ]; then
			FEAT_BINARY_URL_x64="https://github.com/antonmedv/fx/releases/download/39.2.0/fx_linux_arm64"
			FEAT_BINARY_URL_FILENAME_x64="fx_linux_arm64_${FEAT_VERSION}"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP"
		fi
	fi
	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "intel" ]; then
			FEAT_BINARY_URL_x64="https://github.com/antonmedv/fx/releases/download/39.2.0/fx_darwin_amd64"
			FEAT_BINARY_URL_FILENAME_x64="fx_darwin_amd64_${FEAT_VERSION}"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP"
		fi
		if [ "$STELLA_CURRENT_CPU_FAMILY" = "arm" ]; then
			FEAT_BINARY_URL_x64="https://github.com/antonmedv/fx/releases/download/39.2.0/fx_darwin_arm64"
			FEAT_BINARY_URL_FILENAME_x64="fx_darwin_arm64_${FEAT_VERSION}"
			FEAT_BINARY_URL_PROTOCOL_x64="HTTP"
		fi
	fi

	FEAT_INSTALL_TEST="${FEAT_INSTALL_ROOT}/fx"
	FEAT_SEARCH_PATH="${FEAT_INSTALL_ROOT}"
}


feature_fx_install_binary() {
	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "DEST_ERASE STRIP FORCE_NAME $FEAT_BINARY_URL_FILENAME"

	if [ -f "${FEAT_INSTALL_ROOT}/${FEAT_BINARY_URL_FILENAME}" ]; then
		mv "${FEAT_INSTALL_ROOT}/${FEAT_BINARY_URL_FILENAME}" "${FEAT_INSTALL_ROOT}/fx"
		chmod +x "${FEAT_INSTALL_ROOT}/fx"
	fi
}


fi
