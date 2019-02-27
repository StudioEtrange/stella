#!sh
if [ ! "$_STELLA_COMMON_INCLUDED_" = "1" ]; then
_STELLA_COMMON_INCLUDED_=1

# TODO : do not hash
#turns off bash's hash function
#set +h


# VARIOUS-----------------------------

# Try to sudo - if not exec without sudo
# On some systems, sudo do not exist, and we may already exec cmd as root
#		sample : __sudo_exec apt-get update
__sudo_exec() {
	type sudo &>/dev/null && \
		sudo -E "$@" || \
		"$@"
}


# Share sudo authentification between ssh sessions until __sudo_ssh_end_session is called
__sudo_ssh_begin_session() {
	local _uri="$1"
	__ssh_execute "$_uri" "sudo -v; echo 'Defaults !tty_tickets' | sudo tee /etc/sudoers.d/rsync_temp_hack_stella" "SHARED"
	# NOTE : needs time before modification is used by sshd
	# TODO ; try this fix https://www.shell-tips.com/2014/09/08/sudo-sorry-you-must-have-a-tty-to-run-sudo/ (!requiretty)
	sleep 2
}

__sudo_ssh_end_session() {
	local _uri="$1"
	__ssh_execute "$_uri" "rm -v /etc/sudoers.d/rsync_temp_hack_stella" "SHARED SUDO"
}

# NOTE : keep sudo authentification alive until __sudo_end_session is called
# 				https://stackoverflow.com/a/30547074
# 				https://serverfault.com/a/833888
# NOTE : trap signal
# 			 SIGKILL and SIGSTOP cannot be trapped
#				 ERR and EXIT are pseudo-signals
# https://www.ibm.com/developerworks/aix/library/au-usingtraps/
# https://linuxconfig.org/how-to-modify-scripts-behavior-on-signals-using-bash-traps
# NOTE as it catch it catch exit signal
#				could have side effect when bootstrapping an env
__sudo_begin_session() {
    sudo -v || exit $?
    ( while true; do sudo -nv; sleep 50; done; ) &
    STELLA_SUDO_PID="$!"
    trap '__sudo_end_session; exit' SIGABRT SIGHUP SIGINT SIGQUIT SIGTERM ERR EXIT
}
__sudo_end_session() {
		echo "** Ending sudo session $STELLA_SUDO_PID"
    kill -0 "$STELLA_SUDO_PID"
    trap - SIGABRT SIGHUP SIGINT SIGQUIT SIGTERM ERR EXIT
    sudo -k
}




# option :
# ENDING_CHAR_REVERSE
# SEP .
__get_last_version() {
	local list=$1
	local opt="$2"

	echo $(__sort_version "$list" "$opt DESC") | cut -d' ' -f 1
}


# sort a list of version

#sorted=$(__sort_version "build507 build510 build403 build4000 build" "ASC")
#echo $sorted
# > build build403 build507 build510 build4000
#sorted=$(__sort_version "1.1.0 1.1.1 1.1.1a 1.1.1b" "ASC SEP .")
#echo $sorted
# > 1.1.0 1.1.1 1.1.1a 1.1.1b
#sorted=$(__sort_version "1.1.0 1.1.1 1.1.1a 1.1.1b" "DESC SEP .")
#echo $sorted
# > 1.1.1b 1.1.1a 1.1.1 1.1.0
#sorted=$(__sort_version "1.1.0 1.1.1 1.1.1alpha 1.1.1beta1 1.1.1beta2" "ASC ENDING_CHAR_REVERSE SEP .")
#echo $sorted
# > 1.1.0 1.1.1alpha 1.1.1beta1 1.1.1beta2 1.1.1
#sorted=$(__sort_version "1.1.0 1.1.1 1.1.1alpha 1.1.1beta1 1.1.1beta2" "DESC ENDING_CHAR_REVERSE SEP .")
#echo $sorted
# > 1.1.1 1.1.1beta2 1.1.1beta1 1.1.1alpha 1.1.0
#sorted=$(__sort_version "1.9.0 1.10.0 1.10.1.1 1.10.1 1.10.1alpha1 1.10.1beta1 1.10.1beta2 1.10.2 1.10.2.1 1.10.2.2 1.10.0RC1 1.10.0RC2" "DESC ENDING_CHAR_REVERSE SEP .")
#echo $sorted
# > 1.10.2.2 1.10.2.1 1.10.2 1.10.1.1 1.10.1 1.10.1beta2 1.10.1beta1 1.10.1alpha1 1.10.0 1.10.0RC2 1.10.0RC1 1.9.0


# NOTE : ending characters in a version number may be ordered in the opposite way example :
# 1.0.1 is more recent than 1.0.1beta so in ASC : 1.0.1beta 1.0.1 and in DESC : 1.0.1 1.0.1beta
# To activate this behaviour use "ENDING_CHAR_REVERSE" option
# we also need to indicate separator only if we use ENDING_CHAR_REVERSE and if there is any separator (obviously)
__sort_version() {
	local list=$1
	local opt="$2"

	local opposite_order_for_ending_chars=OFF
	local mode="ASC"

	local separator=

	local flag_sep=OFF
	for o in $opt; do
		[ "$o" = "ASC" ] && mode=$o
		[ "$o" = "DESC" ] && mode=$o
		[ "$o" = "ENDING_CHAR_REVERSE" ] && opposite_order_for_ending_chars=ON
		# we need separator only if we use ENDING_CHAR_REVERSE and if there is any separator (obviously)
		[ "$flag_sep" = "ON" ] && separator="$o" && flag_sep=OFF
		[ "$o" = "SEP" ] && flag_sep=ON
	done

	local internal_separator=}
	local new_list=
	local match_list=
	local max_number_of_block=0
	local number_of_block=0
	for r in $list; do
		# separate each block of number and block of letter
		[ ! "$separator" = "" ] && new_item="$(echo $r | sed "s,\([0-9]*\)\([^0-9]*\)\([0-9]*\),\1$internal_separator\2$internal_separator\3,g" | sed "s,^\([0-9]\),$internal_separator\1," | sed "s,\([0-9]\)$,\1$internal_separator$separator$internal_separator,")"
		[ "$separator" = "" ] && new_item="$(echo $r | sed "s,\([0-9]*\)\([^0-9]*\)\([0-9]*\),\1$internal_separator\2$internal_separator\3,g" | sed "s,^\([0-9]\),$internal_separator\1," | sed "s,\([0-9]\)$,\1$internal_separator,")"

		if [ "$opposite_order_for_ending_chars" = "OFF" ]; then
			[ "$mode" = "ASC" ] && substitute=A
			[ "$mode" = "DESC" ] && substitute=A
		else
			[ "$mode" = "ASC" ] && substitute=z
			[ "$mode" = "DESC" ] && substitute=z
		fi

		[ ! "$separator" = "" ] && new_item="$(echo $new_item | sed "s,\\$separator,$substitute,g")"

		new_list="$new_list $new_item"
		match_list="$new_item $r $match_list"

		number_of_block="${new_item//[^$internal_separator]}"
		[ "${#number_of_block}" -gt "$max_number_of_block" ] && max_number_of_block="${#number_of_block}"
	done
	max_number_of_block=$[max_number_of_block +1]

	# we detect block made with non-number characters for reverse order of block with non-number characters (except the first one)
	local count=0
	local b
	local i
	local char_block_list=

	for i in $new_list; do
		count=1

		for b in $(echo $i | tr "$internal_separator" "\n"); do
			count=$[$count +1]

			if [ ! "$(echo $b | sed "s,[0-9]*,,g")" = "" ]; then
				char_block_list="$char_block_list $count"
			fi
		done
	done

	# make argument for sort function
	# note : for non-number characters : first non-number character is sorted as wanted (ASC or DESC) and others non-number characters are sorted in the opposite way
	# example : 1.0.1 is more recent than 1.0.1beta so in ASC : 1.0.1beta 1.0.1 and in DESC : 1.0.1 1.0.1beta
	# example : build400 is more recent than build300 so in ASC : build300 build400 and in DESC : build400 build300
	count=0
	local sorted_arg=
	local j
	while [  "$count" -lt "$max_number_of_block" ]; do
		count=$[$count +1]

		block_arg=

		block_is_char=
		for j in $char_block_list; do
			[ "$count" = "$j" ] && block_is_char=1
		done
		if [ "$block_is_char" = "" ]; then
			block_arg=n$block_arg
			[ "$mode" = "ASC" ] && block_arg=$block_arg
			[ "$mode" = "DESC" ] && block_arg=r$block_arg
		else
			[ "$mode" = "ASC" ] && block_arg=$block_arg
			[ "$mode" = "DESC" ] && block_arg=r$block_arg
		fi

		sorted_arg="$sorted_arg -k $count,$count"$block_arg
	done
	[ "$mode" = "ASC" ] && sorted_arg="-t$internal_separator $sorted_arg"
	[ "$mode" = "DESC" ] && sorted_arg="-t$internal_separator $sorted_arg"

	sorted_list="$(echo "$new_list" | tr ' ' '\n' | sort $(echo "$sorted_arg") | tr '\n' ' ')"

	# restore original version strings (alternative to hashtable...)
	local result_list=
	local flag_found=OFF
	local flag=KEY
	for r in $sorted_list; do
		flag_found=OFF
		flag=KEY
		for m in $match_list; do
			if [ "$flag_found" = "ON" ]; then
				result_list="$result_list $m"
				break
			fi
			if [ "$flag" = "KEY" ]; then
				[ "$m" = "$r" ] && flag_found=ON
			fi
		done
	done

	echo "$result_list" | sed -e 's/^ *//' -e 's/ *$//'

}






__url_encode() {
	if [ "$(which xxd 2>/dev/null)" = "" ]; then
		__url_encode_1 "$@"
	else
		__url_encode_with_xxd "$@"
	fi
}

# https://gist.github.com/cdown/1163649
__url_encode_1() {
    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C
		# local LANG=C
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done

    LC_COLLATE=$old_lc_collate
}

# https://gist.github.com/cdown/1163649
# xxd is used to suppoert wide characters
__url_encode_with_xxd() {
  local length="${#1}"
  for (( i = 0; i < length; i++ )); do
    local c="${1:i:1}"
    case $c in
	      [a-zA-Z0-9.~_-]) printf "$c" ;;
	    *) printf "$c" | xxd -p -c1 | while read x;do printf "%%%s" "$x";done
	  esac
	done
}

# Faster solution than __url_encode_1 ? (without xxd)
# http://unix.stackexchange.com/a/60698
__url_encode_2() {
	string=$1; format=; set --
  while
    literal=${string%%[!-._~0-9A-Za-z]*}
    case "$literal" in
      ?*)
        format=$format%s
        set -- "$@" "$literal"
        string=${string#$literal};;
    esac
    case "$string" in
      "") false;;
    esac
  do
    tail=${string#?}
    head=${string%$tail}
    format=$format%%%02x
    set -- "$@" "'$head"
    string=$tail
  done
  printf "$format\\n" "$@"
}

# https://gist.github.com/cdown/1163649
__url_decode() {
    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}


# Build path part of an uri
# ./foo ==> /?foo
# ../foo ==> /?../foo
# /foo ==> /foo
__uri_build_path() {
	local __path="$1"

	if [ "$(__is_abs "$__path")" = "FALSE" ]; then
		echo "/?${__path}"
	else
		echo "${__path}"
	fi
}

# __uri_get_path ssh://host/?foo ==> ./foo
# __uri_get_path local://../foo  ==> ../foo
# __uri_get_path local://?../foo  ==> ../foo
#	__uri_get_path local:///?foo	==> ./foo
# __uri_get_path ssh://host/foo  ==> /foo
# __uri_get_path local:///foo  ==> /foo
# __uri_get_path ssh://host ==> .
__uri_get_path() {
	local _uri="$@"
	local __path

	__uri_parse "$_uri"

	# we may have use absolute path or relative path.
	# if relative path is used, it is specify with local://../foo OR local://?../foo
	#	in case local://../foo form __stella_uri_host will contain the ".."
	if [ ! "${__stella_uri_query:1}" = "" ]; then
		# we use explicit relative path with local://?../foo
		__path="${__stella_uri_query:1}"
	else
		# we use relative path with local://../foo OR we use absolute path with local:///foo/bar
		[ "$__stella_uri_schema" = "local" ] && __path="${__stella_uri_host}${__stella_uri_path}"
		# we use absolute path with other protocol (ssh://host/foo)
		[ ! "$__stella_uri_schema" = "local" ] && __path="${__stella_uri_path}"
	fi

	[ "$__path" = "" ] && __path="."

	if [ "$(__is_abs "$__path")" = "FALSE" ]; then
		[ ! "${__path::1}" = "." ] && __path="./$__path"
	fi

	echo "$__path"
}

# http://wp.vpalos.com/537/uri-parsing-using-bash-built-in-features/ (customized)
# https://tools.ietf.org/html/rfc3986
# URI parsing function
#
# The function creates global variables with the parsed results.
# It returns 0 if parsing was successful or non-zero otherwise.
#
# [schema://][user[:password]@][host][:port][/path][?[arg1=val1]...][#fragment]
__uri_parse() {
	# uri capture
	__stella_uri="$@"

	local path
	local count
	local query
	# top level parsing
	# TODO : warning test this !
	local pattern='^(([a-z0-9]+)://)?((([^:\/]+)(:([^@\/]*))?@)?([^:\/?]*)(:([0-9]+))?)(\/[^?#]*)?(\?[^#]*)?(#.*)?$'
	#local pattern='^(([a-z]+)://)?((([^:\/]+)(:([^@\/]*))?@)?([^:\/?]*)(:([0-9]+))?)(\/[^?#]*)?(\?[^#]*)?(#.*)?$'

	__stella_uri_schema=
	__stella_uri_address=
	__stella_uri_user=
	__stella_uri_password=
	__stella_uri_host=
	__stella_uri_port=
	__stella_uri_path=
	__stella_uri_query=
	__stella_uri_fragment=

	if [[ ! "$__stella_uri" =~ $pattern ]]; then
		__stella_uri=
		return 1;
	fi

	# component extraction
	__stella_uri=${BASH_REMATCH[0]}
	__stella_uri_schema=${BASH_REMATCH[2]}
	__stella_uri_address=${BASH_REMATCH[3]}
	__stella_uri_user=${BASH_REMATCH[5]}
	__stella_uri_password=${BASH_REMATCH[7]}
	__stella_uri_host=${BASH_REMATCH[8]}
	__stella_uri_port=${BASH_REMATCH[10]}
	__stella_uri_path=${BASH_REMATCH[11]}
	__stella_uri_query=${BASH_REMATCH[12]}
	__stella_uri_fragment=${BASH_REMATCH[13]}

	# path parsing
	count=0
	path="$__stella_uri_path"
	pattern='^/+([^/]+)'
	while [[ $path =~ $pattern ]]; do
			eval "__stella_uri_parts[$count]='${BASH_REMATCH[1]}'"
			path="${path:${#BASH_REMATCH[0]}}"
			#let count++
			count="$(( count + 1 ))"
	done

	# query parsing
	count=0
	query="$__stella_uri_query"
	pattern='^[?&]+([^= ]+)(=([^&]*))?'
	while [[ "$query" =~ $pattern ]]; do
			eval "__stella_uri_args[$count]='${BASH_REMATCH[1]}'"
			[ ! "${BASH_REMATCH[3]}" = "" ] && eval "__stella_uri_arg_${BASH_REMATCH[1]}='${BASH_REMATCH[3]}'"
			query="${query:${#BASH_REMATCH[0]}}"
			#let count++
			count=$(( count + 1 ))
	done

	# return success
	return 0
}

# [schema://][user@][host][:port][/abs_path|?rel_path]
# By default
# CACHE, WORKSPACE, ENV, GIT are excluded ==> use theses options to force include
# APP, WIN are included ==> uses these option to force exclude
# SUDO use sudo on the target
# FOLDER_CONTENT use this option to transfer content of stella folder only (not stella folder itself)
__transfer_stella() {
	local _uri="$1"
	local _OPT="$2"
	local _opt_ex_cache
	_opt_ex_cache="EXCLUDE /$(__abs_to_rel_path "$STELLA_INTERNAL_CACHE_DIR" "$STELLA_ROOT")/"
	local _opt_ex_workspace
	_opt_ex_workspace="EXCLUDE /$(__abs_to_rel_path "$STELLA_INTERNAL_WORK_ROOT" "$STELLA_ROOT")/"
	local _opt_ex_env
	_opt_ex_env="EXCLUDE /.stella-env"
	local _opt_ex_git
	_opt_ex_git="EXCLUDE /.git/"
	local _opt_ex_win
	_opt_ex_win=
	local _opt_ex_app
	_opt_ex_app=
	local _opt_sudo
	_opt_sudo=
	local _opt_folder_content
	_opt_folder_content=
	local _opt_delete_excluded=

	for o in $_OPT; do
		[ "$o" = "CACHE" ] && _opt_ex_cache=
		[ "$o" = "WORKSPACE" ] && _opt_ex_workspace=
		[ "$o" = "ENV" ] && _opt_ex_env=
		[ "$o" = "GIT" ] && _opt_ex_git=
		[ "$o" = "WIN" ] && _opt_ex_win="EXCLUDE /win/ EXCLUDE /stella.bat EXCLUDE /conf.bat"
		[ "$o" = "APP" ] && _opt_ex_app="EXCLUDE /app/"
		[ "$o" = "SUDO" ] && _opt_sudo="SUDO"
		[ "$o" = "FOLDER_CONTENT" ] && _opt_folder_content="FOLDER_CONTENT"
		[ "$o" = "DELETE_EXCLUDED" ] && _opt_delete_excluded="DELETE_EXCLUDED"
	done
	__log "DEBUG" "** ${_opt_sudo} Transfer stella to $_uri"
	__transfer_folder_rsync "$STELLA_ROOT" "$_uri" "$_opt_delete_excluded $_opt_ex_win $_opt_ex_app $_opt_ex_cache $_opt_ex_workspace $_opt_ex_env $_opt_ex_git $_opt_sudo $_opt_folder_content"
}



# ARG _folder folder to transfer
# ARG _uri target
# 	[schema://][user@][host][:port][/abs_path|?rel_path]
#		uri path must not finish with / or only folder content will be transfered, not folder itself
#	OPTIONS
# 		EXCLUDE (repeat this option for each exclude filter to set - path are absolute to the root of the folder to transfert. example : /workspace/)
# 		INCLUDE (This option override exclude rules. Repeat this option for each include filter to set - path are absolute to the root of the folder to transfert. example : /workspace/)
# 		FOLDER_CONTENT will transfer folder content not folder itself
# 		EXCLUDE_HIDDEN exclude hidden files
#
#	example
# __transfer_folder_rsync /foo/folder ssh://user@ip
#			here target host is 'ip'
#			here path is empty, so folder will be sync inside home directory of user as /home/user/folder
# __transfer_folder_rsync /foo/folder ssh://user@ip/path
#			transfert /foo/folder to host 'ip' into absolute path '/path'
# __transfer_folder_rsync /foo/folder vagrant://default
#			use ssh configuration of vagrant to connect to machine named 'default'
__transfer_folder_rsync() {
	local _folder="$1"
	local _uri="$2"
	local _opt="$3"
	__transfer_rsync "FOLDER" "$_folder" "$_uri" "$_opt"
}


# ARG _file file to transfer
# ARG _uri target
# 		[schema://][user@][host][:port][/abs_path|?rel_path]
#			if uri path end with a "/" it will be a destination folder, else it will be the name of the transfered file
#	OPTIONS
#			SUDO use sudo while transfering to uri
#
# example
# __transfer_file_rsync /foo/file1 ssh://user@ip/?folder/file2
#			file1 will be sync inside home directory of user as /home/user/folder/file2
__transfer_file_rsync() {
	local _file="$1"
	local _uri="$2"
	local _opt="$3"

	__log "DEBUG" "** Transfer file $_file to $_uri"
	__transfer_rsync "FILE" "$_file" "$_uri" "$_opt"
}


# ARG mode FOLDER|FILE
# ARG source
# ARG uri
#			[schema://][user@][host][:port][/abs_path|?rel_path]
# 		path could be absolute path in the target system
# 		or could be relavite path to a default folder
# 		default schema is local
#			available schemas
#					ssh://user@host:port[/abs_path|?rel_path]
#					vagrant://vagrant-machine[/abs_path|?rel_path]
#					local://[/abs_path|[?]rel_path]  ==> with local:// char '?' is optionnal to use relative_path
#
#	NOTE : use ssh shared connection by default
#
#	OPTIONS
# 		EXCLUDE (repeat this option for each exclude filter to set - path are absolute to the root of the folder to transfert. example : /workspace/)
# 		INCLUDE (This option override exclude rules. Repeat this option for each include filter to set - path are absolute to the root of the folder to transfert. example : /workspace/)
# 		FOLDER_CONTENT will transfer folder content not folder itself
# 		EXCLUDE_HIDDEN exclude hidden files
#			SUDO use sudo while transfering to uri
#			COPY_LINKS copy real file linked by a symlink
#			DELETE_EXCLUDED delete excluded files on the target
__transfer_rsync() {
	local _mode="$1"
	local _source="$2"
	local _uri="$3"
	local _OPT="$4"


	local _flag_exclude=OFF
	local _exclude=
	local _flag_include=OFF
	local _include=
	local _opt_folder_content=OFF
	local _opt_sudo=OFF
	local _opt_exclude_hidden=OFF
	local _opt_copy_links=OFF
	local _opt_delete_excluded=OFF
	for o in $_OPT; do
		[ "$_flag_exclude" = "ON" ] && _exclude="$o $_exclude" && _flag_exclude=OFF
		[ "$o" = "EXCLUDE" ] && _flag_exclude=ON
		[ "$_flag_include" = "ON" ] && _include="$o $_include" && _flag_include=OFF
		[ "$o" = "INCLUDE" ] && _flag_include=ON
		[ "$o" = "FOLDER_CONTENT" ] && _opt_folder_content=ON
		[ "$o" = "EXCLUDE_HIDDEN" ] && _opt_exclude_hidden=ON
		[ "$o" = "SUDO" ] && _opt_sudo=ON
		[ "$o" = "COPY_LINKS" ] && _opt_copy_links=ON
		[ "$o" = "DELETE_EXCLUDED" ] && _opt_delete_excluded=ON
	done

	# NOTE : rsync needs to be present on both host (source AND target)
	__require "rsync" "rsync"

	__uri_parse "$_uri"

	[ "$__stella_uri_schema" = "" ] && __stella_uri_schema=local

	local _local_filesystem="OFF"
	if [ "$__stella_uri_schema" = "local" ]; then
		_local_filesystem="ON"
	fi

	if [ "$__stella_uri_schema" = "ssh" ]; then
		__require "ssh" "ssh"
		_ssh_port="22"
		[ ! "$__stella_uri_port" = "" ] && _ssh_port="$__stella_uri_port"
	fi

	if [ "$__stella_uri_schema" = "vagrant" ]; then
		__vagrant_ssh_opt="$(__vagrant_get_ssh_options "$__stella_uri_host")"
		#__vagrant_ssh_opt="$(vagrant ssh-config $__stella_uri_host | sed '/^[[:space:]]*$/d' |  awk '/^Host .*$/ { detected=1; }  { if(start) {print " -o "$1"="$2}; if(detected) start=1; }')"
		__stella_uri_host="localhost"
	fi


	local _target=
	local _target_path=


	if [ "$_local_filesystem" = "ON" ]; then
		_target="$(__uri_get_path "$_uri")"
		_target_path="$_target"
	fi

	if [ "$_local_filesystem" = "OFF" ]; then
		_target="$(__uri_get_path "$_uri")"
		_target_path="$_target"
		_target_address="$__stella_uri_host"
		[ ! "$__stella_uri_user" = "" ] && _target_address="$__stella_uri_user"@"$_target_address"

		_target="$_target_address":"$_target"
	fi

	local _base_folder=
	local _opt_include=
	local _opt_exclude=
	local _opt_links=
	[ "$_opt_copy_links" = "ON" ] && _opt_links="--copy-links"
	[ "$_opt_delete_excluded" = "ON" ] && _opt_exclude="--delete-excluded $_opt_exclude"

	case $_mode in
		FOLDER )
				# _source must not finish with / or only folder content will be transfered, not folder itself
				if [ "$_opt_folder_content" = "ON" ]; then
					_source="$_source/"
				else
					_source="${_source%/}"
					_base_folder="/$(basename $_source)/"
				fi

				for o in $_include; do
					_opt_include="--include=$(echo $_base_folder$o | sed 's,//,/,') $_opt_include"
				done

				for o in $_exclude; do
					_opt_exclude="--exclude=$(echo $_base_folder$o | sed 's,//,/,') $_opt_exclude"
				done
				[ "$_opt_exclude_hidden" = "ON" ] && _opt_exclude="$_opt_exclude --exclude=${_base_folder}.*"

			;;
		FILE )
			;;
	esac

	# NOTE : rsync do not create parent folders of the target. It creates only last level
	#				solution ; http://www.schwertly.com/2013/07/forcing-rsync-to-create-a-remote-path-using-rsync-path/
	# NOTE : rxync progress option https://serverfault.com/questions/219013/showing-total-progress-in-rsync-is-it-possible
	#				--info=progress2 --no-inc-recursive is not portable because it needs a minimum version of rsync
	# NOTE : rsync + ssh + sudo
	#				https://serverfault.com/questions/534683/rsync-over-ssh-getting-no-tty-present
	#				https://superuser.com/questions/270911/run-rsync-with-root-permission-on-remote-machine
	case $__stella_uri_schema in
		ssh )
			if [ "$_opt_sudo" = "ON" ]; then
				__sudo_ssh_begin_session "$_uri"
				rsync $_opt_links $_opt_include $_opt_exclude --rsync-path="stty raw -echo; sudo mkdir -p '$_target_path'; sudo rsync" --no-owner --no-group --force --delete -prltD -vz -e "ssh -t -o ControlPath=~/.ssh/%r@%h-%p -o ControlMaster=auto -o ControlPersist=60 -p $_ssh_port" "$_source" "$_target"
				__sudo_ssh_end_session "$_uri"
			fi
			[ "$_opt_sudo" = "OFF" ] && rsync $_opt_links $_opt_include $_opt_exclude --rsync-path="mkdir -p '$(dirname $_target_path)' && rsync" --no-owner --no-group --force --delete -prltD -vz -e "ssh -o ControlPath=~/.ssh/%r@%h-%p -o ControlMaster=auto -o ControlPersist=60 -p $_ssh_port" "$_source" "$_target"
			;;
		vagrant )
			if [ "$_opt_sudo" = "ON" ]; then
				__sudo_ssh_begin_session "$_uri"
				rsync $_opt_links $_opt_include $_opt_exclude --rsync-path="stty raw -echo; sudo mkdir -p '$_target_path'; sudo rsync" --no-owner --no-group --force --delete -prltD -vz -e "ssh -t -o ControlPath=~/.ssh/%r@%h-%p -o ControlMaster=auto -o ControlPersist=60 $__vagrant_ssh_opt" "$_source" "$_target"
				__sudo_ssh_end_session "$_uri"
			fi
			[ "$_opt_sudo" = "OFF" ] && rsync $_opt_links $_opt_include $_opt_exclude --rsync-path="mkdir -p '$(dirname $_target_path)' && rsync" --no-owner --no-group --force --delete -prltD -vz -e "ssh $__vagrant_ssh_opt -o ControlPath=~/.ssh/%r@%h-%p -o ControlMaster=auto -o ControlPersist=60" "$_source" "$_target"
			;;
		local )
			if [ "$_source" = "$_target" ]; then
				__log "INFO" " ** source $_source and target $_target are equivalent, so no transfer"
			else
				# '--rsync-path' option seems to not work when we are on the same host (local)
				if [ "$_opt_sudo" = "ON" ]; then
					sudo mkdir -p "$(dirname $_target_path)"
					sudo rsync $_opt_links $_opt_include $_opt_exclude --force --delete -avz "$_source" "$_target"
				fi
				if [ "$_opt_sudo" = "OFF" ]; then
					mkdir -p "$(dirname $_target_path)"
					rsync $_opt_links $_opt_include $_opt_exclude --force --delete -avz "$_source" "$_target"
				fi
			fi
			;;
		*)
			echo "** ERROR protocol unknown"
			;;
	esac


}


__daemonize() {
	local _item_path="$1"
	local _log_file="$2"

	if [ "$_log_file" = "" ]; then
		nohup -- $_item_path 1>/dev/null 2>&1 &
	else
		nohup -- $_item_path 1>$_log_file 2>&1 &
	fi

}

__get_active_path() {
	echo "$PATH"
}



__filter_list() {
	local _list="$1"
	local _opt="$2"

	local _result_list=

	[ -z "$_list" ] && return

	# INCLUDE_TAG -- option name of include option -- must be setted before using	 INCLUDE_TAG
	# EXCLUDE_TAG -- option name of exclude option -- must be setted before using EXCLUDE_TAG
	# ${INCLUDE_TAG} <expr> -- include these items
	# ${EXCLUDE_TAG} <expr> -- exclude these items
	# ${INCLUDE_TAG} is apply first, before ${EXCLUDE_TAG}

	local _tag_include=
	local _flag_tag_include=OFF
	local _tag_exclude=
	local _flag_tag_exclude=OFF
	local _flag_exclude_filter=OFF
	local _exclude_filter=
	local _invert_filter=
	local _flag_include_filter=OFF
	local _include_filter=
	local _opt_filter=OFF
	for o in $_opt; do
		[ "$_flag_include_filter" = "ON" ] && _include_filter="$o" && _flag_include_filter=OFF
		[ ! "$_tag_include" = "" ] && [ "$o" = "$_tag_include" ] && _flag_include_filter=ON && _opt_filter=ON
		[ "$_flag_exclude_filter" = "ON" ] && _exclude_filter="$o" && _flag_exclude_filter=OFF
		[ ! "$_tag_exclude" = "" ] && [ "$o" = "$_tag_exclude" ] && _flag_exclude_filter=ON && _invert_filter="-Ev" && _opt_filter=ON
		[ "$_flag_tag_include" = "ON" ] && _tag_include="$o" && _flag_tag_include=OFF
		[ "$o" = "INCLUDE_TAG" ] && _flag_tag_include=ON
		[ "$_flag_tag_exclude" = "ON" ] && _tag_exclude="$o" && _flag_tag_exclude=OFF
		[ "$o" = "EXCLUDE_TAG" ] && _flag_tag_exclude=ON
	done

	if [ "$_opt_filter" = "OFF" ]; then
		echo "$_list"
	else
		for l in $_list; do
			[ -z "$(echo "$l" | grep -E "$_include_filter" | grep $_invert_filter "$_exclude_filter")" ] || _result_list="$_result_list $l"
		done
		echo "$_result_list"
	fi
}


# http://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
__trim3() {
	echo -e "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

# trim whitespace
__trim2() {
	echo $(echo "$1" | sed -e 's/^ *//' -e 's/ *$//')
}

__trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
    echo -n "$var"
}

# http://stackoverflow.com/a/20460402
__string_contains() { [ -z "${1##*$2*}" ] && [ -n "$1" -o -z "$2" ]; }



__get_stella_version() {
	local _stella_root_="$1"

	[ "$_stella_root_" = "" ] && _stella_root_="$STELLA_ROOT"

	_s_flavour=$(__get_stella_flavour "$_stella_root_")

	case "$_s_flavour" in
		STABLE)
				cat "$_stella_root_/VERSION"
		;;

		DEV)
				echo "$(__git_project_version "$_stella_root_" "LONG")"
		;;

		*)
				echo "unknown"
		;;

	esac
}


# return STABLE or DEV
__get_stella_flavour() {
	local _stella_root_="$1"
	[ "$_stella_root_" = "" ] && _stella_root_="$STELLA_ROOT"

	local _s_flavour=unknown

	[ -f "$_stella_root_/VERSION" ] && _s_flavour="STABLE"
	[ -d "$_stella_root_/.git" ] && _s_flavour="DEV"

	echo $_s_flavour
}


__is_dir_empty() {
	if [ $(find "$1" -prune -empty -type d) ]; then
		# dir is empty
		echo "TRUE"
	else
		echo "FALSE"
	fi
}

# To get: /tmp/my.dir (like dirname)
# path = ${foo%/*}
# To get: filename.tar.gz (like basename)
# file = ${foo##*/}
# To get: filename
# base = ${file%%.*}
__get_path_from_string() {
	if [ "$1" = "${1%/*}" ]; then
		echo "."
	else
		echo ${1%/*}
	fi
}

__get_filename_from_string() {
	echo ${1##*/}
}

__get_filename_from_url() {
	local _AFTER_SLASH
	_AFTER_SLASH=${1##*/}
	echo ${_AFTER_SLASH%%\?*}
}

__get_extension_from_string() {
	local _AFTER_DOT
	_AFTER_DOT=${1##*\.}
	echo $_AFTER_DOT
	#echo ${_AFTER_DOT%%\?*}
}


# NOTE : alternative : [ -z "${_path##/*}" ]
__is_abs() {
	local _path="$1"

	case $_path in
		/*)
			echo "TRUE"
			;;
		*)
			echo "FALSE"
			;;
	esac
}

# search a specific folder starting from a root folder and searching in parent folder
__find_folder_up() {
	local _root="$1"
	local _search="$2"

	cwd="$_root"
	while [ ! -d "$cwd/$_search" ] && [ "x$cwd" != x/ ]; do
		cwd=`dirname "$cwd"`
	done
	if [ -d "$cwd/$_search" ]; then
		echo "$cwd/$_search"
	else
		echo
	fi
}

# NOTE : paths do not have to exist
# if path are relative, they are resolved accordingly to current path
# __is_logical_subpath /folder1 /folder1/folder2 ==> TRUE
# __is_logical_subpath /folder /folder ==> FALSE
# __is_logical_subpath /folder /folder/ ==> FALSE
# __is_logical_subpath /folder /folder/file ==> TRUE
__is_logical_subpath() {
	local _root="$1"
	local _subpath="$2"

	local _result

	if [ "$_root" = "/" ]; then
		_result="TRUE"
	else
		_root="$(__rel_to_abs_path "$_root")"
		_subpath="$(__rel_to_abs_path "$_subpath")"
		if [ "${_subpath}" = "${_root}" ]; then
			_result="FALSE"
		else
			if [ "${_subpath}" = "${_root}/" ]; then
				_result="FALSE"
			else
				if [ ! "${_subpath##$_root/}" = "$_subpath" ]; then
					_result="TRUE"
				else
					_result="FALSE"
				fi
			fi
		fi
	fi
	echo "$_result"
}

# NOTE by default path is determined giving by the current running directory
__rel_to_abs_path() {
	local _rel_path="$1"
	local _abs_root_path="$2"
	local result

	if [ "$_abs_root_path" = "" ]; then
		_abs_root_path=$STELLA_CURRENT_RUNNING_DIR
	fi


	if [ "$(__is_abs $_abs_root_path)" = "FALSE" ]; then
		result="$_rel_path"
	else

		case $_rel_path in
			/*)
				# path is already absolute
				result="$_rel_path"
				;;
			*)
				# relative to a given absolute path
				if [ -d "$_abs_root_path/$_rel_path" ]; then
					# NOTE call to __rel_to_abs_path_alternative_3 is equivalent
					result="$(cd "$_abs_root_path/$_rel_path" && pwd -P)"
				else
					# TODO using this method if directory does not exist returned path is not real absolute (example : /tata/toto/../titi instead of /tata/titi)
					# TODO : we rely on pure bash version, because readlink -m option used in alternative2 do not exist on some system
					result=$(__rel_to_abs_path_alternative_1 "$_rel_path" "$_abs_root_path")
					#[ "$STELLA_CURRENT_PLATFORM" = "darwin" ] && result=$(__rel_to_abs_path_alternative_1 "$_rel_path" "$_abs_root_path")
					#[ "$STELLA_CURRENT_PLATFORM" = "linux" ] && result=$(__rel_to_abs_path_alternative_2 "$_rel_path" "$_abs_root_path")
				fi
				;;
		esac
	fi
	echo $result | tr -s '/'
}



# NOTE : http://stackoverflow.com/a/21951256
# NOTE : pure BASH : do not use readlink or cd or pwd command
# NOTE : paths do not have to exists
# NOTE : BUT do not follow symlink
__rel_to_abs_path_alternative_1(){
		local _rel_path=$1
		local _abs_root_path=$2

	  local thePath=$_abs_root_path/$_rel_path
	  # if [[ ! "$1" =~ ^/ ]];then
	  #   thePath="$PWD/$1"
	  # else
	  #   thePath="$1"
	  # fi
	  echo "$thePath"|(
	  IFS=/
	  read -a parr
	  declare -a outp
	  for i in "${parr[@]}";do
	    case "$i" in
	    ''|.) continue ;;
	    ..)
	      len=${#outp[@]}
	      if ((len==0));then
	        continue
	      else
	        unset outp[$((len-1))]
	      fi
	      ;;
	    *)
	      len=${#outp[@]}
	      outp[$len]="$i"
	      ;;
	    esac
	  done
	  echo /"${outp[*]}"
	)
}

# NOTE : http://stackoverflow.com/a/13599997
# NOTE : use basename/dirname/readlink : follow symlink
# NOTE : readlink option -m do not exists on some version
__rel_to_abs_path_alternative_2(){
	local _rel_path=$1
	local _abs_root_path=$2

	local F="$_abs_root_path/$_rel_path"

	#echo "$(dirname $(readlink -e $F))/$(basename $F)"
	echo "$(readlink -m $F)"

}

# How to go from _abs_path_root (ARG2) to _abs_path_to_translate (ARG1)
# example :
#	ARG1 /path1
#	ARG2 /path1/path2
# result ..
# cd /path1/path2/.. is equivalent to /path1
# NOTE by default relative to current running directory
__abs_to_rel_path() {
	local _abs_path_to_translate="$1"/
	local _abs_path_root="$2"

	local result=""

	if [ "$_abs_path_root" = "" ]; then
		_abs_path_root=$STELLA_CURRENT_RUNNING_DIR
	fi

	_abs_path_root="$_abs_path_root"/

	local common_part="$_abs_path_root" # for now

	if [ "$(__is_abs $_abs_path_to_translate)" = "FALSE" ]; then
		result="$_abs_path_to_translate"
	else

		case $_abs_path_root in
			/*)
				while [ "${_abs_path_to_translate#$common_part}" = "${_abs_path_to_translate}" ]; do
					# no match, means that candidate common part is not correct
					# go up one level (reduce common part)
					common_part="$(dirname $common_part)"

					# and record that we went back
					if [ -z "$result" ]; then
						result=".."
					else
						result="../$result"
					fi

				done

				if [ "$common_part" = "/" ]; then
					# special case for root (no common path)
					result="$result/"
				fi


				# since we now have identified the common part,
				# compute the non-common part
				forward_part="${_abs_path_to_translate#$common_part}"
				if [[ -n $result ]] && [[ -n $forward_part ]]; then
					result="$result$forward_part"
				elif [[ -n $forward_part ]]; then
					result="${forward_part}"

				else
					if [[ ! -n $result ]] && [[ $common_part == "$_abs_path_to_translate" ]]; then
						result="."
					fi
				fi
				;;

			*)
				result="$_abs_path_to_translate"
				;;
		esac
	fi

	if [ "${result:(-1)}" = "/" ]; then
		result=${result%?}
	fi
	echo "$result"

}

# NOTE use a subprocess, cd and pwd
# NOTE resolve symlinks
# NOTE but all paths must exist !
__rel_to_abs_path_alternative_3() {
	local _rel_path=$1
	local _abs_root_path=$2

	echo "$(cd "$_abs_root_path/$_rel_path" && pwd -P)"
}

# init stella environment
__init_stella_env() {
	__feature_init_installed
	# PROXY
	__init_proxy
}

#MEASURE TOOL----------------------------------------------
# __timecount_start "count_id"
__timecount_start() {
	local _count_name_var=$1
	local _id=$RANDOM$RANDOM

	eval __stella_timecount_$_id="$(date +%s)"
	eval $_count_name_var="__stella_timecount_$_id"

}

# elapsed_time=$(__timecount_stop "count_id")
__timecount_stop() {
	local _end_count="$(date +%s)"
	local _ellapsed=
	local _tmp="$1"
	local _start_count=${!_tmp}

	local _ellapsed=$(echo "$_end_count - ${!_start_count}" | bc)
	echo $_ellapsed
}


#FILE TOOLS----------------------------------------------
#http://stackoverflow.com/a/17902999/5027535
__count_folder_item() {
	local _path="$1"
	local _filter="$2"

	if [ "$_filter" = "" ]; then

		_filter="*"
	fi

	local files=$(shopt -s nullglob dotglob; echo $_path/$_filter)
	echo ${#files[@]}

}

__del_folder() {
	echo "** Deleting $1 folder"
	[ -d $1 ] && rm -Rf $1
}

# copy content of folder ARG1 into folder ARG2
__copy_folder_content_into() {
	local source="$1"
	local dest="$2"
	local select_filter="$3"
	if [ "$select_filter" = "" ]; then
		select_filter="*"
	fi
	if [ -d "$source" ]; then
		if [ $(__count_folder_item $1 $select_filter) -gt 0 ]; then
			mkdir -p "$dest"
			if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
				cp -fa "$source/"$select_filter "$dest"
			else
				cp -fa "$source/"$select_filter --target-directory="$dest"
			fi
		fi
	fi
}


#RESSOURCES MANAGEMENT ---------------------------------------------------
__get_resource() {
	local OPT="$5"
	OPT="$OPT GET"
	__resource "$1" "$2" "$3" "$4" "$OPT"
}

__update_resource() {
	local OPT="$5"
	OPT="$OPT UPDATE"
	__resource "$1" "$2" "$3" "$4" "$OPT"
}

__delete_resource() {
	local OPT="$5"
	OPT="$OPT DELETE"
	__resource "$1" "$2" "$3" "$4" "$OPT"
}

__revert_resource() {
	local OPT="$5"
	OPT="$OPT REVERT"
	__resource "$1" "$2" "$3" "$4" "$OPT"
}

__resource() {
	local NAME="$1"
	local URI="$2"
	local PROTOCOL="$3"
	# FINAL_DESTINATION is the folder inside which one the resource will be put
	local FINAL_DESTINATION="$4"
	local OPT="$5"
	# option should passed as one string "OPT1 OPT2"
	# 	"MERGE" for merge in FINAL_DESTINATION
	# 	"STRIP" for remove root folder and copy content of root folder in FINAL_DESTINATION
	# 	"FORCE_NAME" force name of downloaded file
	# 	"GET" get resource (action by default)
	# 	"UPDATE" pull and update resource (only for HG or GIT)
	# 	"REVERT" complete revert of the resource (only for HG or GIT)
	# 	"DELETE" delete resource
	#  	"VERSION" retrieve specific version (only for HG or GIT) when GET or UPDATE
	#		"DEST_ERASE" when GET, will erase FINAL_DESTINATION first
	# TODO : remove illegal characters in NAME. NAME is used in flag file name when merging

	local _opt_merge=OFF
	local _opt_strip=OFF
	local _opt_get=ON
	local _opt_delete=OFF
	local _opt_update=OFF
	local _opt_revert=OFF
	local _opt_force_name=OFF
	local _opt_version=OFF
	local _opt_dest_erase=OFF
	local _checkout_version=
	local _download_filename=_AUTO_
	for o in $OPT; do
		if [ "$_opt_force_name" = "ON" ]; then
			_download_filename=$o
			_opt_force_name=OFF
		else
			if [ "$_opt_version" = "ON" ]; then
				_checkout_version=$o
				_opt_version=OFF
			else
				[ "$o" = "VERSION" ] && _opt_version=ON
				[ "$o" = "MERGE" ] && _opt_merge=ON
				[ "$o" = "DEST_ERASE" ] && _opt_dest_erase=ON
				[ "$o" = "STRIP" ] && _opt_strip=ON
				[ "$o" = "FORCE_NAME" ] && _opt_force_name=ON
				if [ "$o" = "DELETE" ]; then _opt_delete=ON;  _opt_revert=OFF;  _opt_get=OFF; _opt_update=OFF; fi
				if [ "$o" = "UPDATE" ]; then _opt_update=ON;  _opt_revert=OFF;  _opt_get=OFF; _opt_delete=OFF; fi
				if [ "$o" = "REVERT" ]; then _opt_revert=ON;  _opt_update=OFF;  _opt_get=OFF; _opt_delete=OFF; fi
			fi
		fi
	done

	[ "$_opt_revert" = "ON" ] && __log "INFO" " ** Reverting resource :"
	[ "$_opt_update" = "ON" ] && __log "INFO" " ** Updating resource :"
	[ "$_opt_delete" = "ON" ] && __log "INFO" " ** Deleting resource :"
	[ "$_opt_get" = "ON" ] && __log "INFO" " ** Getting resource :"
	[ ! "$FINAL_DESTINATION" = "" ] && __log "INFO" " $NAME in $FINAL_DESTINATION" || __log "INFO" " $NAME"

	#[ "$FORCE" ] && rm -Rf $FINAL_DESTINATION
	if [ "$_opt_get" = "ON" ]; then
		#if [ "$FORCE" ]; then
		#	[ "$_opt_merge" = "OFF" ] && rm -Rf "$FINAL_DESTINATION"
		#	[ "$_opt_merge" = "ON" ] && rm -f "$FINAL_DESTINATION/._MERGED_$NAME"
		#fi
		if [ "$_opt_dest_erase" = "ON" ]; then
			[ "$_opt_merge" = "OFF" ] && rm -Rf "$FINAL_DESTINATION"
			[ "$_opt_merge" = "ON" ] && rm -f "$FINAL_DESTINATION/._MERGED_$NAME"
		fi
	fi


	if [ "$_opt_delete" = "ON" ]; then
		[ "$_opt_merge" = "OFF" ] && rm -Rf "$FINAL_DESTINATION"
		[ "$_opt_merge" = "ON" ] && rm -f "$FINAL_DESTINATION/._MERGED_$NAME"
		_FLAG=0
	fi

	if [ "$_opt_delete" = "OFF" ]; then
		# strip root folder mode
		_STRIP=
		[ "$_opt_strip" = "ON" ] && _STRIP=STRIP


		_FLAG=1
		case $PROTOCOL in
			HTTP_ZIP|FILE_ZIP)
				[ "$_opt_revert" = "ON" ] && __log "INFO" "REVERT Not supported with this protocol" && _FLAG=0
				[ "$_opt_update" = "ON" ] && __log "INFO" "UPDATE Not supported with this protocol" && _FLAG=0
				if [ -d "$FINAL_DESTINATION" ]; then
					if [ "$_opt_get" = "ON" ]; then
						if [ "$_opt_merge" = "ON" ]; then
							if [ -f "$FINAL_DESTINATION/._MERGED_$NAME" ]; then
								__log "INFO" " ** Ressource already merged"
								_FLAG=0
							fi
						fi
						if [ "$_opt_strip" = "ON" ]; then
							#__log " ** Ressource already stripped"
							__log "INFO" " ** Destination folder exist"
							#_FLAG=0
						fi
					fi
				fi
				;;
			HTTP|FILE)
				[ "$_opt_strip" = "ON" ] && __log "INFO" "STRIP option not in use"
				[ "$_opt_revert" = "ON" ] && __log "INFO" "REVERT Not supported with this protocol" && _FLAG=0
				[ "$_opt_update" = "ON" ] && __log "INFO" "UPDATE Not supported with this protocol" && _FLAG=0

				if [ -d "$FINAL_DESTINATION" ]; then
					if [ "$_opt_get" = "ON" ]; then
						if [ "$_opt_merge" = "ON" ]; then
							if [ -f "$FINAL_DESTINATION/._MERGED_$NAME" ]; then
								__log "INFO" " ** Ressource already merged"
								_FLAG=0
							fi
						fi
					fi
				fi
				;;
			HG|GIT)
				[ "$_opt_strip" = "ON" ] && __log "INFO" "STRIP option not supported with this protocol"
				[ "$_opt_merge" = "ON" ] && __log "INFO" "MERGE option not supported with this protocol"
				if [ -d "$FINAL_DESTINATION" ]; then
					if [ "$_opt_get" = "ON" ]; then
						__log "INFO" " ** Ressource already exist"
						_FLAG=0
					fi
				else
					[ "$_opt_revert" = "ON" ] && __log "INFO" " ** Ressource does not exist" && _FLAG=0
					[ "$_opt_update" = "ON" ] && __log "INFO" " ** Ressource does not exist" && _FLAG=0
				fi
				;;
		esac
	fi

	if [ "$_FLAG" = "1" ]; then
		[ ! -d $FINAL_DESTINATION ] && mkdir -p $FINAL_DESTINATION

		case $PROTOCOL in
			HTTP_ZIP)
				if [ "$_opt_get" = "ON" ]; then __download_uncompress "$URI" "$_download_filename" "$FINAL_DESTINATION" "$_STRIP"; fi
				if [ "$_opt_merge" = "ON" ]; then echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"; fi
				;;
			HTTP)
				# HTTP protocol use always merge by default : because it never erase destination folder
				# but the 'merged' flag file will be created only if we pass the option MERGE
				if [ "$_opt_get" = "ON" ]; then __download "$URI" "$_download_filename" "$FINAL_DESTINATION"; fi
				if [ "$_opt_merge" = "ON" ]; then echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"; fi
				;;
			HG)
				if [ "$_opt_revert" = "ON" ]; then cd "$FINAL_DESTINATION"; hg revert --all -C; fi
				if [ "$_opt_update" = "ON" ]; then cd "$FINAL_DESTINATION"; hg pull; hg update $_checkout_version; fi
				if [ "$_opt_get" = "ON" ]; then hg clone $URI "$FINAL_DESTINATION"; if [ ! "$_checkout_version" = "" ]; then cd "$FINAL_DESTINATION"; hg update $_checkout_version; fi; fi
				# [ "$_opt_merge" = "ON" ] && echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"
				;;
			GIT)
				__require "git" "git" "SYSTEM"
				if [ "$_opt_revert" = "ON" ]; then cd "$FINAL_DESTINATION"; git reset --hard; fi
				if [ "$_opt_update" = "ON" ]; then cd "$FINAL_DESTINATION"; git pull;if [ ! "$_checkout_version" = "" ]; then git checkout $_checkout_version; fi; fi
				if [ "$_opt_get" = "ON" ]; then git clone --recursive $URI "$FINAL_DESTINATION"; if [ ! "$_checkout_version" = "" ]; then cd "$FINAL_DESTINATION"; git checkout $_checkout_version; fi; fi
				# [ "$_opt_merge" = "ON" ] && echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"
				;;
			FILE)
				if [ "$_opt_get" = "ON" ]; then __copy_folder_content_into "$URI" "$FINAL_DESTINATION"; fi
				if [ "$_opt_merge" = "ON" ]; then echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"; fi
				;;
			FILE_ZIP)
				__uncompress "$URI" "$FINAL_DESTINATION%" "$_STRIP"
				if [ "$_opt_merge" = "ON" ]; then echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"; fi
				;;
			*)
				__log "INFO" " ** ERROR Unknow protocol"
				;;
		esac
	fi
}

#DOWNLOAD AND ZIP FUNCTIONS---------------------------------------------------
__download_uncompress() {
	local URL
	local FILE_NAME
	local UNZIP_DIR
	local OPT
	# DEST_ERASE delete destination folder
	# STRIP delete first folder in archive

	URL="$1"
	FILE_NAME="$2"
	UNZIP_DIR="$3"
	OPT="$4"


	if [ "$FILE_NAME" = "_AUTO_" ]; then
		#_AFTER_SLASH=${URL##*/}
		FILE_NAME=$(__get_filename_from_url "$URL")
		__log "INFO" "** Guessed file name is $FILE_NAME"
	fi

	__download "$URL" "$FILE_NAME"
	if [ -f "$STELLA_APP_CACHE_DIR/$FILE_NAME" ]; then
		__uncompress "$STELLA_APP_CACHE_DIR/$FILE_NAME" "$UNZIP_DIR" "$OPT"
	else
		if [ -f "$STELLA_INTERNAL_CACHE_DIR/$FILE_NAME" ]; then
			__uncompress "$STELLA_INTERNAL_CACHE_DIR/$FILE_NAME" "$UNZIP_DIR" "$OPT"
		fi
	fi

}

__compress() {
	local _mode=$1
	local _target=$2
	local _output_archive=$3

	local _tar_flag

	case $_mode in
		TARGZ )
			_tar_flag=-z
			;;
		TARBZ )
			_tar_flag=-j
			;;
		TARXZ )
			_tar_flag=-J
			;;
		TARLZMA )
			_tar_flag=--lzma
			;;
	esac

	case $_mode in
		7Z)
			if [ -d "$_target" ]; then
				cd "$_target/.."
				7z a -t7z "$_output_archive" "$(basename $_target)"
				mv "$_output_archive" "$_output_archive"
			fi
			if [ -f "$_target" ]; then
				cd "$(dirname $_target)"
				7z a -t7z "$_output_archive" "$(basename $_target)"
				mv "$_output_archive" "$_output_archive"
			fi
			;;
		ZIP)
			__log "DEBUG" "TODO: *********** ZIP NOT IMPLEMENTED"
			;;
		TAR*)
				[ -d "$_target" ] && tar -c -v $_tar_flag -f "$_output_archive" -C "$_target/.." "$(basename $_target)"
				[ -f "$_target" ] && tar -c -v $_tar_flag -f "$_output_archive" -C "$(dirname $_target)" "$(basename $_target)"
			;;
	esac


}

__uncompress() {
	local FILE_PATH
	local UNZIP_DIR
	local OPT
	FILE_PATH="$1"
	UNZIP_DIR="$2"
	OPT="$3"

	local _opt_dest_erase=OFF # delete destination folder (default : FALSE)
	local _opt_strip=OFF # delete first folder in archive  (default : FALSE)
	for o in $OPT; do
		[ "$o" = "DEST_ERASE" ] && _opt_dest_erase=ON
		[ "$o" = "STRIP" ] && _opt_strip=ON
	done


	if [ "$_opt_dest_erase" = "ON" ]; then
		rm -Rf "$UNZIP_DIR"
	fi

	mkdir -p "$UNZIP_DIR"

	__log "INFO" " ** Uncompress $FILE_PATH in $UNZIP_DIR"

	cd "$UNZIP_DIR"

	case "$FILE_PATH" in
		*.zip)
			__require "unzip" "unzip" "SYSTEM"
			[ "$_opt_strip" = "OFF" ] && unzip -a -o "$FILE_PATH"
			[ "$_opt_strip" = "ON" ] && __unzip-strip "$FILE_PATH" "$UNZIP_DIR"
			;;
		*.tar )
			if [ "$_opt_strip" = "OFF" ]; then
				tar xf "$FILE_PATH"
			else
				tar xf "$FILE_PATH" --strip-components=1 2>/dev/null || __untar-strip "$FILE_PATH" "$UNZIP_DIR"
			fi
			;;
		*.gz | *.tgz)
			if [ "$_opt_strip" = "OFF" ]; then
				tar xzf "$FILE_PATH"
			else
				tar xzf "$FILE_PATH" --strip-components=1 2>/dev/null || __untar-strip "$FILE_PATH" "$UNZIP_DIR"
			fi
			;;
		*.xz | *.bz2)
			if [ "$_opt_strip" = "OFF" ]; then
				tar xf "$FILE_PATH"
			else
				tar xf "$FILE_PATH" --strip-components=1 2>/dev/null || __untar-strip "$FILE_PATH" "$UNZIP_DIR"
			fi
			;;
		*.7z)
			__require "7z" "7z" "SYSTEM"
			[ "$_opt_strip" = "OFF" ] && 7z x "$FILE_PATH" -y -o"$UNZIP_DIR"
			[ "$_opt_strip" = "ON" ] && __sevenzip-strip "$FILE_PATH" "$UNZIP_DIR"
			;;
		*.deb)
			# STRIP not supported. Often in debian packages, there is a lot of folder at first level
			# https://www.g-loaded.eu/2008/01/28/how-to-extract-rpm-or-deb-packages/
			ar p "$FILE_PATH" data.tar.xz | tar x 2>/dev/null || \
				ar p "$FILE_PATH" data.tar.gz | tar xz
			;;
		*)
			__log "INFO" " ** ERROR : Unknown archive format"
	esac
}

__download() {
	local URL
	local FILE_NAME
	local DEST_DIR

	URL="$1"
	FILE_NAME="$2"
	DEST_DIR="$3"

	if [ "$FILE_NAME" = "" ]; then
		FILE_NAME="_AUTO_"
	fi

	if [ "$FILE_NAME" = "_AUTO_" ]; then
		#_AFTER_SLASH=${URL##*/}
		FILE_NAME=$(__get_filename_from_url "$URL")
		__log "INFO" "** Guessed file name is $FILE_NAME"
	fi

	mkdir -p "$STELLA_APP_CACHE_DIR"

	__log "INFO" " ** Download $FILE_NAME from $URL into cache"

	#if [ "$FORCE" = "1" ]; then
	#	rm -Rf "$STELLA_APP_CACHE_DIR/$FILE_NAME"
	#fi


	if [ ! -f "$STELLA_APP_CACHE_DIR/$FILE_NAME" ]; then
		if [ ! -f "$STELLA_INTERNAL_CACHE_DIR/$FILE_NAME" ]; then
			# NOTE : curl seems to be more compatible
			if [[ -n `which curl 2> /dev/null` ]]; then
				# TODO : why two curl call ?
				curl -fkSL -o "$STELLA_APP_CACHE_DIR/$FILE_NAME" "$URL" || \
				curl -fkSL -o "$STELLA_APP_CACHE_DIR/$FILE_NAME" "$URL" || \
				rm -f "$STELLA_APP_CACHE_DIR/$FILE_NAME"
			else
				if [[ -n `which wget 2> /dev/null` ]]; then
					wget "$URL" -O "$STELLA_APP_CACHE_DIR/$FILE_NAME" --no-check-certificate || \
					wget "$URL" -O "$STELLA_APP_CACHE_DIR/$FILE_NAME" || \
					rm -f "$STELLA_APP_CACHE_DIR/$FILE_NAME"
				else
					__require "curl" "curl" "SYSTEM"
				fi
			fi
		else
			__log "INFO" " ** Already downloaded"
		fi
	else
		__log "INFO" " ** Already downloaded"
	fi

	local _tmp_dir
	if [ -f "$STELLA_APP_CACHE_DIR/$FILE_NAME" ]; then
		_tmp_dir="$STELLA_APP_CACHE_DIR"
	else
		if [ -f "$STELLA_INTERNAL_CACHE_DIR/$FILE_NAME" ]; then
			_tmp_dir="$STELLA_INTERNAL_CACHE_DIR"
		fi
	fi

	if [ ! "$_tmp_dir" = "" ]; then
		if [ ! "$DEST_DIR" = "" ]; then
			if [ ! "$DEST_DIR" = "$STELLA_APP_CACHE_DIR" ]; then
				if [ ! -d "$DEST_DIR" ]; then
					mkdir -p "$DEST_DIR"
				fi
				cp "$_tmp_dir/$FILE_NAME" "$DEST_DIR/"
				__log "INFO" "** Downloaded $FILE_NAME is in $DEST_DIR"
			fi
		fi
	else
		__log "INFO" "** ERROR downloading $URL"
	fi
}

# when --strip-components option on tar does not exist
__untar-strip() {
	local zip=$1
	local dest=${2:-.}
	local temp=$(mktmpdir)

	cd "$temp"
	tar xzf "$FILE_PATH"

	shopt -s dotglob
	local f=("$temp"/*)

	if (( ${#f[@]} == 1 )) && [[ -d "${f[0]}" ]] ; then
			mv "$temp"/*/* "$dest"
	else
			mv "$temp"/* "$dest"
	fi
	rm -Rf "$temp"
}

__unzip-strip() (
    local zip=$1
    local dest=${2:-.}
    local temp=$(mktmpdir)

    unzip -a -o -d "$temp" "$zip"
    shopt -s dotglob
    local f=("$temp"/*)

    if (( ${#f[@]} == 1 )) && [[ -d "${f[0]}" ]] ; then
        mv "$temp"/*/* "$dest"
    else
        mv "$temp"/* "$dest"
    fi
    rm -Rf "$temp"
)

__sevenzip-strip() (
    local zip=$1
    local dest=${2:-.}
    local temp=$(mktmpdir)
    7z x "$zip" -y -o"$temp"
    shopt -s dotglob
    local f=("$temp"/*)

    if (( ${#f[@]} == 1 )) && [[ -d "${f[0]}" ]] ; then
        mv "$temp"/*/* "$dest"
    else
        mv "$temp"/* "$dest"
    fi
    rm -Rf "$temp"
)

# SCM ---------------------------------------------
# https://vcversioner.readthedocs.org/en/latest/
# TODO : should work only if at least one tag exist ?
__mercurial_project_version() {
	local _PATH=$1
	local _OPT=$2

	_opt_version_short=OFF
	_opt_version_long=OFF
	for o in $_OPT; do
		[ "$o" = "SHORT" ] && _opt_version_short=ON
		[ "$o" = "LONG" ] && _opt_version_long=ON
	done

	if [[ -n `which hg 2> /dev/null` ]]; then
		if [ "$_opt_version_long" = "ON" ]; then
			echo "$(hg log -R "$_PATH" -r . --template "{latesttag}-{latesttagdistance}-{node|short}")"
		fi
		if [ "$_opt_version_short" = "ON" ]; then
			echo "$(hg log -R "$_PATH" -r . --template "v{latesttag}")"
		fi
	fi
}

__git_project_version() {
	local _PATH=$1
	local _OPT=$2

	_opt_version_short=ON
	_opt_version_long=OFF
	for o in $_OPT; do
		[ "$o" = "SHORT" ] && _opt_version_short=ON && _opt_version_long=OFF
		[ "$o" = "LONG" ] && _opt_version_long=ON && _opt_version_short=OFF
	done

	if [[ -n `which git 2> /dev/null` ]]; then
		if [ "$_opt_version_long" = "ON" ]; then
			echo "$(git --git-dir "$_PATH/.git" describe --tags --long --always --first-parent)"
		fi
		if [ "$_opt_version_short" = "ON" ]; then
			echo "$(git --git-dir "$_PATH/.git" describe --tags --abbrev=0 --always --first-parent)"
		fi
	fi
}


# INI FILE MANAGEMENT---------------------------------------------------
__get_key() {
	local _FILE=$1
	local _SECTION=$2
	local _KEY=$3
	local _OPT=$4

	_opt_section_prefix=OFF
	for o in $_OPT; do
		[ "$o" = "PREFIX" ] && _opt_section_prefix=ON
	done

	# trim whitespace
	_SECTION=$(__trim "$_SECTION")

	local _win_endline=$'s/\r//g'
	local _exp1="/\[$_SECTION\]/,/\[.*\]/p"
	local _exp2="/^$_KEY=/{print \$2}"

	if [ -f "$_FILE" ]; then
		if [ "$_opt_section_prefix" = "ON" ]; then
			eval "$_SECTION"_"$_KEY"='$(sed -n -e "$_win_endline" -e "$_exp1" "$_FILE" | awk -F= "$_exp2" )'
		else
			eval $_KEY='$(sed -n -e "$_win_endline" -e "$_exp1" "$_FILE" | awk -F= "$_exp2" )'
		fi
	else
		if [ "$_opt_section_prefix" = "ON" ]; then
			eval "$_SECTION"_"$_KEY"=
		else
			eval $_KEY=
		fi
	fi

}

__del_key() {
	local _FILE=$1
	local _SECTION=$2
	local _KEY=$3

	[ -f "$_FILE" ] && __ini_file "DEL" "$_FILE" "$_SECTION" "$_KEY"
}

__add_key() {
	local _FILE=$1
	local _SECTION=$2
	local _KEY=$3
	local _VALUE=$4

	if [ ! -f "$_FILE" ]; then
		touch $_FILE
	fi

	__ini_file "ADD" "$_FILE" "$_SECTION" "$_KEY" "$_VALUE"
}

__ini_file() {
	local _MODE=$1
	local _FILE=$2
	local _SECTION=$3
	local _KEY=$4
	if [ ! "$_KEY" = "" ]; then
		local _VALUE=$5
	fi

	# escape regexp special characters
	# http://stackoverflow.com/questions/407523/escape-a-string-for-a-sed-replace-pattern
	_SECTION_NAME=$_SECTION
	_SECTION=$(echo $_SECTION | sed -e 's/[]\/$*.^|[]/\\&/g')
	_VALUE=$(echo "$_VALUE" | sed -e 's/\\/\\\\/g')
	_KEY=$(echo "$_KEY" | sed -e 's/\\/\\\\/g')

	tp=$(mktmp)

	awk -F= -v mode="$_MODE" -v val="$_VALUE" '
	# Clear the flag
	BEGIN {
		processing = 0;
		skip = 0;
		modified = 0;
	}

	# Leaving the found section
	/\[/ {
		if(processing) {
			if ( mode == "ADD" ) {
				print "'$_KEY'="val;
				modified = 1;
				processing = 0;
			}

			if ( mode == "DEL" ) {
				processing = 0;
			}
		}
	}


	# Entering the section, set the flag
	/^\['$_SECTION']/ {
		processing = 1;
	}

	# Modify the line, if the flag is set
	/^'$_KEY'=/ {
		if (processing) {
		   	if ( mode == "ADD" ) {
		   		print "'$_KEY'="val;
				skip = 1;
				modified = 1;
				processing = 0;
			}

			if ( mode == "DEL" ) {
				skip = 1;
				processing = 0;
			}

		}
	}


	# Output a line (that we didnt output above)
	/.*/ {

		if (skip)
		    skip = 0;
		else
			print $0;
	}
	END {
		if(!modified && mode == "ADD") {
			if(!processing) print "['$_SECTION_NAME']"
			if("'$_KEY'" != "") {
				print "'$_KEY'="val;
		   	}
		}

	}

	' "$_FILE" > $tp

	mv -f $tp "$_FILE"
}



# ARG COMMAND LINE MANAGEMENT---------------------------------------------------
# TODO : MacOS alternative in go of getopt or brew gnu-getopt?
#		https://github.com/droundy/goopt
#		https://code.google.com/p/opts-go/
#		https://godoc.org/code.google.com/p/getopt
#		https://github.com/kesselborn/go-getopt
#		STELLA_ARGPARSE_GETOPT : getopt command instead of "getopt"
__argparse(){
	local PROGNAME=$(__get_filename_from_string "$1")
	local OPTIONS="$2"
	local PARAMETERS="$3"
	local SHORT_DESCRIPTION="$4"
	local LONG_DESCRIPTION="$5"
	# this variable, if setted, will receive the rest of the command line not processed
	local COMMAND_LINE_RESULT="$6"

	shift 6

	local COMMAND_LINE="$@"

	ARGP="
	--HEADER--
	ARGP_PROG=$PROGNAME
	ARGP_DELETE=quiet verbose version
	ARGP_VERSION=$STELLA_APP_NAME
	ARGP_OPTION_SEP=:
	ARGP_SHORT=$SHORT_DESCRIPTION
	ARGP_LONG_DESC=$LONG_DESCRIPTION"

	ARGP=$ARGP"
	--OPTIONS--
	$OPTIONS
	--PARAMETERS--
	$PARAMETERS
	"

	# Debug mode
	# for debug :
	#export ARGP_DEBUG=1
	export ARGP_HELP_FMT=
	#export ARGP_HELP_FMT="rmargin=$(tput cols)"
	#echo $ARGP
	exec 4>&1 # fd4 is now a copy of fd1 ie stdout
	RES=$( echo "$ARGP" | GETOPT_CMD=$STELLA_ARGPARSE_GETOPT $STELLA_COMMON/argp.sh $COMMAND_LINE 3>&1 1>&4 || echo exit $? )
	exec 4>&-

	# $@ now contains not parsed argument, options and identified parameters have been processed and removed:
	# echo "argp returned this for us to eval: '$RES'"
	[ "$RES" ] || exit 0

	# for debug :
	#echo $RES
	eval $RES

	if [ "$COMMAND_LINE_RESULT" ]; then
		# Store rest of the command line not processed in COMMAND_LINE_RESULT
		eval "$COMMAND_LINE_RESULT=\$@"
	fi


}



fi
