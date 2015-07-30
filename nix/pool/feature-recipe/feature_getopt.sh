if [ ! "$_GETOPT_INCLUDED_" == "1" ]; then 
_GETOPT_INCLUDED_=1

#https://github.com/Homebrew/homebrew/blob/master/Library/Formula/gnu-getopt.rb
# TODO : patch makefile with macport recipe ?

function feature_getopt() {

	FEAT_NAME=getopt
	FEAT_LIST_SCHEMA="1_1_6:source"
	FEAT_DEFAULT_VERSION=1_1_6
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_getopt_1_1_6() {
	FEAT_VERSION=1_1_6
	# depend on gettext ?
	FEAT_SOURCE_DEPENDENCIES="gettext#0_19_4:source"
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=http://frodo.looijaard.name/system/files/software/getopt/getopt-1.1.6.tar.gz
	FEAT_SOURCE_URL_FILENAME=getopt-1.1.6.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=feature_getopt_1_1_6_patch
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/getopt
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}



function feature_getopt_1_1_6_patch() {
	# https://github.com/Homebrew/homebrew/blob/master/Library/Formula/gnu-getopt.rb

	__link_library "gettext" "intl" "GET_C_CXX_FLAGS _c_cxx_flags GET_LINK_FLAGS _link_flags"
	
	
	#sed -i .bak 's,^\(CPPFLAGS=.*\),\1 '"-I$FEAT_INSTALL_ROOT/include"',' $SRC_DIR/Makefile
	#sed -i .bak 's,^\(LDFLAGS=.*\),\1 '"-L$FEAT_INSTALL_ROOT/lib -lintl"',' $SRC_DIR/Makefile

	sed -i .bak 's,^\(CPPFLAGS=.*\),\1 '"$_c_cxx_flags"',' $SRC_DIR/Makefile
	sed -i .bak 's,^\(LDFLAGS=.*\),\1 '"$_link_flags"',' $SRC_DIR/Makefile
}

function feature_getopt_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP"

	__feature_callback
	
	cd "$SRC_DIR"
	make -j$STELLA_NB_CPU
	make prefix="$INSTALL_DIR" mandir=man install && __del_folder $SRC_DIR
}



fi