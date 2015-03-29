#!/bin/bash
_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
source $_CURRENT_FILE_DIR/stella-link.sh include


STELLA_FTP_HOST=ftp.cluster002.ovh.net
STELLA_FTP_ROOT=$STELLA_FTP_HOST/stella

STELLA_ADMIN=$STELLA_APPLICATION/admin

function usage() {
	echo "USAGE :"
	echo "----------------"
	echo "List of commands"
	echo " o-- Release management :"
	echo " L     dist [--upload] : pack all stella distribution package for each platform"
	echo " L     items : push all stella items on distant web repository"
	echo " L     dep : download dependencies for this tool"

}


# ----------- Main functions ----------------

function stella_items_release() {

	rm -Rf $STELLA_APP_WORK_ROOT/$STELLA_POOL_PATH
	__copy_folder_content_into "$STELLA_ADMIN/pool" "$STELLA_APP_WORK_ROOT/pool"

	pack_goconfig-cli

	# TODO : delete ftp respository first
	cd $STELLA_APP_WORK_ROOT
	_recurse_push_ftp pool
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
			release_filename="stella-win-$version"	
			;;
		nix)
			release_filename="stella-nix-$version"
			;;
		all)
			release_filename="stella-all-$version"
			;;
	esac

	pack_stella "$_platform" "$release_filename" "$_opt"

	[ "$_opt_upload" == "ON" ] && _upload_ftp "$STELLA_APP_WORK_ROOT/output/$release_filename" "dist"

	rm -f "$STELLA_ROOT/VERSION"
}


# --------------------------- stella packaging ------------------------------------

function pack_stella() {
	local _platform=$1
	local _release_filename=$2
	local _opt="$3"

	local _opt_auto_extract=OFF # make a self uncompress archive
	for o in $_opt; do 
		[ "$o" == "AUTO_EXTRACT" ] && _opt_auto_extract=ON
	done

	# DISTRIBUTIONS PACKAGE FOR NIX SYSTEM WITH tar.gz
	case $_platform in
		win)
			tar -c -v -z --exclude "*DS_Store" --exclude ".git/" --exclude "*.gitignore*" --exclude "./cache/" --exclude "./workspace/" --exclude "./temp/" --exclude "./nix/" --exclude "./app/" --exclude "*.sh" \
		-f "$STELLA_APP_WORK_ROOT/output/$_release_filename".tar.gz -C "$STELLA_ROOT/.."  "$(basename $STELLA_ROOT)"
		;;

		nix)
			tar -c -v -z --exclude "*DS_Store" --exclude ".git/" --exclude "*.gitignore*" --exclude "./cache/" --exclude "./workspace/" --exclude "./temp/" --exclude "./win/" --exclude "./app/" --exclude "*.bat" \
		-f "$STELLA_APP_WORK_ROOT/output/$_release_filename".tar.gz -C "$STELLA_ROOT/.."  "$(basename $STELLA_ROOT)"
		;;

		all)
			tar -c -v -z --exclude "*DS_Store" --exclude ".git/" --exclude "*.gitignore*" --exclude "./cache/" --exclude "./workspace/" --exclude "./temp/" --exclude "./app/" \
		-f "$STELLA_APP_WORK_ROOT/output/$_release_filename".tar.gz -C "$STELLA_ROOT/.."  "$(basename $STELLA_ROOT)"
		;;
	esac
	


	if [ "$_opt_auto_extract" == "ON" ]; then
		__make_targz_sfx_shell "$STELLA_APP_WORK_ROOT/output/$_release_filename".tar.gz "$STELLA_APP_WORK_ROOT/output/$_release_filename".tar.gz.run "TARGZ"
	fi

# 	# DISTRIBUTIONS PACKAGE FOR WIN SYSTEM WITH 7Z
	case $_platform in
		win)
			7z a -t7z "$STELLA_APP_WORK_ROOT/output/$_release_filename".7z \
			-xr\!"*DS_Store" -xr0\!"stella/.stella-env" -xr\!".git" -xr\!"*.gitignore*" -xr0\!"stella/cache" -xr0\!"stella/workspace" -xr0\!"stella/temp" -xr0\!"stella/app" -xr0\!"stella/nix" -xr\!"*.sh" \
			"$STELLA_ROOT"
		;;
		nix)
			7z a -t7z "$STELLA_APP_WORK_ROOT/output/$_release_filename".7z \
			-xr\!"*DS_Store" -xr0\!"stella/.stella-env" -xr\!".git" -xr\!"*.gitignore*" -xr0\!"stella/cache" -xr0\!"stella/workspace" -xr0\!"stella/temp" -xr0\!"stella/app" -xr0\!"stella/win" -xr\!"*.bat" \
			"$STELLA_ROOT"
		;;
		all)
			7z a -t7z "$STELLA_APP_WORK_ROOT/output/$_release_filename".7z \
			-xr\!"*DS_Store" -xr0\!"stella/.stella-env" -xr\!".git" -xr\!"*.gitignore*" -xr0\!"stella/cache" -xr0\!"stella/workspace" -xr0\!"stella/temp" -xr0\!"stella/app" \
			"$STELLA_ROOT"
		;;
	esac

	if [ "$_opt_auto_extract" == "ON" ]; then
		__make_targz_sfx_shell "$STELLA_APP_WORK_ROOT/output/$_release_filename".7z "$STELLA_APP_WORK_ROOT/output/$_release_filename".7z.exe win "7Z"
	fi
}


# -------------------- STELLA ITEM packaging -------------------------------

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





# ----------------------- FTP FUNCTIONS -------------------

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
ACTION=						'action' 			a						'dep dist item'					action.
"
OPTIONS="
UPLOAD=''                   'u'    		''            		b     		0     		'1'           			upload.
"

__argparse "$0" "$OPTIONS" "$PARAMETERS" "Release management" "$(usage)" "" "$@"

# common initializations
__init_stella_env

# MAIN -----------------------------------------------------------------------------------

rm -Rf $STELLA_APP_WORK_ROOT/output
mkdir -p $STELLA_APP_WORK_ROOT/output

[ "$UPLOAD" == "1" ] && UPLOAD=UPLOAD

case $ACTION in
	dep)
		$STELLA_API get_features
		__copy_folder_content_into "$STELLA_ADMIN/pool/common/sfx_for_7z" "$STELLA_APP_CACHE_DIR"
		;;
    dist)
		stella_lib_release nix "AUTO_EXTRACT $UPLOAD"
		stella_lib_release win "AUTO_EXTRACT $UPLOAD"
		stella_lib_release all "AUTO_EXTRACT $UPLOAD"
		;;
	items)
		stella_items_release
		;;
	*)
		echo "use option --help for help"
		;;
esac


echo "** END **"