if [ ! "$_PACKER_INCLUDED_" == "1" ]; then 
_PACKER_INCLUDED_=1




function feature_packer() {

	FEAT_NAME=packer
	FEAT_LIST_SCHEMA="0_6_0@x64/binary 0_6_0@x86/binary 0_7_5@x64/binary 0_7_5@x86/binary"
	FEAT_DEFAULT_VERSION=0_7_5
	FEAT_DEFAULT_ARCH=x64
	FEAT_DEFAULT_FLAVOUR="binary"
}

function feature_packer_0_6_0() {
	FEAT_VERSION=0_6_0

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_CALLBACK=
	
	if [ "$STELLA_CURRENT_PLATFORM" == "macos" ]; then
		FEAT_BINARY_URL_x64=https://dl.bintray.com/mitchellh/packer/0.6.0_darwin_amd64.zip
		FEAT_BINARY_URL_FILENAME_x64=packer_0.6.0_darwin_amd64.zip

		FEAT_BINARY_URL_x86="https://dl.bintray.com/mitchellh/packer/0.6.0_darwin_386.zip"
		FEAT_BINARY_URL_FILENAME_x86="packer_0.6.0_darwin_386.zip"

	fi
	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		FEAT_BINARY_URL_x64=https://dl.bintray.com/mitchellh/packer/0.6.0_linux_amd64.zip
		FEAT_BINARY_URL_FILENAME_x64=packer_0.6.0_linux_amd64.zip

		FEAT_BINARY_URL_x86=https://dl.bintray.com/mitchellh/packer/0.6.0_linux_386.zip
		FEAT_BINARY_URL_FILENAME_x64=packer_0.6.0_linux_386.zip
	fi
	FEAT_BINARY_CALLBACK=

	FEAT_DEPENDENCIES=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/packer
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"
	FEAT_ENV=

	FEAT_BUNDLE_LIST=
}


function feature_packer_0_7_5() {
	FEAT_VERSION=0_7_5

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_CALLBACK=
	
	if [ "$STELLA_CURRENT_PLATFORM" == "macos" ]; then
		FEAT_BINARY_URL_x64=https://dl.bintray.com/mitchellh/packer/packer_0.7.5_darwin_amd64.zip
		FEAT_BINARY_URL_FILENAME_x64=packer_0.7.5_darwin_amd64.zip

		FEAT_BINARY_URL_x86=https://dl.bintray.com/mitchellh/packer/packer_0.7.5_darwin_386.zip
		FEAT_BINARY_URL_FILENAME_x86=packer_0.7.5_darwin_386.zip

	fi
	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		FEAT_BINARY_URL_x64=https://dl.bintray.com/mitchellh/packer/packer_0.7.5_linux_amd64.zip
		FEAT_BINARY_URL_FILENAME_x64=packer_0.7.5_linux_amd64.zip

		FEAT_BINARY_URL_x86=https://dl.bintray.com/mitchellh/packer/packer_0.7.5_linux_386.zip
		FEAT_BINARY_URL_FILENAME_x86=packer_0.7.5_linux_386.zip
	fi

	FEAT_DEPENDENCIES=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/packer
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"
	FEAT_ENV=
	
	FEAT_BUNDLE_LIST=
}


# -----------------------------------------
function feature_packer_install_binary() {
	
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR=
	BUILD_DIR=

	__download_uncompress "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_FILENAME" "$INSTALL_DIR" "DEST_ERASE STRIP"
		
	if [ -d "$INSTALL_DIR" ]; then
		cd $INSTALL_DIR
		chmod +x *
	fi
	
}




fi
