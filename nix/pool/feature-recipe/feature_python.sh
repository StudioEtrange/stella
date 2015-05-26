if [ ! "$_PYTHON_INCLUDED_" == "1" ]; then 
_PYTHON_INCLUDED_=1

# EXPERIMENTAL NOT FINISHED

function feature_python() {

	FEAT_NAME=python
	FEAT_LIST_SCHEMA="2_7_9/source"
	FEAT_DEFAULT_VERSION=2_7_9
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_python_2_7_9() {

	FEAT_VERSION=2_7_9

	FEAT_SOURCE_URL=https://www.python.org/ftp/python/2.7.9/Python-2.7.9.tgz
	FEAT_SOURCE_URL_FILENAME=Python-2.7.9.tgz
	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_CALLBACK=

	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/python
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/lib
	FEAT_ENV_CALLBACK=
	
	FEAT_BUNDLE_ITEM=
}

function feature_python_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-build"

	# depend on openssl

	# AUTO_INSTALL_FLAG_PREFIX=
	# AUTO_INSTALL_FLAG_POSTFIX="--disable-dependency-tracking \
 #                          --enable-utf8 \
 #                          --enable-python8 \
 #                          --enable-python16 \
 #                          --enable-python32 \
 #                          --enable-unicode-properties \
 #                          --enable-pythongrep-libz \
 #                          --enable-pythongrep-libbz2 \
 #                          --enable-jit"

	__auto_install "configure" "python" "$FEAT_SOURCE_URL_FILENAME" "$FEAT_SOURCE_URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "DEST_ERASE STRIP"

}



fi