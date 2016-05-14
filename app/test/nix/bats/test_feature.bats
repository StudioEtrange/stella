load test_bats_helper


setup() {
    rm -Rf "$STELLA_APP_FEATURE_ROOT"

    # remove feature from app properties file
	__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_FEATURE_LIST" ""
	__get_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_FEATURE_LIST" "PREFIX"
}

teardown() {
   	rm -Rf "$STELLA_APP_FEATURE_ROOT"

   	# remove feature from app properties file
	__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_FEATURE_LIST" ""
	__get_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_FEATURE_LIST" "PREFIX"
}



# INFO -------------------------------------------------------------------
@test "__translate_schema" {

	skip
	local TR_FEATURE_OS_RESTRICTION=
	local TR_FEATURE_VER=
	local TR_FEATURE_NAME=
	local TR_FEATURE_ARCH=
	local TR_FEATURE_FLAVOUR=
	local _test=

	_test="wget/ubuntu#1_2@x86:source"
	__translate_schema "$_test" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" "TR_FEATURE_OS_EXCLUSION"
	assert_equal "wget" "$TR_FEATURE_NAME"
	assert_equal "1_2" "$TR_FEATURE_VER"
	assert_equal "x86" "$TR_FEATURE_ARCH"
	assert_equal "source" "$TR_FEATURE_FLAVOUR"
	assert_equal "ubuntu" "$TR_FEATURE_OS_RESTRICTION"
	assert_equal "" "$TR_FEATURE_OS_EXCLUSION"

	_test="wget:source@x86/ubuntu#1_2"
	__translate_schema "$_test" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" "TR_FEATURE_OS_EXCLUSION"
	assert_equal "wget" "$TR_FEATURE_NAME"
	assert_equal "1_2" "$TR_FEATURE_VER"
	assert_equal "x86" "$TR_FEATURE_ARCH"
	assert_equal "source" "$TR_FEATURE_FLAVOUR"
	assert_equal "ubuntu" "$TR_FEATURE_OS_RESTRICTION"
	assert_equal "" "$TR_FEATURE_OS_EXCLUSION"

	_test="wget"
	__translate_schema "$_test" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" "TR_FEATURE_OS_EXCLUSION"
	assert_equal "wget" "$TR_FEATURE_NAME"
	assert_equal "" "$TR_FEATURE_VER"
	assert_equal "" "$TR_FEATURE_ARCH"
	assert_equal "" "$TR_FEATURE_FLAVOUR"
	assert_equal "" "$TR_FEATURE_OS_RESTRICTION"
	assert_equal "" "$TR_FEATURE_OS_EXCLUSION"

	_test="kibana:source"
	__translate_schema "$_test" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" "TR_FEATURE_OS_EXCLUSION"
	assert_equal "kibana" "$TR_FEATURE_NAME"
	assert_equal "" "$TR_FEATURE_VER"
	assert_equal "" "$TR_FEATURE_ARCH"
	assert_equal "source" "$TR_FEATURE_FLAVOUR"
	assert_equal "" "$TR_FEATURE_OS_RESTRICTION"
	assert_equal "" "$TR_FEATURE_OS_EXCLUSION"

	_test="kibana:source\windows"
	__translate_schema "$_test" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" "TR_FEATURE_OS_EXCLUSION"
	assert_equal "kibana" "$TR_FEATURE_NAME"
	assert_equal "" "$TR_FEATURE_VER"
	assert_equal "" "$TR_FEATURE_ARCH"
	assert_equal "source" "$TR_FEATURE_FLAVOUR"
	assert_equal "" "$TR_FEATURE_OS_RESTRICTION"
	assert_equal "windows" "$TR_FEATURE_OS_EXCLUSION"
}


@test "__feature_install" {
	skip

	local _test="sbt"
	__feature_catalog_info $_test
	local def_ver=$FEAT_VERSION
	local def_arch=$FEAT_ARCH

	local old_feature_list="$FEATURE_LIST_ENABLED"

	__feature_install $_test
	assert_output_not_contains "ERROR"

	# empty feature informations values
	#__internal_feature_context
	run __feature_inspect $_test
	assert_equal "1" "$TEST_FEATURE"
	assert_equal "sbt" "$FEAT_NAME"
	assert_equal "$def_ver" "$FEAT_VERSION"
	assert_equal "$def_arch" "$FEAT_ARCH"
	assert_equal "$STELLA_APP_FEATURE_ROOT/$FEAT_NAME/$FEAT_VERSION" "$FEAT_INSTALL_ROOT"
	assert_equal "$old_feature_list $FEAT_NAME#$def_ver" "$FEATURE_LIST_ENABLED"

	
}




@test "__feature_install build from source" {

	local _test="cmatrix:source"
	__feature_catalog_info $_test
	local def_ver=$FEAT_VERSION
	local def_arch=$FEAT_ARCH

	local old_feature_list="$FEATURE_LIST_ENABLED"

	__feature_install $_test
	assert_output_not_contains "ERROR"

	
	run __feature_inspect $_test
	assert_equal "1" "$TEST_FEATURE"
	assert_equal "cmatrix" "$FEAT_NAME"
	assert_equal "$def_ver" "$FEAT_VERSION"
	assert_equal "$def_arch" "$FEAT_ARCH"
	assert_equal "$STELLA_APP_FEATURE_ROOT/$FEAT_NAME/$FEAT_VERSION" "$FEAT_INSTALL_ROOT"
	assert_equal "$old_feature_list $FEAT_NAME#$def_ver" "$FEATURE_LIST_ENABLED"


}



