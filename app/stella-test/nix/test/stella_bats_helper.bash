# import stella env vars and functions inside bats context
{ set +e; source "$__BATS_STELLA_DECLARE" &>/dev/null; set -e; }
