if [ ! "$_BOOST_INCLUDED_" == "1" ]; then 
_BOOST_INCLUDED_=1


# https://github.com/Homebrew/homebrew/blob/master/Library/Formula/boost.rb
# Note for windows : http://stackoverflow.com/questions/7282645/how-to-build-boost-iostreams-with-gzip-and-bzip2-support-on-windows
# Built without boost.python, for boost.python see : https://github.com/Homebrew/homebrew/blob/master/Library/Formula/boost-python.rb

function feature_boost() {
	FEAT_NAME=boost
	FEAT_LIST_SCHEMA="1_58_0:source"
	FEAT_DEFAULT_VERSION=1_58_0
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_boost_1_58_0() {
	FEAT_VERSION=1_58_0


	# do NOT depend on Boost.Build
	# Boost build is own embedded version of Boost.Build. If we do not want thaht, precise --with-bjam=<path> when building
	FEAT_SOURCE_DEPENDENCIES="zlib bzip2"
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=https://downloads.sourceforge.net/project/boost/boost/1.58.0/boost_1_58_0.tar.bz2
	FEAT_SOURCE_URL_FILENAME=boost_1_58_0.tar.bz2
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK="feature_boost_dep"
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK="boost_set_env"

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/lib/libboost_wave.a
	FEAT_SEARCH_PATH=

}


function boost_set_env() {
	BOOST_ROOT="$FEAT_INSTALL_ROOT"
	export 	BOOST_ROOT="$FEAT_INSTALL_ROOT"
}

#http://www.boost.org/doc/libs/1_58_0/libs/iostreams/doc/installation.html
function feature_boost_dep() {

	save_FEAT_SCHEMA_SELECTED=$FEAT_SCHEMA_SELECTED

	__feature_inspect bzip2
	if [ "$TEST_FEATURE" == "0" ]; then
		echo " ** ERROR : depend on bzip2"
		return
	fi
	BZIP2_LIBPATH="$FEAT_INSTALL_ROOT/lib"
	BZIP2_INCLUDE="$FEAT_INSTALL_ROOT/include"
	
	


	__feature_inspect zlib
	if [ "$TEST_FEATURE" == "0" ]; then
		echo " ** ERROR : depend on lib zlib"
		return
	fi
	# we make a link so that only the static version of zlib is found and used (instead of dynamic version)
	ln -fs $FEAT_INSTALL_ROOT/lib/libz.a $FEAT_INSTALL_ROOT/libz.a
	ZLIB_LIBPATH="$FEAT_INSTALL_ROOT"
	ZLIB_INCLUDE="$FEAT_INSTALL_ROOT/include"
	
	FEAT_SCHEMA_SELECTED=$save_FEAT_SCHEMA_SELECTED
	__internal_feature_context $FEAT_SCHEMA_SELECTED

}

function feature_boost_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP"


	local without_lib=python,mpi

	# The context library is implemented as x86_64 ASM, so it
    # won't build on PPC or 32-bit builds
    if [ ! "$STELLA_CPU_ARCH" == "64" ]; then
    	without_lib="$without_lib",context,coroutine
    fi

    __feature_callback

	cd "$SRC_DIR"
	./bootstrap.sh --prefix="$INSTALL_DIR" --libdir="$INSTALL_DIR/lib" --includedir="$INSTALL_DIR/include" --without-icu --without-libraries="$without_lib"
    ./b2 --prefix="$INSTALL_DIR" --libdir="$INSTALL_DIR/lib" --includedir="$INSTALL_DIR/include" -d2 -j$STELLA_NB_CPU --layout=tagged install threading=multi,single link=shared,static \
		-sBZIP2_INCLUDE="$BZIP2_INCLUDE" -sBZIP2_LIBPATH="$BZIP2_LIBPATH" -sZLIB_INCLUDE="$ZLIB_INCLUDE" -sZLIB_LIBPATH="$ZLIB_LIBPATH"
    
    __del_folder "$SRC_DIR"


}


fi
