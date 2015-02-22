if [ ! "$_KIBANA_INCLUDED_" == "1" ]; then 
_KIBANA_INCLUDED_=1


function __list_kibana() {
	echo "3_1_2 4_0_0"
}

function __default_kibana() {
	echo "3_1_2"
}

function __install_kibana() {
	local _VER=$1

	TEST_FEATURE=0
	FEATURE_PATH=
	FEATURE_ROOT=
	FEATURE_VER=

	mkdir -p $STELLA_APP_FEATURE_ROOT/kibana
	if [ "$_VER" == "" ]; then
		__install_kibana_$(__default_kibana)
	else
		# check for version
		for v in $(__list_kibana); do
			[ "$v" == "$_VER" ] && __install_kibana_$_VER
		done
	fi
	
}
function __feature_kibana() {
	local _VER=$1

	TEST_FEATURE=0
	FEATURE_PATH=
	FEATURE_ROOT=
	FEATURE_VER=

	if [ "$_VER" == "" ]; then
		__feature_kibana_$(__default_kibana)
	else
		# check for version
		for v in $(__list_kibana); do
			[ "$v" == "$_VER" ] && __feature_kibana_$_VER
		done
	fi
}



# --------------------------------------
function __install_kibana_3_1_2() {
	URL=https://download.elasticsearch.org/kibana/kibana/kibana-3.1.2.tar.gz
	VER=3_1_2
	FILE_NAME=kibana-3.1.2.tar.gz
	__install_kibana_internal

	# NEED Elasticsearch
}

function __feature_kibana_3_1_2() {
	FEATURE_TEST="$STELLA_APP_FEATURE_ROOT/kibana/3_1_2/config.js"
	FEATURE_RESULT_ROOT="$STELLA_APP_FEATURE_ROOT/kibana/3_1_2"
	FEATURE_RESULT_PATH="$FEATURE_RESULT_ROOT"
	FEATURE_RESULT_VER="3_1_2"
	__feature_kibana_internal
}


function __install_kibana_4_0_0() {
	if [ "$STELLA_CURRENT_PLATFORM" == "macos" ]; then 
		URL=https://download.elasticsearch.org/kibana/kibana/kibana-4.0.0-darwin-x64.tar.gz
		FILE_NAME=kibana-4.0.0-darwin-x64.tar.gz
	fi

	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		URL=https://download.elasticsearch.org/kibana/kibana/kibana-4.0.0-linux-x64.tar.gz
		FILE_NAME=kibana-4.0.0-linux-x64.tar.gz
	fi
	VER=4_0_0
	
	__install_kibana_internal

	# NEED Elasticsearch
}

function __feature_kibana_4_0_0() {
	FEATURE_TEST="$STELLA_APP_FEATURE_ROOT/kibana/4_0_0/bin/kibana"
	FEATURE_RESULT_ROOT="$STELLA_APP_FEATURE_ROOT/kibana/4_0_0"
	FEATURE_RESULT_PATH="$FEATURE_RESULT_ROOT/bin"
	FEATURE_RESULT_VER="4_0_0"
	__feature_kibana_internal
}


# --------------------------------------



function __install_kibana_internal() {
	
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/kibana/$VER"
	SRC_DIR=
	BUILD_DIR=


	echo " ** Installing kibana version $VER in $INSTALL_DIR"
	

	__feature_kibana_$VER
	if [ "$FORCE" ]; then
		TEST_FEATURE=0
		__del_folder $INSTALL_DIR
	fi
	if [ "$TEST_FEATURE" == "0" ]; then


		__download_uncompress "$URL" "$FILE_NAME" "$INSTALL_DIR" "DEST_ERASE STRIP"


		__feature_kibana_$VER
		if [ "$TEST_FEATURE" == "1" ]; then
			echo " ** kibana installed"
		else
			echo "** ERROR"
		fi
	else
		echo " ** Already installed"
	fi

}
function __feature_kibana_internal() {
	TEST_FEATURE=0
	
	if [ -f "$FEATURE_TEST" ]; then
		TEST_FEATURE=1
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : kibana in $FEATURE_RESULT_ROOT"
		FEATURE_PATH="$FEATURE_RESULT_PATH"
		FEATURE_ROOT="$FEATURE_RESULT_ROOT"
		FEATURE_VER="$FEATURE_RESULT_VER"
	fi
}

fi