if [ ! "$_BOOST_INCLUDED_" == "1" ]; then
_BOOST_INCLUDED_=1


# https://github.com/Homebrew/homebrew-core/blob/master/Formula/boost.rb
# Note for windows : http://stackoverflow.com/questions/7282645/how-to-build-boost-iostreams-with-gzip-and-bzip2-support-on-windows
# for boost.python see : https://gist.github.com/tdsmith/893df85e1c4d952fd150

# http://www.boost.org/doc/libs/1_58_0/libs/iostreams/doc/installation.html

# TODO Apply debian patch : https://packages.debian.org/sid/libboost1.60-dev


	# TODO do not find pyconfig.h
	# TODO BUGGGGG
	# http://stackoverflow.com/questions/19810940/ubuntu-linking-boost-python-fatal-error-pyconfig-cannot-be-found
# http://stackoverflow.com/questions/19810940/ubuntu-linking-boost-python-fatal-error-pyconfig-cannot-be-found
function feature_boost() {
	FEAT_NAME=boost
	FEAT_LIST_SCHEMA="1_61_0:source 1_58_0:source"
	FEAT_DEFAULT_VERSION=1_58_0
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}



function feature_boost_1_61_0() {
	FEAT_VERSION=1_61_0


	# Do NOT depend on Boost.Build
	# Boost have its own embedded version of Boost.Build. If we do not want that, precise --with-bjam=<path> when building
	FEAT_SOURCE_DEPENDENCIES="zlib#1_2_8 bzip2 openmpi#1_10_3 icu4c FORCE_ORIGIN_SYSTEM python"
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=http://downloads.sourceforge.net/project/boost/boost/1.61.0/boost_1_61_0.tar.gz
	FEAT_SOURCE_URL_FILENAME=boost_1_61_0.tar.gz
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

function feature_boost_1_58_0() {
	FEAT_VERSION=1_58_0


	# Do NOT depend on Boost.Build
	# Boost have its own embedded version of Boost.Build. If we do not want that, precise --with-bjam=<path> when building
	FEAT_SOURCE_DEPENDENCIES="zlib#1_2_8 bzip2 icu4c openmpi#1_10_3 FORCE_ORIGIN_SYSTEM python"
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


function feature_boost_dep() {

	__link_feature_library "bzip2" "LIBS_NAME bz2 GET_FOLDER _bzip2 NO_SET_FLAGS"

	BZIP2_LIBPATH="$_bzip2_LIB"
	BZIP2_INCLUDE="$_bzip2_INCLUDE"

	__link_feature_library "zlib#1_2_8" "GET_FOLDER _zlib NO_SET_FLAGS LIBS_NAME z"

	ZLIB_LIBPATH="$_zlib_LIB"
	ZLIB_INCLUDE="$_zlib_INCLUDE"

	__link_feature_library "openmpi#1_10_3" "GET_FOLDER _openmpi NO_SET_FLAGS"

	OPENMPI_BIN="$_openmpi_BIN"

	__link_feature_library "icu4c" "GET_FOLDER _icu NO_SET_FLAGS"

	ICU_ROOT="$_icu_ROOT"

}

function feature_boost_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP"

	__set_toolset "STANDARD"

	__set_build_mode "DARWIN_STDLIB" "LIBSTDCPP"

	__feature_callback

	__prepare_build "$INSTALL_DIR"

	local without_lib_base
	# The context library is implemented as x86_64 ASM, so it
  # won't build on PPC or 32-bit builds
  if [ ! "$STELLA_CPU_ARCH" == "64" ]; then
  	without_lib_base="$without_lib_base,context,coroutine"
  fi
	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
	# Boost.Log cannot be built using Apple GCC at the moment. Disabled (see brew formula)
		without_lib_base="$without_lib_base,log"
	fi






	# building Boost.MPI with shared, static, single thread and multi thread do not work, we have to split builds
	# https://svn.boost.org/trac/boost/ticket/8841

	# FIRST Building All (except python) with single thread ----
	local without_lib="$(echo $without_lib_base,python | sed s/^,//)"

	# building Boost.MPI require a user-config.jam
	# http://stackoverflow.com/questions/2892582/trying-to-build-boost-mpi-but-the-lib-files-are-not-created-whats-going-on
	echo "using mpi : $OPENMPI_BIN/mpicc ;" > "$SRC_DIR/user-config.jam"

	cd "$SRC_DIR"
	./bootstrap.sh --prefix="$INSTALL_DIR" --libdir="$INSTALL_DIR/lib" --includedir="$INSTALL_DIR/include" --with-icu="$ICU_ROOT" --without-libraries="$without_lib"
	./b2 --prefix="$INSTALL_DIR" --libdir="$INSTALL_DIR/lib" --includedir="$INSTALL_DIR/include" -d2 -j$STELLA_NB_CPU --layout=tagged install threading=single link=shared,static \
	-sBZIP2_INCLUDE="$BZIP2_INCLUDE" -sBZIP2_LIBPATH="$BZIP2_LIBPATH" -sZLIB_INCLUDE="$ZLIB_INCLUDE" -sZLIB_LIBPATH="$ZLIB_LIBPATH" \
	--user-config="$SRC_DIR/user-config.jam"

	# SECOND Building All (except python) with multi thread ----
	cd "$SRC_DIR"
	./bootstrap.sh --prefix="$INSTALL_DIR" --libdir="$INSTALL_DIR/lib" --includedir="$INSTALL_DIR/include" --with-icu="$ICU_ROOT" --without-libraries="$without_lib"
	./b2 --prefix="$INSTALL_DIR" --libdir="$INSTALL_DIR/lib" --includedir="$INSTALL_DIR/include" -d2 -j$STELLA_NB_CPU --layout=tagged install threading=multi link=shared,static \
	-sBZIP2_INCLUDE="$BZIP2_INCLUDE" -sBZIP2_LIBPATH="$BZIP2_LIBPATH" -sZLIB_INCLUDE="$ZLIB_INCLUDE" -sZLIB_LIBPATH="$ZLIB_LIBPATH" \
	--user-config="$SRC_DIR/user-config.jam"




	# THIRD Building python single and multi -------
	# For specify several python version (from debian):
	# for pyver in $(pyversions); do \
	# 	echo "using python : $$pyver : /usr ;" >> $@; \
	# done
	echo "using mpi : $OPENMPI_BIN/mpicc ;" > "$SRC_DIR/user-config.jam"
	echo "using python ;" >> "$SRC_DIR/user-config.jam"


	cd "$SRC_DIR"
	./bootstrap.sh --prefix="$INSTALL_DIR" --libdir="$INSTALL_DIR/lib" --includedir="$INSTALL_DIR/include" --with-icu="$ICU_ROOT" --with-libraries="python"
	./b2 --prefix="$INSTALL_DIR" --libdir="$INSTALL_DIR/lib" --includedir="$INSTALL_DIR/include" -d2 -j$STELLA_NB_CPU --layout=tagged install threading=multi,single link=shared,static \
	-sBZIP2_INCLUDE="$BZIP2_INCLUDE" -sBZIP2_LIBPATH="$BZIP2_LIBPATH" -sZLIB_INCLUDE="$ZLIB_INCLUDE" -sZLIB_LIBPATH="$ZLIB_LIBPATH" \
	--user-config="$SRC_DIR/user-config.jam"



	__del_folder "$SRC_DIR"

	[ "$STELLA_CURRENT_PLATFORM" == "darwin" ] && __tweak_install_name_darwin "$FEAT_INSTALL_ROOT/lib" "PATH"
	__inspect_and_fix_build "$FEAT_INSTALL_ROOT/lib"


}


fi
