if [ ! "$_PCRE_INCLUDED_" == "1" ]; then 
_PCRE_INCLUDED_=1



function feature_pcre() {

	FEAT_NAME=pcre
	FEAT_LIST_SCHEMA="8_36:source"
	FEAT_DEFAULT_VERSION=8_36
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_pcre_8_36() {

	FEAT_VERSION=8_36

	FEAT_SOURCE_URL=https://downloads.sourceforge.net/project/pcre/pcre/8.36/pcre-8.36.tar.bz2
	FEAT_SOURCE_URL_FILENAME=pcre-8.36.tar.bz2
	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_CALLBACK=

	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/lib/libpcre.a
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/lib
	FEAT_ENV_CALLBACK=
	
	FEAT_BUNDLE_ITEM=
}

function feature_pcre_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-build"


	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX="--disable-dependency-tracking \
                          --enable-utf8 \
                          --enable-pcre8 \
                          --enable-pcre16 \
                          --enable-pcre32 \
                          --enable-unicode-properties \
                          --enable-pcregrep-libz \
                          --enable-pcregrep-libbz2 \
                          --enable-jit"

	__auto_install "configure" "pcre" "$FEAT_SOURCE_URL_FILENAME" "$FEAT_SOURCE_URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "DEST_ERASE STRIP"

}



fi