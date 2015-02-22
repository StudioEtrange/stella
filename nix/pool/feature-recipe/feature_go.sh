if [ ! "$_GO_INCLUDED_" == "1" ]; then 
_GO_INCLUDED_=1


 
function __list_go() {
	echo "1_4_2"
}

function __default_go() {
	echo "1_4_2"
}


function __install_go() {
	local _VER=$1

	TEST_FEATURE=0
	FEATURE_PATH=
	FEATURE_ROOT=
	FEATURE_VER=

	mkdir -p $STELLA_APP_FEATURE_ROOT/go

	if [ "$_VER" == "" ]; then
		__install_go_$(__default_go)
	else
		# check for version
		for v in $(__list_go); do
			[ "$v" == "$_VER" ] && __install_go_$_VER
		done
	fi

}
function __feature_go() {
	local _VER=$1

	TEST_FEATURE=0
	FEATURE_PATH=
	FEATURE_ROOT=
	FEATURE_VER=

	if [ "$_VER" == "" ]; then
		__feature_go_$(__default_go)
	else
		# check for version
		for v in $(__list_go); do
			[ "$v" == "$_VER" ] && __feature_go_$_VER
		done
	fi
}


# --------------------------------------
function __install_go_1_4_2() {
	URL=https://storage.googleapis.com/golang/go1.4.2.src.tar.gz
	VER=1_4_2
	FILE_NAME=go1.4.2.src.tar.gz
	__install_go_internal
}


function __feature_go_1_4_2() {
	FEATURE_TEST="$STELLA_APP_FEATURE_ROOT/go/1_4_2/bin/go"
	FEATURE_RESULT_ROOT="$STELLA_APP_FEATURE_ROOT/go/1_4_2"
	FEATURE_RESULT_PATH="$FEATURE_RESULT_ROOT/bin"
	FEATURE_RESULT_VER="1_4_2"
	__feature_go_internal


}

# --------------------------------------

function __install_go_internal() { 
	
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/go/$VER"
	SRC_DIR=
	BUILD_DIR=

	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX=

	__feature_go_$VER
	if [ "$FORCE" ]; then
		TEST_FEATURE=0
		__del_folder $INSTALL_DIR
	fi
	if [ "$TEST_FEATURE" == "0" ]; then
		__download_uncompress "$URL" "$FILE_NAME" "$INSTALL_DIR" "DEST_ERASE STRIP"
		
		
		# GOOS and GOARCH are selected xith the current system
		#GOOS
		#GOARCH=amd64 or 386 or arm

		cd "$SRC_DIR"
		cd src

		# line below include tests which are too slow
		#./all.bash
		./make.bash
		
		__feature_go_$VER
		if [ "$TEST_FEATURE" == "1" ]; then
			echo " ** Go installed"
			"$FEATURE_ROOT/bin/go" version
		else
			echo "** ERROR"
		fi

	else
		echo " ** Already installed"
	fi
}
function __feature_go_internal() {
	TEST_FEATURE=0
	
	if [ -f "$FEATURE_TEST" ]; then
		TEST_FEATURE=1
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : go in $FEATURE_RESULT_ROOT"
		FEATURE_PATH="$FEATURE_RESULT_PATH"
		FEATURE_ROOT="$FEATURE_RESULT_ROOT"
		FEATURE_VER="$FEATURE_RESULT_VER"

		export GOROOT=$FEATURE_RESULT_ROOT
		export GOPATH=$STELLA_APP_ROOT
		[ "$VERBOSE_MODE" == "0" ] || ( echo " * Go setup : $("$FEATURE_ROOT/bin/go" version)"
										echo " * GOROOT : $GOROOT"
										echo " * GOPATH : $GOPATH" )
		
	fi

}


fi