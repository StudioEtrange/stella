if [ ! "$_reg_INCLUDED_" = "1" ]; then
_reg_INCLUDED_=1

#https://github.com/jessfraz/reg

feature_reg() {
	FEAT_NAME=reg
	FEAT_LIST_SCHEMA="0_9_0@x64:binary 0_9_0@x86:binary"
	FEAT_DEFAULT_ARCH=x64
	FEAT_DEFAULT_FLAVOUR="binary"

	FEAT_DESC="docker registry client"
	FEAT_LINK="https://github.com/jessfraz/reg"
}



feature_reg_0_9_0() {
	FEAT_VERSION=0_9_0

	# Dependencies
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	# Properties for BINARY flavour
	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		FEAT_BINARY_URL_x86="https://github.com/jessfraz/reg/releases/download/v0.9.0/reg-darwin-386"
		FEAT_BINARY_URL_FILENAME_x86="reg-darwin-386-$FEAT_VERSION"
		FEAT_BINARY_URL_PROTOCOL_x86="HTTP"
		FEAT_BINARY_URL_x64="https://github.com/jessfraz/reg/releases/download/v0.9.0/reg-darwin-amd64"
		FEAT_BINARY_URL_FILENAME_x64="reg-darwin-amd64-$FEAT_VERSION"
		FEAT_BINARY_URL_PROTOCOL_x64="HTTP"
	fi
	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		FEAT_BINARY_URL_x86="https://github.com/jessfraz/reg/releases/download/v0.9.0/reg-linux-386"
		FEAT_BINARY_URL_FILENAME_x86="reg-linux-386-$FEAT_VERSION"
		FEAT_BINARY_URL_PROTOCOL_x86="HTTP"
		FEAT_BINARY_URL_x64="https://github.com/jessfraz/reg/releases/download/v0.9.0/reg-linux-amd64"
		FEAT_BINARY_URL_FILENAME_x64="reg-linux-amd64-$FEAT_VERSION"
		FEAT_BINARY_URL_PROTOCOL_x64="HTTP"
	fi


	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	# List of files to test if feature is installed
	FEAT_INSTALL_TEST=$FEAT_INSTALL_ROOT/reg
	# PATH to add to system PATH
	FEAT_SEARCH_PATH=$FEAT_INSTALL_ROOT

}


feature_reg_install_binary() {

	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "DEST_ERASE FORCE_NAME $FEAT_BINARY_URL_FILENAME"
	mv -f "$FEAT_INSTALL_ROOT/$FEAT_BINARY_URL_FILENAME" "$FEAT_INSTALL_ROOT/reg"
	chmod +x "$FEAT_INSTALL_ROOT/reg"

}



fi
