#!/bin/bash
_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
source $_CURRENT_FILE_DIR/stella-link.sh include


source $_CURRENT_FILE_DIR/test-lib.sh


function test__abs_to_rel_path_1() {

	result=OK
	r=$(__abs_to_rel_path "/path1" "/path1/path2") && echo $r  && [ "$r" == ".." ] && result=OK || result=ERROR
	[ ! "$result" == "ERROR" ] && r=$(__abs_to_rel_path "/path1" "/path1/path2/path3") && echo $r && [ "$r" == "../.." ] && result=OK || result=ERROR
	[ ! "$result" == "ERROR" ] && r=$(__abs_to_rel_path "$_STELLA_CURRENT_RUNNING_DIR" "/path1/path2/path3") && echo $r && [ "$r" == "../../..$_STELLA_CURRENT_RUNNING_DIR" ] && result=OK || result=ERROR
	[ ! "$result" == "ERROR" ] && r=$(__abs_to_rel_path "/path1/path2" "/path1/path3") && echo $r && [ "$r" == "../path2" ] && result=OK || result=ERROR
	[ ! "$result" == "ERROR" ] && r=$(__abs_to_rel_path "/path1/path2" "/path1") && echo $r && [ "$r" == "path2" ] && result=OK || result=ERROR
	[ ! "$result" == "ERROR" ] && r=$(__abs_to_rel_path "/path1/path2/path3" "/path1") && echo $r && [ "$r" == "path2/path3" ] && result=OK || result=ERROR
	[ ! "$result" == "ERROR" ] && r=$(__abs_to_rel_path "/path1/path2" "/path3/path4") && echo $r && [ "$r" == "../../path1/path2" ] && result=OK || result=ERROR
	


	[ ! "$result" == "ERROR" ] && r=$(__abs_to_rel_path "/path1" "/path1") && echo $r && [ "$r" == "." ] && result=OK || result=ERROR
	[ ! "$result" == "ERROR" ] && r=$(__abs_to_rel_path "/path1/path2" "/path1/path2") && echo $r && [ "$r" == "." ] && result=OK || result=ERROR
	[ ! "$result" == "ERROR" ] && r=$(__abs_to_rel_path "/path2/path1" "/path3/path1") && echo $r && [ "$r" == "../../path2/path1" ] && result=OK || result=ERROR
	
	[ ! "$result" == "ERROR" ] && r=$(__abs_to_rel_path ".." "/path1/path2") && echo $r && [ "$r" == ".." ] && result=OK || result=ERROR
	[ ! "$result" == "ERROR" ] && r=$(__abs_to_rel_path ".." "../path1/path2") && echo $r && [ "$r" == ".." ] && result=OK || result=ERROR
	[ ! "$result" == "ERROR" ] && r=$(__abs_to_rel_path "../path2" "/path1/path2") && echo $r && [ "$r" == "../path2" ] && result=OK || result=ERROR

	[ ! "$result" == "ERROR" ] && r=$(__abs_to_rel_path "/path1/path2work" "/path1/path2") && echo $r && [ "$r" == "../path2work" ] && result=OK || result=ERROR
	
	[ ! "$result" == "ERROR" ] && r=$(__abs_to_rel_path "/" "/") && echo $r && [ "$r" == "." ] && result=OK || result=ERROR
	


	log "test__abs_to_rel_path_1" "$result" "test __abs_to_rel_path"

}


function test__rel_to_abs_path_1() {


	result=OK
	r=$(__rel_to_abs_path ".." "/path1/path2") && echo $r  && [ "$r" == "/path1" ] && result=OK || result=ERROR
	[ ! "$result" == "ERROR" ] && r=$(__rel_to_abs_path "../.." "$STELLA_ROOT/nix/bin") && echo $r && [ "$r" == "$STELLA_ROOT" ] && result=OK || result=ERROR
	[ ! "$result" == "ERROR" ] && r=$(__rel_to_abs_path "../../../" "/") && echo $r && [ "$r" == "/" ] && result=OK || result=ERROR
	
	[ ! "$result" == "ERROR" ] && r=$(__rel_to_abs_path "../nix" "$STELLA_ROOT/nix") && echo $r && [ "$r" == "$STELLA_ROOT/nix" ] && result=OK || result=ERROR
	[ ! "$result" == "ERROR" ] && r=$(__rel_to_abs_path "../test" "$STELLA_ROOT/nix") && echo $r && [ "$r" == "$STELLA_ROOT/test" ] && result=OK || result=ERROR

	[ ! "$result" == "ERROR" ] && r=$(__abs_to_rel_path "../test2work" "/test2") && echo $r && [ "$r" == "../test2work" ] && result=OK || result=ERROR


	log "test__rel_to_abs_path_1" "$result" "test __rel_to_abs_path"

}

test__abs_to_rel_path_1
test__rel_to_abs_path_1


