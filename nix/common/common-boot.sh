#!sh
if [ ! "$_STELLA_BOOT_INCLUDED_" = "1" ]; then
_STELLA_BOOT_INCLUDED_=1

# TODO : include into API
# TODO : when booting a script, how pass arg to script ?


# [schema://][user[:password]@][host][:port][/abs_path|?rel_path]
# schema values
#     local://
#     ssh://
#     vagrant://


# When ssh or vagrant (with vagrant, use vagrant name machine as host)
#     stella requirements are installed
#     <path> is computed from default path when logging in ssh and then applying abs_path|rel_path
#     current folder is setted to <path>
#     stella is sync in default <path>/stella
#     stella env file is synced
#     when 'shell' : launch a shell with stella env setted
#     when 'script' : executing script is sync in <path>/<script.sh> or default_path/<script.sh> then launch the script
#     when 'cmd' : launch a cmd inside a bootstraped stella env

# When local
#     stella requirement are not installed
#     current folder do not change
#     stella do not move
#     stella env file is conserved
#     when 'shell' : launch a shell with stella env setted
#     when 'script' : launch the script
#     when 'cmd' : launch a cmd inside a bootstraped stella env


# SAMPLE
# from an app
# ./stella-link.sh boot shell vagrant://default

# MAIN FUNCTION -----------------------------------------
__boot_stella_shell() {
  local _uri="$1"
  __boot_stella "SHELL" "$_uri"
}

__boot_stella_cmd() {
  local _uri="$1"
  local _cmd="$2"
  __boot_stella "CMD" "$_uri" "$_cmd"

}

__boot_stella_script() {
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
    # [schema://][user[:password]@][host][:port][/abspath|?relpath]
    __uri_parse "$_uri"
  fi

  case $__stella_uri_schema in

    local )

      case $_mode in
        SHELL )
          __bootstrap_stella_env
          ;;
        CMD )
          eval "$_arg"
          ;;
        SCRIPT )
          "$_arg"
          ;;
      esac
      ;;



    ssh|vagrant )
      #ssh://user@host:port[/abs_path|?rel_path]
      #vagrant://vagrant-machine[/abs_path|?rel_path]


      # folders
      local _boot_folder="."
      [ "${__stella_uri_query:1}" = "" ] && _boot_folder="${__stella_uri_path}" || _boot_folder="${__stella_uri_fragment:1}"

      # relative path
      if [ ! "${__stella_uri_query:1}" = "" ]; then
        __transfer_stella "$_uri" "ENV"
        __boot_folder="${__stella_uri_query:1}"
        __stella_folder="stella"
      else
        # absolute ppath
        if [ ! "$__stella_uri_path" = "" ]; then
          __transfer_stella "$_uri" "ENV"
          __boot_folder="$__stella_uri_path"
          __stella_folder="$__stella_uri_path/stella"
        # empty path
        else
          __transfer_stella "$_uri" "ENV"
          __boot_folder="."
          __stella_folder="./stella"
        fi
      fi

      # NOTE : __stella_uri_address contain user
      # we need to build a user@host without port number
      #local _ssh_user=
      #[ ! "$__stella_uri_user" = "" ] && _ssh_user="$__stella_uri_user"@

      # http://www.cyberciti.biz/faq/linux-unix-bsd-sudo-sorry-you-must-haveattytorun/
      case $_mode in
        SHELL )
          __ssh_execute "$_uri" "cd $__boot_folder && $__stella_folder/stella.sh stella install dep && $__stella_folder/stella.sh boot shell local"
          #ssh -t $__ssh_opt $__vagrant_ssh_opt "$_ssh_user$__stella_uri_host" "cd $__boot_folder && $__stella_folder/stella.sh stella install dep && $__stella_folder/stella.sh boot shell local"
          ;;
        CMD )
          __ssh_execute "$_uri" "cd $__boot_folder && $__stella_folder/stella.sh stella install dep && $__stella_folder/stella.sh boot cmd local -- '$_arg'"
          ;;
        SCRIPT )
          __script_filename="$(__get_filename_from_string $_arg)"

          # relative path
          if [ ! "${__stella_uri_query:1}" = "" ]; then
            __transfer_file_rsync "$_arg" "$_uri/$__script_filename"
            __target_script_path="${__stella_uri_query:1}/$__script_filename"
          else
            # absolute  path
            if [ ! "$__stella_uri_path" = "" ]; then
              __transfer_file_rsync "$_arg" "$_uri/$__script_filename"
              __target_script_path="${__stella_uri_path}/$__script_filename"
            # empty path
            else
              __transfer_file_rsync "$_arg" "${_uri}?./${__script_filename}"
              __target_script_path="./$__script_filename"
            fi
          fi
          __ssh_execute "$_uri" "cd $__boot_folder && $__stella_folder/stella.sh stella install dep && $__target_script_path"
          #ssh -t $__ssh_opt $__vagrant_ssh_opt "$_ssh_user$__stella_uri_host" "cd $__boot_folder && $__stella_folder/stella.sh stella install dep && $__target_script_path"
          ;;
        esac
    ;;
    *)
      echo " ** ERROR uri protocol unknown"
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
