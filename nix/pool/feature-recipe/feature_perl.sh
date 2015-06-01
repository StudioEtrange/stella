if [ ! "$_PERL_INCLUDED_" == "1" ]; then 
_PERL_INCLUDED_=1


function feature_perl() {

	FEAT_NAME=perl
	FEAT_LIST_SCHEMA="5_18_2:source"
	FEAT_DEFAULT_VERSION=5_18_2
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_perl_5_18_2() {

	FEAT_VERSION=5_18_2

	FEAT_SOURCE_URL=http://www.cpan.org/src/5.0/perl-5.18.2.tar.gz
	FEAT_SOURCE_URL_FILENAME=perl-5.18.2.tar.gz
	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_CALLBACK=

	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/perl
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
	FEAT_ENV_CALLBACK=
	
	FEAT_BUNDLE_ITEM=
}

function feature_perl_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"
	BUILD_DIR=

	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX=


	__download_uncompress "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_FILENAME" "$SRC_DIR" "DEST_ERASE STRIP"

	cd "$SRC_DIR"

	sh "$SRC_DIR/Configure" -des -Dprefix=$INSTALL_DIR \
                  -Dvendorprefix=$INSTALL_DIR \
                  -Dpager="/usr/bin/less -isR"  \
                  -Duseshrplib

	make
	# test are too long
	# make test
	make install && __del_folder $SRC_DIR
}



fi