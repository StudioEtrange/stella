if [ ! "$_clangomp_INCLUDED_" == "1" ]; then
_clangomp_INCLUDED_=1

# Clang OpenMP

# NOTE:
# LLVM is an unmbrella project and a common libs for several project
# Need CMake >= 3.4.3
# source code : http://llvm.org/docs/GettingStarted.html

# TODO : shadow/deactivate installed gnu autotools on macosx ?
# https://github.com/Homebrew/legacy-homebrew/issues/28442
# On MacOSX : Do not install autotools, problem with GNU libtool, because GNU autotools shadow xcode libtools

# Need python to build
function feature_clang-omp() {
	FEAT_NAME=clang-omp
	FEAT_LIST_SCHEMA="3_9_0:source"
	FEAT_DEFAULT_VERSION=3_9_0
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_clang-omp_3_9_0() {
	FEAT_VERSION=3_9_0


	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL="http://llvm.org/releases/3.9.0/llvm-3.9.0.src.tar.xz"
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=feature_clang-omp_add_resource
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/clang-omp
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

	FEAT_ADD_RESOURCES_CLANG="http://llvm.org/releases/3.9.0/cfe-3.9.0.src.tar.xz"
	FEAT_ADD_RESOURCES_CLANG_TOOLS="http://llvm.org/releases/3.9.0/clang-tools-extra-3.9.0.src.tar.xz"
	FEAT_ADD_RESOURCES_PROJECTS="http://llvm.org/releases/3.9.0/libcxx-3.9.0.src.tar.xz \
	http://llvm.org/releases/3.9.0/compiler-rt-3.9.0.src.tar.xz \
	http://llvm.org/releases/3.9.0/openmp-3.9.0.src.tar.xz \
	http://llvm.org/releases/3.9.0/libcxxabi-3.9.0.src.tar.xz"
}
#http://llvm.org/releases/3.9.0/test-suite-3.9.0.src.tar.xz \

function feature_clang-omp_add_resource() {
	__get_resource "$FEAT_NAME" "$FEAT_ADD_RESOURCES_CLANG" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR/llvm/tools/clang" "DEST_ERASE STRIP"
	__get_resource "$FEAT_NAME" "$FEAT_ADD_RESOURCES_CLANG_TOOLS" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR/llvm/tools/clang/tools/extra" "DEST_ERASE STRIP"

	for t in $FEAT_ADD_RESOURCES_PROJECTS; do
		__get_resource "$FEAT_NAME" "$t" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR/llvm/projects"
	done

}

function feature_clang-omp_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR/llvm" "DEST_ERASE STRIP"

	__set_toolset "CMAKE"

  __feature_callback

	# TODO ?
	#[ "$STELLA_CURRENT_PLATFORM" == "darwin" ] && __set_build_mode "MACOSX_DEPLOYMENT_TARGET" "10.8"

  AUTO_INSTALL_CONF_FLAG_PREFIX=
  AUTO_INSTALL_CONF_FLAG_POSTFIX="-DLIBOMP_ARCH=x86_64 -DLLVM_ENABLE_LIBCXX=ON"
  AUTO_INSTALL_BUILD_FLAG_PREFIX=
  AUTO_INSTALL_BUILD_FLAG_POSTFIX=


	__auto_build "$FEAT_NAME" "$SRC_DIR/llvm" "$INSTALL_DIR" "SOURCE_KEEP"

	# TESTS -------
	cat > $SRC_DIR/hello.c << EOL
/* hello.c */
#include <omp.h>
#include <stdio.h>
int main() {
  	#pragma omp parallel
    printf("Hello from thread %d, nthreads %d\n", omp_get_thread_num(), omp_get_num_threads());
}
EOL

	cd $SRC_DIR
	LIBRARY_PATH=$FEAT_INSTALL_ROOT/lib:$LIBRARY_PATH \
	$FEAT_INSTALL_ROOT/bin/clang -fopenmp hello.c -o hello

	[ "$STELLA_CURRENT_PLATFORM" == "darwin" ] && DYLD_LIBRARY_PATH=$FEAT_INSTALL_ROOT/lib ./hello
	[ "$STELLA_CURRENT_PLATFORM" == "linux" ] && LD_LIBRARY_PATH=$FEAT_INSTALL_ROOT/lib ./hello


	ln -s "$FEAT_INSTALL_ROOT"/bin/clang "$FEAT_INSTALL_ROOT"/bin/clang-omp
	ln -s "$FEAT_INSTALL_ROOT"/bin/clang++ "$FEAT_INSTALL_ROOT"/bin/clang++-omp

	__del_folder "$SRC_DIR"
}


fi
