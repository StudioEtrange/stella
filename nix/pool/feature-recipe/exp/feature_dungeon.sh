if [ ! "$_dungeon_INCLUDED_" = "1" ]; then
_dungeon_INCLUDED_=1

# TODO
# missing dependencies : gfortran and others 

feature_dungeon() {
	FEAT_NAME="dungeon"
	FEAT_LIST_SCHEMA="latest:binary"
	
	FEAT_DEFAULT_FLAVOUR="binary"

	FEAT_DESC="The classic text adventure updated to compile using gfortran"
	FEAT_LINK="https://github.com/GOFAI/dungeon https://formulae.brew.sh/formula/dungeon"
}


feature_dungeon_latest() {
	FEAT_VERSION="latest"

	FEAT_BINARY_URL="dungeon"
	FEAT_BINARY_URL_PROTOCOL="HOMEBREW_BOTTLE"

	FEAT_INSTALL_TEST="${FEAT_INSTALL_ROOT}/bin/dungeon"
	FEAT_SEARCH_PATH="${FEAT_INSTALL_ROOT}/bin"
}



feature_dungeon_install_binary() {

	case $FEAT_BINARY_URL_PROTOCOL in
		HOMEBREW_BOTTLE)
			__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "DEST_ERASE STRIP"
			local content_folder=""
			(
				shopt -s dotglob

				for x in "$FEAT_INSTALL_ROOT/"*; do
            		[ -d "$x" ] || continue
					content_folder="$x"
				done

				for f in "$content_folder/"*; do mv "$f" "${FEAT_INSTALL_ROOT}"/; done

				rm -rf "${content_folder}"
			)
			;;
	esac
	
	

}


fi
