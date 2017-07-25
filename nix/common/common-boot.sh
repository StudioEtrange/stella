#!sh
if [ ! "$_STELLA_BOOT_INCLUDED_" = "1" ]; then
_STELLA_BOOT_INCLUDED_=1

# TODO : include into API
# TODO : when booting a script, how pass arg to script ?

# When docker/dm
#     stella requirements are installed
#     stella is mounted on /
#     stella env file is mounted
#     current folder is stella_root or <path>
#     when 'shell' : bootstrap shell with stella env setted, inside container
#     when 'script' : executing script is mounted on /<script.sh>
#     when 'cmd' : nothing special

# When dm
#     if -f option is used then docker-machine is created

# When ssh
#     stella requirements are installed
#     current folder is <path> or default path when logging in ssh
#     stella is sync in default path/stella
#     stella env file is synced
#     when 'shell' : bootstrap shell with stella env setted
#     when 'script' : executing script is sync in <path>/<script.sh> or default_path/<script.sh>
#     when 'cmd' : nothing special

# When local
#     stella requirement are not installed
#     current folder do not change
#     stella do not move
#     stella env file is conserved
#     when 'shell' : N/1
#     when 'script' : nothing special
#     when 'cmd' : nothing special

# MAIN FUNCTION -----------------------------------------
__boot_shell() {
  local _uri="$1"
  __boot_stella "SHELL" "$_uri"
}

__boot_cmd() {
  local _uri="$1"
  local _cmd="$2"
  __boot_stella "CMD" "$_uri" "$_cmd"

}

__boot_script() {
  local _uri="$1"
  local _script="$2"
  __boot_stella "SCRIPT" "$_uri" "$_script"
}







# INTERNAL -----------------------------------------

# MODE = SHELL | CMD | SCRIPT
__boot_stella() {
  local _mode="$1"
  local _uri="$2"
  local _arg="$3"

  if [ "$_uri" = "local" ]; then
    __stella_uri_schema="local"
  else
    # [schema://][user[:password]@][host][:port][/path][?[arg1=val1]...][#fragment]
    __uri_parse "$_uri"
  fi

  case $__stella_uri_schema in
    local )
      # local

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
      __require "docker" "docker" "SYSTEM"

      if [ "$__stella_uri_schema" = "dm" ]; then
        __require "docker-machine" "docker-machine" "SYSTEM"
        [ ! -z "$FORCE" ] && docker-machine create --driver virtualbox $__stella_uri_host
        docker-machine start $__stella_uri_host
        # will also set docker-machine ip as no_proxy
        eval $(docker-machine env $__stella_uri_host)
      fi

      if [ "$__stella_uri_schema" = "docker" ]; then
        [ ! "$__stella_uri_host" = "" ] && _docker_prefix="DOCKER_HOST=tcp://$__stella_uri_host:$__stella_uri_port"
      fi

      # folders
      local _boot_folder="${__stella_uri_fragment:1}"
      [ -z "$_boot_folder" ] && _boot_folder="/stella"
      local _stella_folder="/stella"
      local _boot_script_path="/$(__get_filename_from_string $_arg)"

      case $_mode in
        SHELL )
          _docker_opt="-it"
          eval $(echo $_docker_prefix) && docker run --rm -v "$STELLA_ROOT":"$_stella_folder" $_docker_opt ${__stella_uri_path:1} bash -c "cd $_boot_folder && $_stella_folder/stella.sh stella install dep && $_stella_folder/stella.sh boot shell local"
          ;;
        CMD )
          eval $(echo $_docker_prefix) && docker run --rm -v "$STELLA_ROOT":"$_stella_folder" $_docker_opt ${__stella_uri_path:1} bash -c "cd $_boot_folder && $_stella_folder/stella.sh stella install dep && $_stella_folder/stella.sh boot cmd local -- '$_arg'"
          ;;
        SCRIPT )
          eval $(echo $_docker_prefix) && docker run --rm -v "$STELLA_ROOT":"$_stella_folder" -v "$_arg":"$_boot_script_path" $_docker_opt ${__stella_uri_path:1} bash -c "cd $_boot_folder && $_stella_folder/stella.sh stella install dep && $_stella_folder/stella.sh boot script local -- '$_boot_script_path'"
          ;;
      esac
      ;;




    ssh )
      #ssh://user@host:port/#abs_or_rel_path

      local _ssh_port="22"
    	[ ! "$__stella_uri_port" = "" ] && _ssh_port="$__stella_uri_port"
      local _ssh_user=
      [ ! "$__stella_uri_user" = "" ] && _ssh_user="$__stella_uri_user"@

      __require "ssh" "ssh" "SYSTEM"

      __transfert_stella "$_uri" "ENV"

      # folders
      [ "$__stella_uri_fragment" = "" ] && __stella_uri_fragment="."
      [ "$__stella_uri_fragment" = "#" ] && __stella_uri_fragment="."
      [ ! "$__stella_uri_fragment" = "." ] && __stella_uri_fragment=${__stella_uri_fragment:1}
      local _boot_folder="$__stella_uri_fragment"
      #local _stella_folder="$__stella_uri_fragment"/stella
      local _stella_folder="./stella"
      local _boot_script_path="$__stella_uri_fragment/$(__get_filename_from_string $_arg)"

      # http://www.cyberciti.biz/faq/linux-unix-bsd-sudo-sorry-you-must-haveattytorun/
      case $_mode in
        SHELL )
          ssh -t -p "$_ssh_port" "$_ssh_user$__stella_uri_host" "cd $_boot_folder && $_stella_folder/stella.sh stella install dep && $_stella_folder/stella.sh boot shell local"
          ;;
        CMD )
          ssh -t -p "$_ssh_port" "$_ssh_user$__stella_uri_host" "cd $_boot_folder && $_stella_folder/stella.sh stella install dep && $_stella_folder/stella.sh boot cmd local -- '$_arg'"
          ;;
        SCRIPT )
          __transfert_file_rsync "$_arg" "$_uri"
          ssh -t -p "$_ssh_port" "$_ssh_user$__stella_uri_host" "cd $_boot_folder && $_stella_folder/stella.sh stella install dep && $_stella_folder/stella.sh boot script local -- '$_boot_script_path'"
          ;;
        esac
    ;;


    vagrant)
      echo TODO
    ;;

  esac

}


__bootstrap_stella_env() {
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



fi
