
bats_load_library 'bats-assert'
bats_load_library 'bats-support'


setup() {
	load 'stella_bats_helper.bash'
	mkdir -p "$STELLA_APP_WORK_ROOT"
}

teardown() {
    true
}


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

@test "__uri_parse_strict_validation" {
	run __uri_parse 'http://www.example.com' "STRICT_VALIDATION"
	assert_success
	__uri_parse 'http://www.example.com' "STRICT_VALIDATION"
	assert_equal "$__stella_uri" 'http://www.example.com'

	run __uri_parse 'http://127.0.0.1/foo' "STRICT_VALIDATION"
	assert_success
	__uri_parse 'http://127.0.0.1/foo' "STRICT_VALIDATION"
	assert_equal "$__stella_uri" 'http://127.0.0.1/foo'
	assert_equal "$__stella_uri_address" '127.0.0.1'
	assert_equal "$__stella_uri_host" '127.0.0.1'
	assert_equal "$__stella_uri_port" ''
	assert_equal "$__stella_uri_path" '/foo'


	run __uri_parse 'http://user:pass@www.example.com:19741/dir1/dir2/file.php' "STRICT_VALIDATION"
	assert_success
	__uri_parse 'http://user:pass@www.example.com:19741/dir1/dir2/file.php' "STRICT_VALIDATION"
	assert_equal "$__stella_uri" 'http://user:pass@www.example.com:19741/dir1/dir2/file.php'

	run __uri_parse 'http://user:pass@www.example.com:19741/dir1/dir2/file.php?param=some_value&array0=123&param2=3#bottomleft' "STRICT_VALIDATION"
	assert_success
	__uri_parse 'http://user:pass@www.example.com:19741/dir1/dir2/file.php?param=some_value&array0=123&param2=3#bottomleft' "STRICT_VALIDATION"
	assert_equal "$__stella_uri"  'http://user:pass@www.example.com:19741/dir1/dir2/file.php?param=some_value&array0=123&param2=3#bottomleft'

	run __uri_parse 'http://user:pass@www.example.com:19741/#bottom-left' "STRICT_VALIDATION"
	assert_success
	__uri_parse 'http://user:pass@www.example.com:19741/#bottom-left' "STRICT_VALIDATION"
	assert_equal "$__stella_uri" 'http://user:pass@www.example.com:19741/#bottom-left'


	
	run __uri_parse 'http://user:pass@www.example.com:19741/dir1/dir2/file.php?param=some_value&array0=123&param2=#bottom-left' "STRICT_VALIDATION"
	assert_success
	__uri_parse 'http://user:pass@www.example.com:19741/dir1/dir2/file.php?param=some_value&array0=123&param2=#bottom-left' "STRICT_VALIDATION"
	assert_equal 'http://user:pass@www.example.com:19741/dir1/dir2/file.php?param=some_value&array0=123&param2=#bottom-left' "$__stella_uri"
	assert_equal "$__stella_uri_schema" 'http' 
	assert_equal "$__stella_uri_address" 'user:pass@www.example.com:19741'
	assert_equal "$__stella_uri_user" 'user'
	assert_equal "$__stella_uri_password" 'pass'
	assert_equal "$__stella_uri_host" 'www.example.com'
	assert_equal "$__stella_uri_port" '19741'
	assert_equal "$__stella_uri_path" '/dir1/dir2/file.php'
	assert_equal "$__stella_uri_query" '?param=some_value&array0=123&param2='
	assert_equal "$__stella_uri_fragment" '#bottom-left'

	assert_equal "${__stella_uri_parts[0]}" 'dir1'
	assert_equal "${__stella_uri_parts[1]}" 'dir2'
	assert_equal "${__stella_uri_parts[2]}" 'file.php'
	assert_equal "${__stella_uri_args[0]}" 'param'
	assert_equal "${__stella_uri_args[1]}" 'array0'
	assert_equal "${__stella_uri_args[2]}" 'param2'
	assert_equal "$__stella_uri_arg_param" 'some_value'
	assert_equal "${__stella_uri_arg_array0}" '123'
	assert_equal "${__stella_uri_arg_param2}" ''


	run __uri_parse 'http://user:pass@www.example.com:19741/dir1/dir2/file.php?param=some_value&array[0]="123"&param2=`cat /etc/passwd`#bottom-left' "STRICT_VALIDATION"
	assert_failure

	run __uri_parse 'https://acme-staging-v02.api.letsencrypt.org/acme/authz-v3/2697133184' "STRICT_VALIDATION"
	assert_success
	__uri_parse 'https://acme-staging-v02.api.letsencrypt.org/acme/authz-v3/2697133184' "STRICT_VALIDATION"
	assert_equal 'https://acme-staging-v02.api.letsencrypt.org/acme/authz-v3/2697133184' "$__stella_uri"
	assert_equal "$__stella_uri_host" 'acme-staging-v02.api.letsencrypt.org'
	assert_equal "$__stella_uri_path" '/acme/authz-v3/2697133184'

	__uri_parse 'file:///root/foo' "STRICT_VALIDATION"
	assert_equal 'file:///root/foo' "$__stella_uri"
	assert_equal 'file' "$__stella_uri_schema"
	assert_equal "$__stella_uri_address" ''
	assert_equal "$__stella_uri_user" ''
	assert_equal "$__stella_uri_password" ''
	assert_equal "$__stella_uri_host" ''
	assert_equal "$__stella_uri_port" ''
	assert_equal "$__stella_uri_path" '/root/foo'
	assert_equal "$__stella_uri_query" ''
	assert_equal "$__stella_uri_fragment" ''
	assert_equal "${__stella_uri_parts[0]}" 'root'
	assert_equal "${__stella_uri_parts[1]}" 'foo'

	__uri_parse '/root/foo' "STRICT_VALIDATION"
	assert_equal '/root/foo' "$__stella_uri"
	assert_equal '' "$__stella_uri_schema"
	assert_equal 'root' "${__stella_uri_parts[0]}"
	assert_equal 'foo' "${__stella_uri_parts[1]}"

	__uri_parse 'docker:///id' "STRICT_VALIDATION"
	assert_equal 'docker:///id' "$__stella_uri"
	assert_equal 'docker' "$__stella_uri_schema"
	assert_equal 'id' "${__stella_uri_parts[0]}"

	__uri_parse 'docker:///id1/id2#/frag/frag' "STRICT_VALIDATION"
	assert_equal "$__stella_uri" 'docker:///id1/id2#/frag/frag'
	assert_equal "$__stella_uri_schema" 'docker'
	assert_equal "${__stella_uri_parts[0]}" 'id1'
	assert_equal "${__stella_uri_parts[1]}" 'id2'
	assert_equal "$__stella_uri_fragment" '#/frag/frag'

}


@test "__uri_parse_match_strict_validation" {
	run __uri_parse 'http://www.example.com' "MATCH_ONLY_STRICT_VALIDATION"
	assert_success
	__uri_parse 'http://www.example.com' "MATCH_ONLY_STRICT_VALIDATION"
	assert_equal "$__stella_uri" 'http://www.example.com'

	run __uri_parse 'http://127.0.0.1/foo' "MATCH_ONLY_STRICT_VALIDATION"
	assert_success
	__uri_parse 'http://127.0.0.1/foo' "MATCH_ONLY_STRICT_VALIDATION"
	assert_equal "$__stella_uri" 'http://127.0.0.1/foo'
	assert_equal "$__stella_uri_address" '127.0.0.1'
	assert_equal "$__stella_uri_host" '127.0.0.1'
	assert_equal "$__stella_uri_port" ''
	assert_equal "$__stella_uri_path" '/foo'


	run __uri_parse 'http://user:pass@www.example.com:19741/dir1/dir2/file.php' "MATCH_ONLY_STRICT_VALIDATION"
	assert_success
	__uri_parse 'http://user:pass@www.example.com:19741/dir1/dir2/file.php' "MATCH_ONLY_STRICT_VALIDATION"
	assert_equal "$__stella_uri" 'http://user:pass@www.example.com:19741/dir1/dir2/file.php'

	
	run __uri_parse 'http://user:pass@www.example.com:19741/dir1/dir2/file.php?param=some_value&array[0]=123&param2=#bottom-left' "MATCH_ONLY_STRICT_VALIDATION"
	assert_success
	__uri_parse 'http://user:pass@www.example.com:19741/dir1/dir2/file.php?param=some_value&array[0]=123&param2=#bottom-left' "MATCH_ONLY_STRICT_VALIDATION"
	assert_equal 'http://user:pass@www.example.com:19741/dir1/dir2/file.php?param=some_value&array' "$__stella_uri"
	assert_equal "$__stella_uri_schema" 'http' 
	assert_equal "$__stella_uri_address" 'user:pass@www.example.com:19741'
	assert_equal "$__stella_uri_user" 'user'
	assert_equal "$__stella_uri_password" 'pass'
	assert_equal "$__stella_uri_host" 'www.example.com'
	assert_equal "$__stella_uri_port" '19741'
	assert_equal "$__stella_uri_path" '/dir1/dir2/file.php'
	assert_equal "$__stella_uri_query" '?param=some_value&array'
	assert_equal "$__stella_uri_fragment" ''

	assert_equal "${__stella_uri_parts[0]}" 'dir1'
	assert_equal "${__stella_uri_parts[1]}" 'dir2'
	assert_equal "${__stella_uri_parts[2]}" 'file.php'
	assert_equal "${__stella_uri_args[0]}" 'param'
	assert_equal "${__stella_uri_args[1]}" 'array'
	assert_equal "${__stella_uri_args[2]}" ''
	assert_equal "$__stella_uri_arg_param" 'some_value'
	assert_equal "${__stella_uri_arg_array}" ''
	assert_equal "${__stella_uri_arg_param2}" ''

}

@test "__uri_parse_simple_validation" {
	run __uri_parse 'http://www.example.com' "SIMPLE_VALIDATION"
	assert_success
	__uri_parse 'http://www.example.com' "SIMPLE_VALIDATION"
	assert_equal "$__stella_uri" 'http://www.example.com'

	run __uri_parse 'http://127.0.0.1/foo' "SIMPLE_VALIDATION"
	assert_success
	__uri_parse 'http://127.0.0.1/foo' "SIMPLE_VALIDATION"
	assert_equal "$__stella_uri" 'http://127.0.0.1/foo'
	assert_equal "$__stella_uri_address" '127.0.0.1'
	assert_equal "$__stella_uri_host" '127.0.0.1'
	assert_equal "$__stella_uri_port" ''
	assert_equal "$__stella_uri_path" '/foo'


	run __uri_parse 'http://user:pass@www.example.com:19741/dir1/dir2/file.php' "SIMPLE_VALIDATION"
	assert_success
	__uri_parse 'http://user:pass@www.example.com:19741/dir1/dir2/file.php' "SIMPLE_VALIDATION"
	assert_equal "$__stella_uri" 'http://user:pass@www.example.com:19741/dir1/dir2/file.php'

	run __uri_parse 'http://user:pass@www.example.com:19741/dir1/dir2/file.php?param=some_value&array0=123&param2=3#bottomleft' "SIMPLE_VALIDATION"
	assert_success
	__uri_parse 'http://user:pass@www.example.com:19741/dir1/dir2/file.php?param=some_value&array0=123&param2=3#bottomleft' "SIMPLE_VALIDATION"
	assert_equal "$__stella_uri"  'http://user:pass@www.example.com:19741/dir1/dir2/file.php?param=some_value&array0=123&param2=3#bottomleft'

	run __uri_parse 'http://user:pass@www.example.com:19741/#bottom-left' "SIMPLE_VALIDATION"
	assert_success
	__uri_parse 'http://user:pass@www.example.com:19741/#bottom-left' "SIMPLE_VALIDATION"
	assert_equal "$__stella_uri" 'http://user:pass@www.example.com:19741/#bottom-left'


	
	run __uri_parse 'http://user:pass@www.example.com:19741/dir1/dir2/file.php?param=some_value&array0=123&param2=#bottom-left' "SIMPLE_VALIDATION"
	assert_success
	__uri_parse 'http://user:pass@www.example.com:19741/dir1/dir2/file.php?param=some_value&array0=123&param2=#bottom-left' "SIMPLE_VALIDATION"
	assert_equal 'http://user:pass@www.example.com:19741/dir1/dir2/file.php?param=some_value&array0=123&param2=#bottom-left' "$__stella_uri"
	assert_equal "$__stella_uri_schema" 'http' 
	assert_equal "$__stella_uri_address" 'user:pass@www.example.com:19741'
	assert_equal "$__stella_uri_user" 'user'
	assert_equal "$__stella_uri_password" 'pass'
	assert_equal "$__stella_uri_host" 'www.example.com'
	assert_equal "$__stella_uri_port" '19741'
	assert_equal "$__stella_uri_path" '/dir1/dir2/file.php'
	assert_equal "$__stella_uri_query" '?param=some_value&array0=123&param2='
	assert_equal "$__stella_uri_fragment" '#bottom-left'

	assert_equal "${__stella_uri_parts[0]}" 'dir1'
	assert_equal "${__stella_uri_parts[1]}" 'dir2'
	assert_equal "${__stella_uri_parts[2]}" 'file.php'
	assert_equal "${__stella_uri_args[0]}" 'param'
	assert_equal "${__stella_uri_args[1]}" 'array0'
	assert_equal "${__stella_uri_args[2]}" 'param2'
	assert_equal "$__stella_uri_arg_param" 'some_value'
	assert_equal "${__stella_uri_arg_array0}" '123'
	assert_equal "${__stella_uri_arg_param2}" ''

	run __uri_parse 'https://acme-staging-v02.api.letsencrypt.org/acme/authz-v3/2697133184' "SIMPLE_VALIDATION"
	assert_success
	__uri_parse 'https://acme-staging-v02.api.letsencrypt.org/acme/authz-v3/2697133184' "SIMPLE_VALIDATION"
	assert_equal 'https://acme-staging-v02.api.letsencrypt.org/acme/authz-v3/2697133184' "$__stella_uri"
	assert_equal "$__stella_uri_host" 'acme-staging-v02.api.letsencrypt.org'
	assert_equal "$__stella_uri_path" '/acme/authz-v3/2697133184'

	run __uri_parse 'http://user:pass@www.example.com:19741/dir1/dir2/file.php?param=some_value&array[0]="123"&param2=`cat /etc/passwd`#bottom-left' "SIMPLE_VALIDATION"
	assert_success
	__uri_parse 'http://user:pass@www.example.com:19741/dir1/dir2/file.php?param=some_value&array[0]="123"&param2=`cat /etc/passwd`#bottom-left' "SIMPLE_VALIDATION"
	assert_equal 'http://user:pass@www.example.com:19741/dir1/dir2/file.php?param=some_value&array[0]="123"&param2=`cat /etc/passwd`#bottom-left' "$__stella_uri"
	assert_equal "$__stella_uri_schema" 'http' 
	assert_equal "$__stella_uri_address" 'user:pass@www.example.com:19741'
	assert_equal "$__stella_uri_user" 'user'
	assert_equal "$__stella_uri_password" 'pass'
	assert_equal "$__stella_uri_host" 'www.example.com'
	assert_equal "$__stella_uri_port" '19741'
	assert_equal "$__stella_uri_path" '/dir1/dir2/file.php'
	assert_equal "$__stella_uri_query" '?param=some_value&array[0]="123"&param2=`cat /etc/passwd`'
	assert_equal "$__stella_uri_fragment" '#bottom-left'

	assert_equal "${__stella_uri_parts[0]}" 'dir1'
	assert_equal "${__stella_uri_parts[1]}" 'dir2'
	assert_equal "${__stella_uri_parts[2]}" 'file.php'
	assert_equal "${__stella_uri_args[0]}" 'param'
	assert_equal "${__stella_uri_args[1]}" 'array[0]'
	assert_equal "${__stella_uri_args[2]}" 'param2'
	assert_equal "$__stella_uri_arg_param" 'some_value'
	assert_equal "${__stella_uri_arg_array[0]}" '"123"'
	assert_equal "${__stella_uri_arg_param2}" '`cat /etc/passwd`'


	__uri_parse 'file:///root/foo' "SIMPLE_VALIDATION"
	assert_equal 'file:///root/foo' "$__stella_uri"
	assert_equal 'file' "$__stella_uri_schema"
	assert_equal "$__stella_uri_address" ''
	assert_equal "$__stella_uri_user" ''
	assert_equal "$__stella_uri_password" ''
	assert_equal "$__stella_uri_host" ''
	assert_equal "$__stella_uri_port" ''
	assert_equal "$__stella_uri_path" '/root/foo'
	assert_equal "$__stella_uri_query" ''
	assert_equal "$__stella_uri_fragment" ''
	assert_equal "${__stella_uri_parts[0]}" 'root'
	assert_equal "${__stella_uri_parts[1]}" 'foo'

	__uri_parse '/root/foo' "SIMPLE_VALIDATION"
	assert_equal '/root/foo' "$__stella_uri"
	assert_equal '' "$__stella_uri_schema"
	assert_equal 'root' "${__stella_uri_parts[0]}"
	assert_equal 'foo' "${__stella_uri_parts[1]}"

	__uri_parse 'docker:///id' "SIMPLE_VALIDATION"
	assert_equal 'docker:///id' "$__stella_uri"
	assert_equal 'docker' "$__stella_uri_schema"
	assert_equal 'id' "${__stella_uri_parts[0]}"

	__uri_parse 'docker:///id1/id2#/frag/frag' "SIMPLE_VALIDATION"
	assert_equal "$__stella_uri" 'docker:///id1/id2#/frag/frag'
	assert_equal "$__stella_uri_schema" 'docker'
	assert_equal "${__stella_uri_parts[0]}" 'id1'
	assert_equal "${__stella_uri_parts[1]}" 'id2'
	assert_equal "$__stella_uri_fragment" '#/frag/frag'

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


# LIST  -------------------------------------------------------------------
@test "__list_contains" {

	run __list_contains "aa bb xx" "bb"
	assert_success
 
	run __list_contains "aa bb xx" "b"
	assert_failure

	run __list_contains "aa bb xx" "bb xx"
	assert_success

	run __list_contains "aa bb xx" "aa xx"
	assert_failure

	run __list_contains "aa bb xx" ""
	assert_failure

	run __list_contains "" ""
	assert_failure

}