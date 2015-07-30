if [ ! "$_OPENSSL_INCLUDED_" == "1" ]; then 
_OPENSSL_INCLUDED_=1

# Requipre perl (from system is enough), to configure source code
# Require system "build-system"

function feature_openssl() {
	FEAT_NAME=openssl
	FEAT_LIST_SCHEMA="1_0_2d:source"
	FEAT_DEFAULT_VERSION=1_0_2d
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_openssl_1_0_2d() {
	FEAT_VERSION=1_0_2d

	FEAT_SOURCE_DEPENDENCIES="zlib#1_2_8"
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=https://www.openssl.org/source/openssl-1.0.2d.tar.gz
	FEAT_SOURCE_URL_FILENAME=openssl-1.0.2d.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/openssl
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}



function feature_openssl_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"
	

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP"

	ARCH=x64
	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		OPENSSL_OPT="shared no-idea no-mdc2 no-rc5 enable-ssl2 enable-tlsext enable-cms"

		[ "$ARCH" == "x86" ] && OPENSSL_PLATFORM="darwin-i386-cc"
		if [ "$ARCH" == "x64" ]; then
			OPENSSL_PLATFORM="darwin64-x86_64-cc"
			OPENSSL_OPT="$OPENSSL_OPT enable-ec_nistp_64_gcc_128"
		fi
	fi

	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		OPENSSL_OPT="shared no-idea no-mdc2 no-rc5 enable-ssl2 enable-tlsext enable-cms"

		[ "$ARCH" == "x86" ] && OPENSSL_PLATFORM=linux-generic32
		[ "$ARCH" == "x64" ] && OPENSSL_PLATFORM=linux-x86_64
	fi

	# zlib dependencies
	__link_library "zlib" "z" "GET_C_CXX_FLAGS _c_cxx_flags GET_LINK_FLAGS _link_flags"
	

	# configure --------------------------------
	# http://stackoverflow.com/questions/16601895/how-can-one-build-openssl-on-ubuntu-with-a-specific-version-of-zlib
	# zlib zlib-dynamic --with-zlib-lib and --with-zlib-include do not work properly to link openssl against a specific zlib version
	# 		zlib-dynamic --with-zlib-lib="$ZLIB_ROOT/lib" --with-zlib-include="$ZLIB_ROOT/include" \
	perl "Configure" $OPENSSL_OPT \
		$_c_cxx_flags $_link_flags \
		--openssldir=$INSTALL_DIR/etc/ssl --libdir=lib --prefix=$INSTALL_DIR \
		$OPENSSL_PLATFORM

	# build --------------------------------
	$STELLA_API del_folder $INSTALL_DIR/share/man/openssl

	make depend
	make -j$STELLA_NB_CPU all

	make MANDIR=$INSTALL_DIR/share/man/openssl MANSUFFIX=ssl install
	# TODO : 'make test' do not work if we build for a different architecture than the host
	#[ "$ARCH" == "x64" ] && make test

	# clean --------------------------------
	rm -Rf $SRC_DIR
}


fi
