#!/bin/bash

# USE in crontab or with download
# bootstrap-release.sh [<CURRENT|version>]
# example :
# 	curl -sSL https://raw.githubusercontent.com/StudioEtrange/stella/master/app/stella-release/bootstrap-release.sh | bash
# requirement:
#	7z
_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_CURRENT_RUNNING_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"


current_stella=$_STELLA_LINK_CURRENT_FILE_DIR/../../../stella
if [ ! -f "$current_stella/stella.sh" ]; then
	mkdir -p "$_CURRENT_FILE_DIR/bootstrap-stella-release"
	cd "$_CURRENT_FILE_DIR/bootstrap-stella-release"
	git clone https://github.com/StudioEtrange/stella
	cd stella
	git pull
	current_stella="$_CURRENT_FILE_DIR/bootstrap-stella-release/stella"
fi

ver=$1

$current_stella/app/stella-release/release.sh install
$current_stella/app/stella-release/release.sh stella-release --ver=$ver

echo "** END **"