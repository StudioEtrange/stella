#!/usr/bin/env bash
_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# https://gist.github.com/StudioEtrange/290afc0b333e66f271a000bba4b1e110
updage_homebrew-get-bottle() {
  rm -f "${_CURRENT_FILE_DIR}/homebrew_get_bottle.sh"
  curl -fksL "https://gist.githubusercontent.com/StudioEtrange/290afc0b333e66f271a000bba4b1e110/raw/homebrew_get_bottle.sh" -o "${_CURRENT_FILE_DIR}/homebrew_get_bottle.sh"
  chmod +x "${_CURRENT_FILE_DIR}/homebrew_get_bottle.sh"
}

# https://github.com/mercuriev/bash-colors
update_bash-colors() {
  rm -Rf "${_CURRENT_FILE_DIR}/bash-colors"
  echo "Using https://github.com/mercuriev/bash-colors"
  git clone https://github.com/mercuriev/bash-colors "${_CURRENT_FILE_DIR}/bash-colors"
  rm -Rf "${_CURRENT_FILE_DIR}/bash-colors/.git"
}


# https://github.com/rudimeier/bash_ini_parser
update_bash_ini_parser() {
  rm -Rf "${_CURRENT_FILE_DIR}/bash_ini_parser"
  # NOTE do not use albfan fork which seems to have problem when evaluating value
  #git clone https://github.com/albfan/bash_ini_parser "${_CURRENT_FILE_DIR}/bash_ini_parser"
  echo "Using https://github.com/rudimeier/bash_ini_parser v0.4.2"
  git clone https://github.com/rudimeier/bash_ini_parser "${_CURRENT_FILE_DIR}/bash_ini_parser"
  cd "${_CURRENT_FILE_DIR}/bash_ini_parser"
  git checkout "v0.4.2"
  rm -Rf "${_CURRENT_FILE_DIR}/bash_ini_parser/.git"
}

# https://github.com/KittyKatt/screenFetch
update_screenFetch() {
  rm -Rf "${_CURRENT_FILE_DIR}/screenFetch"
  echo "Using https://github.com/KittyKatt/screenFetch"
  git clone https://github.com/KittyKatt/screenFetch "${_CURRENT_FILE_DIR}/screenFetch"
  rm -Rf "${_CURRENT_FILE_DIR}/screenFetch/.git"
}

# https://github.com/StudioEtrange/lddtree
update_lddtree() {
  rm -Rf "${_CURRENT_FILE_DIR}/lddtree"
  echo "Using StudioEtrange fork (https://github.com/StudioEtrange/lddtree) of original ncopa (https://github.com/ncopa/lddtree)"
  git clone https://github.com/StudioEtrange/lddtree "${_CURRENT_FILE_DIR}/lddtree"
  rm -Rf "${_CURRENT_FILE_DIR}/lddtree/.git"
}

# https://github.com/agriffis/pure-getopt
update_pure-getopt() {
  echo "TODO"
}

case $1 in
  bash-colors )
    update_bash-colors
    ;;
  bash_ini_parser )
    update_bash_ini_parser
    ;;
  pure-getopt )
    update_pure-getopt
    ;;
  screenFetch )
    update_screenFetch
    ;;
  lddtree )
    update_lddtree
    ;;
  homebrew-get-bottle )
    updage_homebrew-get-bottle
    ;;
  * )
    echo "Usage : ${_CURRENT_FILE_DIR}/update.sh <bash-colors|bash_ini_parser|pure-getopt|screenFetch|lddtree|homebrew-get-bottle>"
    ;;
esac
