
function log() {
	local test_name=$1
	local result=$2
	local string=$3

	echo " ** TEST ${BASH_SOURCE[1]}::$test_name '$string' [$result]"
}