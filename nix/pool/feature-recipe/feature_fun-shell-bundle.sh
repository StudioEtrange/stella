if [ ! "$_FUNSHELL_INCLUDED_" == "1" ]; then 
_FUNSHELL_INCLUDED_=1


# https://hub.docker.com/r/jess/nerdy/~/dockerfile/

function feature_fun-shell-bundle() {
	FEAT_NAME="fun-shell-bundle"
	FEAT_LIST_SCHEMA="1_0"
	FEAT_DEFAULT_VERSION=1_0
	FEAT_DEFAULT_ARCH=

	FEAT_BUNDLE=LIST
}

function feature_fun-shell-bundle_1_0() {
	FEAT_VERSION=1_0
	
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_BUNDLE_ITEM="figlet"

	FEAT_ENV_CALLBACK=
	FEAT_BUNDLE_CALLBACK=feature_fun-shell-bundle_print

	FEAT_INSTALL_TEST=
	FEAT_SEARCH_PATH=
}


function feature_fun-shell-bundle_print() {
	
	figlet " ** Fun     Shell **"
	echo " -- a collection of amazing shell tools."
	echo " 		figlet"
	echo "		lolcat"
	echo "		fortune"
	echo "		cowsay"

}


fi