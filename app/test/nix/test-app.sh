#!/bin/bash
# TODO : migrate to bats
_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
source $_CURRENT_FILE_DIR/stella-link.sh include


source $_CURRENT_FILE_DIR/lib.sh






function test__app_init_1() {
	rm -Rf "$STELLA_APP_WORK_ROOT/output"
	mkdir -p "$STELLA_APP_WORK_ROOT/output"

	cd $STELLA_APP_WORK_ROOT/output
	__init_app "test_1" "$STELLA_APP_WORK_ROOT/output/test1" "." "cachedir"

	_test_app_root=$STELLA_APP_WORK_ROOT/output/test1

	result=ERROR
	[ -f "$_test_app_root/stella-link.sh" ] && result=OK || result=ERROR
	[ ! "$result" = "ERROR" ] && [ -f "$_test_app_root/stella.properties" ] && result=OK || result=ERROR
	[ ! "$result" = "ERROR" ] && r="$(cat $_test_app_root/stella.properties | grep APP_WORK_ROOT)" && echo $r && [ "$r" = "APP_WORK_ROOT=." ] && result=OK || result=ERROR
	[ ! "$result" = "ERROR" ] && r="$(cat $_test_app_root/stella.properties | grep APP_CACHE_DIR)" && echo $r && [ "$r" = "APP_CACHE_DIR=cachedir" ] && result=OK || result=ERROR

	[ ! "$result" = "ERROR" ] && r="$(cat $_test_app_root/stella-link.sh | grep STELLA_ROOT=)" && echo $r && [ "$r" = "STELLA_ROOT=\$_STELLA_LINK_CURRENT_FILE_DIR/../../../../lib-stella" ] && result=OK || result=ERROR


	log "test__app_init_1" "$result" "test init app function"

}



function test__app_init_2() {
	rm -Rf "$STELLA_APP_WORK_ROOT/output"
	mkdir -p "$STELLA_APP_WORK_ROOT/output"

	cd $STELLA_APP_WORK_ROOT/output
	__init_app "test_2" "$STELLA_APP_WORK_ROOT/output/test2" "../test2work"

	_test_app_root=$STELLA_APP_WORK_ROOT/output/test2

	result=ERROR
	[ -f "$_test_app_root/stella-link.sh" ] && result=OK || result=ERROR
	[ ! "$result" = "ERROR" ] && [ -f "$_test_app_root/stella.properties" ] && result=OK || result=ERROR
	[ ! "$result" = "ERROR" ] && r="$(cat $_test_app_root/stella.properties | grep APP_WORK_ROOT)" && echo $r && [ "$r" = "APP_WORK_ROOT=../test2work" ] && result=OK || result=ERROR
	[ ! "$result" = "ERROR" ] && r="$(cat $_test_app_root/stella.properties | grep APP_CACHE_DIR)" && echo $r && [ "$r" = "APP_CACHE_DIR=../test2work/cache" ] && result=OK || result=ERROR

	[ ! "$result" = "ERROR" ] && r="$(cat $_test_app_root/stella-link.sh | grep STELLA_ROOT=)" && echo $r && [ "$r" = "STELLA_ROOT=\$_STELLA_LINK_CURRENT_FILE_DIR/../../../../lib-stella" ] && result=OK || result=ERROR


	log "test__app_init_2" "$result" "test init app function"
}

function test_bin_app_init_1() {
	rm -Rf "$STELLA_APP_WORK_ROOT/output"
	mkdir -p "$STELLA_APP_WORK_ROOT/output"

	cd $STELLA_APP_WORK_ROOT/output
	$STELLA_BIN/app.sh init "test_1" --approot="$STELLA_APP_WORK_ROOT/output/test3" --workroot="../test2work" --cachedir="$STELLA_APP_WORK_ROOT/output/cache"


	_test_app_root=$STELLA_APP_WORK_ROOT/output/test3

	result=ERROR
	[ -f "$_test_app_root/stella-link.sh" ] && result=OK || result=ERROR
	[ ! "$result" = "ERROR" ] && [ -f "$_test_app_root/stella.properties" ] && result=OK || result=ERROR
	[ ! "$result" = "ERROR" ] && r="$(cat $_test_app_root/stella.properties | grep APP_WORK_ROOT)" && echo $r && [ "$r" = "APP_WORK_ROOT=../test2work" ] && result=OK || result=ERROR
	[ ! "$result" = "ERROR" ] && r="$(cat $_test_app_root/stella.properties | grep APP_CACHE_DIR)" && echo $r && [ "$r" = "APP_CACHE_DIR=../cache" ] && result=OK || result=ERROR

	[ ! "$result" = "ERROR" ] && r="$(cat $_test_app_root/stella-link.sh | grep STELLA_ROOT=)" && echo $r && [ "$r" = "STELLA_ROOT=\$_STELLA_LINK_CURRENT_FILE_DIR/../../../../lib-stella" ] && result=OK || result=ERROR


	log "test_bin_app_init_1" "$result" "test binary app : init"

}

test__app_init_1
test__app_init_2

test_bin_app_init_1
