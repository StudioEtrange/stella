if [ ! "$_AUTOTOOLSBUNDLE_INCLUDED_" == "1" ]; then 
_AUTOTOOLSBUNDLE_INCLUDED_=1

function feature_autotools-bundle() {
	FEAT_NAME=autotools-bundle
	FEAT_LIST_SCHEMA="1"
	FEAT_DEFAULT_VERSION=1
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR=

	FEAT_BUNDLE=TRUE
}

function feature_autotools-bundle_1() {
	FEAT_VERSION=1

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_CALLBACK=

	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST=
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
	FEAT_ENV=
	
	# BUNDLE ITEM LIST
	# order is important
	# see http://petio.org/tools.html
	FEAT_BUNDLE_LIST="m4#1_4_17/source autoconf#2_69/source automake#1_14/source libtool#2_4_2/source"


}



fi