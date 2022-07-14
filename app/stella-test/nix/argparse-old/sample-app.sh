#!/bin/bash
_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_CURRENT_RUNNING_DIR="$( cd "$( dirname "." )" && pwd )"
. $_CURRENT_FILE_DIR/stella-link.sh include

# TEST with
# ./nix/test/argparse/sample-app.sh
# SHOULD FAIL



# ./nix/test/argparse/sample-app.sh "foo bar" run
#ORIGINAL ARGUMENTS LINE :
#foo bar run
#--PARAMETERS--
#DOMAIN : foo bar
#ID : run
#TARGET :
#SOURCE :
#--OPTIONS--
#OPT1 : default_val1
#OPT2 : default_val2
#OPT3 :
#--EXTRA ARG end PARAMETERS--
#extra_parameter : ''
#extra_arg :
#evaluation of extra_arg_eval : set --



# ./nix/test/argparse/sample-app.sh "foo bar" --opt1="'a b'" --opt2 "a b" run "'target'"
# ./nix/test/argparse/sample-app.sh "foo bar" --opt1="'a b'" --opt2 "a b" run "'target'" source "other param" '"another"'
# ./nix/test/argparse/sample-app.sh "foo bar" run --  bash -c "'a b'" 'd e' '"c ee"' f
# ./nix/test/argparse/sample-app.sh "foo bar" --opt1="'a b'" --opt2 "a b" run "'target'" --  bash -c "'a b'" 'd e' '"c ee"' f



# ./nix/test/argparse/sample-app.sh "foo bar" --opt1="'a b'" --opt2 "a b" run "'target'" source "other param" '"another"' --  bash -c "'a b'" 'd e' '"c ee"' f
#ORIGINAL ARGUMENTS LINE :
#foo bar --opt1='a b' --opt2 a b run 'target' source other param "another" -- bash -c 'a b' d e "c ee" f
#--PARAMETERS--
#DOMAIN : foo bar
#ID : run
#TARGET : 'target'
#SOURCE : source
#--OPTIONS--
#OPT1 : 'a b'
#OPT2 : a b
#OPT3 :
#--EXTRA ARG end PARAMETERS--
#extra_parameter : 'other param' '"another"'
#extra_arg : bash -c 'a b' d e "c ee" f
#evaluation of extra_arg_eval : set -- 'bash' '-c' ''\''a b'\''' 'd e' '"c ee"' 'f'
#1 bash
#2 -c
#3 'a b'
#4 d e
#5 "c ee"
#6 f



# ./nix/test/argparse/sample-app.sh "foo bar" --  bash -c "'a b'" 'd e' '"c ee"' f
# SHOUD FAIL



# ./nix/test/argparse/sample-app.sh "foo bar" "run" --  echo "'a b'" 'd e' '"c ee"' f



# ./nix/test/argparse/sample-app.sh "foo bar" "run" --opt1="exec" --  echo "'a b'" 'd e' '"c ee"' f
#ORIGINAL ARGUMENTS LINE :
#foo bar run --opt1=exec -- echo 'a b' d e "c ee" f
#--PARAMETERS--
#DOMAIN : foo bar
#ID : run
#TARGET :
#SOURCE :
#--OPTIONS--
#OPT1 : exec
#OPT2 : default_val2
#OPT3 :
#--EXTRA ARG end PARAMETERS--
#extra_parameter :
#extra_arg : echo 'a b' d e "c ee" f
#evaluation of extra_arg_eval : set -- 'echo' ''\''a b'\''' 'd e' '"c ee"' 'f'
#1 echo
#2 'a b'
#3 d e
#4 "c ee"
#5 f
#Try to exec extra arg : echo 'a b' d e "c ee" f
#using extra arg eval before
#a b d e c ee f




# ./nix/test/argparse/sample-app.sh "foo bar" run --opt1="exec" -- bash -c '"echo a b d e c ee f"'
#ORIGINAL ARGUMENTS LINE :
#foo bar run --opt1=exec -- bash -c "echo a b d e c ee f"
#--PARAMETERS--
#DOMAIN : foo bar
#ID : run
#TARGET :
#SOURCE :
#--OPTIONS--
#OPT1 : exec
#OPT2 : default_val2
#OPT3 :
#--EXTRA ARG end PARAMETERS--
#extra_parameter :
#extra_arg : bash -c "echo a b d e c ee f"
#evaluation of extra_arg_eval : set -- 'bash' '-c' '"echo a b d e c ee f"'
#1 bash
#2 -c
#3 "echo a b d e c ee f"
#Try to exec extra arg : bash -c "echo a b d e c ee f"
#using extra arg eval before
#a b d e c ee f



# ./nix/test/argparse/sample-app.sh "foo bar" "run" --opt1="exec" --  '$STELLA_API' list_feature_version bindfs
#ORIGINAL ARGUMENTS LINE :
#foo bar run --opt1=exec -- $STELLA_API list_feature_version bindfs
#--PARAMETERS--
#DOMAIN : foo bar
#ID : run
#TARGET :
#SOURCE :
#--OPTIONS--
#OPT1 : exec
#OPT2 : default_val2
#OPT3 :
#--EXTRA ARG end PARAMETERS--
#extra_parameter :
#extra_arg : $STELLA_API list_feature_version bindfs
#evaluation of extra_arg_eval : set -- '$STELLA_API' 'list_feature_version' 'bindfs'
#1 $STELLA_API
#2 list_feature_version
#3 bindfs
#Try to exec extra arg : $STELLA_API list_feature_version bindfs
#using extra arg eval before
#1_14_1:source 1_13_11:source 1_13_10:source





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

		if [ "$OPT1" = "exec" ]; then
			echo Try to exec extra arg : $extra_arg
			echo using extra arg eval before
			eval "${extra_arg_eval}"
			eval "$@"
		fi
	fi


fi
