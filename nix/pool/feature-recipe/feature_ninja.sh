if [ ! "$_NINJA_INCLUDED_" == "1" ]; then 
_NINJA_INCLUDED_=1


function feature_ninja() {

	FEAT_NAME=ninja
	FEAT_LIST_SCHEMA="last_release:source"
	FEAT_DEFAULT_VERSION=last_release
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_ninja_last_release() {

	FEAT_VERSION=last_release

	FEAT_SOURCE_URL=https://github.com/martine/ninja/archive/release.zip
	FEAT_SOURCE_URL_FILENAME=ninja-release.zip
	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_CALLBACK=

	# TODO echo " ** NEED : python"
	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/ninja
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"
	FEAT_ENV_CALLBACK=
	
	FEAT_BUNDLE_ITEM=
}

function feature_ninja_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR=
	BUILD_DIR=

	__download_uncompress "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_FILENAME" "$INSTALL_DIR" "DEST_ERASE STRIP"

	cd "$INSTALL_DIR"
	#python ./bootstrap.py
	python ./configure.py --bootstrap
}


fi
