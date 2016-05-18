if [ ! "$_STELLA_BOOT_INCLUDED_" == "1" ]; then
_STELLA_BOOT_INCLUDED_=1

# TODO : include into API

# boot shell local
# boot cmd local -- '<command>'

# boot shell docker
# boot cmd docker -- '<command>'

# MAIN FUNCTION -----------------------------------------
function __boot_shell() {
  local _uri="$1"
  __boot_stella "SHELL" "$_uri"
}

function __boot_cmd() {
  local _uri="$1"
  local _cmd="$2"
  __boot_stella "CMD" "$_uri" "$_cmd"

}

function __boot_script() {
  local _uri="$1"
  local _script="$2"
  __boot_stella "SCRIPT" "$_uri" "$_script"
}







# INTERNAL -----------------------------------------

# MODE = SHELL | CMD | SCRIPT
function __boot_stella() {
  local _mode="$1"
  local _uri="$2"
  local _arg="$3"

  if [ "$_uri" == "local" ]; then
    __stella_uri_schema="local"
  else
    # [schema://][user[:password]@][host][:port][/path][?[arg1=val1]...][#fragment]
    __uri_parse "$_uri"
  fi

  case $__stella_uri_schema in
    local )
      # local
      # do not change folder -- keep current folder
      case $_mode in
        SHELL )
          __bootstrap_stella_env
          ;;
        CMD )
          eval "$_arg"
          ;;
        SCRIPT )
          source "$_arg"
          ;;
      esac
      ;;




    dm|docker )
      # dm://docker-machine-id/docker-id/docker-id#/path
      # docker://docker-daemon-host:docker-daemon-port/docker-id/docker-id#/path

      # prepare docker
      local _docker_opt
      local _docker_prefix
      __require "docker" "docker" "PREFER_SYSTEM"

      if [ "$__stella_uri_schema" == "dm" ]; then
        __require "docker-machine" "docker-machine" "PREFER_SYSTEM"
        eval $(docker-machine env $__stella_uri_host)
      fi

      if [ "$__stella_uri_schema" == "docker" ]; then
        [ ! "$__stella_uri_host" == "" ] && _docker_prefix="DOCKER_HOST=tcp://$__stella_uri_host:$__stella_uri_port"
      fi

      # folders
      local _boot_folder="${__stella_uri_fragment:1}"
      [ -z "$_boot_folder" ] && _boot_folder="/stella"
      #TODO
      local _stella_folder="/stella"
      local _boot_script_path="/stella-boot-script.sh"

      case $_mode in
        SHELL )
          _docker_opt="-it"
          eval $(echo $_docker_prefix) docker run --rm -v "$STELLA_ROOT":"$_stella_folder" $_docker_opt ${__stella_uri_path:1} bash -c "cd $_boot_folder 1>/dev/null && $_stella_folder/stella.sh stella install dep 1>/dev/null && $_stella_folder/stella.sh boot shell local"
          ;;
        CMD )
          eval $(echo $_docker_prefix) docker run --rm -v "$STELLA_ROOT":"$_stella_folder" $_docker_opt ${__stella_uri_path:1} bash -c "cd $_boot_folder 1>/dev/null && $_stella_folder/stella.sh stella install dep 1>/dev/null && $_stella_folder/stella.sh boot cmd local -- '$_arg'"
          ;;
        SCRIPT )
          eval $(echo $_docker_prefix) docker run --rm -v "$STELLA_ROOT":"$_stella_folder" -v "$_arg":"$_boot_script_path" $_docker_opt ${__stella_uri_path:1} bash -c "cd $_boot_folder 1>/dev/null && $_stella_folder/stella.sh stella install dep 1>/dev/null && $_stella_folder/stella.sh boot script local -- '$_boot_script_path'"
          ;;
      esac
      ;;




    ssh )
      #ssh://user@host:port/path
      __require "ssh" "ssh" "PREFER_SYSTEM"
      # target form is USER@]HOST[:PORT]/DEST
      __transfert_stella "$__stella_uri_user@$__stella_uri_host:$_stella_uri_port$__stella_uri_path"
      #ssh -p $_stella_uri_port
      ;;

  esac

}


function __bootstrap_stella_env() {
	export PS1="[stella] \u@\h|\W>"

	local _t=$(mktmp)
	#(set -o posix; set) >$_t
	declare >$_t
	declare -f >>$_t
( exec bash -i 3<<HERE 4<&0 <&3
. $_t 2>/dev/null;rm $_t;
echo "** STELLA SHELL with env var setted (type exit to exit...) **"
exec  3>&- <&4
HERE
)
}








# TODO NOT USED
function __bootstrap_stella_files_linux() {
  local _cmd=$@

  local _t="$(mktmp)"
  local _d="$STELLA_APP_TEMP_DIR"/"$(__get_filename_from_string "$_t")"

  mkdir -p "$_d"
  rm -Rf $_t

  cat <<EOT > $_d/stella-boot.sh
#!/bin/bash
export STELLA_ROOT=/stella
STELLA_APP_ROOT=/stella
source /stella/conf.sh
__init_stella_env
$_cmd
EOT

  chmod +x "$_d/stella-boot.sh"

  echo "$_d"
}


fi
