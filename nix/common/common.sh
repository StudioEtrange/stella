if [ ! "$_STELLA_COMMON_INCLUDED_" == "1" ]; then
_STELLA_COMMON_INCLUDED_=1

#turns off bash's hash function
set +h


# VARIOUS-----------------------------
function __daemonize() {
	local _item_path=$1
	local _log_file=$2

	if [ "$_log_file" == "" ]; then
		nohup -- $_item_path 1>/dev/null 2>&1 &
	else
		nohup -- $_item_path 1>$_log_file 2>&1 &
	fi

}

function __bootstrap_stella_env() {
	export PS1="[stella] \u@\h|\W>"
	
	local _t=$(mktmp)
	#(set -o posix; set) >$_t
	declare >$_t
	declare -f >>$_t
( exec bash -i 3<<SCRIPT 4<&0 <&3
. $_t 2>/dev/null;rm $_t;
echo "** STELLA SHELL with env var setted (type exit to exit...) **"
exec  3>&- <&4
SCRIPT
)
}

# trim whitespace
function __trim() {
	echo $(echo "$1" | sed -e 's/^ *//' -e 's/ *$//')
}

function __get_stella_version() {
	local OPT="$1"
	
	# option
	# 	"LONG" long version
	# 	"SHORT" short

	if [ "$OPT" == "" ]; then
		OPT=SHORT
	fi

	if [ -f "$STELLA_ROOT/VERSION" ]; then
		cat "$STELLA_ROOT/VERSION"
	else
		echo $(__git_project_version "$STELLA_ROOT" "$OPT")
	fi
}


# path = ${foo%/*}
# To get: /tmp/my.dir (like dirname)
# file = ${foo##*/}
# To get: filename.tar.gz (like basename)	
# base = ${file%%.*}
# To get: filename
# ext = ${file#*.}
# To get: tar.gz

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
					#result="$_abs_root_path/$_rel_path"
					# NOTE using this method if directory does not exist returned path is not real absolute (example : /tata/toto/../titi instead of /tata/titi)

					[ "$STELLA_CURRENT_PLATFORM" == "darwin" ] && result=$(__rel_to_abs_path_alternative_1 "$_rel_path" "$_abs_root_path")
					[ "$STELLA_CURRENT_PLATFORM" == "linux" ] && result=$(__rel_to_abs_path_alternative_2 "$_rel_path" "$_abs_root_path")
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



function __init_stella_env() {
	__feature_init_installed
}



#FILE TOOLS----------------------------------------------
function __del_folder() {
	echo "** Deleting $1 folder"
	[ -d $1 ] && rm -Rf $1
}
# copy content of folder ARG1 into folder ARG2
function __copy_folder_content_into() {
	local filter=$3
	if [ "$filter" == "" ]; then
		filter="*"
	fi
	mkdir -p $2
	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		cp -R $1/$filter $2
	else
		cp -R $1/$filter --target-directory=$2
	fi
}

#RESSOURCES MANAGEMENT ---------------------------------------------------
function __get_resource() {
	local OPT="$5"
	OPT="$OPT GET"
	__resource $1 $2 $3 $4 $OPT
}

function __update_resource() {
	local OPT="$5"
	OPT="$OPT UPDATE"
	__resource $1 $2 $3 $4 $OPT
}

function __delete_resource() {
	local OPT="$5"
	OPT="$OPT DELETE"
	__resource $1 $2 $3 $4 $OPT
}

function __revert_resource() {
	local OPT="$5"
	OPT="$OPT REVERT"
	__resource $1 $2 $3 $4 $OPT
}

function __resource() {
	local NAME=$1
	local URI=$2
	local PROTOCOL=$3
	local FINAL_DESTINATION=$4
	local OPT="$5"
	# option should passed as one string "OPT1 OPT2"
	# 	"MERGE" for merge in FINAL_DESTINATION
	# 	"STRIP" for remove root folder and copy content of root folder in FINAL_DESTINATION
	# 	"UPDATE" pull and update resource (only for HG or GIT)
	# 	"REVERT" complete revert of the resource (only for HG or GIT)
	# 	"FORCE_NAME" force name of downloaded file
	# 	"DELETE" delete resource
	# TODO : remove illegal characters in NAME. NAME is used in flag file name when merging

	local _opt_merge=OFF
	local _opt_strip=OFF
	local _opt_get=ON
	local _opt_delete=OFF
	local _opt_update=OFF
	local _opt_revert=OFF
	local _opt_force_name=OFF
	local _download_filename=_AUTO_
	for o in $OPT; do 
		if [ "$_opt_force_name" == "OFF" ]; then
			[ "$o" == "MERGE" ] && _opt_merge=ON
			[ "$o" == "STRIP" ] && _opt_strip=ON
			[ "$o" == "FORCE_NAME" ] && _opt_force_name=ON
			if [ "$o" == "DELETE" ]; then _opt_delete=ON;  _opt_revert=OFF;  _opt_get=OFF; _opt_update=OFF; fi
			if [ "$o" == "UPDATE" ]; then _opt_update=ON;  _opt_revert=OFF;  _opt_get=OFF; _opt_delete=OFF; fi
			if [ "$o" == "REVERT" ]; then _opt_revert=ON;  _opt_update=OFF;  _opt_get=OFF; _opt_delete=OFF; fi
		else
			_download_filename=$o
			_opt_force_name=OFF
		fi
	done

	[ "$_opt_revert" == "ON" ] && echo " ** Reverting resource :"
	[ "$_opt_update" == "ON" ] && echo " ** Updating resource :"
	[ "$_opt_delete" == "ON" ] && echo " ** Deleting resource :"
	[ "$_opt_get" == "ON" ] && echo " ** Getting resource :"
	[ ! "$FINAL_DESTINATION" == "" ] && echo " $NAME in $FINAL_DESTINATION" || echo " $NAME"

	#[ "$FORCE" ] && rm -Rf $FINAL_DESTINATION
	if [ "$_opt_get" == "ON" ]; then
		if [ "$FORCE" ]; then
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
							echo " ** Ressource already stripped"
							_FLAG=0
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
				[ "$_opt_get" == "ON" ] && __download_uncompress "$URI" "$_download_filename" "$FINAL_DESTINATION" "$_STRIP"
				[ "$_opt_merge" == "ON" ] && echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"
				;;
			HTTP)
				# HTTP protocol use always merge by default : because it never erase destination folder
				# the flag file will be setted only if we pass the option MERGE
				[ "$_opt_get" == "ON" ] && __download "$URI" "$_download_filename" "$FINAL_DESTINATION"
				[ "$_opt_merge" == "ON" ] && echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"
				;;
			HG)
				if [ "$_opt_revert" == "ON" ]; then cd "$FINAL_DESTINATION"; hg revert --all -C; fi
				if [ "$_opt_update" == "ON" ]; then cd "$FINAL_DESTINATION"; hg pull; hg update; fi
				[ "$_opt_get" == "ON" ] && hg clone $URI "$FINAL_DESTINATION"
				# [ "$_opt_merge" == "ON" ] && echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"
				;;
			GIT)
				if [ "$_opt_revert" == "ON" ]; then cd "$FINAL_DESTINATION"; git reset --hard; fi
				if [ "$_opt_update" == "ON" ]; then cd "$FINAL_DESTINATION"; git pull; fi
				[ "$_opt_get" == "ON" ] && git clone $URI "$FINAL_DESTINATION"
				# [ "$_opt_merge" == "ON" ] && echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"
				;;
			FILE)
				[ "$_opt_get" == "ON" ] && __copy_folder_content_into "$URI" "$FINAL_DESTINATION"
				[ "$_opt_merge" == "ON" ] && echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"
				;;
			FILE_ZIP)
				__uncompress "$URI" "$FINAL_DESTINATION%" "$_STRIP"
				[ "$_opt_merge" == "ON" ] && echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"
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
				7z a -t7z "$_output_archive".7z "$(basename $_target)"
				mv "$_output_archive".7z "$_output_archive"
			fi
			if [ -f "$_target" ]; then
				cd "$(dirname $_target)"
				7z a -t7z "$_output_archive" "$(basename $_target)"
				mv "$_output_archive".7z "$_output_archive"
			fi
			;;
		ZIP)
			# TODO
			;;
		TAR*)
				[ -d "$_target" ] && tar -c -v -z -f "$_output_archive" -C "$_target/.." "$(basename $_target)"
				[ -f "$_target" ] && tar -c -v -z -f "$_output_archive" -C "$(dirname $_target)" "$(basename $_target)"
			;;
	esac
	

}

function __uncompress() {
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
			[ "$_opt_strip" == "OFF" ] && unzip -a -o "$FILE_PATH"
			[ "$_opt_strip" == "ON" ] && __unzip-strip "$FILE_PATH" "$UNZIP_DIR"
			;;
		*.gz | *.tgz) 
			[ "$_opt_strip" == "OFF" ] && tar xvf "$FILE_PATH"
			[ "$_opt_strip" == "ON" ] && tar xvf "$FILE_PATH" --strip-components=1
			;;
		*.xz | *.bz2)
			[ "$_opt_strip" == "OFF" ] && tar xvf "$FILE_PATH"
			[ "$_opt_strip" == "ON" ] && tar xvf "$FILE_PATH" --strip-components=1
			;;
		*.7z)
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
		if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
			curl -kSL -o "$STELLA_APP_CACHE_DIR/$FILE_NAME" "$URL"
		else
			wget "$URL" -O "$STELLA_APP_CACHE_DIR/$FILE_NAME" --no-check-certificate || rm -f "$STELLA_APP_CACHE_DIR/$FILE_NAME"
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

	tp=$(mktmp)

	awk -F= -v mode="$_MODE" -v val="$_VALUE" '
	# Clear the flag
	BEGIN {
		processing = 0;
		skip = 0;
		modified = 0;
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
	ARGP_DELETE=quiet verbose
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
