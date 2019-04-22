if [ ! "$_FUNSHELL_INCLUDED_" = "1" ]; then
_FUNSHELL_INCLUDED_=1


feature_funshell() {
	FEAT_NAME="funshell"
	FEAT_LIST_SCHEMA="1_0"
	FEAT_DEFAULT_ARCH=

	FEAT_BUNDLE=LIST
}

feature_funshell_1_0() {
	FEAT_VERSION=1_0

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_BUNDLE_ITEM="figlet cmatrix nms"

	FEAT_ENV_CALLBACK=
	FEAT_BUNDLE_CALLBACK=feature_funshell_print

	FEAT_INSTALL_TEST=
	FEAT_SEARCH_PATH=
}


feature_funshell_print() {

	figlet " ** Fun     Shell **"
	echo " -- a collection of amazing shell tools."
	echo " 		figlet"
	#echo "		lolcat"
	#echo "		fortune"
	#echo "		cowsay"
	echo "		cmatrix"
	echo "		nms && sneakers"

}


fi
