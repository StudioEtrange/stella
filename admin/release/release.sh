#!/bin/bash
_STELLA_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_STELLA_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
source $_STELLA_CURRENT_FILE_DIR/../../conf.sh


function usage() {
	echo "USAGE :"
	echo "----------------"
	echo "List of commands"
	echo " o-- Release management :"
	echo " L     do --platform=<win|nix|all> : pack and push a release"
}


function release_from_local() {
	local _platform=$1
	local _opt="$2"

	local release_filename

	local _opt_auto_extract=OFF # make a self uncompress archive
	local _opt_upload=OFF # upload release file
	for o in $_opt; do 
		[ "$o" == "AUTO_EXTRACT" ] && _opt_auto_extract=ON
		[ "$o" == "UPLOAD" ] && _opt_upload=ON
	done

	version=$(__get_stella_version "LONG")
	echo $version > "$STELLA_ROOT/VERSION"

	case $_platform in
		win)
			release_filename="stella-win-$version.gz"	
			;;
		linux|macos)
			release_filename="stella-nix-$version.gz"
			;;
		all)
			release_filename="stella-all-$version.gz"
			;;
	esac

	[ "$_opt_auto_extract" == "ON" ] && release_filename="$release_filename.run"

	pack "$_platform" "$release_filename" "$_opt"

	upload_ftp "$STELLA_APP_WORK_ROOT/output/$release_filename" "dist"

	rm -f "$STELLA_ROOT/VERSION"
}


function pack() {
	local _platform=$1
	local _release_filename=$2
	local _opt="$3"

	local _opt_auto_extract=OFF # make a self uncompress archive
	for o in $_opt; do 
		[ "$o" == "AUTO_EXTRACT" ] && _opt_auto_extract=ON
	done

	case $_platform in
		win)
			tar -c -v -z --exclude "*DS_Store" --exclude ".git/" --exclude "*.gitignore*" --exclude "./nix/" --exclude "./test/" --exclude "./admin/" --exclude "*.sh" \
		-f "$STELLA_APP_WORK_ROOT/output/$_release_filename" -C "$STELLA_ROOT/.."  "$(basename $STELLA_ROOT)"
		;;

		linux|macos)
			tar -c -v -z --exclude "*DS_Store" --exclude ".git/" --exclude "*.gitignore*" --exclude "./win/" --exclude "./test/" --exclude "./admin/" --exclude "*.bat" \
		-f "$STELLA_APP_WORK_ROOT/output/$_release_filename" -C "$STELLA_ROOT/.."  "$(basename $STELLA_ROOT)"
		;;

		all)
			tar -c -v -z --exclude "*DS_Store" --exclude ".git/" --exclude "*.gitignore*" --exclude "./test/" --exclude "./admin/" \
		-f "$STELLA_APP_WORK_ROOT/output/$_release_filename" -C "$STELLA_ROOT/.."  "$(basename $STELLA_ROOT)"
		;;
	esac
	
	if [ "$_opt_auto_extract" == "ON" ]; then
		mv "$STELLA_APP_WORK_ROOT/output/$_release_filename" "$STELLA_APP_WORK_ROOT/output/$_release_filename".tmp
		__make_targz_sfx_shell "$STELLA_APP_WORK_ROOT/output/$_release_filename".tmp "$STELLA_APP_WORK_ROOT/output/$_release_filename" "TARGZ"
		rm -Rf "$STELLA_APP_WORK_ROOT/output/$_release_filename".tmp
	fi

}

function upload_ftp() {
	local _file=$1
	local _ftp_path=$2/

	curl --ftp-create-dirs --netrc-file $_STELLA_CURRENT_FILE_DIR/credentials -T $_file ftp://ftp.cluster014.ovh.net/stella/$_ftp_path
}




function push_repository() {
	# TODO : delete ftp respository first
	cd $STELLA_ADMIN
	for f in respository/* repository/**/*; do
		[ -f "$f" ] && upload_ftp "$f" "$(dirname $f)"
	done
}

# ARGUMENTS -----------------------------------------------------------------------------------
PARAMETERS="
ACTION=						'action' 			a						'local repository'					Action.
"
OPTIONS="
PLATFORM='all'				''			''					'a'			0			'win linux macos all'			Target platform.
"

__argparse "$0" "$OPTIONS" "$PARAMETERS" "Release management" "$(usage)" "" "$@"

# common initializations
__init_stella_env

# MAIN -----------------------------------------------------------------------------------

rm -Rf $STELLA_APP_WORK_ROOT/output
mkdir -p $STELLA_APP_WORK_ROOT/output



case $ACTION in
    local)
		release_from_local $PLATFORM AUTO_EXTRACT
		;;
	repository)
		push_repository
		;;
	*)
		echo "use option --help for help"
		;;
esac


echo "** END **"