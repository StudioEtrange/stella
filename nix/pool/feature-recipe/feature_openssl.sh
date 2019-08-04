if [ ! "$_OPENSSL_INCLUDED_" = "1" ]; then
_OPENSSL_INCLUDED_=1

# TODO
# When building from source : Require perl (from system is enough), to configure source code
# Require system "build-system"
# build with an arch

# NOTE : On darwin openssl lib in lib/engines folder does not have LC_ID_DYLIB

# TODO finished binaries version
# NOTE :
# binaries version are retrieved from conan.io repository conan-center
# https://bintray.com/conan-community/conan/OpenSSL%3Aconan
# https://github.com/conan-community/conan-openssl

# To inspect openssl binaries from conan-center repository :
# List all available versions from connan
#				conan search OpenSSL -r=conan-center
# List all available binaries with compilated options
#				conan search OpenSSL/1.0.2o@conan/stable -r=conan-center
#				conan search OpenSSL/1.0.2o@conan/stable -r=conan-center --table openssl.html
# List with filters
# 			conan search OpenSSL/1.0.2o@conan/stable -r=conan-center -q 'build_type=Release AND arch=x86_64 AND os=Macos AND compiler=apple-clang AND shared=True'
# Get info and dependencies
#				conan info OpenSSL/1.0.2o@conan/stable -r conan-center
# Create a default profile depending on the current platform
#				conan profile new default --detect

# To identify URL of the tar.gz use search :
#			conan search OpenSSL/1.0.2o@conan/stable -r=conan-center -q 'shared=True AND build_type=Release AND arch=x86_64 AND os=Macos'
#			retrieve Package_ID matching compiler and compiler.version
#			find this Package_ID here https://bintray.com/conan-community/conan/OpenSSL%3Aconan/1.0.2o%3Astable#files/conan%2FOpenSSL%2F1.0.2o%2Fstable%2Fpackage

# Options for downloaded openssl from conan-center
# no_sse2=False
# no_threads=False
# no_cast=False
# 386=False
# no_md5=False
# no_sha=False
# no_dh=False
# no_asm=False
# no_rsa=False
# no_dsa=False
# no_rc5=False
# no_zlib=False
# shared=False
# no_rc4=False
# no_md2=False
# no_rc2=False
# no_bf=False
# no_hmac=False
# no_des=False
# no_mdc2=False

# 1_0_2o@x64:binary 1_0_2o@x86:binary

feature_openssl() {
	FEAT_NAME=openssl
	FEAT_LIST_SCHEMA="1_0_2k:source 1_0_2d:source"
	FEAT_DEFAULT_ARCH=x64
	FEAT_DEFAULT_FLAVOUR="binary"
}



feature_openssl_1_0_2o() {
	FEAT_VERSION=1_0_2o

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		COMPIL_FRONTEND_VERSION="$(__gcc_version)"
		FEAT_BINARY_URL_x86="http://download.oracle.com/otn-pub/java/jdk/8u152-b16/aa0333dd3019491ca4f6ddbe78cdb6d0/jdk-8u152-linux-i586.tar.gz"
		FEAT_BINARY_URL_FILENAME_x86=jdk-8u152-linux-i586.tar.gz
		FEAT_BINARY_URL_PROTOCOL_x86=HTTP_ZIP

		FEAT_BINARY_URL_x64="http://download.oracle.com/otn-pub/java/jdk/8u152-b16/aa0333dd3019491ca4f6ddbe78cdb6d0/jdk-8u152-linux-x64.tar.gz"
		FEAT_BINARY_URL_FILENAME_x64=jdk-8u152-linux-x64.tar.gz
		FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP
	fi

	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		COMPIL_FRONTEND_VERSION="$(__clang_version)"

		# build_type=Release AND arch=x86_64 AND os=Macos AND compiler=apple-clang
		#					compiler.version=7.3 AND shared=True			ce60e8abcb35e7bdbb633792511ac6240e2a2ceb
		#					compiler.version=7.3 AND shared=False			b66d1d7c33354c2d4701c7f4d67b40395e741a86
		#					compiler.version=8.1 AND shared=True			4dc21962ebc63953d4b0879c71588b3b46212e03
		#					compiler.version=8.1 AND shared=False			0197c20e330042c026560da838f5b4c4bf094b8a
		#					compiler.version=9.0 AND shared=True			5e9b4170b1252b259e07e6ebd53940386a1c30e6
		#					compiler.version=9.0 AND shared=False			227fb0ea22f4797212e72ba94ea89c7b3fbc2a0c
		#					compiler.version=9.1 AND shared=True			b58c275d0c193bfbdf9cf9875a4cd2b8048dea19
		#					compiler.version=9.1 AND shared=False			b3e8c6b6e5f8456a00d1a77a6a5a1aeb06b2ad48
	fi

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/openssl
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}


feature_openssl_1_0_2k() {
	FEAT_VERSION=1_0_2k

	FEAT_SOURCE_DEPENDENCIES="zlib#^1_2"
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

	FEAT_SOURCE_DEPENDENCIES="zlib#^1_2"
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
	__link_feature_library "zlib#^1_2" "LIBS_NAME z GET_FLAGS _zlib FORCE_DYNAMIC NO_SET_FLAGS"
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
