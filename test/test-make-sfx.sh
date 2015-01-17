#!/bin/bash
_STELLA_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_STELLA_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
source $_STELLA_CURRENT_FILE_DIR/../conf.sh

__init_stella_env


source $_STELLA_CURRENT_FILE_DIR/test-lib.sh

function test__make_targz_sfx_shell_1() {
	rm -Rf "$STELLA_TEST/output"
	mkdir -p "$STELLA_TEST/output"


	__make_targz_sfx_shell "$STELLA_ROOT/nix" "$STELLA_TEST/output/stella.gz.run"

	cd $STELLA_TEST/output
	./stella.gz.run

	if [ -f "$STELLA_TEST/output/nix/common/common.sh" ]; then
		log "test__make_targz_sfx_shell_1" "OK" "test gzip folder and sfx"
	else
		log "test__make_targz_sfx_shell_1" "ERROR" "test gzip folder and sfx"
	fi

}

function test__make_targz_sfx_shell_2() {
	rm -Rf "$STELLA_TEST/output"
	mkdir -p "$STELLA_TEST/output"

	__make_targz_sfx_shell "$STELLA_ROOT/stella.sh" "$STELLA_TEST/output/stella.gz.run"

	cd $STELLA_TEST/output
	./stella.gz.run

	if [ -f "$STELLA_TEST/output/stella.sh" ]; then
		log "test__make_targz_sfx_shell_2" "OK" "test gzip file and sfx"
	else
		log "test__make_targz_sfx_shell_2" "ERROR" "test gzip file and sfx"
	fi

}

function test__make_targz_sfx_shell_3() {
	rm -Rf "$STELLA_TEST/output"
	mkdir -p "$STELLA_TEST/output"


	tar -c -v -z -f "$STELLA_TEST/output/stella.gz" -C "$STELLA_ROOT/nix/.."  "nix"

	__make_targz_sfx_shell "$STELLA_TEST/output/stella.gz" "$STELLA_TEST/output/stella.gz.run" "TARGZ"

	cd $STELLA_TEST/output
	./stella.gz.run

	if [ -f "$STELLA_TEST/output/nix/common/common.sh" ]; then
		log "test__make_targz_sfx_shell_3" "OK" "test build sfx from existing targz"
	else
		log "test__make_targz_sfx_shell_3" "ERROR" "test build sfx from existing targz"
	fi

}


function test__make_sevenzip_sfx_bin_1() {

	STELLA_APP_CACHE_DIR="$STELLA_TEST/output/cache"

	rm -Rf "$STELLA_TEST/output"
	mkdir -p "$STELLA_TEST/output"


	__make_sevenzip_sfx_bin "$STELLA_ROOT/nix" "$STELLA_TEST/output/stella.7z.run" "$STELLA_CURRENT_PLATFORM_SUFFIX"

	cd $STELLA_TEST/output
	./stella.7z.run

	if [ -f "$STELLA_TEST/output/nix/common/common.sh" ]; then
		log "test__make_sevenzip_sfx_bin_1" "OK" "test 7z folder and sfx"
	else
		log "test__make_sevenzip_sfx_bin_1" "ERROR" "test 7z folder and sfx"
	fi

}



test__make_targz_sfx_shell_1
test__make_targz_sfx_shell_2
test__make_targz_sfx_shell_3

test__make_sevenzip_sfx_bin_1

