if [ ! "$_GOBUILD_INCLUDED_" == "1" ]; then 
_GOBUILD_INCLUDED_=1



#· TODO : not finished

function feature_go-buildchain-bundle() {
	FEAT_NAME="go-buildchain-bundle"
	FEAT_LIST_SCHEMA="1_4_2"
	FEAT_DEFAULT_VERSION=1_4_2
	FEAT_DEFAULT_ARCH=

	FEAT_BUNDLE=NESTED
}

function feature_go-buildchain-bundle_1_4_2() {
	FEAT_VERSION=1_4_2
	
	# need gcc
	FEAT_DEPENDENCIES=

	FEAT_BUNDLE_ITEM="go#1_4_2"

	FEAT_ENV_CALLBACK=feature_buildchain_setenv
	FEAT_BUNDLE_CALLBACK="feature_buildchain_setenv feature_prepare_toolchain"

	FEAT_INSTALL_TEST=
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT/_WORKSPACE_/bin"

	BUILDCHAIN_GO_VERSION="1.4.2"
}


function feature_buildchain_setenv() {
	GOPATH="$FEAT_INSTALL_ROOT/_WORKSPACE_"
}

function feature_prepare_toolchain() {
	PATH="$FEAT_SEARCH_PATH:$PATH"


	echo "** install godep"
	go get github.com/tools/godep

	echo "** install gox"
  	go get github.com/mitchellh/gox

	echo "** install gonative"
	go get github.com/inconshreveable/gonative

	echo "** build toolchain"
	mkdir -p "$FEAT_INSTALL_ROOT/_GONATIVE_TOOLCHAIN_"
	cd "$FEAT_INSTALL_ROOT/_GONATIVE_TOOLCHAIN_"
	gonative build --version="$BUILDCHAIN_GO_VERSION" --platforms="windows_386 windows_amd64 linux_386 linux_amd64 darwin_386 darwin_amd64"
	
}

fi