#!/bin/bash
_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
source $_CURRENT_FILE_DIR/stella-link.sh include


STELLA_FTP_HOST=ftp.cluster002.ovh.net
STELLA_FTP_ROOT=$STELLA_FTP_HOST/stella

STELLA_APP_ADMIN=$STELLA_APPLICATION/admin

function usage() {
	echo "USAGE :"
	echo "----------------"
	echo "List of commands"
	echo " o-- Release management :"
	echo " L     lib --platform=<win|nix|all> : pack and push a release from local source code"
	echo " L     pool : push all pool items on distant web repository"
}



function stella_pool_release() {

	rm -Rf $STELLA_APP_WORK_ROOT/$STELLA_POOL_PATH
	__copy_folder_content_into "$STELLA_APP_ADMIN/$STELLA_POOL_PATH" "$STELLA_APP_WORK_ROOT/$STELLA_POOL_PATH"

	pack_goconfig-cli

	# TODO : delete ftp respository first
	cd $STELLA_APP_WORK_ROOT
	_recurse_push_ftp $STELLA_POOL_PATH
}


function stella_lib_release() {
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
		nix)
			release_filename="stella-nix-$version.gz"
			;;
		all)
			release_filename="stella-all-$version.gz"
			;;
	esac

	[ "$_opt_auto_extract" == "ON" ] && release_filename="$release_filename.run"

	pack_stella "$_platform" "$release_filename" "$_opt"

	upload_ftp "$STELLA_APP_WORK_ROOT/output/$release_filename" "$STELLA_DIST_PATH"

	rm -f "$STELLA_ROOT/VERSION"
}



function pack_stella() {
	local _platform=$1
	local _release_filename=$2
	local _opt="$3"

	local _opt_auto_extract=OFF # make a self uncompress archive
	for o in $_opt; do 
		[ "$o" == "AUTO_EXTRACT" ] && _opt_auto_extract=ON
	done

	case $_platform in
		win)
			tar -c -v -z --exclude "*DS_Store" --exclude ".git/" --exclude "*.gitignore*" --exclude "./nix/" --exclude "./app/" --exclude "*.sh" \
		-f "$STELLA_APP_WORK_ROOT/output/$_release_filename" -C "$STELLA_ROOT/.."  "$(basename $STELLA_ROOT)"
		;;

		nix)
			tar -c -v -z --exclude "*DS_Store" --exclude ".git/" --exclude "*.gitignore*" --exclude "./win/" --exclude "./app/" --exclude "*.bat" \
		-f "$STELLA_APP_WORK_ROOT/output/$_release_filename" -C "$STELLA_ROOT/.."  "$(basename $STELLA_ROOT)"
		;;

		all)
			tar -c -v -z --exclude "*DS_Store" --exclude ".git/" --exclude "*.gitignore*" --exclude "./app/" \
		-f "$STELLA_APP_WORK_ROOT/output/$_release_filename" -C "$STELLA_ROOT/.."  "$(basename $STELLA_ROOT)"
		;;
	esac
	
	if [ "$_opt_auto_extract" == "ON" ]; then
		mv "$STELLA_APP_WORK_ROOT/output/$_release_filename" "$STELLA_APP_WORK_ROOT/output/$_release_filename".tmp
		__make_targz_sfx_shell "$STELLA_APP_WORK_ROOT/output/$_release_filename".tmp "$STELLA_APP_WORK_ROOT/output/$_release_filename" "TARGZ"
		rm -Rf "$STELLA_APP_WORK_ROOT/output/$_release_filename".tmp
	fi

}



function pack_goconfig-cli() {
	# Need Go
	GOPATH="$STELLA_APP_WORK_ROOT/go"
	__del_folder "$GOPATH"

	GOPATH="$GOPATH" go get github.com/tools/godep
	GOPATH="$GOPATH" go get github.com/StudioEtrange/goconfig-cli
	cd "$GOPATH"/src/github.com/StudioEtrange/goconfig-cli
	GOPATH="$GOPATH" "$GOPATH"/bin/godep restore

	GOPATH="$GOPATH" go get github.com/laher/goxc
	GOPATH="$GOPATH" "$GOPATH"/bin/goxc -tasks-=package

	mkdir -p "$STELLA_APP_WORK_ROOT/$STELLA_POOL_PATH"/win/repository/goconfig-cli/
	cp "$GOPATH"/bin/goconfig-cli-xc/snapshot/windows_386/goconfig-cli.exe "$STELLA_APP_WORK_ROOT/$STELLA_POOL_PATH"/win/repository/goconfig-cli/

	upx "$STELLA_APP_WORK_ROOT/$STELLA_POOL_PATH"/win/repository/goconfig-cli/goconfig-cli.exe
}







function _upload_ftp() {
	local _file=$1
	local _ftp_path=$2/

	curl --ftp-create-dirs --netrc-file $HOME/stella_credentials -T $_file ftp://$STELLA_FTP_ROOT/$_ftp_path
}

function _recurse_push_ftp() {
	for f in  "$1"/*; do
		[ -d "$f" ] && _recurse_push_ftp "$f"
		[ -f "$f" ] && _upload_ftp "$f" "$(dirname $f)"
	done
}

# ARGUMENTS -----------------------------------------------------------------------------------
PARAMETERS="
ACTION=						'action' 			a						'lib pool'					Action.
"
OPTIONS="
PLATFORM='all'				''			''					'a'			0			'win nix all'			Target platform.
"

__argparse "$0" "$OPTIONS" "$PARAMETERS" "Release management" "$(usage)" "" "$@"

# common initializations
__init_stella_env

# MAIN -----------------------------------------------------------------------------------

rm -Rf $STELLA_APP_WORK_ROOT/output
mkdir -p $STELLA_APP_WORK_ROOT/output



case $ACTION in
    lib)
		stella_lib_release $PLATFORM AUTO_EXTRACT
		;;
	pool)
		stella_pool_release
		;;
	*)
		echo "use option --help for help"
		;;
esac


echo "** END **"