if [ ! "$_SCALA_INCLUDED_" == "1" ]; then 
_SCALA_INCLUDED_=1



function feature_scala() {
	FEAT_NAME=scala
	FEAT_LIST_SCHEMA="2_11_6/binary"
	FEAT_DEFAULT_VERSION=2_11_6
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="binary"
}

function feature_scala_env() {
	SCALA_HOME=$FEAT_INSTALL_ROOT
	export SCALA_HOME=$FEAT_INSTALL_ROOT
}


function feature_scala_2_11_6() {
	FEAT_VERSION=2_11_6

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_BINARY_URL=http://downloads.typesafe.com/scala/2.11.6/scala-2.11.6.tgz
	FEAT_BINARY_URL_FILENAME=cala-2.11.6.tgz

	FEAT_BINARY_CALLBACK=

	# need JVM
	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/scala
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
	FEAT_ENV_CALLBACK=feature_scala_env

	FEAT_BUNDLE_ITEM=
}



function feature_scala_install_binary() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR=
	BUILD_DIR=

	__download_uncompress "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_FILENAME" "$INSTALL_DIR" "DEST_ERASE STRIP"
	
}


fi
