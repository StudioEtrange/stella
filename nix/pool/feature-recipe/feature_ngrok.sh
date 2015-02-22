if [ ! "$_NGROK_INCLUDED_" == "1" ]; then 
_NGROK_INCLUDED_=1

 
function __list_ngrok() {
	echo "stable_x86 stable_x64"
}

function __default_ngrok() {
	echo "stable_x64"
}

function __install_ngrok() {
	local _VER=$1

	TEST_FEATURE=0
	FEATURE_PATH=
	FEATURE_ROOT=
	FEATURE_VER=

	mkdir -p $STELLA_APP_FEATURE_ROOT/ngrok

	if [ "$_VER" == "" ]; then
		__install_ngrok_$(__default_ngrok)
	else
		# check for version
		for v in $(__list_ngrok); do
			[ "$v" == "$_VER" ] && __install_ngrok_$_VER
		done
	fi

}
function __feature_ngrok() {
	local _VER=$1

	TEST_FEATURE=0
	FEATURE_PATH=
	FEATURE_ROOT=
	FEATURE_VER=

	if [ "$_VER" == "" ]; then
		__feature_ngrok_$(__default_ngrok)
	else
		# check for version
		for v in $(__list_ngrok); do
			[ "$v" == "$_VER" ] && __feature_ngrok_$_VER
		done
	fi
}

# -----------------------------------------

function __install_ngrok_stable_x64() {
	if [ "$STELLA_CURRENT_PLATFORM" == "macos" ]; then
		URL="https://api.equinox.io/1/Applications/ap_pJSFC5wQYkAyI0FIVwKYs9h1hW/Updates/Asset/ngrok.zip?channel=stable&os=darwin&arch=amd64"
		FILE_NAME=ngrok_darwin_amd64.zip
	fi
	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		URL="https://api.equinox.io/1/Applications/ap_pJSFC5wQYkAyI0FIVwKYs9h1hW/Updates/Asset/ngrok.zip?channel=stable&os=linux&arch=amd64"
		FILE_NAME=ngrok_linux_amd64.zip
	fi

	VER=stable_x64
	__install_ngrok_internal
}
function __feature_ngrok_stable_x64() {
	FEATURE_TEST="$STELLA_APP_FEATURE_ROOT/ngrok/stable_x64/ngrok"
	FEATURE_RESULT_ROOT="$STELLA_APP_FEATURE_ROOT/ngrok/stable_x64"
	FEATURE_RESULT_PATH="$FEATURE_RESULT_ROOT"
	FEATURE_RESULT_VER="stable_x64"
	__feature_ngrok_internal
}



function __install_ngrok_stable_x86() {
	if [ "$STELLA_CURRENT_PLATFORM" == "macos" ]; then
		URL="https://api.equinox.io/1/Applications/ap_pJSFC5wQYkAyI0FIVwKYs9h1hW/Updates/Asset/ngrok.zip?channel=stable&os=darwin&arch=386"
		FILE_NAME=ngrok_darwin_386.zip
	fi
	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		URL="https://api.equinox.io/1/Applications/ap_pJSFC5wQYkAyI0FIVwKYs9h1hW/Updates/Asset/ngrok.zip?channel=stable&os=linux&arch=386"
		FILE_NAME=ngrok_linux_386.zip
	fi

	VER=stable_x86
	__install_ngrok_internal
}
function __feature_ngrok_stable_x86() {
	FEATURE_TEST="$STELLA_APP_FEATURE_ROOT/ngrok/stable_x86/ngrok"
	FEATURE_RESULT_ROOT="$STELLA_APP_FEATURE_ROOT/ngrok/stable_x86"
	FEATURE_RESULT_PATH="$FEATURE_RESULT_ROOT"
	FEATURE_RESULT_VER="stable_x86"
	__feature_ngrok_internal
}


# -----------------------------------------
function __install_ngrok_internal() {
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/ngrok/$VER"
	
	echo " ** Installing ngrok version $VER in $INSTALL_DIR"
	
	__feature_ngrok_$VER
	if [ "$FORCE" ]; then
		TEST_FEATURE=0
		__del_folder $INSTALL_DIR
	fi
	if [ "$TEST_FEATURE" == "0" ]; then

		__download_uncompress "$URL" "$FILE_NAME" "$INSTALL_DIR" "DEST_ERASE STRIP"

		__feature_ngrok_$VER
		if [ "$TEST_FEATURE" == "1" ]; then
			cd $INSTALL_DIR
			chmod +x *
			echo " ** ngrok installed"
			"$FEATURE_ROOT/ngrok" version
		else
			echo "** ERROR"
		fi
	else
		echo " ** Already installed"
	fi
}


function __feature_ngrok_internal() {
	TEST_FEATURE=0
	
	if [ -f "$FEATURE_TEST" ]; then
		TEST_FEATURE=1
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : ngrok in $FEATURE_RESULT_ROOT"
		FEATURE_PATH="$FEATURE_RESULT_PATH"
		FEATURE_ROOT="$FEATURE_RESULT_ROOT"
		FEATURE_VER="$FEATURE_RESULT_VER"
	fi
}


fi
