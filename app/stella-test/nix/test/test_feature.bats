bats_load_library 'bats-assert'
bats_load_library 'bats-support'

# TODO use a copy of properties file and another app work root to run test on them
setup() {
	load 'stella_bats_helper.bash'
	
	rm -Rf $STELLA_APP_FEATURE_ROOT
	mkdir -p "$STELLA_APP_WORK_ROOT"

	
	

	#rm -Rf "$STELLA_APP_FEATURE_ROOT"
	cp -f $_STELLA_APP_PROPERTIES_FILE $STELLA_APP_WORK_ROOT/

    # remove feature from app properties file
	#__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_FEATURE_LIST" ""
	#__get_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_FEATURE_LIST" "PREFIX"
}

teardown() {
    #rm -Rf "$STELLA_APP_FEATURE_ROOT"
	cp -f $STELLA_APP_WORK_ROOT/$STELLA_APP_PROPERTIES_FILENAME $_STELLA_APP_PROPERTIES_FILE
   	# remove feature from app properties file
	#__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_FEATURE_LIST" ""
	#__get_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_FEATURE_LIST" "PREFIX"
}



# INFO -------------------------------------------------------------------
@test "__translate_schema" {

	local TR_FEATURE_OS_RESTRICTION=
	local TR_FEATURE_VER=
	local TR_FEATURE_NAME=
	local TR_FEATURE_ARCH=
	local TR_FEATURE_FLAVOUR=
	local _test=

	_test='wget/ubuntu#1_2@x86:source'
	__translate_schema "$_test" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" "TR_FEATURE_OS_EXCLUSION"
	assert_equal "$TR_FEATURE_NAME" "wget"
	assert_equal "$TR_FEATURE_VER" "1_2"
	assert_equal "$TR_FEATURE_ARCH" "x86"
	assert_equal "$TR_FEATURE_FLAVOUR" "source"
	assert_equal "$TR_FEATURE_OS_RESTRICTION" "ubuntu"
	assert_equal "$TR_FEATURE_OS_EXCLUSION" ""

	_test='wget:source@x86/ubuntu#1_2'
	__translate_schema "$_test" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" "TR_FEATURE_OS_EXCLUSION"
	assert_equal "$TR_FEATURE_NAME" "wget"
	assert_equal "$TR_FEATURE_VER" "1_2"
	assert_equal "$TR_FEATURE_ARCH" "x86"
	assert_equal "$TR_FEATURE_FLAVOUR" "source"
	assert_equal "$TR_FEATURE_OS_RESTRICTION" "ubuntu"
	assert_equal "$TR_FEATURE_OS_EXCLUSION" ""


	_test='wget:source@x86/ubuntu#>=1_2'
	__translate_schema "$_test" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" "TR_FEATURE_OS_EXCLUSION"
	assert_equal "$TR_FEATURE_NAME" "wget"
	assert_equal "$TR_FEATURE_VER" '>=1_2'
	assert_equal "$TR_FEATURE_ARCH" "x86"
	assert_equal "$TR_FEATURE_FLAVOUR" "source"
	assert_equal "$TR_FEATURE_OS_RESTRICTION" "ubuntu"
	assert_equal "$TR_FEATURE_OS_EXCLUSION" ""

	_test='wget:source@x86/ubuntu#<=1_2'
	__translate_schema "$_test" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" "TR_FEATURE_OS_EXCLUSION"
	assert_equal "$TR_FEATURE_NAME" "wget"
	assert_equal "$TR_FEATURE_VER" '<=1_2'
	assert_equal "$TR_FEATURE_ARCH" "x86"
	assert_equal "$TR_FEATURE_FLAVOUR" "source"
	assert_equal "$TR_FEATURE_OS_RESTRICTION" "ubuntu"
	assert_equal "$TR_FEATURE_OS_EXCLUSION" ""

	_test='wget:source@x86/ubuntu#^1_2'
	__translate_schema "$_test" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" "TR_FEATURE_OS_EXCLUSION"
	assert_equal "$TR_FEATURE_NAME" "wget"
	assert_equal "$TR_FEATURE_VER" "^1_2"
	assert_equal "$TR_FEATURE_ARCH" "x86"
	assert_equal "$TR_FEATURE_FLAVOUR" "source"
	assert_equal "$TR_FEATURE_OS_RESTRICTION" "ubuntu"
	assert_equal "$TR_FEATURE_OS_EXCLUSION" ""


	_test="wget"
	__translate_schema "$_test" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" "TR_FEATURE_OS_EXCLUSION"
	assert_equal "$TR_FEATURE_NAME" "wget"
	assert_equal "$TR_FEATURE_VER" ""
	assert_equal "$TR_FEATURE_ARCH" ""
	assert_equal "$TR_FEATURE_FLAVOUR" ""
	assert_equal "$TR_FEATURE_OS_RESTRICTION" ""
	assert_equal "$TR_FEATURE_OS_EXCLUSION" ""

	_test="kibana:source"
	__translate_schema "$_test" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" "TR_FEATURE_OS_EXCLUSION"
	assert_equal "$TR_FEATURE_NAME" "kibana"
	assert_equal "$TR_FEATURE_VER" ""
	assert_equal "$TR_FEATURE_ARCH" ""
	assert_equal "$TR_FEATURE_FLAVOUR" "source"
	assert_equal "$TR_FEATURE_OS_RESTRICTION" ""
	assert_equal "$TR_FEATURE_OS_EXCLUSION" ""

	_test='kibana:source\windows'
	__translate_schema "$_test" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" "TR_FEATURE_OS_EXCLUSION"
	assert_equal "$TR_FEATURE_NAME" "kibana"
	assert_equal "$TR_FEATURE_VER" ""
	assert_equal "$TR_FEATURE_ARCH" ""
	assert_equal "$TR_FEATURE_FLAVOUR" "source"
	assert_equal "$TR_FEATURE_OS_RESTRICTION" ""
	assert_equal "$TR_FEATURE_OS_EXCLUSION" "windows"

	_test="sbt"
	__translate_schema "$_test" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" "TR_FEATURE_OS_EXCLUSION"
	assert_equal "$TR_FEATURE_NAME" "sbt"
	assert_equal "$TR_FEATURE_FLAVOUR" ""
	assert_equal "$TR_FEATURE_OS_RESTRICTION" ""
	assert_equal "$TR_FEATURE_OS_EXCLUSION" ""


	_test='bin1!lib1%bin2!wget/ubuntu#1_2@x86:source'
	__translate_schema "$_test" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" "TR_FEATURE_OS_EXCLUSION" "TR_FEATURE_COND_LIB" "TR_FEATURE_COND_BIN"
	assert_equal "$TR_FEATURE_NAME" "wget"
	assert_equal "$TR_FEATURE_VER" "1_2"
	assert_equal "$TR_FEATURE_ARCH" "x86"
	assert_equal "$TR_FEATURE_FLAVOUR" "source"
	assert_equal "$TR_FEATURE_OS_RESTRICTION" "ubuntu"
	assert_equal "$TR_FEATURE_OS_EXCLUSION" ""
	assert_equal "$TR_FEATURE_COND_LIB" "lib1"
	assert_equal "$TR_FEATURE_COND_BIN" "bin1 bin2"

	_test='bin1#1_5!lib1#1_3%bin2!wget/ubuntu#1_2@x86:source'
	__translate_schema "$_test" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" "TR_FEATURE_OS_EXCLUSION" "TR_FEATURE_COND_LIB" "TR_FEATURE_COND_BIN"
	assert_equal "$TR_FEATURE_NAME" "wget"
	assert_equal "$TR_FEATURE_VER" "1_2"
	assert_equal "$TR_FEATURE_ARCH" "x86"
	assert_equal "$TR_FEATURE_FLAVOUR" "source"
	assert_equal "$TR_FEATURE_OS_RESTRICTION" "ubuntu"
	assert_equal "$TR_FEATURE_OS_EXCLUSION" ""
	assert_equal "$TR_FEATURE_COND_LIB" "lib1#1_3"
	assert_equal "$TR_FEATURE_COND_BIN" "bin1#1_5 bin2"

	_test='bin1#1_5!lib1#1_3%bin2!'
	__translate_schema "$_test" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" "TR_FEATURE_OS_EXCLUSION" "TR_FEATURE_COND_LIB" "TR_FEATURE_COND_BIN"
	assert_equal "$TR_FEATURE_NAME" ""
	assert_equal "$TR_FEATURE_VER" ""
	assert_equal "$TR_FEATURE_ARCH" ""
	assert_equal "$TR_FEATURE_FLAVOUR" ""
	assert_equal "$TR_FEATURE_OS_RESTRICTION" ""
	assert_equal "$TR_FEATURE_OS_EXCLUSION" ""
	assert_equal "$TR_FEATURE_COND_LIB" "lib1#1_3"
	assert_equal "$TR_FEATURE_COND_BIN" "bin1#1_5 bin2"

}


@test "__select_official_schema" {

	_test="foobar"
	__select_official_schema "$_test" "TR_SCHEMA" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" "TR_FEATURE_OS_EXCLUSION"
	assert_equal "$TR_SCHEMA" ""
	assert_equal "$TR_FEATURE_NAME" ""
	assert_equal "$TR_FEATURE_VER" ""
	assert_equal "$TR_FEATURE_ARCH" ""
	assert_equal "$TR_FEATURE_FLAVOUR" ""
	assert_equal "$TR_FEATURE_OS_RESTRICTION" ""
	assert_equal "$TR_FEATURE_OS_EXCLUSION" ""

	_test="wget#1_15"
	__select_official_schema "$_test" "TR_SCHEMA" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" "TR_FEATURE_OS_EXCLUSION"
	assert_equal "$TR_SCHEMA" "wget#1_15:source"
	assert_equal "$TR_FEATURE_NAME" "wget"
	assert_equal "$TR_FEATURE_VER" "1_15"
	assert_equal "$TR_FEATURE_ARCH" ""
	assert_equal "$TR_FEATURE_FLAVOUR" "source"
	assert_equal "$TR_FEATURE_OS_RESTRICTION" ""
	assert_equal "$TR_FEATURE_OS_EXCLUSION" ""

	_test="texinfo#^7_1"
	__select_official_schema "$_test" "TR_SCHEMA" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" "TR_FEATURE_OS_EXCLUSION"
	assert_equal "$TR_SCHEMA" "texinfo#7_1_1:source"
	assert_equal "$TR_FEATURE_NAME" "texinfo"
	assert_equal "$TR_FEATURE_VER" "7_1_1"
	assert_equal "$TR_FEATURE_ARCH" ""
	assert_equal "$TR_FEATURE_FLAVOUR" "source"
	assert_equal "$TR_FEATURE_OS_RESTRICTION" ""
	assert_equal "$TR_FEATURE_OS_EXCLUSION" ""

}

@test "__feature_catalog_info" {

	local _test="sbt"
	__feature_catalog_info "$_test"
	local def_ver="$FEAT_VERSION"
	local def_arch="$FEAT_ARCH"

	__feature_catalog_info "$_test"
	assert_equal "$FEAT_NAME" "sbt"
	assert_equal "$FEAT_VERSION" "$def_ver"
	assert_equal "$FEAT_ARCH" "$def_arch"
	assert_equal "$FEAT_INSTALL_ROOT" "$STELLA_APP_FEATURE_ROOT/$FEAT_NAME/$FEAT_VERSION"
}

@test "__feature_install" {

	local _test="sbt"
	__feature_catalog_info "sbt"
	local def_ver=$FEAT_VERSION
	local def_arch=$FEAT_ARCH
	assert_equal "$FEAT_NAME" "sbt"
	
  	local old_feature_list="$(__list_active_features)"

	__feature_install $_test
	#refute_output --partial "ERROR"
	assert_equal "$FEATURE_LIST_ENABLED_VISIBLE" "$old_feature_list $FEAT_NAME#$def_ver"

	run __list_active_features
	assert_output "$old_feature_list $FEAT_NAME#$def_ver"

	__feature_inspect "sbt"
	assert_equal "$TEST_FEATURE" "1"
	assert_equal "$FEAT_NAME" "sbt"
	assert_equal "$FEAT_VERSION" "$def_ver"
	assert_equal "$FEAT_ARCH" "$def_arch"
	assert_equal "$FEAT_INSTALL_ROOT" "$STELLA_APP_FEATURE_ROOT/$FEAT_NAME/$FEAT_VERSION"

}


@test "__feature_remove" {

	local _test="sbt"
	__feature_catalog_info "sbt"
	local def_ver=$FEAT_VERSION
	local def_arch=$FEAT_ARCH
	assert_equal "$FEAT_NAME" "sbt"

	local old_feature_list="$(__list_active_features)"

	run __feature_remove $_test
	assert_success

	run __list_active_features
	refute_output --partial " $_test"


	__feature_inspect "sbt"
	assert_equal "$TEST_FEATURE" "0"
	assert_equal "$FEAT_NAME" "sbt"
	assert_equal "$FEAT_VERSION" "$def_ver"
	assert_equal "$FEAT_ARCH" "$def_arch"
	assert_equal "$FEAT_INSTALL_ROOT" "$STELLA_APP_FEATURE_ROOT/$FEAT_NAME/$FEAT_VERSION"

}




@test "__feature_install build from source" {
	skip
	local _test="cmatrix:source"
	__feature_catalog_info "$_test"
	local def_ver="$FEAT_VERSION"
	local def_arch="$FEAT_ARCH"

	local old_feature_list="$(__list_active_features)"

	__feature_install $_test
	#refute_output --partial "ERROR"
	assert_equal "$FEATURE_LIST_ENABLED_VISIBLE" "$old_feature_list $FEAT_NAME#$def_ver"

	run __list_active_features
	assert_output "$old_feature_list $FEAT_NAME#$def_ver"

	__feature_inspect "$_test"
	assert_equal "$TEST_FEATURE" "1"
	assert_equal "$FEAT_NAME" "cmatrix"
	assert_equal "$FEAT_VERSION" "$def_ver"
	assert_equal "$FEAT_ARCH" "$def_arch"
	assert_equal "$FEAT_INSTALL_ROOT" "$STELLA_APP_FEATURE_ROOT/$FEAT_NAME/$FEAT_VERSION"

}
