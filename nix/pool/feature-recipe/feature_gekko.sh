if [ ! "$_GEKKO_INCLUDED_" = "1" ]; then
_GEKKO_INCLUDED_=1

# run with
# node gekko --ui
# OR use stella alias "gekko-run"
# OR for headless edit config : https://gekko.wizb.it/docs/installation/installing_gekko_on_a_server.html

feature_gekko() {
	FEAT_NAME=gekko
	FEAT_LIST_SCHEMA="0_5_11:binary"
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="binary"
}


feature_gekko_0_5_11() {
	FEAT_VERSION=0_5_11

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES="nodejs#6_10_2"

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	FEAT_BINARY_URL=https://github.com/askmike/gekko/archive/0.5.11.tar.gz
	FEAT_BINARY_URL_FILENAME=gekko-0.5.11.tar.gz
	FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP


	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=feature_gekko_alias

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/gekko.js
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}


feature_gekko_alias() {
	export GEKKO_HOME="$FEAT_INSTALL_ROOT"
	gekko-run() {
		node $GEKKO_HOME/gekko --ui
	}
}

feature_gekko_install_binary() {
	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "DEST_ERASE STRIP FORCE_NAME $FEAT_BINARY_URL_FILENAME"
	npm install --only=production
}



fi
