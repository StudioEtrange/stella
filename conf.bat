set _STELLA_CURRENT_FILE_DIR=%~dp0
set _STELLA_CURRENT_FILE_DIR=%_STELLA_CURRENT_FILE_DIR:~0,-1%
if "%_STELLA_CURRENT_RUNNING_DIR%"=="" set _STELLA_CURRENT_RUNNING_DIR=%cd%


:: PATHS
set STELLA_ROOT=%_STELLA_CURRENT_FILE_DIR%
set STELLA_COMMON=%STELLA_ROOT%\win\common
set STELLA_POOL=%STELLA_ROOT%\win\pool
set STELLA_BIN=%STELLA_ROOT%\win\bin
set STELLA_FEATURE_RECIPE=%STELLA_POOL%\feature-recipe


:: GATHER PLATFORM INFO
call %STELLA_COMMON%\platform.bat :set_current_platform_info

:: DEFAULT APP INFO -------------
set STELLA_APP_ROOT=%_STELLA_CURRENT_RUNNING_DIR%
set STELLA_APP_WORK_ROOT=%_STELLA_CURRENT_RUNNING_DIR%
set STELLA_APP_CACHE_DIR=
set STELLA_APP_NAME=
set STELLA_APP_PROPERTIES_FILENAME=stella.properties

:: GATHER APP INFO
call %STELLA_COMMON%\common-app.bat :select_app "_STELLA_APP_PROPERTIES_FILE"
call %STELLA_COMMON%\common-app.bat :get_all_properties !_STELLA_APP_PROPERTIES_FILE!

:: APP PATH
call %STELLA_COMMON%\common.bat :rel_to_abs_path "STELLA_APP_ROOT" "%STELLA_APP_ROOT%" "%_STELLA_CURRENT_RUNNING_DIR%"
call %STELLA_COMMON%\common.bat :rel_to_abs_path "STELLA_APP_WORK_ROOT" "%STELLA_APP_WORK_ROOT%" "%STELLA_APP_ROOT%"
if "%STELLA_APP_CACHE_DIR%"=="" (
	set STELLA_APP_CACHE_DIR=%STELLA_APP_WORK_ROOT%\cache
)
call %STELLA_COMMON%\common.bat :rel_to_abs_path "STELLA_APP_CACHE_DIR" "%STELLA_APP_CACHE_DIR%" "%STELLA_APP_ROOT%"

set STELLA_APP_TEMP_DIR=%STELLA_APP_WORK_ROOT%\temp
set STELLA_APP_FEATURE_ROOT=%STELLA_APP_WORK_ROOT%\feature_%STELLA_CURRENT_PLATFORM_SUFFIX%\%STELLA_CURRENT_OS%
set ASSETS_ROOT=%STELLA_APP_WORK_ROOT%\assets
call %STELLA_COMMON%\common.bat :rel_to_abs_path "ASSETS_REPOSITORY" "..\assets_repository" "%STELLA_APP_WORK_ROOT%"

:: DEFAULT FEATURE ---------------------------------------------
set "WGET=%STELLA_APP_FEATURE_ROOT%\wget\bin\wget.exe"
set "UZIP=%STELLA_APP_FEATURE_ROOT%\unzip\bin\unzip.exe"
set "U7ZIP=%STELLA_APP_FEATURE_ROOT%\sevenzip\7z.exe"
set "PATCH=%STELLA_APP_FEATURE_ROOT%\patch\bin\patch.exe"
set "GNUMAKE=%STELLA_APP_FEATURE_ROOT%\make\bin\make.exe"


:: OTHERS ---------------------------------------------
set FEATURE_LIST_ENABLED=
set VERBOSE_MODE=0


:: VIRTUALIZATION ----------------------
set "VIRTUAL_WORK_ROOT=%STELLA_APP_WORK_ROOT%\virtual"
set "VIRTUAL_TEMPLATE_ROOT=%VIRTUAL_WORK_ROOT%\template"
set "VIRTUAL_ENV_ROOT=%VIRTUAL_WORK_ROOT%\env"

set "VIRTUAL_INTERNAL_ROOT=%STELLA_ROOT%\common\virtual"
set "VIRTUAL_INTERNAL_TEMPLATE_ROOT=%VIRTUAL_INTERNAL_ROOT%\template"
set "VIRTUAL_CONF_FILE=%VIRTUAL_INTERNAL_ROOT%\virtual.ini"

set PACKER_CMD=packer
set VAGRANT_CMD=vagrant

set "PACKER_STELLA_APP_CACHE_DIR=%STELLA_APP_CACHE_DIR%"

:: choose a default hypervisor for packer and vagrant
:: vmware or virtualbox
set VIRTUAL_DEFAULT_HYPERVISOR=virtualbox


:: INTERNAL LIST ---------------------------------------------
set "__STELLA_DISTRIB_LIST=ubuntu64_13_10 debian64_7_5 centos64_6_5 archlinux boot2docker"
set "__STELLA_FEATURE_LIST=ninja jom cmake packer perl ruby nasm python vagrant openssh"

:: API ---------------------------------------------
set "STELLA_API_COMMON_PUBLIC=is_path_abs get_ressource download_uncompress del_folder copy_folder_content_into fork run_admin"
set "STELLA_API_APP_PUBLIC=get_data get_assets get_all_data get_all_assets update_data update_assets revert_data revert_assets"
set "STELLA_API_FEATURE_PUBLIC=install_feature init_feature reinit_all_features"
set "STELLA_API_VIRTUAL_PUBLIC="


set "STELLA_API=%STELLA_COMMON%\common-api.bat :api_proxy+"

