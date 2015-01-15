#!/bin/bash
_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $_CURRENT_FILE_DIR/stella-bridge.sh include


function usage() {
	echo "USAGE :"
	echo "----------------"
	echo "List of commands"
	echo " o-- Feature management :"
	echo " L     install required : install minimal required features for Stella"
	echo " L     install <feature name> --vers=<version> : install a feature. Version is optional"
	echo " L     <all|feature name> : list all available features OR available versions of a feature"
}


function pack() {
	tar -c -v -z --exclude "*DS_Store" --exclude ".git/" --exclude ".gitignore" --exclude "./win/" --exclude "./admin/" --exclude "*.bat" \
		-f "$_CURRENT_FILE_DIR/output/stella-nix-$version.gz" -C "$STELLA_ROOT" .

}


# ARGUMENTS -----------------------------------------------------------------------------------
PARAMETERS="
ACTION=						'action' 			a						'pack'					Action.
"
OPTIONS="
OPT1='default val'							'o'			''					'a'			0			'val1 val2 val3'			Option 1 description.
"

$STELLA_API argparse "$0" "$OPTIONS" "$PARAMETERS" "Release app" "$(usage)" "" "$@"


# MAIN -----------------------------------------------------------------------------------

rm -Rf $_CURRENT_FILE_DIR/output
mkdir -p $_CURRENT_FILE_DIR/output

version=$($STELLA_API get_stella_version)

case $ACTION in
    pack)
		pack
		;;
	*)
		echo "use option --help for help"
		;;
esac


echo "** END **"