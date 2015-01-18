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
