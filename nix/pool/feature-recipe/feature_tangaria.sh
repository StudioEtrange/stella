if [ ! "$_TANGARIA_INCLUDED_" = "1" ]; then
_TANGARIA_INCLUDED_=1

# Tangaria retains the upstream pwmangband and pwmangclient executable names.

# see pwmangband for original recipe
# to see server version
#	./tangaria-server -v


# quick start
# # —— build game and game server
# cd ~
# git clone https://github.com/StudioEtrange/stella
# ~/stella/stella.sh feature install tangaria

# # —— launch game server
# ~/stella/stella.sh shell
# tangaria-server

# # —— launch game
# ~/stella/stella.sh shell
# tangaria --host localhost --port 18346


. "${STELLA_FEATURE_RECIPE}/feature_pwmangband.sh"

feature_tangaria() {
	FEAT_NAME="tangaria"
	FEAT_LIST_SCHEMA="2026_05_30:source"
	FEAT_DEFAULT_FLAVOUR="source"
	FEAT_DESC="Free open-source multiplayer roguelike game based loosely on Tolkien’s lore and powered by PWMAngband."
	FEAT_LINK="https://tangaria.com/ https://github.com/igroglaz/Tangaria https://github.com/igroglaz/Tangaria_release"
}

feature_tangaria_2026_05_30() {
	FEAT_VERSION="2026_05_30"

	FEAT_SOURCE_DEPENDENCIES="ncurses#6_5"
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL="https://github.com/igroglaz/Tangaria/archive/bb320f8ceea491f46f05aa285b3bd6f7bcfd2e86.tar.gz"
	FEAT_SOURCE_URL_FILENAME="tangaria-${FEAT_VERSION}-bb320f8.tar.gz"
	FEAT_SOURCE_URL_PROTOCOL="HTTP_ZIP"

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK="feature_tangaria_link"
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK="feature_tangaria_message"

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/bin/tangaria $FEAT_INSTALL_ROOT/bin/tangaria-server $FEAT_INSTALL_ROOT/games/pwmangclient $FEAT_INSTALL_ROOT/games/pwmangband"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT/bin"

	# matching FEAT_VERSION on github
	FEAT_VERSION_SHORT_COMMIT="bb320f8"

}

feature_tangaria_link() {
	__link_feature_library "ncurses#6_5" "FORCE_DYNAMIC"
}

feature_tangaria_message() {
	printf '%s\n' \
		'--- Tangaria ---' \
		'Start server : ./tangaria-server' \
		'Connect client : ./tangaria --host localhost --port 18346' \
		'Client configuration: $HOME/.tangaria/pwmangclient.ini' \
		'Server configuration: $HOME/.tangaria/mangband.cfg' \
		'Private game data is stored under $HOME/.tangaria'
}

feature_tangaria_install_source() (
	local INSTALL_DIR="$FEAT_INSTALL_ROOT"
	local SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"
	local SYSCONFDIR="$FEAT_INSTALL_ROOT/etc"
	local SYSCONFDIR_AUTOTOOLS_SYNTAX="\${prefix}/etc"

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP FORCE_NAME $FEAT_SOURCE_URL_FILENAME" || return 1

	__set_toolset "STANDARD"
	__add_toolset "autotools"

	AUTO_INSTALL_CONF_FLAG_PREFIX=
	# SYSCONFDIR will contains SYSCONFDIR/pwmangband/gamedata/*.txt rules files and SYSCONFDIR/pwmangband/customize/*.prf preference files
	# SYSCONFDIR_AUTOTOOLS_SYNTAX is a trick to avoid problem with spaces in path - ${prefix} is a configure keyword
	AUTO_INSTALL_CONF_FLAG_POSTFIX="--enable-curses --disable-x11 --disable-sdl \
			--disable-sdl2 --disable-sdl-mixer --disable-sdl2-mixer \
			--with-private-dirs --sysconfdir=$SYSCONFDIR_AUTOTOOLS_SYNTAX"
	AUTO_INSTALL_BUILD_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_POSTFIX=

	# Keep Tangaria saves and preferences separate from PWMAngband
	# definie a default folder value when using --with-private-dirs 
	STELLA_C_CXX_FLAGS="$STELLA_C_CXX_FLAGS -DPRIVATE_USER_PATH=\\\"~/.tangaria\\\""
	
	
	feature_pwmangband_darwin_build
	feature_pwmangband_arm_build

	__feature_callback

	# Useless
	#feature_pwmangband_version_generate

	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR" "SOURCE_KEEP NO_OUT_OF_TREE_BUILD AUTOTOOLS autogen"

	feature_pwmangband_default_config_generate
	feature_pwmangband_missing_config_files

	# make launchers -------------------------------
	mkdir -p "$INSTALL_DIR/bin"

	feature_pwmangband_create_launcher \
		"client" \
		"$INSTALL_DIR/bin/tangaria" \
		"games/pwmangclient" \
		"\$HOME/.tangaria" \
		"pwmangclient.ini" \
		"share/pwmangband/defaults/pwmangclient.ini"

	feature_pwmangband_create_launcher \
		"server" \
		"$INSTALL_DIR/bin/tangaria-server" \
		"games/pwmangband" \
		"\$HOME/.tangaria" \
		"mangband.cfg" \
		"share/pwmangband/defaults/mangband.cfg"

	rm -Rf "$SRC_DIR"
)

fi
