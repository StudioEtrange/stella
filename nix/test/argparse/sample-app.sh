#!/bin/bash
_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_CURRENT_RUNNING_DIR="$( cd "$( dirname "." )" && pwd )"
. $_CURRENT_FILE_DIR/stella-link.sh include

# TEST with
# ./nix/test/argparse/sample-app.sh
# ./nix/test/argparse/sample-app.sh "foo bar" run
# ./nix/test/argparse/sample-app.sh "foo bar" --opt1="'a b'" --opt2 "a b" run "'target'"
# ./nix/test/argparse/sample-app.sh "foo bar" --opt1="'a b'" --opt2 "a b" run "'target'" source "other param" '"another"'
# ./nix/test/argparse/sample-app.sh "foo bar" run --  bash -c "'a b'" 'd e' '"c ee"' f
# ./nix/test/argparse/sample-app.sh "foo bar" --opt1="'a b'" --opt2 "a b" run "'target'" --  bash -c "'a b'" 'd e' '"c ee"' f
# ./nix/test/argparse/sample-app.sh "foo bar" --opt1="'a b'" --opt2 "a b" run "'target'" source "other param" '"another"' --  bash -c "'a b'" 'd e' '"c ee"' f
# ./nix/test/argparse/sample-app.sh --  bash -c "'a b'" 'd e' '"c ee"' f


usage() {
	echo "USAGE :"
	echo "----------------"
	echo "o-- foo management :"
	echo "L     foo run [--opt=<string>]"
}

# COMMAND LINE -----------------------------------------------------------------------------------
PARAMETERS="
DOMAIN=											'domain' 			s		'' 	'1'		'Action domain.'
ID=												'' 					a			'install uninstall run' '0'		'Action Desc.'
TARGET=												'' 					s			'' '0'		'Action Desc.'
SOURCE=												'' 					s			'' '0'		'Action Desc.'
"
OPTIONS="
FORCE=''				   'f'		  ''					b			0		'1'					  Force.
OPT1='default_val1' 						'' 			'string'				s 			0			''		  Sample option.
OPT2='default_val2' 						'' 			'string'				s 			0			''		  Sample option.
OPT3='' 						'' 			'string'				s 			0			''		  Sample option.
"

echo ORIGINAL ARGUMENTS LINE :
echo "$@"

$STELLA_API argparse "$0" "$OPTIONS" "$PARAMETERS" "$STELLA_APP_NAME" "$(usage)" "EXTRA_PARAMETER extra_parameter EXTRA_ARG_EVAL extra_arg_eval EXTRA_ARG extra_arg" "$@"

#-------------------------------------------------------------------------------------------


# --------------- FOO ----------------------------
if [ "$DOMAIN" = "foo bar" ]; then

	if [ "$ID" = "run" ]; then
		echo --PARAMETERS--
		echo DOMAIN : $DOMAIN
		echo ID : $ID
		echo TARGET : $TARGET
		echo SOURCE : $SOURCE

		echo --OPTIONS--
		echo OPT1 : $OPT1
		echo OPT2 : $OPT2
		echo OPT3 : $OPT3

		echo --EXTRA ARG end PARAMETERS--
		echo extra_parameter : $extra_parameter
		echo extra_arg : $extra_arg
		echo evaluation of extra_arg_eval : $extra_arg_eval
		eval "${extra_arg_eval}"
		i=1
		for a in "$@"; do
			echo $i $a
			((i++))
		done
	fi
fi
