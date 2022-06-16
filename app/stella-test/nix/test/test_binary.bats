load test_bats_helper


# COMMON FILES -------------------------------------------------------------------
__test_clean_file() {
	local _test_file="$1"
	rm -Rf "$_test_file"
}

__test_prepare_bin_file() {
	local _origin_test_file="$(which cat)"
	local _test_file="$BATS_TMPDIR/cat"
	cp -f "$_origin_test_file" "$_test_file"

	echo $_test_file
}

__test_prepare_bin_file_linked() {
	local _origin_test_file="$(which ssh)"
	local _test_file="$BATS_TMPDIR/ssh"
	cp -f "$_origin_test_file" "$_test_file"

	echo $_test_file
}


__test_prepare_dynamic_lib_file_darwin() {
	local _origin_test_file="/usr/lib/libz.1.dylib"
	local _test_file="$BATS_TMPDIR/libz.1.dylib"
	cp -f "$_origin_test_file" "$_test_file"
	echo $_test_file
}


# GENERIC -------------------------------------------------------------------
@test "__get_arch" {
	run __get_arch "$(which cat)"
	assert_output_not_empty
}

@test "__check_arch" {
	run __check_arch "$(which cat)"
	assert_output_not_empty
	assert_success

	run __check_arch "$(which cat)" "FOO"
	assert_output_not_empty
	assert_failure
}

# DARWIN ----------------------------------------------------------------
@test "__is_object_bin" {
	_test_file="$(__test_prepare_bin_file)"

	run __is_object_bin "$_test_file"
	assert_output "TRUE"

	__test_clean_file "$_test_file"
}

# DARWIN : INSTALL NAME --------------------------------
@test "__get_install_name_darwin" {
	[ "$STELLA_CURRENT_PLATFORM" != "darwin" ] && skip
	run __get_install_name_darwin "/usr/lib/libz.1.dylib"
	assert_output "/usr/lib/libz.1.dylib"
}

@test "__tweak_install_name_darwin" {
	[ "$STELLA_CURRENT_PLATFORM" != "darwin" ] && skip
	_test_file="$(__test_prepare_dynamic_lib_file_darwin)"

	run __tweak_install_name_darwin "$_test_file" "PATH"
	assert_success
	run __get_install_name_darwin "$_test_file"
	assert_output "$_test_file"

	run __tweak_install_name_darwin "$_test_file" "RPATH"
	assert_success
	run __get_install_name_darwin "$_test_file"
	assert_output "@rpath/libz.1.dylib"

	__test_clean_file "$_test_file"
}


# RPATH --------------------------------
@test "__get_rpath" {
	_test_file="$(__test_prepare_bin_file)"

	run __get_rpath "$_test_file"
	assert_output ""

	__test_clean_file "$_test_file"
}


@test "__add_rpath AND __remove_all_rpath" {
	_test_file="$(__test_prepare_bin_file)"

	run __remove_all_rpath "$_test_file"
	run __get_rpath "$_test_file"
	assert_output ""

	run __add_rpath "$_test_file" "test/rpath1 test/rpath2" "FIRST"
	assert_success

	run __get_rpath "$_test_file"
	assert_output "test/rpath1 test/rpath2"

	run __add_rpath "$_test_file" "test/rpath3" "LAST"
	assert_success

	run __get_rpath "$_test_file"
	assert_output "test/rpath1 test/rpath2 test/rpath3"

	run __remove_all_rpath "$_test_file"
	run __get_rpath "$_test_file"
	assert_output ""

	__test_clean_file "$_test_file"
}


@test "__tweak_rpath" {
	[ "$STELLA_CURRENT_PLATFORM" != "darwin" ] && skip
	_test_file="$(__test_prepare_bin_file)"
	_root_path="$(__get_path_from_string $_test_file)"

	run __remove_all_rpath "$_test_file"
	run __get_rpath "$_test_file"
	assert_output ""

	run __add_rpath "$_test_file" "test/rpath1 ./rpath2"
	assert_success
	run __get_rpath "$_test_file"
	assert_output "test/rpath1 ./rpath2"


	run __tweak_rpath "$_test_file" "ABS_RPATH"
	assert_success
	run __get_rpath "$_test_file"
	assert_output "$_root_path/test/rpath1 $_root_path/rpath2"


	run __add_rpath "$_test_file" "test/rpath3"
	assert_success
	run __get_rpath "$_test_file"
	assert_output "test/rpath3 $_root_path/test/rpath1 $_root_path/rpath2"

	run __tweak_rpath "$_test_file" "REL_RPATH"
	assert_success
	run __get_rpath "$_test_file"
	assert_output "test/rpath3 @loader_path/test/rpath1 @loader_path/rpath2"

	__test_clean_file "$_test_file"
}



# LINKED LIB --------------------------------
@test "__get_linked_lib" {
	_test_file="$(__test_prepare_bin_file_linked)"

	run __get_linked_lib "$_test_file"
	assert_output ""

	__test_clean_file "$_test_file"
}


@test "__check_linked_lib" {
	[ "$STELLA_CURRENT_PLATFORM" != "darwin" ] && skip
	_test_file="$(__test_prepare_bin_file_linked)"

	run __check_linked_lib "$_test_file"
	assert_output_not_contains "WARN"
	assert_success

	__test_clean_file "$_test_file"
}
