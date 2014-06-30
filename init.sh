#!/bin/bash
_INCLUDED_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_CALLING_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
source $_INCLUDED_FILE_DIR/conf.sh


function init_stella(){
	init_stella_by_os "$CURRENT_OS"
}


OPTIONS="
"
argparse "$0" "$OPTIONS" "" "Lib Stella Init " "Lib Stella Init" "RESULT" "$@"

init_stella

echo "** END **"
