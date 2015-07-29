if [ ! "$_NGINX_INCLUDED_" == "1" ]; then 
_NGINX_INCLUDED_=1



function feature_nginx() {
	FEAT_NAME=nginx
	FEAT_LIST_SCHEMA="1_7_11:source"
	FEAT_DEFAULT_VERSION=1_7_11
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_nginx_1_7_11() {
	FEAT_VERSION=1_7_11
	
	# depend on zlib
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=http://nginx.org/download/nginx-1.7.11.tar.gz
	FEAT_SOURCE_URL_FILENAME=nginx-1.7.11.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=feature_nginx_get_pcre
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/sbin/nginx
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/sbin

}




function feature_nginx_get_pcre() {
	# depend on pcre, but nginx have its own way of building it
	__download_uncompress "https://downloads.sourceforge.net/project/pcre/pcre/8.36/pcre-8.36.tar.bz2" "pcre-8.36.tar.bz2" "$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src/pcre/pcre-8_36-src" "DEST_ERASE STRIP"

	AUTO_INSTALL_CONF_FLAG_POSTFIX="$AUTO_INSTALL_CONF_FLAG_POSTFIX --with-pcre=$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src/pcre/pcre-8_36-src"
}

function feature_nginx_install_source() {
	
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src/nginx"

	AUTO_INSTALL_CONF_FLAG_PREFIX=
	AUTO_INSTALL_CONF_FLAG_POSTFIX=	
	AUTO_INSTALL_BUILD_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_POSTFIX=

	__feature_callback

	# out of tree build do not work
	__auto_install "nginx" "$FEAT_SOURCE_URL_FILENAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "$INSTALL_DIR" "NO_OUT_OF_TREE_BUILD CONF_TOOL configure BUILD_TOOL make"
	

}


fi