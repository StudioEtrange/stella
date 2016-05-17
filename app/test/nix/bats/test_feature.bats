load test_bats_helper


setup() {
    rm -Rf "$STELLA_APP_FEATURE_ROOT"

    # remove feature from app properties file
	__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_FEATURE_LIST" ""
	__get_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_FEATURE_LIST" "PREFIX"

   #set +e; source "$__BATS_STELLA_DECLARE" &>/dev/null; set -e;
}

teardown() {
   	rm -Rf "$STELLA_APP_FEATURE_ROOT"

   	# remove feature from app properties file
	__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_FEATURE_LIST" ""
	__get_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_FEATURE_LIST" "PREFIX"
}



# INFO -------------------------------------------------------------------
@test "__translate_schema" {

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

	local _test="sbt"
	__feature_catalog_info $_test
	local def_ver=$FEAT_VERSION
	local def_arch=$FEAT_ARCH

  local old_feature_list="$(__list_active_features)"

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

  run __list_active_features
	assert_output "$old_feature_list $FEAT_NAME#$def_ver"


}


@test "__feature_remove" {

  local _test="sbt"
	__feature_catalog_info $_test
	local def_ver=$FEAT_VERSION
	local def_arch=$FEAT_ARCH

	local old_feature_list="$(__list_active_features)"

	__feature_install $_test
	assert_output_not_contains "ERROR"

  __feature_remove $_test

	# empty feature informations values
	#__internal_feature_context

	__feature_inspect $_test
	assert_equal "0" "$TEST_FEATURE"
	assert_equal "sbt" "$FEAT_NAME"
	assert_equal "$def_ver" "$FEAT_VERSION"
	assert_equal "$def_arch" "$FEAT_ARCH"
	assert_equal "$STELLA_APP_FEATURE_ROOT/$FEAT_NAME/$FEAT_VERSION" "$FEAT_INSTALL_ROOT"

  run __list_active_features
	assert_output "$old_feature_list"

}




@test "__feature_install build from source" {
  skip
	local _test="cmatrix:source"
	__feature_catalog_info $_test
	local def_ver=$FEAT_VERSION
	local def_arch=$FEAT_ARCH

	local old_feature_list="$(__list_active_features)"

	__feature_install $_test
	assert_output_not_contains "ERROR"

  # empty feature informations values
	#__internal_feature_context

	run __feature_inspect $_test
	assert_equal "1" "$TEST_FEATURE"
	assert_equal "cmatrix" "$FEAT_NAME"
	assert_equal "$def_ver" "$FEAT_VERSION"
	assert_equal "$def_arch" "$FEAT_ARCH"
	assert_equal "$STELLA_APP_FEATURE_ROOT/$FEAT_NAME/$FEAT_VERSION" "$FEAT_INSTALL_ROOT"

  run __list_active_features
  assert_output "$old_feature_list $FEAT_NAME#$def_ver"

}
