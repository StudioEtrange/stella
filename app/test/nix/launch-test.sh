#!/bin/bash
_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
source $_CURRENT_FILE_DIR/stella-link.sh include

__require "bats" "bats#SNAPSHOT" "STELLA_FEATURE"

function test_launch_bats() {
	local domain=$1

  local _v=$(mktmp)
  declare >"$_v"
  declare -f >>"$_v"

	#bats --verbose test_binary.bats
	__BATS_STELLA_DECLARE="$_v" bats "$STELLA_APP_ROOT/bats/test_$domain".bats

  rm -f "$_v"
}





case $1 in
  all )
    test_launch_bats common
    test_launch_bats binary
    test_launch_bats feature
    ;;
  * )
    test_launch_bats $1
    ;;
esac
