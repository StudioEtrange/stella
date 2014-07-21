#!/bin/bash

_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $_CURRENT_FILE_DIR/stella.sh include

# MAIN -----------------------------------------------------------------------------------

# arguments
PARAMETERS="
PARAM1=											'action' 			a						'param1 param2'					Param1 description.
"
OPTIONS="
OPT1='default val'							'o'			''					a			0			'val1 val2 val3'			Option 1 description.
"

argparse "$0" "$OPTIONS" "$PARAMETERS" "App demo" "App demo" "" "$@"

init_env

echo "Param1 value: $PARAM1"
echo "Opt1 value: $OPT1"