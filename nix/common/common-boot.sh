#!sh
if [ ! "$_STELLA_BOOT_INCLUDED_" = "1" ]; then
_STELLA_BOOT_INCLUDED_=1


# TODO : when booting a script, how pass arg to script ?


# [schema://][user[:password]@][host][:port][/abs_path|?rel_path]
# schema values
#     local:// (or just 'local')
#          (with local, host is never used. i.e : local:///abs_path local://?rel_path)
#     ssh://
#     vagrant://
#          (with vagrant, use vagrant machine name as host)



# TODO : implements this, using STELLA_APP_IS_STELLA

# When schema is 'ssh' or 'vagrant'
#     <path> is computed from default path when logging in ssh and then applying abs_path|rel_path
#     current folder is setted to <path>
#     When booting 'stella'
#         stella is sync with its env file in <path>/stella
#         stella requirements are installed
#         When action is
#               'shell' : launch a shell with a bootstrapped stella env inside shell
#               'script' : script is sync in <path>/<script.sh> then launch the script
#               'cmd' : launch a cmd inside a bootstraped stella env
#     When booting an 'app'
#         app is sync in <path>/app
#         stella is sync with its env file accordingly to its position defined in stella-link file [only if stella is outside of app]
#         stella requirements are installed
#         When action is
#               'shell' : launch a shell with a bootstrapped stella env inside shell, launched from app stella-link file
#               'script' : script is sync in <path>/<script.sh> then launch the script
#               'cmd' : launch a cmd (HERE : stella env is not bootstrapped!)


# When schema is 'local'
#     <path> is computed from current running path and then applying abs_path|rel_path
#            if abs_path|rel_path are not provided, then <path> is considered as NULL
#     current folder is setted to <path> [if <path> is not NULL]
#     When booting 'stella'
#         stella is sync with its env file in <path>/stella [if <path> is not NULL]
#         stella requirements are NOT installed
#         When action is
#               'shell' : launch a shell with a bootstrapped stella env inside shell
#               'script' : script is sync in <path>/<script.sh> [if <path> is not NULL] then launch the script
#               'cmd' : launch a cmd inside a bootstraped stella env
#     When booting an 'app'
#         app is sync in <path>/app [if <path> is not NULL]
#         stella is sync with its env file accordingly to its position defined in stella-link file [only if stella is outside of app AND if <path> is not NULL]
#         stella requirements are NOT installed
#         When action is
#               'shell' : launch a shell with a bootstrapped stella env inside shell, launched from app stella-link file
#               'script' : script is sync in <path>/<script.sh> [if <path> is not NULL] then launch the script
#               'cmd' : launch a cmd (HERE : stella env is not bootstrapped!)


# SAMPLES
# from an app
# ./stella-link.sh boot shell vagrant://default
# ./stella-link.sh boot shell local
# from an stella
# ./stella.sh boot shell vagrant://default
# ./stella.sh boot shell local


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

  # transfer stella : oui, non
  # transfer app : oui, non


  if [ "$_uri" = "local" ]; then
    __stella_uri_schema="local"
  else
    # [schema://][user[:password]@][host][:port][/abs_path|?rel_path]
    __uri_parse "$_uri"
  fi


  if [ ! "$__stella_uri_host" = "" ]; then
    # boot stella itself
    if [ "$STELLA_APP_IS_STELLA" = "1" ]; then

      [ "${__stella_uri_query:1}" = "" ] && __path="${__stella_uri_path}" || __path="${__stella_uri_query:1}"
      [ "$__path" = "" ] && __path="."

      __stella_path="$__path/stella"
      __transfer_stella "$_uri" "ENV"
      __boot_folder="$__path"

    else
      # boot an app
      __transfer_app "$_uri"
      [ "${__stella_uri_query:1}" = "" ] && __path="${__stella_uri_path}" || __path="${__stella_uri_query:1}"
      [ "$__path" = "" ] && __path="."

      __stella_path="${__path}/$(__abs_to_rel_path "$STELLA_ROOT" "$STELLA_APP_ROOT")"
      if [ "$(__is_logical_subfolder "$STELLA_APP_ROOT" "$STELLA_ROOT")" = "FALSE" ]; then
        __transfer_stella "${__stella_uri_schema}://${__stella_uri_address}/?${__stella_path}" "ENV"
      fi

      __boot_folder="$__path"
    fi
  fi


  case $__stella_uri_schema in

    local )
      #local://[/abs_path|?rel_path]
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

      # http://www.cyberciti.biz/faq/linux-unix-bsd-sudo-sorry-you-must-haveattytorun/
      case $_mode in
        SHELL )
          __ssh_execute "$_uri" "cd $__boot_folder && $__stella_path/stella.sh stella install dep && $__stella_path/stella.sh boot shell local"
          ;;
        CMD )
          __ssh_execute "$_uri" "cd $__boot_folder && $__stella_path/stella.sh stella install dep && $__stella_path/stella.sh boot cmd local -- '$_arg'"
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
          __ssh_execute "$_uri" "cd $__boot_folder && $__stella_path/stella.sh stella install dep && $__target_script_path"
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
