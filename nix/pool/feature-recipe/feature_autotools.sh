if [ ! "$_AUTOTOOLS_INCLUDED_" = "1" ]; then
_AUTOTOOLS_INCLUDED_=1



feature_autotools() {
	FEAT_NAME=autotools
	FEAT_LIST_SCHEMA="1"
	FEAT_DEFAULT_ARCH=

	FEAT_BUNDLE=MERGE
}

feature_autotools_1() {
	FEAT_VERSION=1

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=


	# BUNDLE ITEM LIST
	# order is important
	# see http://petio.org/tools.html
	FEAT_BUNDLE_ITEM="m4#1_4_17:source autoconf#2_69:source automake#1_14:source libtool#2_4_2:source"

	FEAT_ENV_CALLBACK=
	FEAT_BUNDLE_CALLBACK=

	FEAT_INSTALL_TEST=
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin


}


fi
