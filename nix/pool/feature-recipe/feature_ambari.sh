if [ ! "$_AMBARI_INCLUDED_" == "1" ]; then 
_AMBARI_INCLUDED_=1

#TODO not finished
#https://cwiki.apache.org/confluence/display/AMBARI/Ambari+Development

function feature_ambari() {
	FEAT_NAME="ambari"
	FEAT_LIST_SCHEMA="2_1_0:source"
	FEAT_DEFAULT_VERSION="2_1_0"
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}


function feature_ambari_2_1_0() {
	FEAT_VERSION="2_1_0"
	# need python
	FEAT_SOURCE_DEPENDENCIES="maven#3_0_5:binary oracle-jdk#7u80@x64:binary nodejs#0_10_31@x64:binary"
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL="http://www.apache.org/dist/ambari/ambari-2.1.0/apache-ambari-2.1.0-src.tar.gz"
	FEAT_SOURCE_URL_FILENAME="apache-ambari-2.1.0-src.tar.gz"
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=
	
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/getopt"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"

	_AMBARI_NEW_VERSION=2.1.0.0
}


function feature_ambari_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$FEAT_INSTALL_ROOT/src"
	BUILD_DIR=

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP FORCE_NAME $FEAT_SOURCE_URL_FILENAME"

	 

	npm install -g brunch@1.7.17
	
	cd "$SRC_DIR/ambari-metrics"
	mvn versions:set -DnewVersion=$_AMBARI_NEW_VERSION

	cd "$SRC_DIR"
	mvn versions:set -DnewVersion=$_AMBARI_NEW_VERSION
	mvn -T 1.5C -B install -DskipTests
	#mvn test

	#cd "$SRC_DIR/ambari-metrics"
	#mvn versions:set -DnewVersion=$_AMBARI_NEW_VERSION
	#mvn -B package -DskipTests

}

fi
