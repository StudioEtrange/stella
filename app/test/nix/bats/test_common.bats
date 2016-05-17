load test_bats_helper

# GENERIC -------------------------------------------------------------------
@test "__trim" {

	run __trim "test  test"
	assert_output "test  test"

	run __trim " test .. test "
	assert_output "test .. test"

}

# PATH -------------------------------------------------------------------

@test "__abs_to_rel_path" {

	run __abs_to_rel_path "/path1" "/path1/path2/path3"
	assert_output "../.."

	run __abs_to_rel_path "$STELLA_CURRENT_RUNNING_DIR" "/path1/path2/path3"
	assert_output "../../..$STELLA_CURRENT_RUNNING_DIR"

	run __abs_to_rel_path "/path1/path2" "/path1/path3"
	assert_output "../path2"

	run __abs_to_rel_path "/path1/path2" "/path1"
	assert_output "path2"

	run __abs_to_rel_path "/path1/path2/path3" "/path1"
	assert_output "path2/path3"

	run __abs_to_rel_path "/path1/path2" "/path3/path4"
	assert_output "../../path1/path2"

	run __abs_to_rel_path "/path1" "/path1"
	assert_output "."

	run __abs_to_rel_path "/path1/path2" "/path1/path2"
	assert_output "."

	run __abs_to_rel_path "/path2/path1" "/path3/path1"
	assert_output "../../path2/path1"

	run __abs_to_rel_path ".." "/path1/path2"
	assert_output ".."

	run __abs_to_rel_path ".." "../path1/path2"
	assert_output ".."

	run __abs_to_rel_path "../path2" "/path1/path2"
	assert_output "../path2"

	run __abs_to_rel_path "/path1/path2work" "/path1/path2"
	assert_output "../path2work"

	run __abs_to_rel_path "/" "/"
	assert_output "."

}

@test "__rel_to_abs_path" {

	run __rel_to_abs_path ".." "/path1/path2"
	assert_output "/path1"

	run __rel_to_abs_path "../.." "$STELLA_ROOT/nix/bin"
	assert_output "$STELLA_ROOT"

	run __rel_to_abs_path "../../../" "/"
	assert_output "/"

	run __rel_to_abs_path "../nix" "$STELLA_ROOT/nix"
	assert_output "$STELLA_ROOT/nix"

	run __rel_to_abs_path "../test" "$STELLA_ROOT/nix"
	assert_output "$STELLA_ROOT/test"

	run __rel_to_abs_path "../test2work" "/test2"
	assert_output "/test2work"

}
