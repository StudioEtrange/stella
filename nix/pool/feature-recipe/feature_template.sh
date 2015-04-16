if [ ! "$_TEMPLATE_INCLUDED_" == "1" ]; then 
_TEMPLATE_INCLUDED_=1


function feature_template() {
	FEAT_NAME=template
	FEAT_LIST_SCHEMA="0_0_1/source 0_0_1/binary"
	FEAT_DEFAULT_VERSION=0_0_1
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR=binary

	FEAT_BUNDLE=
}

function feature_template_env()  {
	TEMPLATE_HOME=$FEAT_INSTALL_ROOT
	export TEMPLATE_HOME
}

function feature_template_0_0_1() {

	FEAT_VERSION=0_0_1

	FEAT_SOURCE_URL=http://foo.org/foo-src.zip
	FEAT_SOURCE_URL_FILENAME=foo-src.zip
	FEAT_SOURCE_CALLBACK=feature_template_patch_0_0_1
	FEAT_BINARY_URL=http://foo.org/foo-bin.zip
	FEAT_BINARY_URL_FILENAME=foo-bin.zip
	FEAT_BINARY_CALLBACK=feature_template_patch_0_0_1

	FEAT_DEPENDENCIES=
	# this one is auto setted but can be overrided
	#FEAT_INSTALL_ROOT=
	
	FEAT_INSTALL_TEST=$FEAT_INSTALL_ROOT/bin/foo
	FEAT_SEARCH_PATH=$FEAT_INSTALL_ROOT/bin
	FEAT_ENV=feature_template_env

	FEAT_BUNDLE_LIST=
}

function feature_template_patch_0_0_1 () {

}



function feature_template_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-build"

	__feature_apply_source_callback

	__download_uncompress "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_FILENAME" "$SRC_DIR" "DEST_ERASE STRIP"
	
	cd "$SRC_DIR"

	make
	make install && __del_folder $SRC_DIR
}

function feature_template_install_binary() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR=
	BUILD_DIR=

	__feature_apply_binary_callback

	__download_uncompress "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_FILENAME" "$INSTALL_DIR" "DEST_ERASE STRIP"

}


fi