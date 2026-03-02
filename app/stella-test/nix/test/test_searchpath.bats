
bats_load_library 'bats-assert'
bats_load_library 'bats-support'


setup() {
	load 'stella_bats_helper.bash'
	mkdir -p "$STELLA_APP_WORK_ROOT"
}

teardown() {
    true
}

@test "__search_static_library" {

	run __search_static_library "libc"
	assert_success
	assert_output --partial "/libc.a"

}