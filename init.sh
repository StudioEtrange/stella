#!/bin/bash
_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
source $_CURRENT_FILE_DIR/conf.sh


function init_stella(){
	init_stella_by_os "$STELLA_CURRENT_OS"
}


OPTIONS="
"
argparse "$0" "$OPTIONS" "" "Lib Stella Init " "Lib Stella Init" "RESULT" "$@"

init_stella

echo "** END **"
