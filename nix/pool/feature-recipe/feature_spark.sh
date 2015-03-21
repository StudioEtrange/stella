if [ ! "$_SPARK_INCLUDED_" == "1" ]; then 
_SPARK_INCLUDED_=1



function feature_spark() {
	FEAT_NAME=spark
	FEAT_LIST_SCHEMA="1_3_0_HADOOP_2_4/binary"
	FEAT_DEFAULT_VERSION=1_3_0_HADOOP_2_4
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="binary"
}

function feature_spark_1_3_0_HADOOP_2_4() {
	FEAT_VERSION=1_3_0_HADOOP_2_4

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_CALLBACK=	
	FEAT_BINARY_URL=http://d3kbcqa49mib13.cloudfront.net/spark-1.3.0-bin-hadoop2.4.tgz
	FEAT_BINARY_URL_FILENAME=spark-1.3.0-bin-hadoop2.4.tgz
	FEAT_BINARY_CALLBACK=

	# embed his own scala version
	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/spark-shell
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin:"$FEAT_INSTALL_ROOT"/sbin

	FEAT_BUNDLE_LIST=
}


function feature_spark_install_binary() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR=
	BUILD_DIR=

	__download_uncompress "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_FILENAME" "$INSTALL_DIR" "DEST_ERASE STRIP"

}


fi
