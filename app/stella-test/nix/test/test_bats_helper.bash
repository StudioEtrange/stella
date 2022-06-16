# load stella env vars and functions
{ set +e; source "$__BATS_STELLA_DECLARE" &>/dev/null; set -e; }



setup() {
    true
}

teardown() {
    true
}




flunk() {
  { if [ "$#" -eq 0 ]; then cat -
    else echo "$@"
    fi
  } | sed "s:${BATS_TEST_DIRNAME}:TEST_DIR:g" >&2
  return 1
}

assert_success() {
  if [ "$status" -ne 0 ]; then
    flunk "command failed with exit status $status"
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_failure() {
  if [ "$status" -eq 0 ]; then
    flunk "expected failed exit status"
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_equal() {
  if [ "$1" != "$2" ]; then
    { echo "expected: $1"
      echo "actual:   $2"
    } | flunk
  fi
}

assert_output() {
  local expected
  if [ $# -eq 0 ]; then expected="$(cat -)"
    else expected="$1"
  fi
  assert_equal "$expected" "$output"
}


output_contains() {
  local input="$output"; local expected="$1"; local found=0
  until [ "${input/$expected/}" = "$input" ]; do
    input="${input/$expected/}"
    let found+=1
  done

  echo "$found"
}

assert_output_not_empty() {
  if [ "$output" == "" ]; then
    { echo "output is empty"
      echo "found:    $output"
    } | flunk
  fi
}

assert_output_empty() {
  if [ "$output" != "" ]; then
    { echo "output is not empty"
      echo "found:    $output"
    } | flunk
  fi
}

# contains n ($2) occurence of string ($1)
assert_output_contains_exact() {
  local expected="$1"; local count="${2:-1}";
  local found="$(output_contains $expected)"

  if [ "$count" != "$found" ]; then
    { echo "search string: $1"
      echo "expected: $count time(s)"
      echo "found:    $found time(s)"
    } | flunk
  fi
}

# contains at least 1 occurence of string ($1)
assert_output_contains() {
  local expected="$1";
  local found="$(output_contains $expected)"

  if [ "$found" -lt 1 ]; then
    { echo "search string: $expected"
      echo "not found"
    } | flunk
  fi
}

# contains at least 1 occurence of string ($1)
assert_output_not_contains() {
  assert_output_contains_exact "$1" "0"
}


assert_line() {
  if [ "$1" -ge 0 ] 2>/dev/null; then
    assert_equal "$2" "${lines[$1]}"
  else
    local line
    for line in "${lines[@]}"; do
      if [ "$line" = "$1" ]; then return 0; fi
    done
    flunk "expected line \`$1'"
  fi
}

refute_line() {
  if [ "$1" -ge 0 ] 2>/dev/null; then
    local num_lines="${#lines[@]}"
    if [ "$1" -lt "$num_lines" ]; then
      flunk "output has $num_lines lines"
    fi
  else
    local line
    for line in "${lines[@]}"; do
      if [ "$line" = "$1" ]; then
        flunk "expected to not find line \`$line'"
      fi
    done
  fi
}

assert() {
  if ! "$@"; then
    flunk "failed: $@"
  fi
}

assert_exit_status() {
  assert_equal "$status" "$1"
}
