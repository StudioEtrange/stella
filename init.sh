#!/bin/bash
_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
source $_CURRENT_FILE_DIR/conf.sh



OPTIONS="
"
__argparse "$0" "$OPTIONS" "" "Lib Stella Init " "Lib Stella Init" "RESULT" "$@"

__init_stella_env

__init_stella_by_os "$STELLA_CURRENT_OS"

echo "** END **"
