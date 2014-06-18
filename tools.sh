#!/bin/bash
_INCLUDED_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_CALLING_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
source $_INCLUDED_FILE_DIR/conf.sh

function init_tools() {
	echo "** Initialize Tools"
	if [ ! -d "$TOOL_ROOT" ]; then
		mkdir -p "$TOOL_ROOT"
	fi

	if [ "$CURRENT_PLATFORM" == "macos" ]; then
		init_tools_macos
	fi
}

function init_tools_macos {
	# wget
	# TODO use existing function for download/install ?
	if [ ! -f "$TOOL_ROOT/wget/bin/wget" ]; then
		if [ ! -f "$CACHE_DIR/wget-1.15.tar.gz" ]; then
			cd "$CACHE_DIR"
			curl -O http://ftp.gnu.org/gnu/wget/wget-1.15.tar.gz
		fi
		mkdir -p "$TOOL_ROOT/wget"
		cp "$CACHE_DIR/wget-1.15.tar.gz" "$TOOL_ROOT/wget/"
		cd "$TOOL_ROOT/wget/"
		tar -xzf wget-1.15.tar.gz
		cd wget-1.15
		./configure --with-ssl=openssl --prefix="$TOOL_ROOT/wget"
		#./configure --without-ssl --prefix="$TOOL_ROOT/wget"
		make
		make install
	fi

	# getopt 
	# TODO ? https://github.com/Homebrew/homebrew/blob/master/Library/Formula/gnu-getopt.rb
	
	
}






# MAIN ------------------------
PARAMETERS="
ACTION=											'action' 			a						'init install'					Action to compute. 'init' install minimal tools. \
																																	'install' install bonus tool specified by --extra option
"
OPTIONS="
ARCH='x64'				'a'			''					a			0			'x86 x64 arm'			Select architecture.
JOB='1'					'j'			'nb_job'			i			0			'1:100'					Number of jobs used by build tool. (Only for supported build tool)
VERBOSE=$DEFAULT_VERBOSE_MODE		'v'			'level'				i			0			'0:2'					Verbose level : 0 (default) no verbose, 1 verbose, 2 ultraverbose.
EXTRA=''				''			'tool'				a			0			'ninja cmake packer autotools ide perl'		Select tool to install. \
																													(autotools means autoconf, automake, libtool, m4).																			
"

argparse "$0" "$OPTIONS" "$PARAMETERS" "Stella tools management" "Stella tools management" "" "$@"



# common initializations
init_env
BUILD_JOB=$JOB

case $ACTION in
    init)
    	init_tools
    	;;
    install)
		case $EXTRA in
			cmake)
				cmake_install
				;;
			ninja)
				ninja_install
				;;
			packer)
				packer_install
				;;
			autotools)
				autotools_install
				;;
			ide)
				ide_install
				;;
			perl)
				perl_install
				;;

			*)
				echo "use option --help for help"
				;;
		esac
		;;
	*)
		echo "use option --help for help"
		;;
esac


echo "** END **"
