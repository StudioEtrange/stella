[1mdiff --git a/conf.sh b/conf.sh[m
[1mindex d436dd4..370236a 100755[m
[1m--- a/conf.sh[m
[1m+++ b/conf.sh[m
[36m@@ -266,7 +266,7 @@[m [mSTELLA_API_APP_PUBLIC="transfer_app get_app_property link_app get_data get_asset[m
 STELLA_API_FEATURE_PUBLIC="feature_add_repo feature_info list_feature_version feature_remove feature_catalog_info feature_install feature_install_list feature_init list_active_features feature_reinit_installed feature_inspect"[m
 STELLA_API_BINARY_PUBLIC="tweak_linked_lib get_rpath add_rpath check_rpath check_binary_file tweak_binary_file"[m
 STELLA_API_BUILD_PUBLIC="toolset_info set_toolset start_build_session set_build_mode auto_build"[m
[31m-STELLA_API_PLATFORM_PUBLIC="python_get_lib_dir python_get_include_dir python_get_bin_dir python_get_site_packages_global_path python_get_site_packages_user_path python_get_standard_packages_path yum_proxy_unset yum_proxy_unset_repo yum_proxy_set yum_proxy_set_repo yum_add_extra_repositories yum_remove_extra_repositories python_build_get_libs python_build_get_includes python_build_get_ldflags python_build_get_clags python_build_get_prefix python_major_version python_short_version sys_install sys_remove require"[m
[32m+[m[32mSTELLA_API_PLATFORM_PUBLIC="ansible_play ansible_play_localhost python_get_lib_dir python_get_include_dir python_get_bin_dir python_get_site_packages_global_path python_get_site_packages_user_path python_get_standard_packages_path yum_proxy_unset yum_proxy_unset_repo yum_proxy_set yum_proxy_set_repo yum_add_extra_repositories yum_remove_extra_repositories python_build_get_libs python_build_get_includes python_build_get_ldflags python_build_get_clags python_build_get_prefix python_major_version python_short_version sys_install sys_remove require"[m
 STELLA_API_NETWORK_PUBLIC="find_free_port get_ip_external check_tcp_port_open ssh_execute get_ip_from_hostname get_ip_from_interface proxy_tunnel enable_proxy disable_proxy no_proxy_for register_proxy register_no_proxy"[m
 STELLA_API_BOOT_PUBLIC="boot_stella_shell boot_stella_cmd boot_stella_script boot_app_shell boot_app_cmd boot_app_script"[m
 STELLA_API_LOG_PUBLIC="log set_log_level set_log_state"[m
[1mdiff --git a/nix/common/common-platform.sh b/nix/common/common-platform.sh[m
[1mindex f9eeb86..2b75f76 100644[m
[1m--- a/nix/common/common-platform.sh[m
[1m+++ b/nix/common/common-platform.sh[m
[36m@@ -750,28 +750,49 @@[m [m__use_package_manager() {[m
 # ARG1 playbook yml file[m
 # ARG2 roles root folder[m
 # ARG3 inventory file[m
[31m-# ARG4 limit execution to some host[m
[32m+[m[32m# OPTION[m
[32m+[m[32m#	LIMIT restrict execution to some host[m
[32m+[m[32m#	TAGS execute tasks tagged by one of these tags, separated by comma[m
 __ansible_play() {[m
[31m-  local __playbook="$1"[m
[31m-  local __roles="$2"[m
[32m+[m	[32mlocal __playbook="$1"[m
[32m+[m	[32mlocal __roles="$2"[m
 	local __inventory_file="$3"[m
[31m-	local __limit="$4"[m
[32m+[m	[32mlocal __opt="$4"[m
[32m+[m
[32m+[m	[32mlocal __limit=[m
[32m+[m	[32mlocal __tags=[m
[32m+[m	[32mfor o in ${__opt}; do[m
[32m+[m		[32m[ "$__limit" = "1" ] && __limit="--limit=$o"[m
[32m+[m		[32m[ "$o" = "LIMIT" ] && __limit="1"[m
[32m+[m		[32m[ "$__tags" = "1" ] && __tags="--tags= $o"[m
[32m+[m		[32m[ "$o" = "TAGS" ] && __tags="1"[m
[32m+[m	[32mdone[m
[32m+[m[41m	[m
 	[ -z $__limit ] && __limit=all[m
 [m
[31m-  #ANSIBLE_EXTRA_VARS=\{\"infra_name\":\"$INFRA_NAME\"}[m
[32m+[m	[32m#ANSIBLE_EXTRA_VARS=\{\"infra_name\":\"$INFRA_NAME\"}[m
 	#--extra-vars=$ANSIBLE_EXTRA_VARS[m
[31m-	ANSIBLE_ROLES_PATH="$__roles" PYTHONUNBUFFERED=1 ANSIBLE_FORCE_COLOR=true ansible-playbook --inventory-file="$__inventory_file" --limit="$__limit" -v "$__playbook"[m
[32m+[m	[32mANSIBLE_ROLES_PATH="$__roles" PYTHONUNBUFFERED=1 ANSIBLE_FORCE_COLOR=true ansible-playbook --inventory-file="$__inventory_file" $__limit -v "$__playbook" $__tags[m
 }[m
 [m
 # ARG1 playbook yml file[m
 # ARG2 roles root folder[m
[32m+[m[32m# OPTION[m
[32m+[m[32m#	TAGS execute tasks tagged by one of these tags, separated by comma[m
 __ansible_play_localhost() {[m
[31m-  local __playbook="$1"[m
[32m+[m	[32mlocal __playbook="$1"[m
 	local __roles="$2"[m
[32m+[m	[32mlocal __opt="$3"[m
[32m+[m
[32m+[m	[32mlocal __tags=[m
[32m+[m	[32mfor o in ${__opt}; do[m
[32m+[m		[32m[ "$__tags" = "1" ] && __tags="--tags= $o"[m
[32m+[m		[32m[ "$o" = "TAGS" ] && __tags="1"[m
[32m+[m	[32mdone[m
 [m
[31m-  #ANSIBLE_EXTRA_VARS=\{\"infra_name\"=\"$INFRA_NAME\"}[m
[32m+[m	[32m#ANSIBLE_EXTRA_VARS=\{\"infra_name\"=\"$INFRA_NAME\"}[m
 		#--extra-vars=$ANSIBLE_EXTRA_VARS[m
[31m-  ANSIBLE_ROLES_PATH="$__roles" PYTHONUNBUFFERED=1 ANSIBLE_FORCE_COLOR=true ansible-playbook --connection local --inventory 'localhost,' -v "$__playbook"[m
[32m+[m	[32mANSIBLE_ROLES_PATH="$__roles" PYTHONUNBUFFERED=1 ANSIBLE_FORCE_COLOR=true ansible-playbook --connection local --inventory 'localhost,' -v "$__playbook" $__tags[m
 [m
 [m
 }[m
