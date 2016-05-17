#!/bin/bash
# TODO : migrate to bats
_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
source $_CURRENT_FILE_DIR/stella-link.sh include

source $_CURRENT_FILE_DIR/lib.sh

function test__make_targz_sfx_shell_1() {
	rm -Rf "$STELLA_APP_WORK_ROOT/output"
	mkdir -p "$STELLA_APP_WORK_ROOT/output"


	__make_targz_sfx_shell "$STELLA_ROOT/nix" "$STELLA_APP_WORK_ROOT/output/stella.gz.run"

	cd $STELLA_APP_WORK_ROOT/output
	./stella.gz.run

	if [ -f "$STELLA_APP_WORK_ROOT/output/nix/common/common.sh" ]; then
		log "test__make_targz_sfx_shell_1" "OK" "test gzip folder and sfx"
	else
		log "test__make_targz_sfx_shell_1" "ERROR" "test gzip folder and sfx"
	fi

}

function test__make_targz_sfx_shell_2() {
	rm -Rf "$STELLA_APP_WORK_ROOT/output"
	mkdir -p "$STELLA_APP_WORK_ROOT/output"

	__make_targz_sfx_shell "$STELLA_ROOT/stella.sh" "$STELLA_APP_WORK_ROOT/output/stella.gz.run"

	cd $STELLA_APP_WORK_ROOT/output
	./stella.gz.run

	if [ -f "$STELLA_APP_WORK_ROOT/output/stella.sh" ]; then
		log "test__make_targz_sfx_shell_2" "OK" "test gzip file and sfx"
	else
		log "test__make_targz_sfx_shell_2" "ERROR" "test gzip file and sfx"
	fi

}

function test__make_targz_sfx_shell_3() {
	rm -Rf "$STELLA_APP_WORK_ROOT/output"
	mkdir -p "$STELLA_APP_WORK_ROOT/output"


	tar -c -v -z -f "$STELLA_APP_WORK_ROOT/output/stella.gz" -C "$STELLA_ROOT/nix/.."  "nix"

	__make_targz_sfx_shell "$STELLA_APP_WORK_ROOT/output/stella.gz" "$STELLA_APP_WORK_ROOT/output/stella.gz.run" "TARGZ"

	cd $STELLA_APP_WORK_ROOT/output
	./stella.gz.run

	if [ -f "$STELLA_APP_WORK_ROOT/output/nix/common/common.sh" ]; then
		log "test__make_targz_sfx_shell_3" "OK" "test build sfx from existing targz"
	else
		log "test__make_targz_sfx_shell_3" "ERROR" "test build sfx from existing targz"
	fi

}


function test__make_sevenzip_sfx_bin_1() {

	rm -Rf "$STELLA_APP_WORK_ROOT/output"
	mkdir -p "$STELLA_APP_WORK_ROOT/output"


	__make_sevenzip_sfx_bin "$STELLA_ROOT/nix" "$STELLA_APP_WORK_ROOT/output/stella.7z.run" "$STELLA_CURRENT_PLATFORM_SUFFIX"

	__make_sevenzip_sfx_bin "$STELLA_ROOT/win" "$STELLA_APP_WORK_ROOT/output/stella.7z.exe" "win"

	cd $STELLA_APP_WORK_ROOT/output
	./stella.7z.run

	if [ -f "$STELLA_APP_WORK_ROOT/output/nix/common/common.sh" ]; then
		log "test__make_sevenzip_sfx_bin_1" "OK" "test 7z folder and sfx"
	else
		log "test__make_sevenzip_sfx_bin_1" "ERROR" "test 7z folder and sfx"
	fi

}



test__make_targz_sfx_shell_1
test__make_targz_sfx_shell_2
test__make_targz_sfx_shell_3

test__make_sevenzip_sfx_bin_1
