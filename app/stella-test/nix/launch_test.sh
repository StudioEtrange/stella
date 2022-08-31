#!/bin/bash
_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"

STELLA_LOG_STATE=OFF
. "$_CURRENT_FILE_DIR/stella-link.sh" include

$STELLA_API require "bats" "bats"

function test_launch_bats() {
	local domain="$1"
  # regular expression that will match tests functions names
  local filter="$2"

  local _v=$(mktmp)
  declare >"$_v"
  declare -f >>"$_v"

  if [ "$filter" = "" ]; then
    __BATS_STELLA_DECLARE="$_v" bats --verbose-run "$STELLA_APP_ROOT/test/test_$domain.bats"
  else
    __BATS_STELLA_DECLARE="$_v" bats --verbose-run "$STELLA_APP_ROOT/test/test_$domain.bats" -f ${filter}
  fi
  rm -f "$_v"
}

case $1 in
  all|"" )
    test_launch_bats common $2
    test_launch_bats binary $2
    test_launch_bats feature $2
    ;;
  * )
    test_launch_bats $1 $2
    ;;
esac
