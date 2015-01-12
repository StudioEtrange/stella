#!/bin/bash
_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $_CURRENT_FILE_DIR/stella.sh include

# ARGUMENTS -----------------------------------------------------------------------------------
PARAMETERS="
PARAM1=											'action' 			a						'param1 param2'					Param1 description.
"
OPTIONS="
OPT1='default val'							'o'			''					'a'			0			'val1 val2 val3'			Option 1 description.
"

$STELLA_API argparse "$0" "$OPTIONS" "$PARAMETERS" "App demo" "App demo" "" "$@"


# MAIN -----------------------------------------------------------------------------------

echo "Param1 value: $PARAM1"
echo "Opt1 value: $OPT1"

echo "APP_ROOT : $STELLA_APP_ROOT"
echo "APP_WORK_ROOT : $STELLA_APP_WORK_ROOT"


result=$($STELLA_API is_abs "../")
echo $result
