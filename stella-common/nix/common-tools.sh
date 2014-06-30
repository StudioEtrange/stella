if [ ! "$_COMMON_EXTRA_INCLUDED_" == "1" ]; then 
_COMMON_EXTRA_INCLUDED_=1


# EXTRA TOOLS---------------------------------------------------
function ninja_install() {
	URL="https://github.com/martine/ninja/archive/release.zip"
	VER="last release"
	FILE_NAME=ninja-release.zip
	INSTALL_DIR="$TOOL_ROOT/ninja-release"

	echo " ** Installing ninja in $INSTALL_DIR"
	echo " ** NEED : python"

	feature_last_ninja
	if [ "$FORCE" ]; then
		TEST_FEATURE=0
		del_folder $INSTALL_DIR
	fi
	if [ "$TEST_FEATURE" == "0" ]; then
		download_uncompress "$URL" "$FILE_NAME" "$INSTALL_DIR" "DEST_ERASE STRIP"

		#TODO
		#prerequites python

		cd "$INSTALL_DIR"
		python ./bootstrap.py

		feature_last_ninja
		if [ ! "$TEST_FEATURE" == "0" ]; then
			echo " ** Ninja installed"
			"$TEST_FEATURE/ninja" --version
		else
			echo "** ERROR"
		fi
	else
		echo " ** Already installed"
	fi
}
function feature_last_ninja() {
	TEST_FEATURE=0
	if [ -f "$TOOL_ROOT/ninja-release/ninja" ]; then
		TEST_FEATURE="$TOOL_ROOT/ninja-release"
	fi

	if [ ! "$TEST_FEATURE" == "0" ]; then
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : ninja in $TEST_FEATURE"
		NINJA_MAKE_CMD="$TEST_FEATURE/./$NINJA_MAKE_CMD"
		NINJA_MAKE_CMD_VERBOSE="$TEST_FEATURE/./$NINJA_MAKE_CMD_VERBOSE"
		NINJA_MAKE_CMD_VERBOSE_ULTRA="$TEST_FEATURE/./$NINJA_MAKE_CMD_VERBOSE_ULTRA"
		FEATURE_PATH="$TEST_FEATURE"
	fi
}





function cmake_install() {
	URL=http://www.cmake.org/files/v2.8/cmake-2.8.12.tar.gz
	VER=2.8.12
	FILE_NAME=cmake-2.8.12.tar.gz
	INSTALL_DIR="$TOOL_ROOT/cmake/cmake-$VER"
	SRC_DIR="$TOOL_ROOT/cmake/cmake-$VER-src"
	BUILD_DIR="$TOOL_ROOT/cmake/cmake-$VER-build"


	echo " ** Installing cmake version $VER in $INSTALL_DIR"
	echo " ** NEED : cURL-7.32.0, libarchive-3.1.2 and expat-2.1.0"

	#TODO
	#prerequires Recommended cURL-7.32.0, libarchive-3.1.2 and expat-2.1.0

	feature_cmake
	if [ "$FORCE" ]; then
		TEST_FEATURE=0
		del_folder $INSTALL_DIR
	fi
	if [ "$TEST_FEATURE" == "0" ]; then

		download_uncompress "$URL" "$FILE_NAME" "$SRC_DIR" "DEST_ERASE STRIP"

		rm -Rf "$BUILD_DIR"
		mkdir -p "$INSTALL_DIR"
		rm -Rf "$BUILD_DIR"
		mkdir -p "$BUILD_DIR"
		cd "$BUILD_DIR"

		chmod +x $SRC_DIR/bootstrap
		$SRC_DIR/bootstrap --prefix="$INSTALL_DIR"
		#cmake "$SRC_DIR" -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR"
		make -j$BUILD_JOB 
		make install


		feature_cmake
		if [ ! "$TEST_FEATURE" == "0" ]; then
			echo " ** CMake installed"
			"$TEST_FEATURE/bin/cmake" --version
		else
			echo "** ERROR"
		fi
	else
		echo " ** Already installed"
	fi

}
function feature_cmake() {
	TEST_FEATURE=0
	if [ -f "$TOOL_ROOT/cmake/cmake-2.8.12/bin/cmake" ]; then
		TEST_FEATURE="$TOOL_ROOT/cmake/cmake-2.8.12"
	fi

	if [ ! "$TEST_FEATURE" == "0" ]; then
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : cmake in $TEST_FEATURE"
		CMAKE_CMD="$TEST_FEATURE/bin/$CMAKE_CMD"
		CMAKE_CMD_VERBOSE="$TEST_FEATURE/bin/$CMAKE_CMD_VERBOSE"
		CMAKE_CMD_VERBOSE_ULTRA="$TEST_FEATURE/bin/$CMAKE_CMD_VERBOSE_ULTRA"
		FEATURE_PATH="$TEST_FEATURE/bin"
	fi
}


function packer_install() {
	if [ "$CURRENT_PLATFORM" == "macos" ]; then
		if [ "$ARCH" == "x64" ]; then
			URL=https://dl.bintray.com/mitchellh/packer/0.6.0_darwin_amd64.zip
			FILE_NAME=0.6.0_darwin_amd64.zip
		else
			URL=https://dl.bintray.com/mitchellh/packer/0.6.0_darwin_386.zip
			FILE_NAME=0.6.0_darwin_386.zip
		fi
	else
		if [ "$ARCH" == "x64" ]; then
			URL=https://dl.bintray.com/mitchellh/packer/0.6.0_linux_amd64.zip
			FILE_NAME=0.6.0_linux_amd64.zip
		else
			URL=https://dl.bintray.com/mitchellh/packer/0.6.0_linux_386.zip
			FILE_NAME=0.6.0_linux_386.zip
		fi
	fi
	VER=0.6.0
	INSTALL_DIR="$TOOL_ROOT/packer-$VER"
	
	echo " ** Installing packer version $VER in $INSTALL_DIR"
	
	feature_packer
	if [ "$FORCE" ]; then
		TEST_FEATURE=0
		del_folder $INSTALL_DIR
	fi
	if [ "$TEST_FEATURE" == "0" ]; then

		download_uncompress "$URL" "$FILE_NAME" "$INSTALL_DIR" "DEST_ERASE STRIP"
		
		feature_packer
		if [ ! "$TEST_FEATURE" == "0" ]; then
			cd $INSTALL_DIR
			chmod +x *
			echo " ** Packer installed"
			"$TEST_FEATURE/packer" --version
		else
			echo "** ERROR"
		fi
	else
		echo " ** Already installed"
	fi
}
function feature_packer() {
	TEST_FEATURE=0
	if [ -f "$TOOL_ROOT/packer-0.6.0/packer" ]; then
		TEST_FEATURE="$TOOL_ROOT/packer-0.6.0"
	fi

	if [ ! "$TEST_FEATURE" == "0" ]; then
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : packer in $TEST_FEATURE"
		PACKER_CMD="$TEST_FEATURE/./$PACKER_CMD"
		FEATURE_PATH="$TEST_FEATURE"
	fi
}


function perl_install() { 
	URL=http://www.cpan.org/src/5.0/perl-5.18.2.tar.gz
	VER=5.18.2
	FILE_NAME=perl-5.18.2.tar.gz
	INSTALL_DIR="$TOOL_ROOT/perl"
	SRC_DIR="$TOOL_ROOT/perl/code/perl-$VER-src"
	BUILD_DIR=

	CONFIGURE_FLAG_PREFIX=
	CONFIGURE_FLAG_POSTFIX=

	feature_perl
	if [ "$FORCE" ]; then
		TEST_FEATURE=0
		del_folder $INSTALL_DIR
	fi
	if [ "$TEST_FEATURE" == "0" ]; then
		download_uncompress "$URL" "$FILE_NAME" "$SRC_DIR" "DEST_ERASE STRIP"

		rm -Rf "$BUILD_DIR"
		mkdir -p "$INSTALL_DIR"
		cd "$SRC_DIR"

		sh "$SRC_DIR/Configure" -des -Dprefix=$INSTALL_DIR \
	                  -Dvendorprefix=$INSTALL_DIR \
	                  -Dpager="/usr/bin/less -isR"  \
	                  -Duseshrplib

		make -j$BUILD_JOB
		make install

		feature_perl
		if [ ! "$TEST_FEATURE" == "0" ]; then
			echo " ** Perl installed"
			"$TEST_FEATURE/bin/perl" --version
		else
			echo "** ERROR"
		fi

	else
		echo " ** Already installed"
	fi
}
function feature_perl() {
	TEST_FEATURE=0
	if [ -f "$TOOL_ROOT/perl/bin/perl" ]; then
		TEST_FEATURE="$TOOL_ROOT/perl"
	fi

	if [ ! "$TEST_FEATURE" == "0" ]; then
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : perl in $TEST_FEATURE"
		FEATURE_PATH="$TEST_FEATURE/bin"
	fi

}


# AUTOTOOLS---------------------------------------------------
function autotools_install() {
	[ "$FORCE" ] && rm -Rf "$TOOL_ROOT/autotools"
	[ ! -d "$TOOL_ROOT/autotools" ] && mkdir -p "$TOOL_ROOT/autotools"
	# order is important
	# see http://petio.org/tools.html
	m4_1417_install
	init_features "feature_m4_1417"
	autoconf269_install
	init_features "feature_autoconf269"
	automake114_install
	init_features "feature_automake114"
	libtool242_install
	init_features "feature_libtool242"
}
function feature_autotools() {
	TEST_FEATURE=0
	if [ -f "$TOOL_ROOT/autotools/bin/autoconf" ]; then
		TEST_FEATURE="$TOOL_ROOT/autotools/bin"
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : autotools in $TEST_FEATURE"
		FEATURE_PATH="$TEST_FEATURE"
	fi
}

function autoconf269_install() {
	URL=http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
	VER=2.69
	FILE_NAME=autoconf-2.69.tar.gz
	INSTALL_DIR="$TOOL_ROOT/autotools"
	SRC_DIR="$TOOL_ROOT/autotools/code/autoconf-$VER-src"
	BUILD_DIR="$TOOL_ROOT/autotools/code/autoconf-$VER-build"

	echo " ** NEED : perl 5.6"
	init_features "feature_perl"

	CONFIGURE_FLAG_PREFIX=
	CONFIGURE_FLAG_POSTFIX="--docdir=$INSTALL_DIR/share/doc/automake-1.14"

	feature_autoconf269
	[ "$FORCE" ] && TEST_FEATURE=0
	if [ "$TEST_FEATURE" == "0" ]; then
		_auto_install "configure" "autoconf" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"
	else
		echo " ** Already installed"
	fi
}
function feature_autoconf269() {
	TEST_FEATURE=0
	if [ -f "$TOOL_ROOT/autotools/bin/autoconf" ]; then
		TEST_FEATURE="$TOOL_ROOT/autotools/bin"
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : autoconf in $TEST_FEATURE"
		$TEST_FEATURE/autoconf --version | sed -ne "1,1p"
		FEATURE_PATH="$TEST_FEATURE"
	fi
}


function automake114_install() {
	URL=http://ftp.gnu.org/gnu/automake/automake-1.14.tar.gz
	VER=1.14
	FILE_NAME=automake-1.14.tar.gz
	INSTALL_DIR="$TOOL_ROOT/autotools"
	SRC_DIR="$TOOL_ROOT/autotools/code/automake-$VER-src"
	BUILD_DIR="$TOOL_ROOT/autotools/code/automake-$VER-build"

	CONFIGURE_FLAG_PREFIX=
	CONFIGURE_FLAG_POSTFIX="--docdir=$INSTALL_DIR/share/doc/automake-1.14"

	feature_automake114
	[ "$FORCE" ] && TEST_FEATURE=0
	if [ "$TEST_FEATURE" == "0" ]; then
		_auto_install "configure" "automake" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"
	else
		echo " ** Already installed"
	fi
}
function feature_automake114() {
	TEST_FEATURE=0
	if [ -f "$TOOL_ROOT/autotools/bin/automake" ]; then
		TEST_FEATURE="$TOOL_ROOT/autotools/bin"
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : automake in $TEST_FEATURE"
		$TEST_FEATURE/automake --version | sed -ne "1,1p"
		FEATURE_PATH="$TEST_FEATURE"
	fi
}

function libtool242_install() {
	URL=http://ftp.gnu.org/gnu/libtool/libtool-2.4.2.tar.gz
	VER=2.4.2
	FILE_NAME=libtool-2.4.2.tar.gz
	INSTALL_DIR="$TOOL_ROOT/autotools"
	SRC_DIR="$TOOL_ROOT/autotools/code/libtool-$VER-src"
	BUILD_DIR="$TOOL_ROOT/autotools/code/libtool-$VER-build"

	CONFIGURE_FLAG_PREFIX=
	CONFIGURE_FLAG_POSTFIX=

	feature_libtool242
	[ "$FORCE" ] && TEST_FEATURE=0
	if [ "$TEST_FEATURE" == "0" ]; then
		_auto_install "configure" "libtool" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"
	else
		echo " ** Already installed"
	fi
}
function feature_libtool242() {
	TEST_FEATURE=0
	if [ -f "$TOOL_ROOT/autotools/bin/libtool" ]; then
		TEST_FEATURE="$TOOL_ROOT/autotools/bin"
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : libtool in $TEST_FEATURE"
		$TEST_FEATURE/libtool --version | sed -ne "1,1p"
		FEATURE_PATH="$TEST_FEATURE"
	fi
}

function m4_1417_install() {
	URL=http://ftp.gnu.org/gnu/m4/m4-1.4.17.tar.gz
	VER=1.4.17
	FILE_NAME=m4-1.4.17.tar.gz
	INSTALL_DIR="$TOOL_ROOT/autotools"
	SRC_DIR="$TOOL_ROOT/autotools/code/m4-$VER-src"
	BUILD_DIR="$TOOL_ROOT/autotools/code/m4-$VER-build"

	CONFIGURE_FLAG_PREFIX=
	CONFIGURE_FLAG_POSTFIX=

	feature_m4_1417
	[ "$FORCE" ] && TEST_FEATURE=0
	if [ "$TEST_FEATURE" == "0" ]; then
		_auto_install "configure" "m4" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"
	else
		echo " ** Already installed"
	fi
}
function feature_m4_1417() {
	TEST_FEATURE=0
	if [ -f "$TOOL_ROOT/autotools/bin/m4" ]; then
		TEST_FEATURE="$TOOL_ROOT/autotools/bin"
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : m4 in $TEST_FEATURE"
		$TEST_FEATURE/m4 --version | sed -ne "1,1p"
		FEATURE_PATH="$TEST_FEATURE"
	fi
}


#TOOLS FOR CROSS COMPILING------------------------------------

function texinfo() {
	URL=http://ftp.gnu.org/gnu/texinfo/texinfo-5.1.tar.xz
	VER=5.1
	FILE_NAME=texinfo-5.1.tar.xz
	INSTALL_DIR="$TOOL_ROOT/cross-tools"
	SRC_DIR="$TOOL_ROOT/cross-tools/code/texinfo-$VER-src"
	BUILD_DIR="$TOOL_ROOT/cross-tools/code/texinfo-$VER-build"

	CONFIGURE_FLAG_PREFIX=
	CONFIGURE_FLAG_POSTFIX=

	
	_auto_install "configure" "texinfo" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"

}

function bc() {
	#http://www.gnu.org/software/bc/bc.html

	URL=http://alpha.gnu.org/gnu/bc/bc-1.06.95.tar.bz2
	VER=1.06.95
	FILE_NAME=bc-1.06.95.tar.bz2
	INSTALL_DIR="$TOOL_ROOT/cross-tools"	
	SRC_DIR="$TOOL_ROOT/cross-tools/code/bc-$VER-src"
	BUILD_DIR="$TOOL_ROOT/cross-tools/code/bc-$VER-build"

	CONFIGURE_FLAG_PREFIX=
	CONFIGURE_FLAG_POSTFIX=
	
	_auto_install "configure" "bc" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"
}

function file5() {
	URL=ftp://ftp.astron.com/pub/file/file-5.15.tar.gz
	VER=5.15
	FILE_NAME=file-5.15.tar.gz
	INSTALL_DIR="$TOOL_ROOT/cross-tools"
	SRC_DIR="$TOOL_ROOT/cross-tools/code/file-$VER-src"
	BUILD_DIR="$TOOL_ROOT/cross-tools/code/file-$VER-build"

	CONFIGURE_FLAG_PREFIX=
	CONFIGURE_FLAG_POSTFIX="--disable-static"

	_auto_install "configure" "file" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"

}

function m4() {

	URL=http://ftp.gnu.org/gnu/m4/m4-1.4.17.tar.gz
	VER=1.4.17
	FILE_NAME=m4-1.4.17.tar.gz
	INSTALL_DIR="$TOOL_ROOT/cross-tools"	
	SRC_DIR="$TOOL_ROOT/cross-tools/code/m4-$VER-src"
	BUILD_DIR="$TOOL_ROOT/cross-tools/code/m4-$VER-build"

	CONFIGURE_FLAG_PREFIX=
	CONFIGURE_FLAG_POSTFIX=

	_auto_install "configure" "m4" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"
}

function binutils() {
	#TODO configure flag
	URL=http://ftp.gnu.org/gnu/binutils/binutils-2.23.2.tar.bz2
	VER=2.23.2
	FILE_NAME=binutils-2.23.2.tar.bz2
	INSTALL_DIR="$TOOL_ROOT/cross-tools"
	SRC_DIR="$TOOL_ROOT/cross-tools/code/binutils-$VER-src"
	BUILD_DIR="$TOOL_ROOT/cross-tools/code/binutils-$VER-build"

	CONFIGURE_FLAG_PREFIX="AR=ar AS=as"
	CONFIGURE_FLAG_POSTFIX="--host=$CROSS_HOST --target=$CROSS_TARGET \
  	--with-sysroot=${CLFS} --with-lib-path=/tools/lib --disable-nls \
  	--disable-static --enable-64-bit-bfd"

	_auto_install "configure" "binutils" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"
}









#INTERNAL FUNCTION---------------------------------------------------
function _auto_build_install_configure() {
	local AUTO_SOURCE_DIR
	local AUTO_BUILD_DIR
	local AUTO_INSTALL_DIR
	local OPT

	AUTO_SOURCE_DIR="$1"
	AUTO_BUILD_DIR="$2"
	AUTO_INSTALL_DIR="$3"
	OPT="$4"

	local _opt_dest_erase
	_opt_dest_erase=OFF # erase installation dir before install (default : FALSE)
	for o in $OPT; do 
		[ "$o" == "DEST_ERASE" ] && _opt_dest_erase=ON
	done


	[ "$_opt_dest_erase" == "ON" ] && rm -Rf "$AUTO_INSTALL_DIR"
	mkdir -p "$AUTO_INSTALL_DIR"
	

	# useless cause rm -Rf "$BUILD_DIR"
	#if [ ! "$NOCONFIG" ]; then
	#	if [ -d "$AUTO_BUILD_DIR" ]; then
	#		make distclean # useless cause rm -Rf "$BUILD_DIR"
	#		make clean # useless rm -Rf "$BUILD_DIR"
	#	fi
	#fi

	[ ! "$NOCONFIG" ] && rm -Rf "$AUTO_BUILD_DIR"
	mkdir -p "$AUTO_BUILD_DIR"

	cd "$AUTO_BUILD_DIR"

	if [ ! "$NOCONFIG" ]; then
		chmod +x "$AUTO_SOURCE_DIR/configure"
		if [ "$CONFIGURE_FLAG_PREFIX" == "" ]; then
			"$AUTO_SOURCE_DIR/configure" --prefix="$AUTO_INSTALL_DIR" $CONFIGURE_FLAG_POSTFIX
		else
			$CONFIGURE_FLAG_PREFIX "$AUTO_SOURCE_DIR/configure" --prefix="$AUTO_INSTALL_DIR" $CONFIGURE_FLAG_POSTFIX
		fi
	fi

	if [ ! "$NOBUILD" ]; then
		make -j$BUILD_JOB
		make install
	fi

}

function _auto_install() {
	local MODE
	local NAME
	local FILE_NAME
	local URL
	local SOURCE_DIR
	local BUILD_DIR
	local INSTALL_DIR
	local OPT
	local _opt_dest_erase
	local _opt_strip
	local DEST_ERASE

	MODE="$1"
	NAME="$2"
	FILE_NAME="$3"
	URL="$4"
	SOURCE_DIR="$5"
	BUILD_DIR="$6"
	INSTALL_DIR="$7"
	OPT="$8"


	_opt_dest_erase=OFF # erase installation dir before install (default : FALSE)
	_opt_strip=OFF # delete first folder in archive  (default : FALSE)
	for o in $OPT; do 
		[ "$o" == "DEST_ERASE" ] && _opt_dest_erase=ON
		[ "$o" == "STRIP" ] && _opt_strip=ON
	done


	echo " ** Installing $NAME in $INSTALL_DIR"

	download_uncompress "$URL" "$FILE_NAME" "$SOURCE_DIR" "$OPT"
	
	DEST_ERASE=
	[ "$_opt_dest_erase" == "ON" ] && DEST_ERASE=DEST_ERASE
	
	case $MODE in
		cmake)
				echo "TODO"
				;;
		configure)
				_auto_build_install_configure "$SOURCE_DIR" "$BUILD_DIR" "$INSTALL_DIR" "$DEST_ERASE" 
				;;
	esac

	echo " ** Done"

}



#IDE FUNCTION-------EXPERIMENTAL-----------------------
function ide_install() {
	#http://www.logilab.org/blogentry/173886
	#rm -Rf "$TOOL_ROOT/ide"
	#mkdir -p "$TOOL_ROOT/ide"
	emacs_install
	ide_custom
	cedet_install
}
function feature_ide() {
	echo "TODO"
}

function emacs_install() {
	# http://www.gnu.org/software/emacs/refcards/
	URL=http://ftp.igh.cnrs.fr/pub/gnu/emacs/emacs-24.3.tar.gz
	VER=24.3
	FILE_NAME=emacs-24.3.tar.gz
	INSTALL_DIR="$TOOL_ROOT/ide"
	SRC_DIR="$TOOL_ROOT/ide/code/emacs-$VER-src"
	BUILD_DIR="$TOOL_ROOT/ide/code/emacs-$VER-build"

	CONFIGURE_FLAG_PREFIX=
	CONFIGURE_FLAG_POSTFIX="--with-xpm=no --with-gif=no --with-tiff=no" #TODO

	feature_emacs
	[ "$FORCE" ] && TEST_FEATURE=0
	if [ "$TEST_FEATURE" == "0" ]; then
		_auto_install "configure" "emacs24" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR"
	else
		echo " ** Already installed"
	fi

	[ -f "$TOOL_ROOT/ide/bin/emacs" ] && PATH="$TOOL_ROOT/ide/bin:$PATH"
}
function feature_emacs() {
	TEST_FEATURE=0
	if [ -f "$TOOL_ROOT/ide/bin/emacs" ]; then
		TEST_FEATURE="$TOOL_ROOT/ide/bin"
		[ "$VERBOSE_MODE" == "0" ] || echo " ** EXTRA FEATURE Detected : emacs in $TEST_FEATURE"
		FEATURE_PATH="$TEST_FEATURE"
	fi
}

function cedet_install() {
	rm -Rf $HOME/.emacs.d/site-lisp/cedet-bzr
	download_uncompress "http://www.randomsample.de/cedet-snapshots/cedet_snapshot-rev_8638.tar.gz" "cedet_snapshot-rev_8638.tar.gz" "$HOME/.emacs.d/site-lisp"
	copy_folder_content_into "$HOME/.emacs.d/site-lisp/cedet-bzr/trunk" "$HOME/.emacs.d/site-lisp/cedet-bzr"
	rm -Rf $HOME/.emacs.d/site-lisp/cedet-bzr/trunk
	cd $HOME/.emacs.d/site-lisp/cedet-bzr
	make
	make install-info

	rm -Rf $HOME/.emacs.d/config/cedet.el
	mkdir -p $HOME/.emacs.d/config

	cat > $HOME/.emacs.d/config/cedet.el << EOL
;;; minimial-cedet-config.el --- Working configuration for CEDET from bzr

;; Copyright (C) Alex Ott
;;
;; Author: Alex Ott <alexott@gmail.com>
;; Keywords: cedet, C++, Java
;; Requirements: CEDET from bzr (http://cedet.sourceforge.net/bzr-repo.shtml)

;; Do checkout of fresh CEDET, and use this config (don't forget to change path below)

(setq cedet-root-path (file-name-as-directory (expand-file-name "~/.emacs.d/site-lisp/cedet-bzr/")))
;;(add-to-list 'Info-directory-list "~/.emacs.d/site-lisp/cedet-bzr/doc/info")


(load-file (concat cedet-root-path "cedet-devel-load.el"))
(add-to-list 'load-path (concat cedet-root-path "contrib"))

;; select which submodes we want to activate
(add-to-list 'semantic-default-submodes 'global-semantic-mru-bookmark-mode)
(add-to-list 'semantic-default-submodes 'global-semanticdb-minor-mode)
(add-to-list 'semantic-default-submodes 'global-semantic-idle-scheduler-mode)
(add-to-list 'semantic-default-submodes 'global-semantic-stickyfunc-mode)
(add-to-list 'semantic-default-submodes 'global-cedet-m3-minor-mode)
(add-to-list 'semantic-default-submodes 'global-semantic-highlight-func-mode)
(add-to-list 'semantic-default-submodes 'global-semanticdb-minor-mode)

;; Activate semantic
(semantic-mode 1)

;; load contrib library
(require 'eassist)

;; customisation of modes
(defun alexott/cedet-hook ()
  (local-set-key [(control return)] 'semantic-ia-complete-symbol-menu)
  (local-set-key "\C-c?" 'semantic-ia-complete-symbol)
  ;;
  (local-set-key "\C-c>" 'semantic-complete-analyze-inline)
  (local-set-key "\C-c=" 'semantic-decoration-include-visit)

  (local-set-key "\C-cj" 'semantic-ia-fast-jump)
  (local-set-key "\C-cq" 'semantic-ia-show-doc)
  (local-set-key "\C-cs" 'semantic-ia-show-summary)
  (local-set-key "\C-cp" 'semantic-analyze-proto-impl-toggle)
  )
(add-hook 'c-mode-common-hook 'alexott/cedet-hook)
(add-hook 'lisp-mode-hook 'alexott/cedet-hook)
(add-hook 'scheme-mode-hook 'alexott/cedet-hook)
(add-hook 'emacs-lisp-mode-hook 'alexott/cedet-hook)
(add-hook 'erlang-mode-hook 'alexott/cedet-hook)

(defun alexott/c-mode-cedet-hook ()
  (local-set-key "\C-ct" 'eassist-switch-h-cpp)
  (local-set-key "\C-xt" 'eassist-switch-h-cpp)
  (local-set-key "\C-ce" 'eassist-list-methods)
  (local-set-key "\C-c\C-r" 'semantic-symref)
  )
(add-hook 'c-mode-common-hook 'alexott/c-mode-cedet-hook)

(semanticdb-enable-gnu-global-databases 'c-mode t)
(semanticdb-enable-gnu-global-databases 'c++-mode t)

(when (cedet-ectag-version-check t)
  (semantic-load-enable-primary-ectags-support))

;; SRecode
(global-srecode-minor-mode 1)

;; EDE
(global-ede-mode 1)
(ede-enable-generic-projects)


;; Setup JAVA....
(require 'cedet-java)

;;; minimial-cedet-config.el ends here
EOL
}


function ide_custom() {
	echo " ** WARNING : any previous emacs conf in ./emacs.d will be erase"
	rm -Rf $HOME/.emacs.d
	mkdir -p $HOME/.emacs.d/site-lisp/

	cat > $HOME/.emacs.d/init.el << EOL
;; this is intended for manually installed libraries
(add-to-list 'load-path "~/.emacs.d/site-lisp/")

;; this is intended for configuration snippets
(add-to-list 'load-path "~/.emacs.d/")

;; load the package system and add some repositories
(require 'package)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)

;; Install a hook running post-init.el *after* initialization took place
(add-hook 'after-init-hook (lambda () (load "post-init.el")))

;; Do here basic initialization, (require) non-ELPA packages, etc.
(load "config/cedet.el")

;; disable automatic loading of packages after init.el is done
(setq package-enable-at-startup nil)
;; and force it to happen now
(package-initialize)
;; NOW you can (require) your ELPA packages and configure them as normal
EOL

}



fi
