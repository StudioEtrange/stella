if [ ! "$_BOOST_INCLUDED_" == "1" ]; then
_BOOST_INCLUDED_=1


# https://github.com/Homebrew/homebrew-core/blob/master/Formula/boost.rb
# Note for windows : http://stackoverflow.com/questions/7282645/how-to-build-boost-iostreams-with-gzip-and-bzip2-support-on-windows
# for boost.python see : https://gist.github.com/tdsmith/893df85e1c4d952fd150

function feature_boost() {
	FEAT_NAME=boost
	FEAT_LIST_SCHEMA="1_58_0:source"
	FEAT_DEFAULT_VERSION=1_58_0
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_boost_1_58_0() {
	FEAT_VERSION=1_58_0


	# Do NOT depend on Boost.Build
	# Boost have its own embedded version of Boost.Build. If we do not want that, precise --with-bjam=<path> when building
	FEAT_SOURCE_DEPENDENCIES="zlib#1_2_8 bzip2 FORCE_ORIGIN_SYSTEM python"
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
	export BOOST_ROOT="$FEAT_INSTALL_ROOT"
}

#http://www.boost.org/doc/libs/1_58_0/libs/iostreams/doc/installation.html
function feature_boost_dep() {

	__link_feature_library "bzip2" "LIBS_NAME bz2 GET_FOLDER _bzip2 NO_SET_FLAGS"

	BZIP2_LIBPATH="$_bzip2_LIB"
	BZIP2_INCLUDE="$_bzip2_INCLUDE"

	__link_feature_library "zlib#1_2_8" "GET_FOLDER _zlib NO_SET_FLAGS LIBS_NAME z"

	ZLIB_LIBPATH="$_zlib_LIB"
	ZLIB_INCLUDE="$_zlib_INCLUDE"

}

function feature_boost_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP"

	__set_toolset "STANDARD"

	__set_build_mode "DARWIN_STDLIB" "LIBSTDCPP"

	local without_lib=mpi

	# The context library is implemented as x86_64 ASM, so it
  # won't build on PPC or 32-bit builds
  if [ ! "$STELLA_CPU_ARCH" == "64" ]; then
  	without_lib="$without_lib",context,coroutine
  fi

	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
	# Boost.Log cannot be built using Apple GCC at the moment. Disabled (see brew formula)
		without_lib="$without_lib",log
	fi

  __feature_callback


  __prepare_build "$INSTALL_DIR"

	cd "$SRC_DIR"
	./bootstrap.sh --prefix="$INSTALL_DIR" --libdir="$INSTALL_DIR/lib" --includedir="$INSTALL_DIR/include" --without-icu --without-libraries="$without_lib"

	./b2 --prefix="$INSTALL_DIR" --libdir="$INSTALL_DIR/lib" --includedir="$INSTALL_DIR/include" -d2 -j$STELLA_NB_CPU --layout=tagged install threading=multi,single link=shared,static \
	-sBZIP2_INCLUDE="$BZIP2_INCLUDE" -sBZIP2_LIBPATH="$BZIP2_LIBPATH" -sZLIB_INCLUDE="$ZLIB_INCLUDE" -sZLIB_LIBPATH="$ZLIB_LIBPATH"

  __del_folder "$SRC_DIR"

	__inspect_and_fix_build "$FEAT_INSTALL_ROOT/lib"

}


fi
