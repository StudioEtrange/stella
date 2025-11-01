#!/usr/bin/env bash
_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


# https://gist.github.com/StudioEtrange/8c2801df68969538cfccc6dcdb8d6bcc
update_macos-dyld-cache-analyse() {
  rm -f "${_CURRENT_FILE_DIR}/macos-dyld-cache-analyse.sh"
  # ?$(date +%s) is here only to invalidate server cache by changing URL
  curl -fksL "https://gist.githubusercontent.com/StudioEtrange/8c2801df68969538cfccc6dcdb8d6bcc/raw/macos-dyld-cache-analyse?$(date +%s)" -o "${_CURRENT_FILE_DIR}/macos-dyld-cache-analyse.sh"
  chmod +x "${_CURRENT_FILE_DIR}/macos-dyld-cache-analyse.sh"
}

# https://gist.github.com/StudioEtrange/c2f1a2f625c5745c84dda2bc02fea4eb
update_macos-link-analyse() {
  rm -f "${_CURRENT_FILE_DIR}/macos-link-analyse.sh"
  # ?$(date +%s) is here only to invalidate server cache by changing URL
  curl -fksL "https://gist.githubusercontent.com/StudioEtrange/c2f1a2f625c5745c84dda2bc02fea4eb/raw/macos-link-analyse.sh?$(date +%s)" -o "${_CURRENT_FILE_DIR}/macos-link-analyse.sh"
  chmod +x "${_CURRENT_FILE_DIR}/macos-link-analyse.sh"
}

# https://gist.github.com/StudioEtrange/5b0eac67f8917d7bc69e01d262854b5b
update_homebrew-get-bottle() {
  rm -f "${_CURRENT_FILE_DIR}/homebrew-get-bottle.sh"
  # ?$(date +%s) is here only to invalidate server cache by changing URL
  curl -fksL "https://gist.githubusercontent.com/StudioEtrange/5b0eac67f8917d7bc69e01d262854b5b/raw/homebrew-get-bottle.sh?$(date +%s)" -o "${_CURRENT_FILE_DIR}/homebrew-get-bottle.sh"
  chmod +x "${_CURRENT_FILE_DIR}/homebrew-get-bottle.sh"
}

# https://github.com/dappvibe/bash-colors
update_bash-colors() {
  rm -Rf "${_CURRENT_FILE_DIR}/bash-colors"
  echo "Using https://github.com/dappvibe/bash-colors"
  git clone https://github.com/dappvibe/bash-colors "${_CURRENT_FILE_DIR}/bash-colors"
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

# https://github.com/dylanaraps/neofetch
update_neofetch() {
  rm -Rf "${_CURRENT_FILE_DIR}/neofetch"
  echo "Using https://github.com/dylanaraps/neofetch"
  git clone https://github.com/dylanaraps/neofetch "${_CURRENT_FILE_DIR}/neofetch"
  rm -Rf "${_CURRENT_FILE_DIR}/neofetch/.git"
}

# https://github.com/StudioEtrange/lddtree
# TODO reunification of my fork versus the original lddtree ?
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
  neofetch )
    update_neofetch
    ;;
  lddtree )
    update_lddtree
    ;;
  homebrew-get-bottle )
    update_homebrew-get-bottle
    ;;
  macos-link-analyse)
    update_macos-link-analyse
    ;;
  macos-dyld-cache-analyse)
    update_macos-dyld-cache-analyse
    ;;
  * )
    echo "Usage : ${_CURRENT_FILE_DIR}/update.sh <bash-colors|bash_ini_parser|pure-getopt|screenFetch|neofetch|lddtree|homebrew-get-bottle|macos-link-analyse|macos-dyld-cache-analyse>"
    ;;
esac
