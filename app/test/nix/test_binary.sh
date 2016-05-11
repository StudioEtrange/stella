#!/bin/bash
_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
source $_CURRENT_FILE_DIR/stella-link.sh include

__require "bats" "bats#SNAPSHOT" "PREFER_STELLA"

_v=$(mktmp)
declare >$_v
declare -f >>$_v
export __BATS_STELLA_DECLARE=$_v

#bats --verbose test_binary.bats
bats test_binary.bats

rm -f $_v
