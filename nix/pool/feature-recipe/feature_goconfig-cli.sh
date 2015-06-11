if [ ! "$_GOCONFIGCLI_INCLUDED_" == "1" ]; then 
_GOCONFIGCLI_INCLUDED_=1


function feature_goconfig-cli() {
	FEAT_NAME="goconfig-cli"
	FEAT_LIST_SCHEMA="snapshot:binary snapshot:source"
	FEAT_DEFAULT_VERSION="snapshot"
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="binary"
}


function feature_goconfig-cli_snapshot() {
	FEAT_VERSION="snapshot"
	
	FEAT_SOURCE_DEPENDENCIES="go-build-chain#1_4_2"
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	FEAT_BINARY_URL="$STELLA_ARTEFACT_URL/nix/goconfig-cli/goconfig-cli"
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL="HTTP"

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=
	
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/goconfig-cli"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"

}


function feature_goconfig-cli_install_binary() {
	get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "DEST_ERASE STRIP"
}

function feature_goconfig-cli_install_source() {
	echo "TODO"
}

fi
