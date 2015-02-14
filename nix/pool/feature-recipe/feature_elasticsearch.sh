if [ ! "$_ELASTICSEARCH_INCLUDED_" == "1" ]; then 
_ELASTICSEARCH_INCLUDED_=1


function __list_elasticsearch() {
	echo "1_4_2"
}

function __default_elasticsearch() {
	echo "1_4_2"
}

function __install_elasticsearch() {
	local _VER=$1

	TEST_FEATURE=0
	FEATURE_PATH=
	FEATURE_ROOT=
	FEATURE_VER=

	mkdir -p $STELLA_APP_FEATURE_ROOT/elasticsearch
	if [ "$_VER" == "" ]; then
		__install_elasticsearch_$(__default_elasticsearch)
	else
		# check for version
		for v in $(__list_elasticsearch); do
			[ "$v" == "$_VER" ] && __install_elasticsearch_$_VER
		done
	fi
	
}
function __feature_elasticsearch() {
	local _VER=$1

	TEST_FEATURE=0
	FEATURE_PATH=
	FEATURE_ROOT=
	FEATURE_VER=

	if [ "$_VER" == "" ]; then
		__feature_elasticsearch_$(__default_elasticsearch)
	else
		# check for version
		for v in $(__list_elasticsearch); do
			[ "$v" == "$_VER" ] && __feature_elasticsearch_$_VER
		done
	fi
}



# --------------------------------------
function __install_elasticsearch_1_4_2() {
	URL=https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.2.tar.gz
	VER=1_4_2
	FILE_NAME=elasticsearch-1.4.2.tar.gz
	__install_elasticsearch_internal

	# NEED JDK 7 >= 7.60
}

function __feature_elasticsearch_1_4_2() {
	FEATURE_TEST="$STELLA_APP_FEATURE_ROOT/elasticsearch/1_4_2/bin/elasticsearch"
	FEATURE_RESULT_ROOT="$STELLA_APP_FEATURE_ROOT/elasticsearch/1_4_2"
	FEATURE_RESULT_PATH="$FEATURE_RESULT_ROOT/bin"
	FEATURE_RESULT_VER="1_4_2"
	__feature_elasticsearch_internal
}


# --------------------------------------



function __install_elasticsearch_internal() {
	
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/elasticsearch/$VER"
	SRC_DIR=
	BUILD_DIR=


	echo " ** Installing elasticsearch version $VER in $INSTALL_DIR"
	

	__feature_elasticsearch_$VER
	if [ "$FORCE" ]; then
		TEST_FEATURE=0
		__del_folder $INSTALL_DIR
	fi
	if [ "$TEST_FEATURE" == "0" ]; then


		__download_uncompress "$URL" "$FILE_NAME" "$INSTALL_DIR" "DEST_ERASE STRIP"

		__feature_elasticsearch_$VER
		if [ "$TEST_FEATURE" == "1" ]; then
			echo " ** elasticsearch installed"
			"$FEATURE_ROOT/bin/elasticsearch" -h

		else
			echo "** ERROR"
		fi
	else
		echo " ** Already installed"
	fi

}
function __feature_elasticsearch_internal() {
	TEST_FEATURE=0
	
	if [ -f "$FEATURE_TEST" ]; then
		TEST_FEATURE=1
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : elasticsearch in $FEATURE_RESULT_ROOT"
		FEATURE_PATH="$FEATURE_RESULT_PATH"
		FEATURE_ROOT="$FEATURE_RESULT_ROOT"
		FEATURE_VER="$FEATURE_RESULT_VER"
	fi
}

fi