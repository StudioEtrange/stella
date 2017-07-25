if [ ! "$_unixodbc_INCLUDED_" = "1" ]; then
_unixodbc_INCLUDED_=1

# https://github.com/Homebrew/homebrew-core/blob/master/Formula/unixodbc.rb

feature_unixodbc() {
	FEAT_NAME=unixodbc
	FEAT_LIST_SCHEMA="2_3_4:source"
	FEAT_DEFAULT_FLAVOUR="source"
}

feature_unixodbc_2_3_4() {
	FEAT_VERSION=2_3_4

	FEAT_SOURCE_URL=https://downloads.sourceforge.net/project/unixodbc/unixODBC/2.3.4/unixODBC-2.3.4.tar.gz
	FEAT_SOURCE_URL_FILENAME=unixODBC-2.3.4.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/odbc_config
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
}



feature_unixodbc_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"

	__set_toolset "STANDARD"

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "STRIP"

	AUTO_INSTALL_CONF_FLAG_POSTFIX="--enable-static --enable-shared --enable-gui=no --disable-debug --disable-dependency-tracking"

	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR"

}



fi
