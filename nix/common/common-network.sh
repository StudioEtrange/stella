if [ ! "$_STELLA_COMMON_NET_INCLUDED_" == "1" ]; then 
_STELLA_COMMON_NET_INCLUDED_=1


# --------------- PROXY INIT ----------------

function __init_proxy() {
	if [ -f "$STELLA_ROOT/.stella-env" ]; then
		__get_key "$STELLA_ROOT/.stella-env" "STELLA_PROXY" "ACTIVE" "PREFIX"
	fi

	if [ ! "$STELLA_PROXY_ACTIVE" == "" ]; then
		__get_key "$STELLA_ROOT/.stella-env" "STELLA_PROXY_$STELLA_PROXY_ACTIVE" "PROXY_HOST" "PREFIX"
		__get_key "$STELLA_ROOT/.stella-env" "STELLA_PROXY_$STELLA_PROXY_ACTIVE" "PROXY_PORT" "PREFIX"
		__get_key "$STELLA_ROOT/.stella-env" "STELLA_PROXY_$STELLA_PROXY_ACTIVE" "PROXY_USER" "PREFIX"
		__get_key "$STELLA_ROOT/.stella-env" "STELLA_PROXY_$STELLA_PROXY_ACTIVE" "PROXY_PASS" "PREFIX"

		eval STELLA_PROXY_HOST=$(echo '$STELLA_PROXY_'$STELLA_PROXY_ACTIVE'_PROXY_HOST')
		eval STELLA_PROXY_PORT=$(echo '$STELLA_PROXY_'$STELLA_PROXY_ACTIVE'_PROXY_PORT')
		
		eval STELLA_PROXY_USER=$(echo '$STELLA_PROXY_'$STELLA_PROXY_ACTIVE'_PROXY_USER')
		if [ "$STELLA_PROXY_USER" == "" ]; then
			STELLA_HTTP_PROXY=http://$STELLA_PROXY_HOST:$STELLA_PROXY_PORT
			STELLA_HTTPS_PROXY=https://$STELLA_PROXY_HOST:$STELLA_PROXY_PORT
		else
			eval STELLA_PROXY_PASS=$(echo '$STELLA_PROXY_'$STELLA_PROXY_ACTIVE'_PROXY_PASS')

			STELLA_HTTP_PROXY=http://$STELLA_PROXY_USER:$STELLA_PROXY_PASS@$STELLA_PROXY_HOST:$STELLA_PROXY_PORT
			STELLA_HTTPS_PROXY=https://$STELLA_PROXY_USER:$STELLA_PROXY_PASS$STELLA_PROXY_HOST:$STELLA_PROXY_PORT
		fi

		https_proxy="$STELLA_HTTPS_PROXY"
		http_proxy="$STELLA_HTTP_PROXY"

		export https_proxy="$STELLA_HTTPS_PROXY"
		export http_proxy="$STELLA_HTTP_PROXY"

		echo "STELLA Proxy Active : $STELLA_PROXY_ACTIVE [ $STELLA_PROXY_HOST:$STELLA_PROXY_PORT ]"


		__proxy_override
	fi

	
}

# ---------------- SHIM FUNCTIONS -----------------------------
function __proxy_override() {
	
	

	function wget() {
		echo $(command wget --execute "$@")
	}


	# http_proxy = http://votre_proxy:port_proxy/
	# proxy_user = votre_user_proxy
	# proxy_password = votre_mot_de_passe
	# use_proxy = on
	# wait = 15

	function curl() {
		[ ! "$STELLA_PROXY_USER" == "" ] && echo $(command curl -x "$STELLA_PROXY_HOST:$STELLA_PROXY_PORT" --proxy-user "$STELLA_PROXY_USER:$STELLA_PROXY_PASS" "$@")
		[ "$STELLA_PROXY_USER" == "" ] && echo $(command curl -x "$STELLA_PROXY_HOST:$STELLA_PROXY_PORT" "$@")
	}


	function git() {
		https_proxy="$STELLA_HTTPS_PROXY" http_proxy="$STELLA_HTTP_PROXY" command git "$@"
	}

	function hg() {
		echo $(command hg --config http_proxy.host="$STELLA_PROXY_HOST":"$STELLA_PROXY_PORT" --config http_proxy.user="$STELLA_PROXY_USER" --config http_proxy.passwd="$STELLA_PROXY_PASS" "$@")
	}

	function mvn() {

		#export HTTPS_PROXY="$STELLA_HTTP_PROXY"
		#export HTTP_PROXY="$STELLA_HTTP_PROXY"
		[ ! "$STELLA_PROXY_USER" == "" ] && command mvn -DproxyActive=true -DproxyId="$STELLA_PROXY_ACTIVE" -DproxyHost="$STELLA_PROXY_HOST" -DproxyPort="$STELLA_PROXY_PORT" -DproxyUsername="$STELLA_PROXY_USER" -DproxyPassword="$STELLA_PROXY_PASS" "$@"
		[ "$STELLA_PROXY_USER" == "" ] && command mvn -DproxyActive=true  -DproxyId="$STELLA_PROXY_ACTIVE" -DproxyHost="$STELLA_PROXY_HOST" -DproxyPort="$STELLA_PROXY_PORT" "$@"
	}

	function npm() {
		command npm --https-proxy="$HTTPS_PROXY" --http-proxy="$HTTP_PROXY" "$@"	
	}

	function brew() {
				# export HTTPS_PROXY="$HTTP_PROXY"
				# export HTTP_PROXY="$HTTP_PROXY"
				# export http_proxy="$HTTP_PROXY"
				# export ALL_PROXY="$HTTP_PROXY"
			# export https_proxy="$STELLA_HTTPS_PROXY"
			# export http_proxy="$STELLA_HTTPS_PROXY" 
			https_proxy="$STELLA_HTTPS_PROXY"  http_proxy="$STELLA_HTTP_PROXY" command brew "$@"
	}

}

# -------------------- FUNCTIONS-----------------

function __register_proxy() {
	local _name=$1
	local _host=$2
	local _port=$3
	local _user=$4
	local _pass=$5

	__add_key "$STELLA_ROOT/.stella-env" "STELLA_PROXY_$_name" "PROXY_HOST" "$_host"
	__add_key "$STELLA_ROOT/.stella-env" "STELLA_PROXY_$_name" "PROXY_PORT" "$_port"
	__add_key "$STELLA_ROOT/.stella-env" "STELLA_PROXY_$_name" "PROXY_USER" "$_user"
	__add_key "$STELLA_ROOT/.stella-env" "STELLA_PROXY_$_name" "PROXY_PASS" "$_pass"
}

function __enable_proxy() {
	local _name=$1
	__add_key "$STELLA_ROOT/.stella-env" "STELLA_PROXY" "ACTIVE" "$_name"
	__init_proxy
}

function __disable_proxy() {
	__enable_proxy
	echo "STELLA Proxy Disabled"
}
fi