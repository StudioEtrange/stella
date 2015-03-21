if [ ! "$_SBT_INCLUDED_" == "1" ]; then 
_SBT_INCLUDED_=1



function feature_sbt() {
	FEAT_NAME=sbt
	FEAT_LIST_SCHEMA="0_13_7/binary"
	FEAT_DEFAULT_VERSION=0_13_7
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="binary"
}

function feature_sbt_0_13_7() {
	FEAT_VERSION=0_13_7

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_BINARY_URL=https://dl.bintray.com/sbt/native-packages/sbt/0.13.7/sbt-0.13.7.tgz
	FEAT_BINARY_URL_FILENAME=sbt-0.13.7.tgz

	FEAT_BINARY_CALLBACK=

	# need jvm
	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/sbt
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
	FEAT_ENV=
	
	FEAT_BUNDLE_LIST=
}


function feature_sbt_install_binary() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR=
	BUILD_DIR=

	__download_uncompress "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_FILENAME" "$INSTALL_DIR" "DEST_ERASE STRIP"
	
}


fi
