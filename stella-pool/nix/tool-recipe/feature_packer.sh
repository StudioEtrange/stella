if [ ! "$_PACKER_INCLUDED_" == "1" ]; then 
_PACKER_INCLUDED_=1

 
function __list_packer() {
	echo "0_6_0"
}


function __install_packer() {
	local _VER=$1
	local _DEFAULT_VER="0_6_0"

	mkdir -p $TOOL_ROOT/packer
	if [ "$_VER" == "" ]; then
		__install_packer_$_DEFAULT_VER
	else
		__install_packer_$_VER
	fi
}
function __feature_packer() {
	local _VER=$1
	local _DEFAULT_VER="0_6_0"

	if [ "$_VER" == "" ]; then
		__feature_packer_$_DEFAULT_VER
	else
		__feature_packer_$_VER
	fi
}





function __install_packer_0_6_0() {
	if [ "$STELLA_CURRENT_PLATFORM" == "macos" ]; then
		if [ "$ARCH" == "x64" ]; then
			URL=https://dl.bintray.com/mitchellh/packer/0.6.0_darwin_amd64.zip
			FILE_NAME=0.6.0_darwin_amd64.zip
		else
			URL=https://dl.bintray.com/mitchellh/packer/0.6.0_darwin_386.zip
			FILE_NAME=0.6.0_darwin_386.zip
		fi
	else
		if [ "$ARCH" == "x64" ]; then
			URL=https://dl.bintray.com/mitchellh/packer/0.6.0_linux_amd64.zip
			FILE_NAME=0.6.0_linux_amd64.zip
		else
			URL=https://dl.bintray.com/mitchellh/packer/0.6.0_linux_386.zip
			FILE_NAME=0.6.0_linux_386.zip
		fi
	fi
	VER=0_6_0
	INSTALL_DIR="$TOOL_ROOT/packer/$VER"
	
	echo " ** Installing packer version $VER in $INSTALL_DIR"
	
	__feature_packer_0_6_0
	if [ "$FORCE" ]; then
		TEST_FEATURE=0
		del_folder $INSTALL_DIR
	fi
	if [ "$TEST_FEATURE" == "0" ]; then

		__download_uncompress "$URL" "$FILE_NAME" "$INSTALL_DIR" "DEST_ERASE STRIP"
		
		__feature_packer_0_6_0
		if [ ! "$TEST_FEATURE" == "0" ]; then
			cd $INSTALL_DIR
			chmod +x *
			echo " ** Packer installed"
			"$TEST_FEATURE/packer" --version
		else
			echo "** ERROR"
		fi
	else
		echo " ** Already installed"
	fi
}
function __feature_packer_0_6_0() {
	TEST_FEATURE=0
	FEATURE_PATH=
	FEATURE_VER=
	if [ -f "$TOOL_ROOT/packer/0_6_0/packer" ]; then
		TEST_FEATURE="$TOOL_ROOT/packer/0_6_0"
	fi

	if [ ! "$TEST_FEATURE" == "0" ]; then
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : packer in $TEST_FEATURE"
		PACKER_CMD="$TEST_FEATURE/./$PACKER_CMD"
		FEATURE_PATH="$TEST_FEATURE"
		FEATURE_VER="0_6_0"
	fi
}


fi
