if [ ! "$_NGINX_INCLUDED_" == "1" ]; then 
_NGINX_INCLUDED_=1


function __list_nginx() {
	echo "1_7_10"
}

function __default_nginx() {
	echo "1_7_10"
}

function __install_nginx() {
	local _VER=$1

	TEST_FEATURE=0
	FEATURE_PATH=
	FEATURE_ROOT=
	FEATURE_VER=

	mkdir -p $STELLA_APP_FEATURE_ROOT/nginx
	if [ "$_VER" == "" ]; then
		__install_nginx_$(__default_nginx)
	else
		# check for version
		for v in $(__list_nginx); do
			[ "$v" == "$_VER" ] && __install_nginx_$_VER
		done
	fi
	
}
function __feature_nginx() {
	local _VER=$1

	TEST_FEATURE=0
	FEATURE_PATH=
	FEATURE_ROOT=
	FEATURE_VER=

	if [ "$_VER" == "" ]; then
		__feature_nginx_$(__default_nginx)
	else
		# check for version
		for v in $(__list_nginx); do
			[ "$v" == "$_VER" ] && __feature_nginx_$_VER
		done
	fi
}



# --------------------------------------


function __install_nginx_1_7_10() {
	URL=http://nginx.org/download/nginx-1.7.10.tar.gz
	FILE_NAME=nginx-1.7.10.tar.gz
	VER=1_7_10
	
	__install_nginx_internal

	# NEED Elasticsearch
}

function __feature_nginx_1_7_10() {
	FEATURE_TEST="$STELLA_APP_FEATURE_ROOT/nginx/1_7_10/sbin/nginx"
	FEATURE_RESULT_ROOT="$STELLA_APP_FEATURE_ROOT/nginx/1_7_10"
	FEATURE_RESULT_PATH="$FEATURE_RESULT_ROOT/sbin"
	FEATURE_RESULT_VER="1_7_10"
	__feature_nginx_internal
}


# --------------------------------------



function __install_nginx_internal() {
	
	# out of tree build do not work
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/nginx/$VER"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/nginx/nginx-$VER-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/nginx/nginx-$VER-src"



	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX=

	__feature_nginx_$VER
	if [ "$FORCE" ]; then
		TEST_FEATURE=0
		__del_folder "$INSTALL_DIR"
	fi
	if [ "$TEST_FEATURE" == "0" ]; then

		# depend on pcre, but nginx have special recipe to build it itself
		__download_uncompress "https://downloads.sourceforge.net/project/pcre/pcre/8.36/pcre-8.36.tar.bz2" "pcre-8.36.tar.bz2" "$STELLA_APP_FEATURE_ROOT/nginx/pcre-8_36-src" "DEST_ERASE STRIP"

		AUTO_INSTALL_FLAG_POSTFIX="$AUTO_INSTALL_FLAG_POSTFIX --with-pcre=$STELLA_APP_FEATURE_ROOT/nginx/pcre-8_36-src"


		__auto_install "configure" "nginx" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "DEST_ERASE STRIP"
		
		__del_folder "$STELLA_APP_FEATURE_ROOT/nginx/pcre-8_36-src"

		__feature_nginx_$VER
		if [ "$TEST_FEATURE" == "1" ]; then
			echo " ** nginx installed"
			"$FEATURE_ROOT/sbin/nginx" -V
		else
			echo "** ERROR"
		fi

	else
		echo " ** Already installed"
	fi

}
function __feature_nginx_internal() {
	TEST_FEATURE=0
	
	if [ -f "$FEATURE_TEST" ]; then
		TEST_FEATURE=1
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : nginx in $FEATURE_RESULT_ROOT"
		FEATURE_PATH="$FEATURE_RESULT_PATH"
		FEATURE_ROOT="$FEATURE_RESULT_ROOT"
		FEATURE_VER="$FEATURE_RESULT_VER"
	fi
}

fi