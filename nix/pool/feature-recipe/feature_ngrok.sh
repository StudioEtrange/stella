if [ ! "$_NGROK_INCLUDED_" == "1" ]; then 
_NGROK_INCLUDED_=1


function feature_ngrok() {
	FEAT_NAME=ngrok
	FEAT_LIST_SCHEMA="stable@x86/binary stable@x64/binary"
	FEAT_DEFAULT_VERSION=stable
	FEAT_DEFAULT_ARCH=x64
	FEAT_DEFAULT_FLAVOUR="binary"
}

function feature_ngrok_stable() {
	FEAT_VERSION=stable

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_CALLBACK=
	
	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		FEAT_BINARY_URL_x64="https://api.equinox.io/1/Applications/ap_pJSFC5wQYkAyI0FIVwKYs9h1hW/Updates/Asset/ngrok.zip?channel=stable&os=darwin&arch=amd64"
		FEAT_BINARY_URL_FILENAME_x64=ngrok_darwin_amd64.zip

		FEAT_BINARY_URL_x86="https://api.equinox.io/1/Applications/ap_pJSFC5wQYkAyI0FIVwKYs9h1hW/Updates/Asset/ngrok.zip?channel=stable&os=darwin&arch=386"
		FEAT_BINARY_URL_FILENAME_x86=ngrok_darwin_386.zip

	fi
	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		FEAT_BINARY_URL_x64="https://api.equinox.io/1/Applications/ap_pJSFC5wQYkAyI0FIVwKYs9h1hW/Updates/Asset/ngrok.zip?channel=stable&os=linux&arch=amd64"
		FEAT_BINARY_URL_FILENAME_x64=ngrok_linux_amd64

		FEAT_BINARY_URL_x86="https://api.equinox.io/1/Applications/ap_pJSFC5wQYkAyI0FIVwKYs9h1hW/Updates/Asset/ngrok.zip?channel=stable&os=linux&arch=386"
		FEAT_BINARY_URL_FILENAME_x86=ngrok_linux_386.zip
	fi
	FEAT_BINARY_CALLBACK=

	FEAT_DEPENDENCIES=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/ngrok
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"
	FEAT_ENV_CALLBACK=
	
	FEAT_BUNDLE_ITEM=
}


# -----------------------------------------
function feature_ngrok_install_binary() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR=
	BUILD_DIR=
	
	

	__download_uncompress "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_FILENAME" "$INSTALL_DIR" "DEST_ERASE STRIP"

}
 


fi
