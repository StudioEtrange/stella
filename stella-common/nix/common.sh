if [ ! "$_COMMON_INCLUDED_" == "1" ]; then
_COMMON_INCLUDED_=1

#turns off bash's hash function
set +h


# VARIOUS-----------------------------

# path = ${foo%/*}
# To get: /tmp/my.dir (like dirname)
# file = ${foo##*/}
# To get: filename.tar.gz (like basename)	
# base = ${file%%.*}
# To get: filename
# ext = ${file#*.}
# To get: tar.gz

function get_path_from_string() {
	echo ${1%/*}
}

function get_filename_from_string() {
	echo ${1##*/}
}

function get_filename_from_url() {
	local _AFTER_SLASH
	_AFTER_SLASH=${1##*/}
	echo ${_AFTER_SLASH%%\?*}
}


function is_abs() {
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

function rel_to_abs_path() {
	local _rel_path=$1
	local _abs_root_path=$2


	case $_rel_path in
		/*)
			# path is already absolute
			echo "$_rel_path"
			;;
		*)
			if [ "$_abs_root_path" == "" ]; then
				# relative to current path
				if [ -f "$_rel_path" ]; then
					echo "$(cd "$_rel_path" && pwd )"
				else
					echo "$_rel_path"
				fi
			else
				# relative to a given absolute path
				if [ -f "$_abs_root_path/$_rel_path" ]; then
					echo "$(cd "$_abs_root_path/$_rel_path" && pwd )"
				else
					echo "$_abs_root_path/$_rel_path"
				fi
			fi
			;;
	esac
}


function abs_to_rel_path() {
	
	local target="$1"
	local _abs_path="$2"
	local common_part=$_abs_path # for now

	local result=""

	case $_abs_path in
		/*)
			while [[ "${target#$common_part}" == "${target}" ]]; do
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
			forward_part="${target#$common_part}"
			
			if [[ -n $result ]] && [[ -n $forward_part ]]; then
				result="$result$forward_part"
			elif [[ -n $forward_part ]]; then
				result="${forward_part:1}"
			else
				do_nothing=1
			fi
			return_value=$result
			echo "$return_value"
			;;

		*)
			echo "$_abs_path"
			;;
	esac

}



function init_env() {
	init_arg
	init_all_features
}




# COMMON COMMAND LINE ARG PARSE
function init_arg() {

	# VERBOSE
	[ "$VERBOSE" == "" ] && VERBOSE=$DEFAULT_VERBOSE_MODE
	VERBOSE_MODE=$VERBOSE
}




#FILE TOOLS----------------------------------------------
function del_folder() {
	echo "** Deleting $1 folder"
	[ -d $1 ] && rm -Rf $1
}
# copy content of folder ARG1 into folder ARG2
function copy_folder_content_into() {
	local filter=$3
	if [ "$filter" == "" ]; then
		filter="*"
	fi
	mkdir -p $2
	if [ "$STELLA_CURRENT_PLATFORM" == "macos" ]; then
		cp -R $1/$filter $2
	else
		cp -R $1/$filter --target-directory=$2
	fi
}

#DOWNLOAD AND ZIP FUNCTIONS---------------------------------------------------
function get_ressource() {
	local NAME=$1
	local URI=$2
	local PROTOCOL=$3
	local FINAL_DESTINATION=$4
	local OPT="$5"

	# TODO : remove illegal characters in NAME. NAME is used in flag file name when merging

	local _opt_merge=OFF
	local _opt_strip=OFF
	for o in $OPT; do 
		[ "$o" == "MERGE" ] && _opt_merge=ON
		[ "$o" == "STRIP" ] && _opt_strip=ON
	done


	[ ! "$FINAL_DESTINATION" == "" ] && echo " ** Getting ressource : $NAME into $FINAL_DESTINATION" || echo " ** Getting ressource : $NAME"

	[ "$FORCE" ] && rm -Rf $FINAL_DESTINATION

	# check if ressource already grabbed or merged
	_FLAG=1
	if [ "$_opt_merge" == "ON" ]; then
		if [ -f "$FINAL_DESTINATION/._MERGED_$NAME" ]; then 
			_FLAG=0
			echo " ** Ressource already merged"
		fi
	else	
		if [ -d "$FINAL_DESTINATION" ]; then
			_FLAG=0
			echo " ** Ressource already grabbed"
		fi	
	fi

	# strip root folde mode
	_STRIP=
	[ "$_opt_strip" == "ON" ] && _STRIP=STRIP
	
	if [ "$_FLAG" == "1" ]; then
		[ ! -d $FINAL_DESTINATION ] && mkdir -p $FINAL_DESTINATION

		case $PROTOCOL in
			HTTP_ZIP)
				echo "MERGE : $_opt_merge"
				echo "STRIP : $_opt_strip"
				download_uncompress "$URI" "_AUTO_" "$FINAL_DESTINATION" "$_STRIP"
				[ "$_opt_merge" == "ON" ] && echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"
				;;
			HTTP)
				echo "MERGE : $_opt_merge"
				# HTTP protocol use always merge by default : because it never erase destination folder
				# the flag file will be setted only if we pass the option MERGE
				download "$URI" "_AUTO_" "$FINAL_DESTINATION"
				[ "$_opt_merge" == "ON" ] && echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"
				;;
			HG)
				echo "MERGE : $_opt_merge"
				[ "$_opt_strip" == "ON" ] && echo "STRIP Not supported with HG protocol"
				hg clone $URI "$FINAL_DESTINATION"
				[ "$_opt_merge" == "ON" ] && echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"
				;;
			GIT)
				echo "MERGE : $_opt_merge"
				[ "$_opt_strip" == "ON" ] && echo "STRIP Not supported with GIT protocol"
				git clone $URI "$FINAL_DESTINATION"
				[ "$_opt_merge" == "ON" ] && echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"
				;;
			FILE)
				echo "MERGE : $_opt_merge"
				[ "$_opt_strip" == "ON" ] && echo "STRIP Not supported with FILE protocol"
				copy_folder_content_into "$URI" "$FINAL_DESTINATION"
				[ "$_opt_merge" == "ON" ] && echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"
				;;
			FILE_ZIP)
				echo "MERGE : $_opt_merge"
				echo "STRIP : $_opt_strip"
				uncompress "$URI" "$FINAL_DESTINATION%" "$_STRIP"
				[ "$_opt_merge" == "ON" ] && echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"
				;;
			*)
				echo " ** ERROR Unknow protocol"
				;;
		esac
	fi
}

function download_uncompress() {
	local URL
	local FILE_NAME
	local UNZIP_DIR
	local OPT


	URL="$1"
	FILE_NAME="$2"
	UNZIP_DIR="$3"
	OPT="$4"
	
	local _opt_dest_erase=OFF # delete destination folder (default : FALSE)
	local _opt_strip=OFF # delete first folder in archive  (default : FALSE)
	for o in $OPT; do 
		[ "$o" == "DEST_ERASE" ] && _opt_dest_erase=ON
		[ "$o" == "STRIP" ] && _opt_strip=ON
	done
	
	
	if [ "$FILE_NAME" == "_AUTO_" ]; then
		#_AFTER_SLASH=${URL##*/}
		FILE_NAME=$(get_filename_from_url "$URL")
		echo "** Guessed file name is $FILE_NAME"
	fi
	
	download $URL $FILE_NAME
	uncompress "$CACHE_DIR/$FILE_NAME" "$UNZIP_DIR" "$OPT"
}

function uncompress() {
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
			[ "$_opt_strip" == "ON" ] && _unzip-strip "$FILE_PATH" "$UNZIP_DIR"
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
			[ "$_opt_strip" == "ON" ] && _sevenzip-strip "$FILE_PATH" "$UNZIP_DIR"
			;;
		*)
			echo " ** ERROR : Unknown archive format"
	esac
}

function download() {
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
		FILE_NAME=$(get_filename_from_url "$URL")
		echo "** Guessed file name is $FILE_NAME"
	fi

	mkdir -p "$CACHE_DIR"

	echo " ** Download $FILE_NAME from $URL into cache"
	
	#if [ "$FORCE" == "1" ]; then
	#	rm -Rf "$CACHE_DIR/$FILE_NAME"
	#fi


	if [ ! -f "$CACHE_DIR/$FILE_NAME" ]; then
		if [ "$STELLA_CURRENT_PLATFORM" == "macos" ]; then
			curl "$URL" -o "$CACHE_DIR/$FILE_NAME"
		else
			wget "$URL" -O "$CACHE_DIR/$FILE_NAME" --no-check-certificate
		fi
	else
		echo " ** Already downloaded"
	fi

	if [ ! "$DEST_DIR" == "" ]; then
		if [ ! "$DEST_DIR" == "$CACHE_DIR" ]; then
			if [ ! -d "$DEST_DIR" ]; then
				mkdir -p "$DEST_DIR"
			fi
			cp "$CACHE_DIR/$FILE_NAME" "$DEST_DIR/"
			echo "** Downloaded $FILE_NAME is in $DEST_DIR"
		fi
	fi
}

function _unzip-strip() (
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

function _sevenzip-strip() (
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


# INI FILE MANAGEMENT---------------------------------------------------
function get_key() {
	local _FILE=$1
	local _SECTION=$2
	local _KEY=$3
	local _OPT=$4

	# TODO : bug when reading windows end line
	# key will be prefixed with the section name
	_opt_section_prefix=OFF
	for o in $_OPT; do
		[ "$o" == "PREFIX" ] && _opt_section_prefix=ON
	done


	local _exp1="/\[$_SECTION\]/,/\[.*\]/p"
	local _exp2="/$_KEY=/{print \$2}"

	if [ "$_opt_section_prefix" == "ON" ]; then
		eval "$_SECTION"_"$_KEY"='$(sed -n "$_exp1" "$_FILE" | awk -F= "$_exp2")'
	else
		eval $_KEY='$(sed -n "$_exp1" "$_FILE" | awk -F= "$_exp2")'
	fi
}

function del_key() {
	local _FILE=$1
	local _SECTION=$2
	local _KEY=$3

	_ini_file "DEL" "$_FILE" "$_SECTION" "$_KEY"
}

function add_key() {
	local _FILE=$1 
	local _SECTION=$2
	local _KEY=$3
	local _VALUE=$4

	if [ ! -f "$_FILE" ]; then
		touch $_FILE
	fi

	_ini_file "ADD" "$_FILE" "$_SECTION" "$_KEY" "$_VALUE"
}

function _ini_file() {
	local _MODE=$1
	local _FILE=$2
	local _SECTION=$3
	local _KEY=$4
	local _VALUE=$5


	tp=$(mktmp)

	awk -F= -v mode="$_MODE" -v val="$_VALUE" '
	# Clear the flag
	BEGIN {
		processing = 0;
		skip = 0;
		modified = 0;
		added = 0;
	}

	# Entering the section, set the flag
	/^\['$_SECTION'/ {
		processing = 1;
	}
		
	# Modify the line, if the flag is set
	/^'$_KEY'=/ {
		if (processing) {
		   	if ( mode == "ADD" ) print "'$_KEY'="val;
			skip = 1;
			modified = 1;
		}
	}

	# Clear the section flag (as were in a new section)
	/^\[$/ {
		if(processing && !added && !modified) {
			if ( mode == "ADD" ) print "'$_KEY'="val
			added = 1;
		}
		processing = 0;
	}

	# Output a line (that we didnt output above)
	/.*/ {
		
		if (skip)
		    skip = 0;
		else
			print $0;
	}
	END {
		if(!added && !modified && mode == "ADD") {
			if(!processing) print "['$_SECTION']"
			print "'$_KEY'="val
		}

	}

	' "$_FILE" > $tp

	mv -f $tp "$_FILE"
}


# FLAG MANAGEMENT---------------------------------------------------
function add_flag() {
	local FLAG_FILE=$1
	local FLAG_NAME=$2
	local FLAG_VALUE=$3

	[ -f $FLAG_FILE ] && (
		del_flag $FLAG_FILE $FLAG_NAME
	)
	echo $FLAG_NAME=$FLAG_VALUE >> "$FLAG_FILE"
}

function del_flag() {
	local FLAG_FILE=$1
	local FLAG_NAME=$2
	FLAGS_FILE_TEMP="$FLAG_FILE".temp

	[ -f $FLAG_FILE ] && (
		touch "$FLAGS_FILE_TEMP"
		while IFS== read flag value || [ -n "$flag" ]
		do   
			if [ "$flag" == "" ]; then 
				echo "" >> "$FLAGS_FILE_TEMP"
			else
	   			[ ! "$flag" == $FLAG_NAME ] && ( echo $flag=$value >> "$FLAGS_FILE_TEMP" )
	   		fi
		done < "$FLAG_FILE"
		rm "$FLAG_FILE"
		mv "$FLAGS_FILE_TEMP" "$FLAG_FILE"
	)
}

function get_flag() {
	local FLAG_FILE=$1
	local FLAG_NAME=$2

	[ ! -f $FLAG_FILE ] && $FLAG_NAME=

	while IFS== read flag value || [ -n "$flag" ]
	do   
   		if [ "$flag" == "$FLAG_NAME" ];then
   			eval "$FLAG_NAME=\$value"
   		fi
	done < "$FLAG_FILE"
}

function reset_all_flag() {
	local FLAG_FILE=$1
	rm -f $FLAG_FILE
}



# ARG COMMAND LINE MANAGEMENT---------------------------------------------------
function argparse(){
	local PROGNAME="$1"
	local OPTIONS="$2"
	local PARAMETERS="$3"
	local SHORT_DESCRIPTION="$4"
	local LONG_DESCRIPTION="$5"
	local COMMAND_LINE_RESULT="$6"
	shift 6
	
	local COMMAND_LINE="$@"
	

	ARGP="
	--HEADER--
	ARGP_PROG=$PROGNAME
	ARGP_DELETE=quiet verbose
	ARGP_VERSION=$APP_NAME_FULL
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
	#export ARGP_DEBUG=1
	export ARGP_HELP_FMT=
	#export ARGP_HELP_FMT="rmargin=$(tput cols)"
	#echo $ARGP
	exec 4>&1 # fd4 is now a copy of fd1 ie stdout
	RES=$( echo "$ARGP" | $STELLA_COMMON/argp.sh $COMMAND_LINE 3>&1 1>&4 || echo exit $? ) 
	exec 4>&-

	# $@ now contains not parsed argument, options and identified parameters have been processed and removed:
	# echo "argp returned this for us to eval: '$RES'"
	[ "$RES" ] || exit 0

	eval $RES

	#echo "rest of command line : $@"
	
	if [ "$COMMAND_LINE_RESULT" ]; then
		eval "$COMMAND_LINE_RESULT=\$@"
	fi

	
}



fi
