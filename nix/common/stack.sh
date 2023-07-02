#!sh
if [ ! "$_STELLA_STACK_INCLUDED_" = "1" ]; then
_STELLA_STACK_INCLUDED_=1
# inspired from Example 26-14. Emulating a push-down stack
# http://www.linuxtopia.org/online_books/advanced_bash_scripting_guide/arrays.html






__stack_push() {
	local __name="$1"
	if [ -z "${__name}" ]; then
		return
	fi

	local __ptr="_STELLA_STACK_SP_${__name}"
	local __stack="_STELLA_STACK_${__name}"

	eval "${__ptr}=\$(( ${__ptr} + 1 ))"
	eval "${__stack}[${!__ptr}]=\$2"
	
	#_STELLA_STACK_SP=$(( _STELLA_STACK_SP + 1 ))
	#_STELLA_STACK_[$_STELLA_STACK_SP]="$2"

	return
}

__stack_pop() {
	local __name="$1"
	local __var="$2"

	if [ -z "${__name}" ]; then
		return
	fi

	local __ptr="_STELLA_STACK_SP_${__name}"
	local __stack="_STELLA_STACK_${__name}"

	local __data=

	if [ "${!__ptr}" -eq "0" ]; then
		# stack is empty
	 	return
	else
		eval "__data=\${${__stack}[${!__ptr}]}"
		eval "${__ptr}=\$(( ${__ptr} - 1 ))"
		#__data="${_STELLA_STACK_[$_STELLA_STACK_SP]}"
		#_STELLA_STACK_SP=$(( _STELLA_STACK_SP - 1 ))
		
		if [ -z "${__var}" ]; then
			echo "${__data}"
		else
			eval "${__var}=\"${__data}\""
		fi
	fi
}

__stack_init() {
	local __name="$1"
	if [ -z "$__name" ]; then
		return
	fi

	local __ptr="_STELLA_STACK_SP_${__name}"
	local __stack="_STELLA_STACK_${__name}"
	eval "unset ${__stack}"
	eval "declare -a ${__stack}"
	# NOTE : position 0 on stack is always empty
	eval "${__ptr}=0"
}


# init a default stella stack
__stack_init "STELLA"

fi
