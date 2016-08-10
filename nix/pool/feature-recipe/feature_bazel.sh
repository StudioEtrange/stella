if [ ! "$_bazel_INCLUDED_" == "1" ]; then
_bazel_INCLUDED_=1


# https://github.com/Homebrew/homebrew-core/blob/master/Formula/bazel.rb

function feature_bazel() {
	FEAT_NAME=bazel
	FEAT_LIST_SCHEMA="0_3_0:source"
	FEAT_DEFAULT_VERSION=0_3_0
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_bazel_0_3_0() {
	FEAT_VERSION=0_3_0

	# TODO : need jdk8
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=https://github.com/bazelbuild/bazel/archive/0.3.0.tar.gz
	FEAT_SOURCE_URL_FILENAME=bazel-0.3.0.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bazel
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"

}



function feature_bazel_link() {
	__link_feature_library "pcre#8_36" "GET_FOLDER _pcre NO_SET_FLAGS"
}


function feature_bazel_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"



	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP FORCE_NAME $FEAT_SOURCE_URL_FILENAME"

	cd $SRC_DIR
	./compile.sh

	__copy_folder_content_into $SRC_DIR/output $INSTALL_DIR

	__del_folder $SRC_DIR

}



fi
