if [ ! "$_MAVEN_INCLUDED_" == "1" ]; then 
_MAVEN_INCLUDED_=1



function feature_maven() {
	FEAT_NAME=maven
	FEAT_LIST_SCHEMA="3_3_1/binary"
	FEAT_DEFAULT_VERSION=3_3_1
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="binary"
}

function feature_maven_env() {
	export M2_HOME=$FEAT_INSTALL_ROOT
}




function feature_maven_3_3_1() {
	FEAT_VERSION=3_3_1

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_CALLBACK=	
	FEAT_BINARY_URL=http://www.eu.apache.org/dist/maven/maven-3/3.3.1/binaries/apache-maven-3.3.1-bin.tar.gz
	FEAT_BINARY_URL_FILENAME=apache-maven-3.3.1-bin.tar.gz
	
	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/mvn
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
	FEAT_ENV=
	
	FEAT_BUNDLE_LIST=
}


function feature_maven_install_binary() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR=
	BUILD_DIR=

	__download_uncompress "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_FILENAME" "$INSTALL_DIR" "DEST_ERASE STRIP"

}




fi