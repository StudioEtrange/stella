load test_bats_helper

# GENERIC -------------------------------------------------------------------
@test "__trim" {

	run __trim "test  test"
	assert_output "test  test"

	run __trim " test .. test "
	assert_output "test .. test"

}

@test "__url_encode __url_decode" {

	run __url_encode 'hello `the` "@world"'
	assert_output "hello%20%60the%60%20%22%40world%22"

	run __url_decode 'hello%20%60the%60%20%22%40world%22'
	assert_output 'hello `the` "@world"'

	run __url_encode "Höhe über dem Meeresspiegel"
	assert_output "H%c3%b6he%20%c3%bcber%20dem%20Meeresspiegel"

	run __url_decode 'H%C3%B6he %C3%BCber%20dem%20Meeresspiegel'
	assert_output "Höhe über dem Meeresspiegel"

	run __url_encode '你好世界'
	assert_output "%e4%bd%a0%e5%a5%bd%e4%b8%96%e7%95%8c"

	run __url_decode $(__url_encode '你好世界')
	assert_output '你好世界'
}

@test "__uri_parse" {
	__uri_parse 'http://www.example.com'
	assert_equal 'http://www.example.com' "$__stella_uri"


	__uri_parse 'http://user:pass@www.example.com:19741/dir1/dir2/file.php?param=some_value&array[0]="123"&param2=\`cat /etc/passwd\`#bottom-left'
	assert_equal 'http://user:pass@www.example.com:19741/dir1/dir2/file.php?param=some_value&array[0]="123"&param2=\`cat /etc/passwd\`#bottom-left' "$__stella_uri"
	assert_equal 'http' "$__stella_uri_schema"
	assert_equal 'user:pass@www.example.com:19741' "$__stella_uri_address"
	assert_equal 'user' "$__stella_uri_user"
	assert_equal 'pass' "$__stella_uri_password"
	assert_equal 'www.example.com' "$__stella_uri_host"
	assert_equal '19741' "$__stella_uri_port"
	assert_equal '/dir1/dir2/file.php' "$__stella_uri_path"
	assert_equal '?param=some_value&array[0]="123"&param2=\`cat /etc/passwd\`' "$__stella_uri_query"
	assert_equal '#bottom-left' "$__stella_uri_fragment"
	assert_equal 'dir1' "${__stella_uri_parts[0]}"
	assert_equal 'dir2' "${__stella_uri_parts[1]}"
	assert_equal 'file.php' "${__stella_uri_parts[2]}"
	assert_equal 'param' "${__stella_uri_args[0]}"
	assert_equal 'array[0]' "${__stella_uri_args[1]}"
	assert_equal 'param2' "${__stella_uri_args[2]}"
	assert_equal 'some_value' "$__stella_uri_arg_param"
	assert_equal '"123"' "${__stella_uri_arg_array[0]}"
	assert_equal '\`cat /etc/passwd\`' "$__stella_uri_arg_param2"


	__uri_parse 'file:///root/foo'
	assert_equal 'file:///root/foo' "$__stella_uri"
	assert_equal 'file' "$__stella_uri_schema"
	assert_equal '' "$__stella_uri_address"
	assert_equal '' "$__stella_uri_user"
	assert_equal '' "$__stella_uri_password"
	assert_equal '' "$__stella_uri_host"
	assert_equal '' "$__stella_uri_port"
	assert_equal '/root/foo' "$__stella_uri_path"
	assert_equal '' "$__stella_uri_query"
	assert_equal '' "$__stella_uri_fragment"
	assert_equal 'root' "${__stella_uri_parts[0]}"
	assert_equal 'foo' "${__stella_uri_parts[1]}"

	__uri_parse '/root/foo'
	assert_equal '/root/foo' "$__stella_uri"
	assert_equal '' "$__stella_uri_schema"
	assert_equal 'root' "${__stella_uri_parts[0]}"
	assert_equal 'foo' "${__stella_uri_parts[1]}"

	__uri_parse 'docker:///id'
	assert_equal 'docker:///id' "$__stella_uri"
	assert_equal 'docker' "$__stella_uri_schema"
	assert_equal 'id' "${__stella_uri_parts[0]}"

	__uri_parse 'docker:///id1/id2#/frag/frag'
	assert_equal 'docker:///id1/id2#/frag/frag' "$__stella_uri"
	assert_equal 'docker' "$__stella_uri_schema"
	assert_equal 'id1' "${__stella_uri_parts[0]}"
	assert_equal 'id2' "${__stella_uri_parts[1]}"
	assert_equal '#/frag/frag' "$__stella_uri_fragment"

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
