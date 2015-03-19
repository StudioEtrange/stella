#!/bin/bash
_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_CURRENT_RUNNING_DIR="$( cd "$( dirname "." )" && pwd )"
source $_CURRENT_FILE_DIR/stella-link.sh include



function usage() {
    echo "USAGE :"
    echo "----------------"
    echo "List of commands"
    echo " o-- domain1 management :"
    echo " L     domain1 action1 [-o <val1|val2>] : foo"
    echo " L     domain1 action2 [-o <val1|val2>] : bar"
    echo " o-- domain2 management :"
    echo " L     domain2 action1 [-o <val1|val2>] : foo"
    echo " L     domain2 action2 [-o <val1|val2>] : bar"
}


# COMMAND LINE ARGUMENTS -----------------------------------------------------------------------------------
PARAMETERS="
PARAM1=											'domain' 			a						'domain1 domain2'					Param1 description.
PARAM2=											'action' 			a						'action1 action2'					Param2 description.
"
OPTIONS="
OPT1='default val'							'o'			''					'a'			0			'val1 val2'			Option 1 description.
"

$STELLA_API argparse "$0" "$OPTIONS" "$PARAMETERS" "App demo" "$(usage)" "" "$@"


# MAIN -----------------------------------------------------------------------------------

echo "Param1 value: $PARAM1"
echo "Opt1 value: $OPT1"

echo "APP_ROOT : $STELLA_APP_ROOT"
echo "APP_WORK_ROOT : $STELLA_APP_WORK_ROOT"


result=$($STELLA_API is_abs "../")
echo $result
