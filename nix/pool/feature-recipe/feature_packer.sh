if [ ! "$_PACKER_INCLUDED_" == "1" ]; then 
_PACKER_INCLUDED_=1

 
function __list_packer() {
	echo "0_6_0_x64 0_6_0_x86"
}

function __default_packer() {
	echo "0_6_0_x64"
}

function __install_packer() {
	local _VER=$1
	local _DEFAULT_VER="$(__default_packer)"

	mkdir -p $STELLA_APP_FEATURE_ROOT/packer
	if [ "$_VER" == "" ]; then
		__install_packer_$_DEFAULT_VER
	else
		__install_packer_$_VER
	fi
}
function __feature_packer() {
	local _VER=$1
	local _DEFAULT_VER="$(__default_packer)"

	if [ "$_VER" == "" ]; then
		__feature_packer_$_DEFAULT_VER
	else
		__feature_packer_$_VER
	fi
}

# -----------------------------------------

function __install_packer_0_6_0_x64() {
	if [ "$STELLA_CURRENT_PLATFORM" == "macos" ]; then
		URL=https://dl.bintray.com/mitchellh/packer/0.6.0_darwin_amd64.zip
		FILE_NAME=0.6.0_darwin_amd64.zip
	else
		URL=https://dl.bintray.com/mitchellh/packer/0.6.0_linux_amd64.zip
		FILE_NAME=0.6.0_linux_amd64.zip
	fi

	VER=0_6_0_x64
	__install_packer_internal
}
function __install_packer_0_6_0_x86() {
	if [ "$STELLA_CURRENT_PLATFORM" == "macos" ]; then
		URL=https://dl.bintray.com/mitchellh/packer/0.6.0_darwin_386.zip
		FILE_NAME=0.6.0_darwin_386.zip
	else
		URL=https://dl.bintray.com/mitchellh/packer/0.6.0_linux_386.zip
		FILE_NAME=0.6.0_linux_386.zip
	fi

	VER=0_6_0_x86
	__install_packer_internal
}


function __feature_packer_0_6_0_x64() {
	FEATURE_TEST="$STELLA_APP_FEATURE_ROOT/packer/0_6_0_x64/packer"
	FEATURE_RESULT_ROOT="$STELLA_APP_FEATURE_ROOT/packer/0_6_0_x64"
	FEATURE_RESULT_PATH="$FEATURE_RESULT_ROOT"
	FEATURE_RESULT_VER="0_6_0_x64"
	__feature_packer_internal
	FEATURE_RESULT_PATH=
	FEATURE_RESULT_ROOT=
	FEATURE_RESULT_VER=
}


function __feature_packer_0_6_0_x86() {
	FEATURE_TEST="$STELLA_APP_FEATURE_ROOT/packer/0_6_0_x86/packer"
	FEATURE_RESULT_ROOT="$STELLA_APP_FEATURE_ROOT/packer/0_6_0_x86"
	FEATURE_RESULT_PATH="$FEATURE_RESULT_ROOT"
	FEATURE_RESULT_VER="0_6_0_x86"
	__feature_packer_internal
	FEATURE_TEST=
	FEATURE_RESULT_PATH=
	FEATURE_RESULT_ROOT=
	FEATURE_RESULT_VER=
}


# -----------------------------------------
function __install_packer_internal() {
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/packer/$VER"
	
	echo " ** Installing packer version $VER in $INSTALL_DIR"
	
	__feature_packer_$VER
	if [ "$FORCE" ]; then
		TEST_FEATURE=0
		del_folder $INSTALL_DIR
	fi
	if [ "$TEST_FEATURE" == "0" ]; then

		__download_uncompress "$URL" "$FILE_NAME" "$INSTALL_DIR" "DEST_ERASE STRIP"
		
		__feature_packer_$VER
		if [ ! "$TEST_FEATURE" == "0" ]; then
			cd $INSTALL_DIR
			chmod +x *
			echo " ** Packer installed"
			"$FEATURE_ROOT/packer" --version
		else
			echo "** ERROR"
		fi
	else
		echo " ** Already installed"
	fi
}


function __feature_packer_internal() {
	TEST_FEATURE=0
	FEATURE_ROOT=
	FEATURE_PATH=
	FEATURE_VER=
	if [ -f "$FEATURE_TEST" ]; then
		TEST_FEATURE=1
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : packer in $FEATURE_RESULT_ROOT"
		FEATURE_PATH="$FEATURE_RESULT_PATH"
		FEATURE_ROOT="$FEATURE_RESULT_ROOT"
		FEATURE_VER="$FEATURE_RESULT_VER"
	fi
}


fi
