if [ ! "$_PWMANGBAND_INCLUDED_" = "1" ]; then
_PWMANGBAND_INCLUDED_=1

# NOTE : pwmangband is the server - pwmangclient is the client
#

# ./configure option from 1_6_2_build_3
# Fine tuning of the installation directories:
#   --bindir=DIR            user executables [EPREFIX/bin]
#   --sbindir=DIR           system admin executables [EPREFIX/sbin]
#   --libexecdir=DIR        program executables [EPREFIX/libexec]
#   --sysconfdir=DIR        read-only single-machine data [PREFIX/etc]
#   --sharedstatedir=DIR    modifiable architecture-independent data [PREFIX/com]
#   --localstatedir=DIR     modifiable single-machine data [PREFIX/var]
#   --runstatedir=DIR       modifiable per-process data [LOCALSTATEDIR/run]
#   --libdir=DIR            object code libraries [EPREFIX/lib]
#   --includedir=DIR        C header files [PREFIX/include]
#   --oldincludedir=DIR     C header files for non-gcc [/usr/include]
#   --datarootdir=DIR       read-only arch.-independent data root [PREFIX/share]
#   --datadir=DIR           read-only architecture-independent data [DATAROOTDIR]
#   --infodir=DIR           info documentation [DATAROOTDIR/info]
#   --localedir=DIR         locale-dependent data [DATAROOTDIR/locale]
#   --mandir=DIR            man documentation [DATAROOTDIR/man]
#   --docdir=DIR            documentation root [DATAROOTDIR/doc/pwmangband]
#   --htmldir=DIR           html documentation [DOCDIR]
#   --dvidir=DIR            dvi documentation [DOCDIR]
#   --pdfdir=DIR            pdf documentation [DOCDIR]
#   --psdir=DIR             ps documentation [DOCDIR]

# X features:
#   --x-includes=DIR    X include files are in DIR
#   --x-libraries=DIR   X library files are in DIR
# Optional Features:
#   --disable-option-checking  ignore unrecognized --enable/--with options
#   --disable-FEATURE       do not include FEATURE (same as --enable-FEATURE=no)
#   --enable-FEATURE[=ARG]  include FEATURE [ARG=yes]
#   --disable-rpath         do not use rpath
#   --disable-silent-rules  print executed commands during build
#   --enable-release        enable a release build
#   --enable-borg           enable Borg (default enabled)
#   --enable-borg-high-scores
#                           allow Borg characters to appear in the high scores
#                           (default: disabled)
#   --enable-curses         enable Curses frontend (default: enabled)
#   --enable-x11            enable X11 frontend (default: disabled)
#   --enable-sdl2           enable SDL2 frontend (default: disabled)
#   --enable-sdl            enable SDL frontend (default: disabled)
#   --enable-win            enable Windows frontend (default: disabled)
#   --enable-test           enable test frontend (default: disabled)
#   --enable-stats          enable stats frontend (default: disabled)
#   --enable-spoil          enable command-line spoiler generation (default:
#                           disabled)
#   --enable-sdl2-mixer     enable SDL2 mixer sound support (default: disabled
#                           unless SDL2 enabled)
#   --enable-sdl-mixer      enable SDL mixer sound support (default: disabled
#                           unless SDL enabled)
#   --disable-ncursestest   do not try to compile and run a test ncurses program
#   --disable-sdl2test      do not try to compile and run a test SDL2 program
#   --disable-sdltest       do not try to compile and run a test SDL program

# Optional Packages:
#   --with-PACKAGE[=ARG]    use PACKAGE [ARG=yes]
#   --without-PACKAGE       do not use PACKAGE (same as --with-PACKAGE=no)
#   --with-setgid=NAME      install pwmangband as group NAME
#   --with-private-dirs     use private scorefiles/savefiles
#   --with-no-install       don't install, just run in-place
#   --with-sphinx           build the documentation with sphinx-build
#   --with-gamedata-in-lib  store the game data in the lib path.
#   --with-ncurses-prefix=PFX
#                           set prefix where ncurses is installed (optional)
#   --with-ncurses-exec-prefix=PFX
#                           set exec prefix where ncurses is installed
#                           (optional)
#   --with-x                use the X Window System
#   --with-sdl2-prefix=PFX  set prefix where SDL2 is installed (optional)
#   --with-sdl2-exec-prefix=PFX
#                           set exec prefix where SDL2 is installed (optional)
#   --with-sdl-prefix=PFX   set prefix where SDL is installed (optional)
#   --with-sdl-exec-prefix=PFX
#                           set exec prefix where SDL is installed (optional)

# Some influential environment variables:
#   SPHINXBUILD full path to sphinx-build for building documentation; overrides
#               auto-detected path
#   DOC_HTML_THEME
#               the builtin Sphinx HTML theme to use or, if not set or empty,
#               use the theme configured in docs/conf.py (currently the better
#               theme)
#   CC          C compiler command
#   CFLAGS      C compiler flags
#   LDFLAGS     linker flags, e.g. -L<lib dir> if you have libraries in a
#               nonstandard directory <lib dir>
#   LIBS        libraries to pass to the linker, e.g. -l<library>
#   CPPFLAGS    (Objective) C/C++ preprocessor flags, e.g. -I<include dir> if
#               you have headers in a nonstandard directory <include dir>
#   CPP         C preprocessor
#   MAKE        Name of a make program to use
#   NCURSES_CONFIG
#               full path to the script for querying details about how to
#               compile and link with an installed ncurses library
#   XMKMF       Path to xmkmf, Makefile generator for X Window System

# Use these variables to override the choices made by `configure' or to help
# it to find libraries and programs with nonstandard names/locations.

# IMPORTANT configuration option
#   --with-private-dirs     
#				use scorefiles/savefiles stored in HOME folder
#				player and server save and scores are in : ~/.pwmangband/PWMAngband
#						  ~/.pwmangband/PWMAngband/save
#						  ~/.pwmangband/PWMAngband/score
#				by default, without with-private-dirs, use --localstatedir (which default value is <prefix>/var)
#   --with-gamedata-in-lib
#				store the gamedata folder (txt.files) in <prefix>/share/pwmangband/gamedata
#				without this option store the gamedata in path <sysconfdir>/pwmangband/gamedata
#				gamedata contains rule txt files for server
#				this option do not change path of customize folder customize/*.prf
#	--sysconfdir
#				set server parameters and rule files path (which is NOT the server config file mangband.cfg)
#					customize/*.prf server parameter files
#					gamedata/*.txt server rule files
#				always add /pwmangband => --sysconfdir=/etc means /etc/pwmangband
#				by default the value is <prefix>/etc


# client config file : pwmangclient.ini
#	default config file : https://github.com/draconisPW/PWMAngband/blob/55348df8f1b1dee1284179dd21fd053e16646f8d/src/client/conf.c#L626-L651
# 	resolution order :
#		https://github.com/draconisPW/PWMAngband/blob/55348df8f1b1dee1284179dd21fd053e16646f8d/src/client/conf.c#L454
#		1. --config <PATH> option of client
#		2. macos : $HOME/pwmangclient.ini, linux : $HOME/.pwmangrc or $HOME/pwmangclient.ini
#		3. current folder
# server config file : mangband.cfg
#	resolution order :
#		https://github.com/draconisPW/PWMAngband/blob/55348df8f1b1dee1284179dd21fd053e16646f8d/src/server/init.c#L5335
#		1. load mangband.cfg only from current folder


feature_pwmangband() {
	FEAT_NAME="pwmangband"
	FEAT_LIST_SCHEMA="1_6_2_build_3:source"
	FEAT_DEFAULT_FLAVOUR="source"
	FEAT_DESC="A free, multi-player roguelike dungeon exploration game based on MAngband"
	FEAT_LINK="https://github.com/draconisPW/PWMAngband https://mangband.org/"
}

feature_pwmangband_1_6_2_build_3() {
	FEAT_VERSION="1_6_2_build_3"

	FEAT_SOURCE_DEPENDENCIES="ncurses#6_5"
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL="https://github.com/draconisPW/PWMAngband/archive/refs/tags/1.6.2-build-3.tar.gz"
	FEAT_SOURCE_URL_FILENAME="pwmangband-1.6.2-build-3.tar.gz"
	FEAT_SOURCE_URL_PROTOCOL="HTTP_ZIP"
	
	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=
	
	FEAT_SOURCE_CALLBACK="feature_pwmangband_link feature_pwmangband_missing_config_file"
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK="feature_pwmangband_message"

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/bin/pwmangband $FEAT_INSTALL_ROOT/bin/pwmangclient"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT/bin"
}

feature_pwmangband_link() {
	__link_feature_library "ncurses#6_5" "FORCE_DYNAMIC"
}

feature_pwmangband_missing_config_file() {
	local INSTALL_DIR="$FEAT_INSTALL_ROOT"
	local SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"
	local SYSCONFDIR="$FEAT_INSTALL_ROOT/etc"
	
	# This Makefile version omits modes.txt
	mkdir -p "$SYSCONFDIR/pwmangband/gamedata"
	cp -f "$SRC_DIR/lib/gamedata/modes.txt" "$SYSCONFDIR/pwmangband/gamedata/modes.txt" || return 1
}

feature_pwmangband_message() {
	printf '%s\n' \
		'PWMAngband server : start pwmangband; connect using pwmangclient --host localhost --port 18346' \
		'Configuration client: $HOME/.pwmangband/pwmangband.ini' \
		'Configuration server: $HOME/.pwmangband/mangband.cfg' \
		'Saves, accounts, scores, panic saves, logs and preferences: $HOME/.pwmangband/PWMAngband.' \
		'New server configurations listen on all IPv4 interfaces, TCP 18346, without metaserver announcement.' \
		'Console access is restricted to 127.0.0.1 peers on the shared listener, not a separate loopback bind.'
}

feature_pwmangband_install_source() (
	local INSTALL_DIR="$FEAT_INSTALL_ROOT"
	local SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"
	local SYSCONFDIR="$FEAT_INSTALL_ROOT/etc"

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP FORCE_NAME $FEAT_SOURCE_URL_FILENAME"

	__set_toolset "STANDARD"
	__add_toolset "autotools"

	AUTO_INSTALL_CONF_FLAG_PREFIX=
	# With this config
	# SYSCONFDIR will contains SYSCONFDIR/pwmangband/gamedata/*.txt and SYSCONFDIR/pwmangband/customize/*.prf
	AUTO_INSTALL_CONF_FLAG_POSTFIX="--enable-curses --disable-x11 --disable-sdl \
			--disable-sdl2 --disable-sdl-mixer --disable-sdl2-mixer \
			--with-private-dirs --sysconfdir="$SYSCONFDIR""
	AUTO_INSTALL_BUILD_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_POSTFIX=


	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		# Apple ld linker should not receive compiler-driver
		# flags such as Stella's -Wl,-rpath on these intermediate relocatable links.
		patch --batch -d "$SRC_DIR" -p0 <<'PATCH' || return 1
*** src/Makefile.orig
--- src/Makefile
***************
*** 51 ****
- 	$(LD) $(LDFLAGS) -nostdlib -r -o $@ $(SERVER_OBJECTS)
--- 51 ----
+ 	$(LD) -nostdlib -r -o $@ $(SERVER_OBJECTS)
***************
*** 55 ****
- 	$(LD) $(LDFLAGS) -nostdlib -r -o $@ $(CLIENT_OBJECTS)
--- 55 ----
+ 	$(LD) -nostdlib -r -o $@ $(CLIENT_OBJECTS)
PATCH
	fi

	if [ "$STELLA_CURRENT_CPU_FAMILY" = "arm" ]; then
		STELLA_C_CXX_FLAGS="$STELLA_C_CXX_FLAGS -fsigned-char"
	fi


	__feature_callback


	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR" "SOURCE_KEEP NO_OUT_OF_TREE_BUILD AUTOTOOLS autogen"




	# save default config files -------------------------------
	mkdir -p "$INSTALL_DIR/share/pwmangband/defaults"
	
	# save server config default file
	# REPORT_TO_METASERVER : disable metaserver announcement
	# BIND_NAME : bind address
	# CONSOLE_LOCAL_ONLY : admin console only from localhost
	sed -e 's/^REPORT_TO_METASERVER = .*/REPORT_TO_METASERVER = false/' \
		-e 's/^BIND_NAME = .*/BIND_NAME = "0.0.0.0"/' \
		-e 's/^CONSOLE_LOCAL_ONLY = .*/CONSOLE_LOCAL_ONLY = true/' \
		"$SRC_DIR/setup/mangband.cfg" > "$INSTALL_DIR/share/pwmangband/defaults/mangband.cfg" 
	
	# save client config default file
	cp "$SRC_DIR/setup/mangclient.ini" "$INSTALL_DIR/share/pwmangband/defaults/pwmangclient.ini" || return 1


	# make launcher -------------------------------
	mkdir -p "$INSTALL_DIR/bin" 

	for c in pwmangclient pwmangband; do
		cat <<'LAUNCHER' > "$INSTALL_DIR/bin/$c"
#!/bin/bash
command="$(basename -- "$0")"
set -e
root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)"
: "${HOME:?HOME must be set}"
# same folder as the root folder used by "with-private-dirs" ~/.pwmangband/PWMAngband => ~/.pwmangband
config_dir="$HOME/.pwmangband"

# we do not use default config file for client, we will generate it at first client launch
#default_config_file="$root/share/pwmangband/defaults/pwmangclient.ini"
case $command in
	pwmangclient) config_file="$config_dir/pwmangclient.ini"; default_config_file="" ;;
	pwmangband) config_file="$config_dir/mangband.cfg"; default_config_file="$root/share/pwmangband/defaults/mangband.cfg" ;;
esac
if [ ! -e "$config_file" ]; then
	if [ -f "$default_config_file" ]; then
		mkdir -p "$config_dir"
		cp "$default_config_file" "$config_file"
	fi
fi
if [ "$command" = "pwmangclient" ]; then
	cd "$config_dir" # launching game from here allow to generate default config file in config_dir
	for argument in "$@"; do
		if [ "$argument" = "--config" ]; then
			exec "$root/games/$command" "$@"
		fi
	done
	exec "$root/games/$command" --config "$config_file" "$@"
fi

if [ "$command" = "pwmangband" ]; then
	cd "$config_dir"
	exec "$root/games/$command" "$@"
fi
LAUNCHER

		chmod 755 "$INSTALL_DIR/bin/$c"
	done

	rm -Rf "$SRC_DIR"

)

fi
