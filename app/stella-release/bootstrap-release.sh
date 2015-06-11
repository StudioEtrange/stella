#!/bin/bash

# USE with crontab or with download
# bootstrap-release.sh [<CURRENT|version>]
# example :
# 	curl -sSL https://raw.githubusercontent.com/StudioEtrange/stella/master/app/stella-release/bootstrap-release.sh | bash
_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"

current_stella=$_STELLA_LINK_CURRENT_FILE_DIR/../../../stella
if [ ! -f "$current_stella/stella.sh" ]; then
	mkdir -p "$_CURRENT_FILE_DIR/workspace"
	cd "$_CURRENT_FILE_DIR/workspace"
	git clone https://github.com/StudioEtrange/stella

	current_stella="$_CURRENT_FILE_DIR/workspace/stella"
fi

ver=$1

$current_stella/app/stella-release/release.sh install
$current_stella/app/stella-release/release.sh stella-release --ver=$ver

echo "** END **"