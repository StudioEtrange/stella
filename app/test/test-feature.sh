#!/bin/bash
_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
source $_CURRENT_FILE_DIR/stella-link.sh include


source $_CURRENT_FILE_DIR/lib.sh

function test__translate_schema_1() {


	TR_FEATURE_OS_RESTRICTION=
	TR_FEATURE_VER=
	TR_FEATURE_NAME=
	TR_FEATURE_ARCH=
	TR_FEATURE_FLAVOUR=

	result=OK
	

	_test="wget:ubuntu#1_2@x86/source"
	[ ! "$result" == "ERROR" ] && __translate_schema "$_test" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" \
			&& [ "$TR_FEATURE_OS_RESTRICTION" == "ubuntu" ] \
			&& [ "$TR_FEATURE_VER" == "1_2" ] && [ "$TR_FEATURE_NAME" == "wget" ] && [ "$TR_FEATURE_ARCH" == "x86" ] \
			&& [ "$TR_FEATURE_FLAVOUR" == "source" ] && result=OK || result=ERROR
	echo "$_test => $TR_FEATURE_NAME#$TR_FEATURE_VER@$TR_FEATURE_ARCH/$TR_FEATURE_FLAVOUR:$TR_FEATURE_OS_RESTRICTION"

	_test="wget/source@x86:ubuntu#1_2"
	[ ! "$result" == "ERROR" ] && __translate_schema "$_test" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" \
			&& [ "$TR_FEATURE_OS_RESTRICTION" == "ubuntu" ] \
			&& [ "$TR_FEATURE_VER" == "1_2" ] && [ "$TR_FEATURE_NAME" == "wget" ] && [ "$TR_FEATURE_ARCH" == "x86" ] \
			&& [ "$TR_FEATURE_FLAVOUR" == "source" ] && result=OK || result=ERROR
	echo "$_test => $TR_FEATURE_NAME#$TR_FEATURE_VER@$TR_FEATURE_ARCH/$TR_FEATURE_FLAVOUR:$TR_FEATURE_OS_RESTRICTION"

	_test="wget"
	[ ! "$result" == "ERROR" ] && __translate_schema "$_test" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" \
			&& [ "$TR_FEATURE_OS_RESTRICTION" == "" ] \
			&& [ "$TR_FEATURE_VER" == "" ] && [ "$TR_FEATURE_NAME" == "wget" ] && [ "$TR_FEATURE_ARCH" == "" ] \
			&& [ "$TR_FEATURE_FLAVOUR" == "" ] && result=OK || result=ERROR
	echo "$_test => $TR_FEATURE_NAME#$TR_FEATURE_VER@$TR_FEATURE_ARCH/$TR_FEATURE_FLAVOUR:$TR_FEATURE_OS_RESTRICTION"


	log "test__translate_schema_1" "$result" "test __translate_schema"

}




function test__install_feature_0() {
	_test="packer#0_6_0@x86/binary"
	__feature_install $_test
	__feature_is_installed $_test
	[ "$TEST_FEATURE" == "1" ] && [ "$FEAT_NAME" == "packer" ] && [ "$FEAT_VERSION" == "0_6_0" ] && [ "$FEAT_ARCH" == "x86" ] && \
	[ "$FEAT_INSTALL_ROOT" == "$STELLA_APP_FEATURE_ROOT/$FEAT_NAME/$FEAT_VER"@"$FEAT_ARCH" ] && result=OK || result=ERROR
	echo "$_test => N:$FEAT_NAME V:$FEAT_VERSION A:$FEAT_ARCH R:$FEAT_INSTALL_ROOT"
	if [ "$STELLA_APP_FEATURE_LIST" == "$_test" ]; then result=OK; else result=ERROR; fi;
	echo "APP_FEATURE_LIST $_test shoud be equal to : $STELLA_APP_FEATURE_LIST"

	[ ! -z "$(which packer)" ] && echo "OK : $FEAT_NAME is in path" || echo "ERROR : $FEAT_NAME is NOT in path"
	[ ! -z "$(which packer)" ] && result=OK || result=ERROR

	__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_FEATURE_LIST" ""
	__get_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_FEATURE_LIST" "PREFIX"

	log "test__install_feature_0" "$result" "test __install_feature"
}

function test__install_feature_1() {
	_test="packer"
	__feature_info $_test
	local def_ver=$FEAT_VERSION
	local def_arch=$FEAT_ARCH

	__feature_install $_test
	__feature_is_installed $_test
	[ "$TEST_FEATURE" == "1" ] && [ "$FEAT_NAME" == "packer" ] && [ "$FEAT_VERSION" == "$def_ver" ] && [ "$FEAT_ARCH" == "$def_arch" ] && \
	[ "$FEAT_INSTALL_ROOT" == "$STELLA_APP_FEATURE_ROOT/$FEAT_NAME/$FEAT_VER"@"$FEAT_ARCH" ] && result=OK || result=ERROR
	echo "$_test => N:$FEAT_NAME V:$FEAT_VERSION A:$FEAT_ARCH R:$FEAT_INSTALL_ROOT"
	if [ "$STELLA_APP_FEATURE_LIST" == "$_test" ]; then result=OK; else result=ERROR; fi;
	echo "APP_FEATURE_LIST $_test shoud be equal to : $STELLA_APP_FEATURE_LIST"

	[ ! -z "$(which packer)" ] && echo "OK : $FEAT_NAME is in path" || echo "ERROR : $FEAT_NAME is NOT in path"
	[ ! -z "$(which packer)" ] && result=OK || result=ERROR

	__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_FEATURE_LIST" ""
	__get_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_FEATURE_LIST" "PREFIX"

	log "test__install_feature_1" "$result" "test __install_feature"
}

function test__install_feature_2() {
	_test="wget"
	__feature_info $_test
	local def_ver=$FEAT_VERSION
	local def_arch=$FEAT_ARCH

	__feature_install $_test
	__feature_is_installed $_test
	[ "$TEST_FEATURE" == "1" ] && [ "$FEAT_NAME" == "wget" ] && [ "$FEAT_VERSION" == "$def_ver" ] && [ "$FEAT_ARCH" == "$def_arch" ] && \
	[ "$FEAT_INSTALL_ROOT" == "$STELLA_APP_FEATURE_ROOT/$FEAT_NAME/$FEAT_VER" ] && result=OK || result=ERROR
	echo "$_test => N:$FEAT_NAME V:$FEAT_VERSION A:$FEAT_ARCH R:$FEAT_INSTALL_ROOT"
	if [ "$STELLA_APP_FEATURE_LIST" == "$_test" ]; then result=OK; else result=ERROR; fi;
	echo "APP_FEATURE_LIST $_test shoud be equal to : $STELLA_APP_FEATURE_LIST"

	[ ! -z "$(which wget)" ] && echo "OK : $FEAT_NAME is in path" || echo "ERROR : $FEAT_NAME is NOT in path"
	[ ! -z "$(which wget)" ] && result=OK || result=ERROR

	__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_FEATURE_LIST" ""
	__get_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_FEATURE_LIST" "PREFIX"

	log "test__install_feature_2" "$result" "test __install_feature"
}


function test__install_feature_3() {
	_test="wget/source"
	__feature_info $_test
	local def_ver=$FEAT_VERSION
	local def_arch=$FEAT_ARCH

	__feature_install $_test
	__feature_is_installed $_test
	[ "$TEST_FEATURE" == "1" ] && [ "$FEAT_NAME" == "wget" ] && [ "$FEAT_VERSION" == "$def_ver" ] && [ "$FEAT_ARCH" == "$def_arch" ] && \
	[ "$FEAT_INSTALL_ROOT" == "$STELLA_APP_FEATURE_ROOT/$FEAT_NAME/$FEAT_VER" ] && result=OK || result=ERROR
	echo "$_test => N:$FEAT_NAME V:$FEAT_VERSION A:$FEAT_ARCH R:$FEAT_INSTALL_ROOT"
	if [ "$STELLA_APP_FEATURE_LIST" == "$_test" ]; then result=OK; else result=ERROR; fi;
	echo "APP_FEATURE_LIST $_test shoud be equal to : $STELLA_APP_FEATURE_LIST"

	[ ! -z "$(which wget)" ] && echo "OK : $FEAT_NAME is in path" || echo "ERROR : $FEAT_NAME is NOT in path"
	[ ! -z "$(which wget)" ] && result=OK || result=ERROR

	__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_FEATURE_LIST" ""
	__get_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_FEATURE_LIST" "PREFIX"

	log "test__install_feature_3" "$result" "test __install_feature"
}


rm -Rf $STELLA_APP_FEATURE_ROOT
mkdir -p $STELLA_APP_FEATURE_ROOT

echo "******* test__translate_schema_1 ********"
test__translate_schema_1

echo "******* test__install_feature_0 ********"
test__install_feature_0

echo "******* test__install_feature_1 ********"
test__install_feature_1

echo "******* test__install_feature_2 ********"
test__install_feature_2

echo "******* test__install_feature_3 ********"
test__install_feature_3
	