if [ ! "$_NINJA_INCLUDED_" == "1" ]; then 
_NINJA_INCLUDED_=1


function feature_ninja() {

	FEAT_NAME=ninja
	FEAT_LIST_SCHEMA="snapshot:source"
	FEAT_DEFAULT_VERSION=snapshot
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_ninja_snapshot() {
	FEAT_VERSION=snapshot

	# TODO echo " ** NEED : python"
	FEAT_SOURCE_DEPENDENCIES="python#2_7_9"
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=https://github.com/martine/ninja/archive/release.zip
	FEAT_SOURCE_URL_FILENAME=ninja-snapshot.zip
	FEAT_SOURCE_URL_PROTOCOL=

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/ninja
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"

}

function feature_ninja_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	
	__download_uncompress "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_FILENAME" "$INSTALL_DIR" "DEST_ERASE STRIP"

	cd "$INSTALL_DIR"
	#python ./bootstrap.py
	python ./configure.py --bootstrap
}


fi
