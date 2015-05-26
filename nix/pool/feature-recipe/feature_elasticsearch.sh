if [ ! "$_ELASTICSEARCH_INCLUDED_" == "1" ]; then 
_ELASTICSEARCH_INCLUDED_=1



function feature_elasticsearch() {
	FEAT_NAME=elasticsearch
	FEAT_LIST_SCHEMA="1_4_4/binary 1_5_0/binary"
	FEAT_DEFAULT_VERSION=1_5_0
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="binary"
}


function feature_elasticsearch_env() {
	ES_HOME=$FEAT_INSTALL_ROOT
	export ES_HOME=$FEAT_INSTALL_ROOT
}

function feature_elasticsearch_1_4_4() {
	FEAT_VERSION=1_4_4

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_CALLBACK=	
	FEAT_BINARY_URL=https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.4.tar.gz
	FEAT_BINARY_URL_FILENAME=elasticsearch-1.4.4.tar.gz
	FEAT_BINARY_CALLBACK=

	# NEED JDK 7 >= 7.60
	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/elasticsearch
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
	FEAT_ENV_CALLBACK=feature_elasticsearch_env

	FEAT_BUNDLE_ITEM=
}


function feature_elasticsearch_1_5_0() {
	FEAT_VERSION=1_5_0

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_CALLBACK=	
	FEAT_BINARY_URL=https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.5.0.tar.gz
	FEAT_BINARY_URL_FILENAME=elasticsearch-1.5.0.tar.gz
	FEAT_BINARY_CALLBACK=

	# NEED JDK 7 >= 7.60
	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/elasticsearch
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
	FEAT_ENV_CALLBACK=feature_elasticsearch_env

	FEAT_BUNDLE_ITEM=
}

function feature_elasticsearch_install_binary() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR=
	BUILD_DIR=

	__download_uncompress "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_FILENAME" "$INSTALL_DIR" "DEST_ERASE STRIP"

}


fi
