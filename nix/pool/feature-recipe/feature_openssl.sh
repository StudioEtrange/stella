if [ ! "$_OPENSSL_INCLUDED_" = "1" ]; then
_OPENSSL_INCLUDED_=1

# TODO
# Require perl (from system is enough), to configure source code
# Require system "build-system"
# build with an arch

# NOTE : On darwin openssl lib in lib/engines folder does not have LC_ID_DYLIB


feature_openssl() {
	FEAT_NAME=openssl
	FEAT_LIST_SCHEMA="1_0_2k:source 1_0_2d:source"
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}




feature_openssl_1_0_2k() {
	FEAT_VERSION=1_0_2k

	FEAT_SOURCE_DEPENDENCIES="zlib#1_2_8"
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=https://www.openssl.org/source/openssl-1.0.2k.tar.gz
	FEAT_SOURCE_URL_FILENAME=openssl-1.0.2k.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=feature_openssl_link
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/openssl
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}


feature_openssl_1_0_2d() {
	FEAT_VERSION=1_0_2d

	FEAT_SOURCE_DEPENDENCIES="zlib#1_2_8"
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=https://www.openssl.org/source/openssl-1.0.2d.tar.gz
	FEAT_SOURCE_URL_FILENAME=openssl-1.0.2d.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=feature_openssl_link
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/openssl
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}

feature_openssl_link() {
	# zlib dependencies
	__link_feature_library "zlib#1_2_8" "LIBS_NAME z GET_FLAGS _zlib FORCE_DYNAMIC NO_SET_FLAGS"
}



feature_openssl_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"

	__set_toolset "STANDARD"

	__require "perl" "perl" "SYSTEM"

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP"


	ARCH=$STELLA_BUILD_ARCH
	[ "$ARCH" = "" ] && ARCH="x64"

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		OPENSSL_OPT="shared no-idea no-mdc2 no-rc5 enable-ssl2 enable-tlsext enable-cms"

		[ "$ARCH" = "x86" ] && OPENSSL_PLATFORM="darwin-i386-cc"
		if [ "$ARCH" = "x64" ]; then
			OPENSSL_PLATFORM="darwin64-x86_64-cc"
			OPENSSL_OPT="$OPENSSL_OPT enable-ec_nistp_64_gcc_128"
		fi
	fi

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		OPENSSL_OPT="shared no-idea no-mdc2 no-rc5 enable-ssl2 enable-tlsext enable-cms enable-krb5"

		[ "$ARCH" = "x86" ] && OPENSSL_PLATFORM=linux-generic32
		[ "$ARCH" = "x64" ] && OPENSSL_PLATFORM=linux-x86_64
	fi

	__feature_callback

	__start_manual_build "openssl" "$SRC_DIR" "$INSTALL_DIR"
	#__prepare_build "$INSTALL_DIR" "$SRC_DIR" "$SRC_DIR"

	cd "$SRC_DIR"
	# configure --------------------------------
	# http://stackoverflow.com/questions/16601895/how-can-one-build-openssl-on-ubuntu-with-a-specific-version-of-zlib
	# zlib zlib-dynamic --with-zlib-lib and --with-zlib-include do not work properly to link openssl against a specific zlib version
	# 		so we use direct flag -Ixxx -Lxxx -lxxx, with zlib before (in this case use "zlib" either when linking static or dynamic)
	perl "Configure" $OPENSSL_OPT \
		zlib $_zlib_CPP_FLAGS $_zlib_C_CXX_FLAGS $_zlib_LINK_FLAGS \
		--openssldir=$INSTALL_DIR/etc/ssl --libdir=lib --prefix=$INSTALL_DIR \
		$OPENSSL_PLATFORM

	# build --------------------------------
	$STELLA_API del_folder $INSTALL_DIR/share/man/openssl

	make depend
	make -j$STELLA_NB_CPU all

	make MANDIR=$INSTALL_DIR/share/man/openssl MANSUFFIX=ssl install
	# TODO : 'make test' do not work if we build for a different architecture than the host
	#[ "$ARCH" = "x64" ] && make test

	__end_manual_build

	# clean --------------------------------
	cd "$INSTALL_DIR"
	rm -Rf "$SRC_DIR"

	__inspect_and_fix_build "$INSTALL_DIR" "EXCLUDE_FILTER /share/man/"
}


fi
