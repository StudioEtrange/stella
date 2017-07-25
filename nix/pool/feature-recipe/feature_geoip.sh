if [ ! "$_geoip_INCLUDED_" = "1" ]; then
_geoip_INCLUDED_=1

# database file : http://dev.maxmind.com/geoip/legacy/geolite/
# auto update database file : http://dev.maxmind.com/geoip/geoipupdate/

feature_geoip() {
	FEAT_NAME=geoip

	FEAT_LIST_SCHEMA="1_6_9:source"
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"


}

feature_geoip_1_6_9() {
	FEAT_VERSION=1_6_9


	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=https://github.com/maxmind/geoip-api-c/releases/download/v1.6.9/GeoIP-1.6.9.tar.gz
	FEAT_SOURCE_URL_FILENAME=GeoIP-1.6.9.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/geoiplookup
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}


feature_geoip_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"

	__set_toolset "STANDARD"

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP"


	AUTO_INSTALL_CONF_FLAG_PREFIX=
	AUTO_INSTALL_CONF_FLAG_POSTFIX=
	AUTO_INSTALL_BUILD_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_POSTFIX=


	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR" "POST_BUILD_STEP check install"


}


fi
