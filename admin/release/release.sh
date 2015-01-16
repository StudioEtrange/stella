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


function do_release() {
	local _platform=$1
	local _opt="$2"

	local release_filename

	local _opt_auto_extract=OFF # make a self uncompress archive
	local _opt_upload=OFF # upload release file
	for o in $_opt; do 
		[ "$o" == "AUTO_EXTRACT" ] && _opt_auto_extract=ON
		[ "$o" == "UPLOAD" ] && _opt_upload=ON
	done

	version=$(__get_stella_version)
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

	pack "$_platform" "$release_filename" "$_opt"

	[ "$_opt_auto_extract" == "ON" ] && release_filename="$release_filename.sh"

	upload "$_STELLA_CURRENT_FILE_DIR/output/$release_filename"
}


function pack() {
	local _platform=$1
	local _release_filename=$2
	local _opt="$3"

	local result_file

	local _opt_auto_extract=OFF # make a self uncompress archive
	for o in $_opt; do 
		[ "$o" == "AUTO_EXTRACT" ] && _opt_auto_extract=ON
	done

	echo "#!/bin/bash" > "$_STELLA_CURRENT_FILE_DIR/output/header"
	echo "ARCHIVE=\`awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0; }' \$0\`" >> "$_STELLA_CURRENT_FILE_DIR/output/header"
	echo "tail -n+\$ARCHIVE \$0 | tar xzv -C ." >> "$_STELLA_CURRENT_FILE_DIR/output/header"
	echo "exit 0" >> "$_STELLA_CURRENT_FILE_DIR/output/header"
	echo "__ARCHIVE_BELOW__" >> "$_STELLA_CURRENT_FILE_DIR/output/header"

	case $_platform in
		win)
			tar -c -v -z --exclude "*DS_Store" --exclude ".git/" --exclude "*.gitignore*" --exclude "./nix/" --exclude "./admin/" --exclude "*.sh" \
		-f "$_STELLA_CURRENT_FILE_DIR/output/$_release_filename" -C "$STELLA_ROOT" .

			[ "$_opt_auto_extract" == "ON" ]  && cat "$_STELLA_CURRENT_FILE_DIR/output/header" "$_STELLA_CURRENT_FILE_DIR/output/$_release_filename" > "$_STELLA_CURRENT_FILE_DIR/output/$_release_filename".sh
		;;

		nix)
			result_file="stella-nix-$version.gz"
			tar -c -v -z --exclude "*DS_Store" --exclude ".git/" --exclude "*.gitignore*" --exclude "./win/" --exclude "./admin/" --exclude "*.bat" \
		-f "$_STELLA_CURRENT_FILE_DIR/output/$_release_filename" -C "$STELLA_ROOT" .

			[ "$_opt_auto_extract" == "ON" ]  && cat "$_STELLA_CURRENT_FILE_DIR/output/header" "$_STELLA_CURRENT_FILE_DIR/output/$_release_filename" > "$_STELLA_CURRENT_FILE_DIR/output/$_release_filename".sh
		;;

		all)
			result_file="stella-all-$version.gz"
			tar -c -v -z --exclude "*DS_Store" --exclude ".git/" --exclude "*.gitignore*" --exclude "./admin/" \
		-f "$_STELLA_CURRENT_FILE_DIR/output/$_release_filename" -C "$STELLA_ROOT" .

			[ "$_opt_auto_extract" == "ON" ]  && cat "$_STELLA_CURRENT_FILE_DIR/output/header" "$_STELLA_CURRENT_FILE_DIR/output/$_release_filename" > "$_STELLA_CURRENT_FILE_DIR/output/$_release_filename".sh
		;;
	esac
	
	rm -Rf "$_STELLA_CURRENT_FILE_DIR/output/header"
	chmod +x $_STELLA_CURRENT_FILE_DIR/output/*.sh 2>/dev/null

}

function upload() {
	local _file=$1
	curl --ftp-create-dirs --netrc-file $_STELLA_CURRENT_FILE_DIR/credentials -T $_file ftp://ftp.cluster014.ovh.net/www/stella/
}


# ARGUMENTS -----------------------------------------------------------------------------------
PARAMETERS="
ACTION=						'action' 			a						'do'					Action.
"
OPTIONS="
PLATFORM='all'				''			''					'a'			0			'win nix'			Target platform.
"

__argparse "$0" "$OPTIONS" "$PARAMETERS" "Release management" "$(usage)" "" "$@"

# common initializations
__init_stella_env

# MAIN -----------------------------------------------------------------------------------

rm -Rf $_STELLA_CURRENT_FILE_DIR/output
mkdir -p $_STELLA_CURRENT_FILE_DIR/output



case $ACTION in
    do)
		do_release $PLATFORM AUTO_EXTRACT
		;;
	*)
		echo "use option --help for help"
		;;
esac


echo "** END **"