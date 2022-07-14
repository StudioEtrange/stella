#!/bin/bash
_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


# TODO : migrate to bats
$_CURRENT_FILE_DIR/test-app.sh
$_CURRENT_FILE_DIR/test-make-sfx.sh