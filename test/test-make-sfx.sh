#!/bin/bash
_STELLA_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_STELLA_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
source $_STELLA_CURRENT_FILE_DIR/../conf.sh

__init_stella_env


source $_STELLA_CURRENT_FILE_DIR/test-lib.sh

function test__make_targz_sfx_shell_1() {
	rm -Rf "$STELLA_TEST/test-workdir"
	mkdir -p "$STELLA_TEST/test-workdir"


	__make_targz_sfx_shell "$STELLA_ROOT/nix" "$STELLA_TEST/test-workdir/stella.gz.run"

	cd $STELLA_TEST/test-workdir
	./stella.gz.run

	if [ -f "$STELLA_TEST/test-workdir/nix/common/common.sh" ]; then
		log "test__make_targz_sfx_shell_1" "OK" "test gzip folder and sfx"
	else
		log "test__make_targz_sfx_shell_1" "ERROR" "test gzip folder and sfx"
	fi

}

function test__make_targz_sfx_shell_2() {
	rm -Rf "$STELLA_TEST/test-workdir"
	mkdir -p "$STELLA_TEST/test-workdir"

	__make_targz_sfx_shell "$STELLA_ROOT/stella.sh" "$STELLA_TEST/test-workdir/stella.gz.run"

	cd $STELLA_TEST/test-workdir
	./stella.gz.run

	if [ -f "$STELLA_TEST/test-workdir/stella.sh" ]; then
		log "test__make_targz_sfx_shell_2" "OK" "test gzip file and sfx"
	else
		log "test__make_targz_sfx_shell_2" "ERROR" "test gzip file and sfx"
	fi

}

function test__make_targz_sfx_shell_3() {
	rm -Rf "$STELLA_TEST/test-workdir"
	mkdir -p "$STELLA_TEST/test-workdir"


	tar -c -v -z -f "$STELLA_TEST/test-workdir/stella.gz" -C "$STELLA_ROOT/nix/.."  "nix"

	__make_targz_sfx_shell "$STELLA_TEST/test-workdir/stella.gz" "$STELLA_TEST/test-workdir/stella.gz.run" "TARGZ"

	cd $STELLA_TEST/test-workdir
	./stella.gz.run

	if [ -f "$STELLA_TEST/test-workdir/nix/common/common.sh" ]; then
		log "test__make_targz_sfx_shell_3" "OK" "test build sfx from existing targz"
	else
		log "test__make_targz_sfx_shell_3" "ERROR" "test build sfx from existing targz"
	fi

}


function test__make_sevenzip_sfx_bin() {
	# rm -Rf "$STELLA_TEST/test-workdir"
	# mkdir -p "$STELLA_TEST/test-workdir"


	# __make_sevenzip_sfx_bin "$STELLA_ROOT/nix" "$STELLA_TEST/test-workdir/stella.gz.run"

	# cd $STELLA_TEST/test-workdir
	# ./stella.gz.run

	# if [ -f "$STELLA_TEST/test-workdir/common/common.sh" ]; then
	# 	log "test__make_targz_sfx_shell" "OK"
	# else
	# 	log "test__make_targz_sfx_shell" "ERROR"
	# fi
	echo
}



test__make_targz_sfx_shell_1
test__make_targz_sfx_shell_2
test__make_targz_sfx_shell_3

test__make_sevenzip_sfx_bin

