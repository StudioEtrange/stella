if [ ! "$_STELLA_COMMON_API_INCLUDED_" == "1" ]; then 
_STELLA_COMMON_API_INCLUDED_=1



function __api_proxy() {
	local FUNC_NAME=$1
	local _result=
	shift

	for f in $STELLA_API_COMMON_PUBLIC $STELLA_API_APP_PUBLIC $STELLA_API_FEATURE_PUBLIC $STELLA_API_VIRTUAL_PUBLIC; do
		if [ "$f" == "$FUNC_NAME" ]; then
			for j in $STELLA_API_RETURN_FUNCTION; do
				if [ "$j" == "$FUNC_NAME" ]; then
					_result=$(__$FUNC_NAME "$@")
					echo $_result
					return
				fi
			done
			__$FUNC_NAME "$@"
			return
		fi
	done

	echo "** API ERROR : Function $FUNC_NAME does not exist"
}

function __api_list() {
	echo "[ COMMON-API : $STELLA_API_COMMON_PUBLIC ] \
	[ FEATURE-API : $STELLA_API_FEATURE_PUBLIC ] \
	[ APP-API : $STELLA_API_APP_PUBLIC ] 
	[ VIRTUAL-API : $STELLA_API_VIRTUAL_PUBLIC ]"
}

fi