_STELLA_LINK_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
STELLA_ROOT=$_STELLA_LINK_CURRENT_FILE_DIR/../..
STELLA_APP_ROOT=$_STELLA_LINK_CURRENT_FILE_DIR

[ ! -f "$STELLA_ROOT/stella.sh" ] && echo "** WARNING Stella is missing"

ACTION=$1
case $ACTION in
	include)
		source "$STELLA_ROOT/conf.sh"
		__init_stella_env
		;;
	*) 
		$STELLA_ROOT/stella.sh $*
		;;
esac
