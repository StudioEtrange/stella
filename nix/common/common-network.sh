#!sh
if [ ! "$_STELLA_COMMON_NET_INCLUDED_" = "1" ]; then
_STELLA_COMMON_NET_INCLUDED_=1


# --------------- PROXY INIT ----------------

__init_proxy() {
	__reset_proxy_values
	__read_proxy_values

	if [ ! "$STELLA_PROXY_ACTIVE" = "" ]; then
		# do not set system proxy values if we uses values from system
		[ ! "$STELLA_PROXY_ACTIVE" = "FROM_SYSTEM" ] && __set_system_proxy_values
		__log "STELLA Proxy : $STELLA_PROXY_SCHEMA://$STELLA_PROXY_HOST:$STELLA_PROXY_PORT"
		__log "STELLA Proxy : bypass for $STELLA_NO_PROXY"
		__proxy_override
	fi
}

__read_proxy_values() {

	use_system_proxy_setting="OFF"

	if [ -f "$STELLA_ENV_FILE" ]; then
		__get_key "$STELLA_ENV_FILE" "STELLA_PROXY" "ACTIVE" "PREFIX"

		if [ ! "$STELLA_PROXY_ACTIVE" = "" ]; then
			__get_key "$STELLA_ENV_FILE" "STELLA_PROXY_$STELLA_PROXY_ACTIVE" "PROXY_HOST" "PREFIX"
			__get_key "$STELLA_ENV_FILE" "STELLA_PROXY_$STELLA_PROXY_ACTIVE" "PROXY_PORT" "PREFIX"
			__get_key "$STELLA_ENV_FILE" "STELLA_PROXY_$STELLA_PROXY_ACTIVE" "PROXY_USER" "PREFIX"
			__get_key "$STELLA_ENV_FILE" "STELLA_PROXY_$STELLA_PROXY_ACTIVE" "PROXY_PASS" "PREFIX"
			__get_key "$STELLA_ENV_FILE" "STELLA_PROXY_$STELLA_PROXY_ACTIVE" "PROXY_SCHEMA" "PREFIX"

			# read NO_PROXY values from env file
			__get_key "$STELLA_ENV_FILE" "STELLA_PROXY" "NO_PROXY" "PREFIX"
			if [ "$STELLA_PROXY_NO_PROXY" = "" ]; then
				STELLA_NO_PROXY="$STELLA_DEFAULT_NO_PROXY"
			else
				[ "$STELLA_DEFAULT_NO_PROXY" = "" ] && STELLA_NO_PROXY="$STELLA_PROXY_NO_PROXY"
				[ ! "$STELLA_DEFAULT_NO_PROXY" = "" ] && STELLA_NO_PROXY="$STELLA_DEFAULT_NO_PROXY","$STELLA_PROXY_NO_PROXY"
			fi
			STELLA_NO_PROXY=${STELLA_NO_PROXY%,}

			eval STELLA_PROXY_HOST=$(echo '$STELLA_PROXY_'$STELLA_PROXY_ACTIVE'_PROXY_HOST')
			eval STELLA_PROXY_PORT=$(echo '$STELLA_PROXY_'$STELLA_PROXY_ACTIVE'_PROXY_PORT')
			eval STELLA_PROXY_SCHEMA=$(echo '$STELLA_PROXY_'$STELLA_PROXY_ACTIVE'_PROXY_SCHEMA')
			[ "$STELLA_PROXY_SCHEMA" = "" ] && STELLA_PROXY_SCHEMA="http"

			eval STELLA_PROXY_USER=$(echo '$STELLA_PROXY_'$STELLA_PROXY_ACTIVE'_PROXY_USER')
			if [ "$STELLA_PROXY_USER" = "" ]; then
				STELLA_HTTP_PROXY=$STELLA_PROXY_SCHEMA://$STELLA_PROXY_HOST:$STELLA_PROXY_PORT
				STELLA_HTTPS_PROXY=$STELLA_PROXY_SCHEMA://$STELLA_PROXY_HOST:$STELLA_PROXY_PORT
			else
				eval STELLA_PROXY_PASS=$(echo '$STELLA_PROXY_'$STELLA_PROXY_ACTIVE'_PROXY_PASS')
				STELLA_HTTP_PROXY=$STELLA_PROXY_SCHEMA://$STELLA_PROXY_USER:$STELLA_PROXY_PASS@$STELLA_PROXY_HOST:$STELLA_PROXY_PORT
				STELLA_HTTPS_PROXY=$STELLA_PROXY_SCHEMA://$STELLA_PROXY_USER:$STELLA_PROXY_PASS@$STELLA_PROXY_HOST:$STELLA_PROXY_PORT
			fi

			__log "STELLA Proxy : $STELLA_PROXY_ACTIVE is ACTIVE"
		else
			use_system_proxy_setting="ON"
		fi
	else
		use_system_proxy_setting="ON"
	fi

	[ "$use_system_proxy_setting" = "ON" ] && __read_system_proxy_values

}

# reset stella proxy values
__reset_proxy_values() {
	STELLA_PROXY_ACTIVE=
	STELLA_PROXY_HOST=
	STELLA_PROXY_SCHEMA=
	STELLA_PROXY_USER=
	STELLA_PROXY_PASS=
	STELLA_HTTP_PROXY=
	STELLA_HTTPS_PROXY=
	STELLA_PROXY_NO_PROXY=
	STELLA_NO_PROXY=
}



__read_system_proxy_values() {

	[ "$HTTP_PROXY" = "" ] && STELLA_HTTP_PROXY="$http_proxy" || STELLA_HTTP_PROXY="$HTTP_PROXY"
	[ "$HTTPS_PROXY" = "" ] && STELLA_HTTPS_PROXY="$https_proxy" || STELLA_HTTPS_PROXY="$HTTPS_PROXY"


	[ "$NO_PROXY" = "" ] && STELLA_NO_PROXY="$no_proxy" || STELLA_NO_PROXY="$NO_PROXY"
	STELLA_NO_PROXY=${STELLA_NO_PROXY%,}


	if [ ! "$STELLA_HTTP_PROXY" = "" ]; then
		STELLA_PROXY_ACTIVE="FROM_SYSTEM"

		__uri_parse "$STELLA_HTTP_PROXY"
		STELLA_PROXY_SCHEMA=$__stella_uri_schema
		STELLA_PROXY_USER="$__stella_uri_user"
		STELLA_PROXY_PASS="$__stella_uri_password"
		STELLA_PROXY_HOST="$__stella_uri_host"
		STELLA_PROXY_PORT="$__stella_uri_port"
	fi

}

__set_system_proxy_values() {

	# override already existing system proxy env var only if stella proxy is active
	if [ ! "$STELLA_PROXY_ACTIVE" = "" ]; then
		http_proxy="$STELLA_HTTP_PROXY"
		export http_proxy="$STELLA_HTTP_PROXY"

		HTTP_PROXY="$http_proxy"
		export HTTP_PROXY="$http_proxy"

		https_proxy="$STELLA_HTTPS_PROXY"
		export https_proxy="$STELLA_HTTPS_PROXY"

		HTTPS_PROXY="$https_proxy"
		export HTTPS_PROXY="$https_proxy"

		if [ ! "$STELLA_NO_PROXY" = "" ]; then
			STELLA_NO_PROXY=${STELLA_NO_PROXY%,}
			no_proxy="$STELLA_NO_PROXY"
			NO_PROXY="$STELLA_NO_PROXY"
			export no_proxy="$STELLA_NO_PROXY"
			export NO_PROXY="$STELLA_NO_PROXY"
		fi
	fi


}


# reset system proxy env (for example when disabling previously activated stella proxy)
__reset_system_proxy_values() {
	http_proxy=
	export http_proxy=
	HTTP_PROXY=
	export HTTP_PROXY=
	https_proxy=
	export https_proxy=
	HTTPS_PROXY=
	export HTTPS_PROXY=
	no_proxy=
	NO_PROXY=
	export no_proxy=
	export NO_PROXY=
}



# ---------------- SHIM FUNCTIONS -----------------------------
__proxy_override() {

	# sudo do not preserve env var by default
	type sudo &>/dev/null && \
	function sudo() {
		command sudo no_proxy="$STELLA_NO_PROXY" https_proxy="$STELLA_HTTPS_PROXY" http_proxy="$STELLA_HTTP_PROXY" "$@"
	}

	#bazel :
	# proxy arg for bazel (not tested)
	# https://github.com/bazelbuild/bazel/issues/587
	#bazel --host_jvm_args=-Dhttp.proxyHost=my.proxy -Dhttp.proxyPort=8888 -Dhttps.proxyHost=....

	#yum
	#use env var or yum.conf

	#wget :
	#use env var
	# http_proxy = http://votre_proxy:port_proxy/
	# proxy_user = votre_user_proxy
	# proxy_password = votre_mot_de_passe
	# use_proxy = on
	# wait = 15
	function wget() {
		# NOTE a lot of these wget option do not exist on different wget version
		[ ! "$STELLA_PROXY_USER" = "" ] && no_proxy="$STELLA_NO_PROXY" https_proxy="$STELLA_HTTPS_PROXY" http_proxy="$STELLA_HTTP_PROXY" command wget --wait=15 --proxy=on --proxy-user="$STELLA_PROXY_USER" --proxy-password="$STELLA_PROXY_PASS" "$@"
		[ "$STELLA_PROXY_USER" = "" ] && no_proxy="$STELLA_NO_PROXY" https_proxy="$STELLA_HTTPS_PROXY" http_proxy="$STELLA_HTTP_PROXY" command wget --wait=15 --proxy=on --proxy-user="$STELLA_PROXY_USER" --proxy-password="$STELLA_PROXY_PASS" "$@"
	}

	function curl() {
		[ ! "$STELLA_PROXY_USER" = "" ] && echo $(command curl --noproxy $STELLA_NO_PROXY --proxy "$STELLA_PROXY_HOST:$STELLA_PROXY_PORT" --proxy-user "$STELLA_PROXY_USER:$STELLA_PROXY_PASS" "$@")
		[ "$STELLA_PROXY_USER" = "" ] && echo $(command curl --noproxy $STELLA_NO_PROXY --proxy "$STELLA_PROXY_HOST:$STELLA_PROXY_PORT" "$@")
	}


	function git() {
		no_proxy="$STELLA_NO_PROXY" https_proxy="$STELLA_HTTPS_PROXY" http_proxy="$STELLA_HTTP_PROXY" command git "$@"
	}

	function hg() {
		echo $(command hg --config http_proxy.host="$STELLA_PROXY_HOST":"$STELLA_PROXY_PORT" --config http_proxy.user="$STELLA_PROXY_USER" --config http_proxy.passwd="$STELLA_PROXY_PASS" "$@")
	}

	function mvn() {
		# -DnonProxyHosts=\""${STELLA_NO_PROXY//,/|}"\" => seems to not, work use instead -Dhttp.nonProxyHosts
		[ ! "$STELLA_PROXY_USER" = "" ] && command mvn -DproxyActive=true -DproxyId="$STELLA_PROXY_ACTIVE" -DproxyHost="$STELLA_PROXY_HOST" -DproxyPort="$STELLA_PROXY_PORT" -Dhttp.nonProxyHosts=\""${STELLA_NO_PROXY//,/|}"\" -DproxyUsername="$STELLA_PROXY_USER" -DproxyPassword="$STELLA_PROXY_PASS" "$@"
		[ "$STELLA_PROXY_USER" = "" ] && command mvn -DproxyActive=true  -DproxyId="$STELLA_PROXY_ACTIVE" -DproxyHost="$STELLA_PROXY_HOST" -DproxyPort="$STELLA_PROXY_PORT" -Dhttp.nonProxyHosts=\""${STELLA_NO_PROXY//,/|}"\" "$@"

	}

	function npm() {
		command npm --https-proxy="$STELLA_HTTPS_PROXY" --proxy="$STELLA_HTTP_PROXY" "$@"
	}

	function brew() {
		no_proxy="$STELLA_NO_PROXY" https_proxy="$STELLA_HTTPS_PROXY" http_proxy="$STELLA_HTTP_PROXY" command brew "$@"
	}



	# PROXY for DOCKER ----------

	# DOCKER ENGINE / DAEMON
	#		Docker daemon is used when accessing docker hub (like for search, pull, ...) and registry also when pushing (push)
	#		see https://docs.docker.com/engine/admin/systemd/#/http-proxy
	# 	Docker daemon rely on HTTP_PROXY env
	#		but the env var need to be setted in daemon environement when daemon is launched (not after)
	#		Instead configure
	# 		for Docker Upstart and SysVinit : /etc/default/docker
	#			for Systemd : /etc/systemd/system/docker.service.d/http-proxy.conf
	#			for ? : /etc/sysconfig/docker
	#			for boot2docker : /var/lib/boot2docker/profile
	#			and add proxy information
	#			/etc/default/docker
	#						export http_proxy="http://HOST:PORT"
	#						export https_proxy="http://HOST:PORT"
	#						export HTTP_PROXY="http://HOST:PORT"
	#						export HTTPS_PROXY="http://HOST:PORT"
	#			/etc/systemd/system/docker.service.d/http-proxy.conf
	#						[Service]
	#						Environment="HTTP_PROXY=http://HOST:PORT"
	#							OR EnvironmentFile=/etc/network-environment (content of envfile : HTTP_PROXY=http://HOST:PORT HTTPS_PROXY=http://HOST:PORT)
	#						TO SEE VALUES :
	#											systemctl show -p EnvironmentFile docker.service
	#											systemctl show -p Environment docker.service
	#
	#						Then use : systemctl daemon-reload docker
	#											 systemctl start docker
	#
	# DOCKER CLIENT
	# docker client rely on HTTP_PROXY env to communicate to docker daemon via http
	#		NOTE : so you may set no-proxy env var to not use proxy when accessing daemon
	# 		eval $(docker-machine env <machine-id> --no-proxy)
	#		docker run -it ubuntu /bin/bash
	#
	# DOCKER MACHINE
	# http://stackoverflow.com/a/29303930
	# Docker machine rely on HTTP_PROXY env (ie : for download boot2docker iso)
	# How to set proxy as env var inside docker-machine (ie : HTTP_PROXY)
	# 		docker-machine create -d virtualbox --engine-env http_proxy=http://example.com:8080 --engine-env https_proxy=https://example.com:8080 --engine-env NO_PROXY=example2.com <machine-id>
	# 		docker-machine create -d virtualbox --engine-env http_proxy=$STELLA_HTTP_PROXY --engine-env https_proxy=$STELLA_HTTPS_PROXY --engine-env NO_PROXY=$STELLA_NO_PROXY <machine-id>
	# 		NOTE :
	#				This will only affect docker daemon configuration file inside the VM machine (/var/lib/boot2docker/profile) and set some HTTP_PROXY env vars
	# How to retrieve ip of a docker-machine
	# 		docker-machine ip <machine-id>
	# How to setup docker client to use a docker machine
	# 		eval $(docker-machine env <machine-id>)
	# How to set no_proxy in current shell with ip of a docker machine
	# 		eval $(docker-machine env --no-proxy <machine-id>)
	#			WARN : it will set 'no_proxy' env var, not 'NO_PROXY' env var. And if 'NO_PROXY' is setted, 'no_proxy' is not used
	#						so use instead : __no_proxy_for $(docker-machine ip <machine-id>)
	#
	# DOCKER FILE
	# into docker file, env var should be setted with ENV
	#		ENV http_proxy http://<proxy_host>:<proxy_port>

	function docker-machine() {
		if [ "$1" = "create" ]; then
			shift 1
			command docker-machine create --engine-env http_proxy="$STELLA_HTTP_PROXY" --engine-env https_proxy="$STELLA_HTTPS_PROXY" --engine-env no_proxy="$STELLA_NO_PROXY" "$@"
		else
			if [ "$1" = "env" ]; then
				echo "
__no_proxy_for $(command docker-machine ip $2);
$(command docker-machine "$@");
"
			else
			  command docker-machine "$@"
			fi
		fi
	}

	# minishift, which relies on a boot2docker VM , needs docker daemon env to be setted
	function minishift() {
		if [ "$1" = "start" ]; then
			shift 1
			command minishift start --docker-env http_proxy="$STELLA_HTTP_PROXY" --docker-env https_proxy="$STELLA_HTTP_PROXY" "$@"
			# TODO : passing no_proxy to env is bugged in minishift args
			#--docker-env no_proxy="$STELLA_NO_PROXY"
			__no_proxy_for $(command minishift ip)
		else
			if [ "$1" = "docker-env" ]; then
				echo "
__no_proxy_for $(command minishift ip);
$(command minishift "$@");
"
			else
				__no_proxy_for $(command minishift ip)
				command minishift "$@"
			fi
		fi
	}

	function minikube() {
		if [ "$1" = "start" ]; then
			shift 1
			command minikube start --docker-env http_proxy="$STELLA_HTTP_PROXY" --docker-env https_proxy="$STELLA_HTTP_PROXY" "$@"
			# TODO : passing no_proxy to env is bugged in minikube args
			#--docker-env no_proxy="$STELLA_NO_PROXY"
			__no_proxy_for $(command minikube ip)
		else
			if [ "$1" = "docker-env" ]; then
				echo "
__no_proxy_for $(command minikube ip);
$(command minikube "$@");
"
			else
				__no_proxy_for $(command minikube ip)
				command minikube "$@"
			fi
		fi

	}


}

# -------------------- FUNCTIONS-----------------
# support ssh:// and vagrant://
# http://www.cyberciti.biz/faq/linux-unix-bsd-sudo-sorry-you-must-haveattytorun/
__ssh_execute() {
	local __uri="$1"
	local __cmd="$2"

	__require "ssh" "ssh"

	__uri_parse "$_uri"

	if [ "$__stella_uri_schema" = "ssh" ]; then
		__ssh_port="22"
		[ ! "$__stella_uri_port" = "" ] && __ssh_port="$__stella_uri_port"
		__ssh_opt="-p $__ssh_port"
	fi

	if [ "$__stella_uri_schema" = "vagrant" ]; then
		__require "vagrant" "vagrant"
		__vagrant_ssh_opt="$(vagrant ssh-config $__stella_uri_host | sed '/^[[:space:]]*$/d' |  awk '/^Host .*$/ { detected=1; }  { if(start) {print " -o "$1"="$2}; if(detected) start=1; }')"
		__stella_uri_host="localhost"
	fi

	# NOTE : __stella_uri_address contain user
	# we need to build a user@host without port number
	local __ssh_user=
	[ ! "$__stella_uri_user" = "" ] && __ssh_user="$__stella_uri_user"@

	ssh -t $__ssh_opt $__vagrant_ssh_opt "$__ssh_user$__stella_uri_host" "$__cmd"
}


# TODO : these function support only ipv4
__get_network_info() {
	local _err=
	type netstat &>/dev/null || _err=1
	if [ "$_err" = "" ]; then
		# NOTE : we pick the first default interface if we have more than one
		STELLA_DEFAULT_INTERFACE=$(netstat -rn | awk '/^0.0.0.0/ {thif=substr($0,74,10); print thif;} /^default.*UG/ {thif=substr($0,65,10); print thif;}' | head -1)
	fi

	_err=
	type ifconfig &>/dev/null || _err=1
	if [ "$_err" = "" ]; then
		# contains default ip
		STELLA_HOST_DEFAULT_IP="$(__get_ip_from_interface ${STELLA_DEFAULT_INTERFACE})"
		# contains all available IP
		STELLA_HOST_IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*')
	fi
}

__get_ip_from_interface() {
	local _if="$1"
	local _err=
	type ifconfig &>/dev/null || _err=1
	if [ "$_err" = "" ]; then
		echo "$(ifconfig ${_if} 2>/dev/null | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*')"
	fi
}

__proxy_tunnel() {
	local _target_proxy_name="$1"
	local _bridge_uri="$2"

	__get_key "$STELLA_ENV_FILE" "STELLA_PROXY_$_target_proxy_name" "PROXY_HOST" "PREFIX"
	__get_key "$STELLA_ENV_FILE" "STELLA_PROXY_$_target_proxy_name" "PROXY_PORT" "PREFIX"
	__get_key "$STELLA_ENV_FILE" "STELLA_PROXY_$_target_proxy_name" "PROXY_USER" "PREFIX"
	__get_key "$STELLA_ENV_FILE" "STELLA_PROXY_$_target_proxy_name" "PROXY_PASS" "PREFIX"
	__get_key "$STELLA_ENV_FILE" "STELLA_PROXY_$_target_proxy_name" "PROXY_SCHEMA" "PREFIX"

	eval _target_proxy_host=$(echo '$STELLA_PROXY_'$_target_proxy_name'_PROXY_HOST')
	eval _target_proxy_port=$(echo '$STELLA_PROXY_'$_target_proxy_name'_PROXY_PORT')
	eval _target_proxy_schema=$(echo '$STELLA_PROXY_'$_target_proxy_name'_PROXY_SCHEMA')

	__register_proxy "_STELLA_TUNNEL_" "http://localhost:7999"
	__enable_proxy "_STELLA_TUNNEL_"

	# TODO : what if targeted proxy require a user/password ?

	# NOTE : -4 : force ipv4 connection
	ssh -4 -N -L 7999:$_target_proxy_host:$_target_proxy_port $_bridge_uri

	__disable_proxy
}

__register_proxy() {
	local _proxy_name="$1"

	__uri_parse "$2"

	local _host="$__stella_uri_host"
	local _port="$__stella_uri_port"
	local _user="$__stella_uri_user"
	local _pass="$__stella_uri_password"
	local _schema="$__stella_uri_schema"

	if [ "$_schema" = "" ]; then
		_schema="http"
	fi

	__add_key "$STELLA_ENV_FILE" "STELLA_PROXY_$_proxy_name" "PROXY_HOST" "$_host"
	__add_key "$STELLA_ENV_FILE" "STELLA_PROXY_$_proxy_name" "PROXY_PORT" "$_port"
	__add_key "$STELLA_ENV_FILE" "STELLA_PROXY_$_proxy_name" "PROXY_USER" "$_user"
	__add_key "$STELLA_ENV_FILE" "STELLA_PROXY_$_proxy_name" "PROXY_PASS" "$_pass"
	__add_key "$STELLA_ENV_FILE" "STELLA_PROXY_$_proxy_name" "PROXY_SCHEMA" "$_schema"
}

__enable_proxy() {
	local _name=$1
	__add_key "$STELLA_ENV_FILE" "STELLA_PROXY" "ACTIVE" "$_name"
	__init_proxy
}

__disable_proxy() {
	__add_key "$STELLA_ENV_FILE" "STELLA_PROXY" "ACTIVE"

	__log "STELLA Proxy Disabled"
	__reset_proxy_values
	__reset_system_proxy_values
}


# no_proxy is read from conf file only if a stella proxy is active
# _list_uri could be a list of no proxy values separated with comma
__register_no_proxy() {
	local _list_uri="$1"
	__get_key "$STELLA_ENV_FILE" "STELLA_PROXY" "NO_PROXY" "PREFIX"

	_list_uri="${_list_uri//,/ }"
	for p in $_list_uri; do
			__uri_parse "$p"

			_host="$__stella_uri_host"

			_exist=
			STELLA_PROXY_NO_PROXY="${STELLA_PROXY_NO_PROXY//,/ }"
			for h in $STELLA_PROXY_NO_PROXY; do
				[ "$h" = "$_host" ] && _exist=1
			done

			if [ "$_exist" = "" ]; then
				if [ "$STELLA_PROXY_NO_PROXY" = "" ]; then
					STELLA_PROXY_NO_PROXY="$_host"
				else
					STELLA_PROXY_NO_PROXY="$STELLA_PROXY_NO_PROXY $_host"
				fi

				__add_key "$STELLA_ENV_FILE" "STELLA_PROXY" "NO_PROXY" "${STELLA_PROXY_NO_PROXY// /,}"
			fi
	done
	__init_proxy

}

# only temporary no proxy
# will be reseted each time proxy values are read from env file
__no_proxy_for() {
	local _uri=$1

	__uri_parse "$_uri"
	local _host="$__stella_uri_host"


	local _exist=
	local _tmp_no_proxy="${STELLA_NO_PROXY//,/ }"
	for h in $_tmp_no_proxy; do
		[ "$h" = "$_host" ] && _exist=1
	done

	if [ "$_exist" = "" ]; then
		__log "STELLA Proxy : temp proxy bypass for $_host"
		[ ! "$STELLA_NO_PROXY" = "" ] && STELLA_NO_PROXY="$STELLA_NO_PROXY","$_host"
		[ "$STELLA_NO_PROXY" = "" ] && STELLA_NO_PROXY="$_host"
		__set_system_proxy_values
	fi

}
fi
