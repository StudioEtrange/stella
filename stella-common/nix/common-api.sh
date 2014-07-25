if [ ! "$_COMMON_API_INCLUDED_" == "1" ]; then 
_COMMON_API_INCLUDED_=1



function __api_proxy() {
	local FUNC_NAME=$1
	local _result=
	shift

	for f in $STELLA_API_COMMON_PUBLIC $STELLA_API_APP_PUBLIC $STELLA_API_TOOLS_PUBLIC $STELLA_API_VIRTUAL_PUBLIC; do
		if [ "$f" == "$FUNC_NAME" ]; then
			_result=$(__$FUNC_NAME $*)
			if [ ! "$_result" == "" ]; then
				echo $_result
			fi
			return
		fi
	done

	echo "** API ERROR : Function $FUNC_NAME does not exist"
}

function __api_list() {
	echo "[ COMMON-API : $STELLA_API_COMMON_PUBLIC ] [ TOOLS-API : $STELLA_API_TOOLS_PUBLIC ] [ APP-API : $STELLA_API_APP_PUBLIC ] [ VIRTUAL-API : $STELLA_API_VIRTUAL_PUBLIC ]"
}

fi