

function test_launch_bats() {
	local domain=$1

	__require "bats" "bats#SNAPSHOT" "PREFER_STELLA"

	local _v=$(mktmp)
	declare >$_v
	declare -f >>$_v
	export __BATS_STELLA_DECLARE=$_v

	#bats --verbose test_binary.bats
	bats "bats/test_$domain".bats

	rm -f $_v

}