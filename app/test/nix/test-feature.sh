#!/bin/bash
_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
source $_CURRENT_FILE_DIR/stella-link.sh include


source $_CURRENT_FILE_DIR/lib.sh




function test__remove_feature() {
	_test="sbt"
	__feature_catalog_info $_test
	local def_ver=$FEAT_VERSION
	local def_arch=$FEAT_ARCH

	__save_feature_list=$STELLA_APP_FEATURE_LIST

	__feature_install $_test

	__feature_remove $_test

	# empty feature informations values
	__internal_feature_context

	__feature_inspect $_test
	[ "$TEST_FEATURE" == "0" ] && [ "$FEAT_NAME" == "sbt" ] && [ "$FEAT_VERSION" == "$def_ver" ] && [ "$FEAT_ARCH" == "$def_arch" ] && \
	[ "$FEAT_INSTALL_ROOT" == "$STELLA_APP_FEATURE_ROOT/$FEAT_NAME/$FEAT_VERSION" ] && result=OK || result=ERROR
	echo "$_test => TEST_FEATURE:$TEST_FEATURE==0 N:$FEAT_NAME==sbt V:$FEAT_VERSION==$def_ver A:$FEAT_ARCH==$def_arch R:$FEAT_INSTALL_ROOT==$STELLA_APP_FEATURE_ROOT/$FEAT_NAME/$FEAT_VERSION"


	__get_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_FEATURE_LIST" "PREFIX"
	[ "$STELLA_APP_FEATURE_LIST" == "$__save_feature_list" ] && result=OK || result=ERROR

	log "test__remove_feature" "$result" "test __remove_feature"
}


rm -Rf $STELLA_APP_FEATURE_ROOT
mkdir -p $STELLA_APP_FEATURE_ROOT
