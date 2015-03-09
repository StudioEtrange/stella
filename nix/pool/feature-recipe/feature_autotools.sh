if [ ! "$_AUTOTOOLS_INCLUDED_" == "1" ]; then 
_AUTOTOOLS_INCLUDED_=1

function feature_autotools() {
	FEAT_NAME=autotools
	FEAT_LIST_SCHEMA="pack"
	FEAT_DEFAULT_VERSION=pack
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR=

	FEAT_BUNDLE_EMBEDDED=TRUE
}

function feature_autotools_pack() {
	FEAT_VERSION=pack

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_CALLBACK=

	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST=
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

	# BUNDLE ITEM LIST
	# order is important
	# see http://petio.org/tools.html
	FEAT_BUNDLE_LIST="m4#1_4_17/source autoconf#2_69/source automake#1_14/source libtool#2_4_2/source"

}



fi