if [ ! "$_GETTEXT_INCLUDED_" == "1" ]; then 
_GETTEXT_INCLUDED_=1

# https://github.com/Homebrew/homebrew/blob/master/Library/Formula/gettext.rb

function feature_gettext() {

	FEAT_NAME=gettext
	FEAT_LIST_SCHEMA="0_19_4:source"
	FEAT_DEFAULT_VERSION=0_19_4
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_gettext_0_19_4() {
	FEAT_VERSION=0_19_4
	
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=http://ftpmirror.gnu.org/gettext/gettext-0.19.4.tar.xz
	FEAT_SOURCE_URL_FILENAME=gettext-0.19.4.tar.xz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/gettext
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
}


function feature_gettext_install_source() {
	
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"
	

	AUTO_INSTALL_CONF_FLAG_PREFIX=
	AUTO_INSTALL_CONF_FLAG_POSTFIX="--disable-dependency-tracking \
                          --disable-silent-rules \
                          --disable-debug \
                          --with-included-gettext \
                          --with-included-glib \
                          --with-included-libcroco \
                          --with-included-libunistring \
                          --with-emacs \
                          --disable-java \
                          --disable-csharp \
                          --without-git \
                          --without-cvs\
                          --without-xz"

	AUTO_INSTALL_BUILD_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_POSTFIX=

	__auto_install "gettext" "$FEAT_SOURCE_URL_FILENAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "$INSTALL_DIR" "CONF_TOOL configure BUILD_TOOL make"
	
}

fi