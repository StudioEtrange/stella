
bats_load_library 'bats-assert'
bats_load_library 'bats-support'


setup() {
	load 'stella_bats_helper.bash'
	mkdir -p "$STELLA_APP_WORK_ROOT"
}

teardown() {
    true
}


# STACK -------------------------------------------------------------------

@test "__stack_1" {

	__stack_init "STACK1"
	assert_success

	run __stack_size "STACK1"
	assert_output "0"
	
	run __stack_print "STACK1"
	assert_output ""
}


@test "__stack_2" {

	__stack_init "STACK2"

	__stack_push "STACK2" "AA"
	__stack_push "STACK2" "BB"
	__stack_push "STACK2" "CC"
	run echo ${_STELLA_STACK_STACK2[@]}
	assert_output "AA BB CC"

	run __stack_print "STACK2"
	assert_output "AA BB CC"

	run __stack_size "STACK2"
 	assert_output "3"

	__stack_pop "STACK2" "VAR"
	assert_equal "$VAR" "CC"
	
	run __stack_size "STACK2"
 	assert_output "2"
	
	run __stack_print "STACK2"
	assert_output "AA BB"
}


