if [ ! "$_STELLA_COMMON_INCLUDED_" == "1" ]; then
_STELLA_COMMON_INCLUDED_=1

#turns off bash's hash function
set +h


# VARIOUS-----------------------------
# sort a list of version

#sorted=$(sort_version "build507 build510 build403 build4000 build" "ASC")
#echo $sorted
# ===> build build403 build507 build510 build4000
#sorted=$(sort_version "1.1.0 1.1.1 1.1.1a 1.1.1b" "ASC SEP .")
#echo $sorted
# ===> 1.1.0 1.1.1 1.1.1a 1.1.1b
#sorted=$(sort_version "1.1.0 1.1.1 1.1.1a 1.1.1b" "DESC SEP .")
#echo $sorted
# ===> 1.1.1b 1.1.1a 1.1.1 1.1.0
#sorted=$(sort_version "1.1.0 1.1.1 1.1.1alpha 1.1.1beta1 1.1.1beta2" "ASC ENDING_CHAR_REVERSE SEP .")
#echo $sorted
# ===> 1.1.0 1.1.1alpha 1.1.1beta1 1.1.1beta2 1.1.1
#sorted=$(sort_version "1.1.0 1.1.1 1.1.1alpha 1.1.1beta1 1.1.1beta2" "DESC ENDING_CHAR_REVERSE SEP .")
#echo $sorted
# ===> 1.1.1 1.1.1beta2 1.1.1beta1 1.1.1alpha 1.1.0
#sorted=$(sort_version "1.9.0 1.10.0 1.10.1.1 1.10.1 1.10.1alpha1 1.10.1beta1 1.10.1beta2 1.10.2 1.10.2.1 1.10.2.2 1.10.0RC1 1.10.0RC2" "DESC ENDING_CHAR_REVERSE SEP .")
#echo $sorted
# ===> 1.10.2.2 1.10.2.1 1.10.2 1.10.1.1 1.10.1 1.10.1beta2 1.10.1beta1 1.10.1alpha1 1.10.0 1.10.0RC2 1.10.0RC1 1.9.0


# NOTE : ending characters in a version number may be ordered in the opposite way example :
# 1.0.1 is more recent than 1.0.1beta so in ASC : 1.0.1beta 1.0.1 and in DESC : 1.0.1 1.0.1beta
# To activate this behaviour use "ENDING_CHAR_REVERSE" option
# we also need to indicate separator only if we use ENDING_CHAR_REVERSE and if there is any separator (obviously)
function __sort_version() {
	local list=$1
	local opt="$2"

	local opposite_order_for_ending_chars=OFF
	local mode="ASC"

	local separator=

	local flag_sep=OFF
	for o in $opt; do
		[ "$o" == "ASC" ] && mode=$o
		[ "$o" == "DESC" ] && mode=$o
		[ "$o" == "ENDING_CHAR_REVERSE" ] && opposite_order_for_ending_chars=ON
		# we need separator only if we use ENDING_CHAR_REVERSE and if there is any separator (obviously)
		[ "$flag_sep" == "ON" ] && separator="$o" && flag_sep=OFF
		[ "$o" == "SEP" ] && flag_sep=ON
	done

	local internal_separator=}
	local new_list=
	local match_list=
	local max_number_of_block=0
	local number_of_block=0
	for r in $list; do
		# separate each block of number and block of letter
		[ ! "$separator" == "" ] && new_item="$(echo $r | sed "s,\([0-9]*\)\([^0-9]*\)\([0-9]*\),\1$internal_separator\2$internal_separator\3,g" | sed "s,^\([0-9]\),$internal_separator\1," | sed "s,\([0-9]\)$,\1$internal_separator$separator$internal_separator,")"
		[ "$separator" == "" ] && new_item="$(echo $r | sed "s,\([0-9]*\)\([^0-9]*\)\([0-9]*\),\1$internal_separator\2$internal_separator\3,g" | sed "s,^\([0-9]\),$internal_separator\1," | sed "s,\([0-9]\)$,\1$internal_separator,")"

		if [ "$opposite_order_for_ending_chars" == "OFF" ]; then
			[ "$mode" == "ASC" ] && substitute=A
			[ "$mode" == "DESC" ] && substitute=A
		else
			[ "$mode" == "ASC" ] && substitute=z
			[ "$mode" == "DESC" ] && substitute=z
		fi

		[ ! "$separator" == "" ] && new_item="$(echo $new_item | sed "s,\\$separator,$substitute,g")"

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

			if [ ! "$(echo $b | sed "s,[0-9]*,,g")" == "" ]; then
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
	local reverse
	local opposite_reverse
	local j
	while [  "$count" -lt "$max_number_of_block" ]; do
		count=$[$count +1]

		block_arg=

		block_is_char=
		for j in $char_block_list; do
			[ "$count" == "$j" ] && block_is_char=1
		done
		if [ "$block_is_char" == "" ]; then
			block_arg=n$block_arg
			[ "$mode" == "ASC" ] && block_arg=$block_arg
			[ "$mode" == "DESC" ] && block_arg=r$block_arg
		else
			[ "$mode" == "ASC" ] && block_arg=$block_arg
			[ "$mode" == "DESC" ] && block_arg=r$block_arg
		fi

		sorted_arg="$sorted_arg -k $count,$count"$block_arg
	done
	[ "$mode" == "ASC" ] && sorted_arg="-t$internal_separator $sorted_arg"
	[ "$mode" == "DESC" ] && sorted_arg="-t$internal_separator $sorted_arg"

	sorted_list="$(echo "$new_list" | tr ' ' '\n' | sort $(echo "$sorted_arg") | tr '\n' ' ')"

	# restore original version strings (alternative to hashtable...)
	local result_list=
	local flag_found=OFF
	local flag=KEY
	for r in $sorted_list; do
		flag_found=OFF
		flag=KEY
		for m in $match_list; do
			if [ "$flag_found" == "ON" ]; then
				result_list="$result_list $m"
				break
			fi
			if [ "$flag" == "KEY" ]; then
				[[ $m == $r ]] && flag_found=ON
			fi
		done
	done

	echo "$result_list" | sed -e 's/^ *//' -e 's/ *$//'

}






function __url_encode() {
	if [ "$(which xxd 2>/dev/null)" == "" ]; then
		__url_encode_1 "$@"
	else
		__url_encode_with_xxd "$@"
	fi
}

# https://gist.github.com/cdown/1163649
function __url_encode_1() {
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
function __url_encode_with_xxd() {
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
function __url_encode_2() {
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
function __url_decode() {

    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}


# http://wp.vpalos.com/537/uri-parsing-using-bash-built-in-features/ (customized)
# URI parsing function
#
# The function creates global variables with the parsed results.
# It returns 0 if parsing was successful or non-zero otherwise.
#
# [schema://][user[:password]@][host][:port][/path][?[arg1=val1]...][#fragment]
function __uri_parse() {
	# uri capture
	__stella_uri="$@"

	local path
	local count
	local query
	# top level parsing
	local pattern='^(([a-z]+)://)?((([^:\/]+)(:([^@\/]*))?@)?([^:\/?]*)(:([0-9]+))?)(\/[^?#]*)?(\?[^#]*)?(#.*)?$'
	[[ "$__stella_uri" =~ $pattern ]] || return 1;

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
	while [[ $query =~ $pattern ]]; do
			eval "__stella_uri_args[$count]='${BASH_REMATCH[1]}'"
			eval "__stella_uri_arg_${BASH_REMATCH[1]}='${BASH_REMATCH[3]}'"
			query="${query:${#BASH_REMATCH[0]}}"
			#let count++
			count=$(( count + 1 ))
	done

	# return success
	return 0
}

# [user@]host[:port][/#abs_or_rel_path]
function __transfert_stella() {
	local _uri="$1"

	local _OPT="$2"
	local _opt_ex_cache="EXCLUDE_FILTER stella/$(__abs_to_rel_path $STELLA_INTERNAL_CACHE_DIR $STELLA_ROOT)/"
	local _opt_ex_workspace="EXCLUDE_FILTER stella/$(__abs_to_rel_path $STELLA_INTERNAL_WORK_ROOT $STELLA_ROOT)/"
	local _opt_ex_env="EXCLUDE_FILTER stella/.stella-env"
	for o in $_OPT; do
		[ "$o" == "CACHE" ] && _opt_ex_cache=
		[ "$o" == "WORKSPACE" ] && _opt_ex_workspace=
		[ "$o" == "ENV" ] && _opt_ex_env=
	done

	__transfert_folder_rsync "$STELLA_ROOT" "$_uri" "$_opt_ex_cache $_opt_ex_workspace $_opt_ex_env"
}

# [user@]host[:port][/#abs_or_rel_path]
# path could be absolute path in the target system
# or could be relavite path to the default folder when logging with ssh
# example
# __transfert_folder_rsync /foo/folder user@ip
#			here path is empty, so folder will be sync inside home directory of user as /home/user/folder
function __transfert_folder_rsync() {
	local _folder="$1"
	local _uri="$2"

	# EXCLUDE_FILTER (repeat this option for each exclude filter to set)
	# FOLDER_CONTENT will transfer only folder content not folder itself
	local _OPT="$3"
	local _flag_exclude_filter=OFF
	local _exclude_filter=
	local _opt_folder_content=OFF
	for o in $_OPT; do
		[ "$_flag_exclude_filter" == "ON" ] && _exclude_filter="--exclude $o $_exclude_filter" && _flag_exclude_filter=OFF
		[ "$o" == "EXCLUDE_FILTER" ] && _flag_exclude_filter=ON
		[ "$o" == "FOLDER_CONTENT" ] && _opt_folder_content=ON
	done

	__require "rsync" "rsync"
	__require "ssh" "ssh"

	__uri_parse "$_uri"

	local _ssh_port="22"
	[ ! "$__stella_uri_port" == "" ] && _ssh_port="$__stella_uri_port"

	local _target="$__stella_uri_host":"${__stella_uri_fragment:1}"
	[ ! "$__stella_uri_user" == "" ] && _target="$__stella_uri_user"@"$_target"

	# $_folder must not finish with / or only folder content will be transfered, not folder itself
	if [ "$_opt_folder_content" == "ON" ]; then
		# remove last '/' char (tested on macos and linux)
		_folder="$_folder/"
	else
		_folder="${_folder%/}"
	fi

	rsync $_exclude_filter --force --delete-excluded --delete -avz -e "ssh -p $_ssh_port" "$_folder" "$_target"
}


# [user@]host[:port][/#abs_or_rel_path]
# path could be absolute path in the target system
# or could be relavite path to the default folder when logging with ssh
# if path end with a "/" it will be a destination folder, else it will be the name of the transfered file
# example
# __transfert_folder_rsync /foo/file1 user@ip:folder/file2
#			file1 will be sync inside home directory of user as /home/user/folder/file2
function __transfert_file_rsync() {
	local _file="$1"
	local _uri="$2"

	__uri_parse "$_uri"

	local _ssh_port="22"
	[ ! "$__stella_uri_port" == "" ] && _ssh_port="$__stella_uri_port"

	local _target="$__stella_uri_host":"${__stella_uri_fragment:1}"
	[ ! "$__stella_uri_user" == "" ] && _target="$__stella_uri_user"@"$_target"

	__require "rsync" "rsync"
	__require "ssh" "ssh"

	rsync -avz -e "ssh -p $_ssh_port" "$_file" "$_target"
}

function __daemonize() {
	local _item_path=$1
	local _log_file=$2

	if [ "$_log_file" == "" ]; then
		nohup -- $_item_path 1>/dev/null 2>&1 &
	else
		nohup -- $_item_path 1>$_log_file 2>&1 &
	fi

}

function __get_active_path() {
	echo "$PATH"
}




# http://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
function __trim3() {
	echo -e "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

# trim whitespace
function __trim2() {
	echo $(echo "$1" | sed -e 's/^ *//' -e 's/ *$//')
}

function __trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
    echo -n "$var"
}

# http://stackoverflow.com/a/20460402
function __string_contains() { [ -z "${1##*$2*}" ] && [ -n "$1" -o -z "$2" ]; }



function __get_stella_version() {
	local _stella_root_="$1"

	[ "$_stella_root_" == "" ] && _stella_root_="$STELLA_ROOT"

	_s_flavour=$(__get_stella_flavour "$_stella_root_")

	case "$_s_flavour" in
		STABLE)
				cat "$_stella_root_/VERSION"
		;;

		DEV)
				echo $(__git_project_version "$_stella_root_" "LONG")
		;;

		*)
				echo "unknown"
		;;

	esac
}


# return STABLE or DEV
function __get_stella_flavour() {
	local _stella_root_="$1"
	[ "$_stella_root_" == "" ] && _stella_root_="$STELLA_ROOT"

	local _s_flavour=unknown

	[ -f "$_stella_root_/VERSION" ] && _s_flavour="STABLE"
	[ -d "$_stella_root_/.git" ] && _s_flavour="DEV"

	echo $_s_flavour
}


function __is_dir_empty() {
	if [ $(find "$1" -prune -empty -type d) ]; then
		# dir is empty
		echo "TRUE"
	else
		echo "FALSE"
	fi
}

# path = ${foo%/*}
# To get: /tmp/my.dir (like dirname)
# file = ${foo##*/}
# To get: filename.tar.gz (like basename)
# base = ${file%%.*}
# To get: filename


function __get_path_from_string() {
	echo ${1%/*}
}

function __get_filename_from_string() {
	echo ${1##*/}
}

function __get_filename_from_url() {
	local _AFTER_SLASH
	_AFTER_SLASH=${1##*/}
	echo ${_AFTER_SLASH%%\?*}
}

function __get_extension_from_string() {
	local _AFTER_DOT
	_AFTER_DOT=${1##*\.}
	echo $_AFTER_DOT
	#echo ${_AFTER_DOT%%\?*}
}


function __is_abs() {
	local _path=$1

	case $_path in
		/*)
			echo "TRUE"
			;;
		*)
			echo "FALSE"
			;;
	esac
}

# NOTE by default path is determined giving by the current running directory
function __rel_to_abs_path() {
	local _rel_path=$1
	local _abs_root_path=$2
	local result

	if [ "$_abs_root_path" == "" ]; then
		_abs_root_path=$STELLA_CURRENT_RUNNING_DIR
	fi


	if [ "$(__is_abs $_abs_root_path)" == "FALSE" ]; then
		result="$_rel_path"
	else

		case $_rel_path in
			/*)
				# path is already absolute
				echo "$_rel_path"
				;;
			*)
				# TODO if directory does not exist returned path is not real absolute (example : /tata/toto/../titi instead of /tata/titi)
				# relative to a given absolute path
				if [ -d "$_abs_root_path/$_rel_path" ]; then
					result="$(cd "$_abs_root_path/$_rel_path" && pwd )"
				else
					# NOTE using this method if directory does not exist returned path is not real absolute (example : /tata/toto/../titi instead of /tata/titi)
					# TODO : we rely on pure bash version, because readlink -m option used un alternative2 do not exist on some system
					result=$(__rel_to_abs_path_alternative_1 "$_rel_path" "$_abs_root_path")
					#[ "$STELLA_CURRENT_PLATFORM" == "darwin" ] && result=$(__rel_to_abs_path_alternative_1 "$_rel_path" "$_abs_root_path")
					#[ "$STELLA_CURRENT_PLATFORM" == "linux" ] && result=$(__rel_to_abs_path_alternative_2 "$_rel_path" "$_abs_root_path")
				fi
				;;
		esac
	fi
	echo $result | tr -s '/'
}

# NOTE : http://stackoverflow.com/a/21951256
# NOTE : pure BASH : do not use readlink or cd or pwd command BUT do not follow symlink
function __rel_to_abs_path_alternative_1(){
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
function __rel_to_abs_path_alternative_2(){
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
function __abs_to_rel_path() {
	local _abs_path_to_translate="$1"/
	local _abs_path_root="$2"

	local result=""

	if [ "$_abs_path_root" == "" ]; then
		_abs_path_root=$STELLA_CURRENT_RUNNING_DIR
	fi

	_abs_path_root="$_abs_path_root"/

	local common_part="$_abs_path_root" # for now

	if [ "$(__is_abs $_abs_path_to_translate)" == "FALSE" ]; then
		result="$_abs_path_to_translate"
	else

		case $_abs_path_root in
			/*)
				while [[ "${_abs_path_to_translate#$common_part}" == "${_abs_path_to_translate}" ]]; do
					# no match, means that candidate common part is not correct
					# go up one level (reduce common part)
					common_part="$(dirname $common_part)"

					# and record that we went back
					if [[ -z $result ]]; then
						result=".."
					else
						result="../$result"
					fi

				done

				if [[ $common_part == "/" ]]; then
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

	if [ "${result:(-1)}" == "/" ]; then
		result=${result%?}
	fi
	echo "$result"

}

# init stella environment
function __init_stella_env() {
	__feature_init_installed
	# PROXY
	__init_proxy
}

#MEASURE TOOL----------------------------------------------
# __timecount_start "count_id"
function __timecount_start() {
	local _count_name_var=$1
	local _id=$RANDOM$RANDOM

	eval __stella_timecount_$_id="$(date +%s)"
	eval $_count_name_var="__stella_timecount_$_id"

}

# elapsed_time=$(__timecount_stop "count_id")
function __timecount_stop() {
	local _end_count="$(date +%s)"
	local _ellapsed=
	local _tmp="$1"
	local _start_count=${!_tmp}

	local _ellapsed=$(echo "$_end_count - ${!_start_count}" | bc)
	echo $_ellapsed
}


#FILE TOOLS----------------------------------------------
#http://stackoverflow.com/a/17902999/5027535
function __count_folder_item() {
	local _path="$1"
	local _filter="$2"

	if [ "$_filter" == "" ]; then

		_filter="*"
	fi

	local files=$(shopt -s nullglob dotglob; echo $_path/$_filter)
	echo ${#files[@]}

}

function __del_folder() {
	echo "** Deleting $1 folder"
	[ -d $1 ] && rm -Rf $1
}

# copy content of folder ARG1 into folder ARG2
function __copy_folder_content_into() {
	local select_filter="$3"
	if [ "$select_filter" == "" ]; then
		select_filter="*"
	fi

	if [ $(__count_folder_item $1 $select_filter) -gt 0 ]; then
		mkdir -p $2
		if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
			cp -fa $1/$select_filter $2
		else
			cp -fa $1/$select_filter --target-directory=$2
		fi
	fi
}

#RESSOURCES MANAGEMENT ---------------------------------------------------
function __get_resource() {
	local OPT="$5"
	OPT="$OPT GET"
	__resource "$1" "$2" "$3" "$4" "$OPT"
}

function __update_resource() {
	local OPT="$5"
	OPT="$OPT UPDATE"
	__resource "$1" "$2" "$3" "$4" "$OPT"
}

function __delete_resource() {
	local OPT="$5"
	OPT="$OPT DELETE"
	__resource "$1" "$2" "$3" "$4" "$OPT"
}

function __revert_resource() {
	local OPT="$5"
	OPT="$OPT REVERT"
	__resource "$1" "$2" "$3" "$4" "$OPT"
}

function __resource() {
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
		if [ "$_opt_force_name" == "ON" ]; then
			_download_filename=$o
			_opt_force_name=OFF
		else
			if [ "$_opt_version" == "ON" ]; then
				_checkout_version=$o
				_opt_version=OFF
			else
				[ "$o" == "VERSION" ] && _opt_version=ON
				[ "$o" == "MERGE" ] && _opt_merge=ON
				[ "$o" == "DEST_ERASE" ] && _opt_dest_erase=ON
				[ "$o" == "STRIP" ] && _opt_strip=ON
				[ "$o" == "FORCE_NAME" ] && _opt_force_name=ON
				if [ "$o" == "DELETE" ]; then _opt_delete=ON;  _opt_revert=OFF;  _opt_get=OFF; _opt_update=OFF; fi
				if [ "$o" == "UPDATE" ]; then _opt_update=ON;  _opt_revert=OFF;  _opt_get=OFF; _opt_delete=OFF; fi
				if [ "$o" == "REVERT" ]; then _opt_revert=ON;  _opt_update=OFF;  _opt_get=OFF; _opt_delete=OFF; fi
			fi
		fi
	done

	[ "$_opt_revert" == "ON" ] && echo " ** Reverting resource :"
	[ "$_opt_update" == "ON" ] && echo " ** Updating resource :"
	[ "$_opt_delete" == "ON" ] && echo " ** Deleting resource :"
	[ "$_opt_get" == "ON" ] && echo " ** Getting resource :"
	[ ! "$FINAL_DESTINATION" == "" ] && echo " $NAME in $FINAL_DESTINATION" || echo " $NAME"

	#[ "$FORCE" ] && rm -Rf $FINAL_DESTINATION
	if [ "$_opt_get" == "ON" ]; then
		#if [ "$FORCE" ]; then
		#	[ "$_opt_merge" == "OFF" ] && rm -Rf "$FINAL_DESTINATION"
		#	[ "$_opt_merge" == "ON" ] && rm -f "$FINAL_DESTINATION/._MERGED_$NAME"
		#fi
		if [ "$_opt_dest_erase" == "ON" ]; then
			[ "$_opt_merge" == "OFF" ] && rm -Rf "$FINAL_DESTINATION"
			[ "$_opt_merge" == "ON" ] && rm -f "$FINAL_DESTINATION/._MERGED_$NAME"
		fi
	fi


	if [ "$_opt_delete" == "ON" ]; then
		[ "$_opt_merge" == "OFF" ] && rm -Rf "$FINAL_DESTINATION"
		[ "$_opt_merge" == "ON" ] && rm -f "$FINAL_DESTINATION/._MERGED_$NAME"
		_FLAG=0
	fi

	if [ "$_opt_delete" == "OFF" ]; then
		# strip root folder mode
		_STRIP=
		[ "$_opt_strip" == "ON" ] && _STRIP=STRIP


		_FLAG=1
		case $PROTOCOL in
			HTTP_ZIP|FILE_ZIP)
				[ "$_opt_revert" == "ON" ] && echo "REVERT Not supported with this protocol" && _FLAG=0
				[ "$_opt_update" == "ON" ] && echo "UPDATE Not supported with this protocol" && _FLAG=0
				if [ -d "$FINAL_DESTINATION" ]; then
					if [ "$_opt_get" == "ON" ]; then
						if [ "$_opt_merge" == "ON" ]; then
							if [ -f "$FINAL_DESTINATION/._MERGED_$NAME" ]; then
								echo " ** Ressource already merged"
								_FLAG=0
							fi
						fi
						if [ "$_opt_strip" == "ON" ]; then
							#echo " ** Ressource already stripped"
							echo " ** Destination folder exist"
							#_FLAG=0
						fi
					fi
				fi
				;;
			HTTP|FILE)
				[ "$_opt_strip" == "ON" ] && echo "STRIP option not in use"
				[ "$_opt_revert" == "ON" ] && echo "REVERT Not supported with this protocol" && _FLAG=0
				[ "$_opt_update" == "ON" ] && echo "UPDATE Not supported with this protocol" && _FLAG=0

				if [ -d "$FINAL_DESTINATION" ]; then
					if [ "$_opt_get" == "ON" ]; then
						if [ "$_opt_merge" == "ON" ]; then
							if [ -f "$FINAL_DESTINATION/._MERGED_$NAME" ]; then
								echo " ** Ressource already merged"
								_FLAG=0
							fi
						fi
					fi
				fi
				;;
			HG|GIT)
				[ "$_opt_strip" == "ON" ] && echo "STRIP option not supported with this protocol"
				[ "$_opt_merge" == "ON" ] && echo "MERGE option not supported with this protocol"
				if [ -d "$FINAL_DESTINATION" ]; then
					if [ "$_opt_get" == "ON" ]; then
						echo " ** Ressource already exist"
						_FLAG=0
					fi
				else
					[ "$_opt_revert" == "ON" ] && echo " ** Ressource does not exist" && _FLAG=0
					[ "$_opt_update" == "ON" ] && echo " ** Ressource does not exist" && _FLAG=0
				fi
				;;
		esac
	fi

	if [ "$_FLAG" == "1" ]; then
		[ ! -d $FINAL_DESTINATION ] && mkdir -p $FINAL_DESTINATION

		case $PROTOCOL in
			HTTP_ZIP)
				if [ "$_opt_get" == "ON" ]; then __download_uncompress "$URI" "$_download_filename" "$FINAL_DESTINATION" "$_STRIP"; fi
				if [ "$_opt_merge" == "ON" ]; then echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"; fi
				;;
			HTTP)
				# HTTP protocol use always merge by default : because it never erase destination folder
				# but the 'merged' flag file will be created only if we pass the option MERGE
				if [ "$_opt_get" == "ON" ]; then __download "$URI" "$_download_filename" "$FINAL_DESTINATION"; fi
				if [ "$_opt_merge" == "ON" ]; then echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"; fi
				;;
			HG)
				if [ "$_opt_revert" == "ON" ]; then cd "$FINAL_DESTINATION"; hg revert --all -C; fi
				if [ "$_opt_update" == "ON" ]; then cd "$FINAL_DESTINATION"; hg pull; hg update $_checkout_version; fi
				if [ "$_opt_get" == "ON" ]; then hg clone $URI "$FINAL_DESTINATION"; if [ ! "$_checkout_version" == "" ]; then cd "$FINAL_DESTINATION"; hg update $_checkout_version; fi; fi
				# [ "$_opt_merge" == "ON" ] && echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"
				;;
			GIT)
				__require "git" "git" "PREFER_SYSTEM"
				if [ "$_opt_revert" == "ON" ]; then cd "$FINAL_DESTINATION"; git reset --hard; fi
				if [ "$_opt_update" == "ON" ]; then cd "$FINAL_DESTINATION"; git pull;if [ ! "$_checkout_version" == "" ]; then git checkout $_checkout_version; fi; fi
				if [ "$_opt_get" == "ON" ]; then git clone $URI "$FINAL_DESTINATION"; if [ ! "$_checkout_version" == "" ]; then cd "$FINAL_DESTINATION"; git checkout $_checkout_version; fi; fi
				# [ "$_opt_merge" == "ON" ] && echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"
				;;
			FILE)
				if [ "$_opt_get" == "ON" ]; then __copy_folder_content_into "$URI" "$FINAL_DESTINATION"; fi
				if [ "$_opt_merge" == "ON" ]; then echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"; fi
				;;
			FILE_ZIP)
				__uncompress "$URI" "$FINAL_DESTINATION%" "$_STRIP"
				if [ "$_opt_merge" == "ON" ]; then echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"; fi
				;;
			*)
				echo " ** ERROR Unknow protocol"
				;;
		esac
	fi
}

#DOWNLOAD AND ZIP FUNCTIONS---------------------------------------------------
function __download_uncompress() {
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


	if [ "$FILE_NAME" == "_AUTO_" ]; then
		#_AFTER_SLASH=${URL##*/}
		FILE_NAME=$(__get_filename_from_url "$URL")
		echo "** Guessed file name is $FILE_NAME"
	fi

	__download $URL $FILE_NAME
	__uncompress "$STELLA_APP_CACHE_DIR/$FILE_NAME" "$UNZIP_DIR" "$OPT"


}

function __compress() {
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
			echo "TODO: *********** ZIP NOT IMPLEMENTED"
			;;
		TAR*)
				[ -d "$_target" ] && tar -c -v -z -f "$_output_archive" -C "$_target/.." "$(basename $_target)"
				[ -f "$_target" ] && tar -c -v -z -f "$_output_archive" -C "$(dirname $_target)" "$(basename $_target)"
			;;
	esac


}

function __uncompress() {
	# TODO : progress bar
	# http://stackoverflow.com/questions/238073/how-to-add-a-progress-bar-to-a-shell-script
	local FILE_PATH
	local UNZIP_DIR
	local OPT
	FILE_PATH="$1"
	UNZIP_DIR="$2"
	OPT="$3"

	local _opt_dest_erase=OFF # delete destination folder (default : FALSE)
	local _opt_strip=OFF # delete first folder in archive  (default : FALSE)
	for o in $OPT; do
		[ "$o" == "DEST_ERASE" ] && _opt_dest_erase=ON
		[ "$o" == "STRIP" ] && _opt_strip=ON
	done


	if [ "$_opt_dest_erase" == "ON" ]; then
		rm -Rf "$UNZIP_DIR"
	fi

	mkdir -p "$UNZIP_DIR"

	echo " ** Uncompress $FILE_PATH in $UNZIP_DIR"

	cd "$UNZIP_DIR"

	case "$FILE_PATH" in
		*.zip)
			__require "unzip" "unzip" "PREFER_SYSTEM"
			[ "$_opt_strip" == "OFF" ] && unzip -a -o "$FILE_PATH"
			[ "$_opt_strip" == "ON" ] && __unzip-strip "$FILE_PATH" "$UNZIP_DIR"
			;;
		*.gz | *.tgz)
			if [ "$_opt_strip" == "OFF" ]; then
				tar xzf "$FILE_PATH"
			else
				tar xzf "$FILE_PATH" --strip-components=1 2>/dev/null || __untar-strip "$FILE_PATH" "$UNZIP_DIR"
			fi
			;;
		*.xz | *.bz2)
			if [ "$_opt_strip" == "OFF" ]; then
				tar xf "$FILE_PATH"
			else
				tar xf "$FILE_PATH" --strip-components=1 2>/dev/null || __untar-strip "$FILE_PATH" "$UNZIP_DIR"
			fi
			;;
		*.7z)
			__require "7z" "7z" "PREFER_SYSTEM"
			[ "$_opt_strip" == "OFF" ] && 7z x "$FILE_PATH" -y -o"$UNZIP_DIR"
			[ "$_opt_strip" == "ON" ] && __sevenzip-strip "$FILE_PATH" "$UNZIP_DIR"
			;;
		*)
			echo " ** ERROR : Unknown archive format"
	esac
}

function __download() {
	local URL
	local FILE_NAME
	local DEST_DIR

	URL="$1"
	FILE_NAME="$2"
	DEST_DIR="$3"

	if [ "$FILE_NAME" == "" ]; then
		FILE_NAME="_AUTO_"
	fi

	if [ "$FILE_NAME" == "_AUTO_" ]; then
		#_AFTER_SLASH=${URL##*/}
		FILE_NAME=$(__get_filename_from_url "$URL")
		echo "** Guessed file name is $FILE_NAME"
	fi

	mkdir -p "$STELLA_APP_CACHE_DIR"

	echo " ** Download $FILE_NAME from $URL into cache"

	#if [ "$FORCE" == "1" ]; then
	#	rm -Rf "$STELLA_APP_CACHE_DIR/$FILE_NAME"
	#fi


	if [ ! -f "$STELLA_APP_CACHE_DIR/$FILE_NAME" ]; then

		# NOTE : curl seems to be more compatible
		if [[ -n `which curl 2> /dev/null` ]]; then
			curl -fSL -o "$STELLA_APP_CACHE_DIR/$FILE_NAME" "$URL" || \
			curl -fkSL -o "$STELLA_APP_CACHE_DIR/$FILE_NAME" "$URL" || \
			rm -f "$STELLA_APP_CACHE_DIR/$FILE_NAME"
		else
			if [[ -n `which wget 2> /dev/null` ]]; then
				wget "$URL" -O "$STELLA_APP_CACHE_DIR/$FILE_NAME" --no-check-certificate || \
				wget "$URL" -O "$STELLA_APP_CACHE_DIR/$FILE_NAME" || \
				rm -f "$STELLA_APP_CACHE_DIR/$FILE_NAME"
			else
				__require "curl" "curl" "PREFER_SYSTEM"
			fi
		fi
	else
		echo " ** Already downloaded"
	fi

	if [ -f "$STELLA_APP_CACHE_DIR/$FILE_NAME" ]; then

		if [ ! "$DEST_DIR" == "" ]; then
			if [ ! "$DEST_DIR" == "$STELLA_APP_CACHE_DIR" ]; then
				if [ ! -d "$DEST_DIR" ]; then
					mkdir -p "$DEST_DIR"
				fi
				cp "$STELLA_APP_CACHE_DIR/$FILE_NAME" "$DEST_DIR/"
				echo "** Downloaded $FILE_NAME is in $DEST_DIR"
			fi
		fi

	else
		echo "** ERROR downloading $URL"
	fi
}

# when --strip-components option on tar does not exist
function __untar-strip() {
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

function __unzip-strip() (
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

function __sevenzip-strip() (
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
function __mercurial_project_version() {
	local _PATH=$1
	local _OPT=$2

	_opt_version_short=OFF
	_opt_version_long=OFF
	for o in $_OPT; do
		[ "$o" == "SHORT" ] && _opt_version_short=ON
		[ "$o" == "LONG" ] && _opt_version_long=ON
	done

	if [[ -n `which hg 2> /dev/null` ]]; then
		if [ "$_opt_version_long" == "ON" ]; then
			echo "$(hg log -R "$_PATH" -r . --template "{latesttag}-{latesttagdistance}-{node|short}")"
		fi
		if [ "$_opt_version_short" == "ON" ]; then
			echo "$(hg log -R "$_PATH" -r . --template "v{latesttag}")"
		fi
	fi
}

function __git_project_version() {
	local _PATH=$1
	local _OPT=$2

	_opt_version_short=OFF
	_opt_version_long=OFF
	for o in $_OPT; do
		[ "$o" == "SHORT" ] && _opt_version_short=ON
		[ "$o" == "LONG" ] && _opt_version_long=ON
	done

	if [[ -n `which git 2> /dev/null` ]]; then
		if [ "$_opt_version_long" == "ON" ]; then
			echo "$(git --git-dir "$_PATH/.git" describe --tags --long --always --first-parent)"
		fi
		if [ "$_opt_version_short" == "ON" ]; then
			echo "$(git --git-dir "$_PATH/.git" describe --tags --abbrev=0 --always --first-parent)"
		fi
	fi
}


# INI FILE MANAGEMENT---------------------------------------------------
function __get_key() {
	local _FILE=$1
	local _SECTION=$2
	local _KEY=$3
	local _OPT=$4

	_opt_section_prefix=OFF
	for o in $_OPT; do
		[ "$o" == "PREFIX" ] && _opt_section_prefix=ON
	done

	# trim whitespace
	_SECTION=$(__trim "$_SECTION")

	local _win_endline=$'s/\r//g'
	local _exp1="/\[$_SECTION\]/,/\[.*\]/p"
	local _exp2="/$_KEY=/{print \$2}"

	if [ "$_opt_section_prefix" == "ON" ]; then
		eval "$_SECTION"_"$_KEY"='$(sed -n -e "$_win_endline" -e "$_exp1" "$_FILE" | awk -F= "$_exp2" )'
	else
		eval $_KEY='$(sed -n -e "$_win_endline" -e "$_exp1" "$_FILE" | awk -F= "$_exp2" )'
	fi

}

function __del_key() {
	local _FILE=$1
	local _SECTION=$2
	local _KEY=$3

	__ini_file "DEL" "$_FILE" "$_SECTION" "$_KEY"
}

function __add_key() {
	local _FILE=$1
	local _SECTION=$2
	local _KEY=$3
	local _VALUE=$4

	if [ ! -f "$_FILE" ]; then
		touch $_FILE
	fi

	__ini_file "ADD" "$_FILE" "$_SECTION" "$_KEY" "$_VALUE"
}

function __ini_file() {
	local _MODE=$1
	local _FILE=$2
	local _SECTION=$3
	local _KEY=$4
	if [ ! "$KEY" == "" ]; then
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
function __argparse(){
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

	#GETOPT_CMD is an env variable we can choose a getopt command instead of default "getopt"

	# Debug mode
	#export ARGP_DEBUG=1
	export ARGP_HELP_FMT=
	#export ARGP_HELP_FMT="rmargin=$(tput cols)"
	#echo $ARGP
	exec 4>&1 # fd4 is now a copy of fd1 ie stdout
	RES=$( echo "$ARGP" | GETOPT_CMD=$GETOPT_CMD $STELLA_COMMON/argp.sh $COMMAND_LINE 3>&1 1>&4 || echo exit $? )
	exec 4>&-

	# $@ now contains not parsed argument, options and identified parameters have been processed and removed:
	# echo "argp returned this for us to eval: '$RES'"
	[ "$RES" ] || exit 0

	eval $RES

	if [ "$COMMAND_LINE_RESULT" ]; then
		# Store rest of the command line not processed in COMMAND_LINE_RESULT
		eval "$COMMAND_LINE_RESULT=\$@"
	fi


}



fi
