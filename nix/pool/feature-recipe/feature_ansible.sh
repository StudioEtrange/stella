if [ ! "$_ansible_INCLUDED_" = "1" ]; then
_ansible_INCLUDED_=1


# https://github.com/ansible/ansible
# https://stackoverflow.com/questions/41535915/python-pip-install-from-local-dir

feature_ansible() {
	FEAT_NAME=ansible

	FEAT_LIST_SCHEMA="2_4_0_0:source"
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"


}

feature_ansible_2_4_0_0() {
	FEAT_VERSION=2_4_0_0


	FEAT_SOURCE_DEPENDENCIES="miniconda"
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=https://releases.ansible.com/ansible/ansible-2.4.0.0.tar.gz
	FEAT_SOURCE_URL_FILENAME=ansible-2.4.0.0.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/ansible
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}



feature_ansible_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	#SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"

	__set_toolset "STANDARD"
	#__add_toolset "autotools"

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$INSTALL_DIR" "DEST_ERASE STRIP"

	pip install -e "$INSTALL_DIR"

#	AUTO_INSTALL_CONF_FLAG_PREFIX=
#	AUTO_INSTALL_CONF_FLAG_POSTFIX=
#	AUTO_INSTALL_BUILD_FLAG_PREFIX=
#	AUTO_INSTALL_BUILD_FLAG_POSTFIX=


	__feature_callback

	#__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR" "NO_OUT_OF_TREE_BUILD AUTOTOOLS autogen"


}


fi
