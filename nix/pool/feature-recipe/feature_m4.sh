if [ ! "$_M4_INCLUDED_" = "1" ]; then
_M4_INCLUDED_=1


feature_m4() {
	FEAT_NAME=m4
	FEAT_LIST_SCHEMA="1_4_18:source 1_4_17:source"
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"

	FEAT_LINK="https://www.gnu.org/software/m4/"
	FEAT_DESC="GNU M4 is an implementation of the traditional Unix macro processor."
}



feature_m4_1_4_18() {
	FEAT_VERSION=1_4_18


	FEAT_SOURCE_URL=http://mirrors.ibiblio.org/gnu/ftp/gnu/m4/m4-1.4.18.tar.gz
	FEAT_SOURCE_URL_FILENAME=m4-1.4.18.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_SOURCE_CALLBACK=feature_m4_patch_for_glibc2_28

	FEAT_TEST="m4"
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/"$FEAT_TEST"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
}

feature_m4_1_4_17() {
	FEAT_VERSION=1_4_17


	FEAT_SOURCE_URL=http://mirrors.ibiblio.org/gnu/ftp/gnu/m4/m4-1.4.17.tar.gz
	FEAT_SOURCE_URL_FILENAME=m4-1.4.17.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_SOURCE_CALLBACK=

	FEAT_TEST="m4"
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/"$FEAT_TEST"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
}



feature_m4_patch_for_glibc2_28() {
	sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' "$SRC_DIR"/lib/*.c
	echo "#define _IO_IN_BACKUP 0x100" >> "$SRC_DIR"/lib/stdio-impl.h
}

feature_m4_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"


	__set_toolset "STANDARD"

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP"

	__feature_callback

	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR"

}

fi
