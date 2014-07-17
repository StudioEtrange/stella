set FILE_DIR=%~dp0
set CUR_DIR=%cd%

:: PATHS
set STELLA_ROOT=%FILE_DIR%
set STELLA_ROOT=%STELLA_ROOT:~0,-1%
set STELLA_COMMON=%STELLA_ROOT%\stella-common\win
set POOL_DIR=%STELLA_ROOT%\stella-pool\win

:: GATHER PLATFORM INFO
call %STELLA_COMMON%\platform.bat :set_current_platform_info

:: DEFAULT APP PATH INFO -------------
set APP_ROOT=%CUR_DIR%
set APP_WORK_ROOT=%CUR_DIR%
set PROJECT_ROOT=%CUR_DIR%
set CACHE_DIR=

:: GATHER APP INFO
call %STELLA_COMMON%\common-app.bat :select_app
call %STELLA_COMMON%\common-app.bat :get_all_properties

:: APP PATH
call %STELLA_COMMON%\common.bat :rel_to_abs_path "APP_ROOT" "%APP_ROOT%" "%CUR_DIR%"

call %STELLA_COMMON%\common.bat :rel_to_abs_path "PROJECT_ROOT" "%APP_WORK_ROOT%" "%APP_ROOT%"

if "%CACHE_DIR%"=="" (
	set CACHE_DIR=%PROJECT_ROOT%\cache
)
call %STELLA_COMMON%\common.bat :rel_to_abs_path "CACHE_DIR" "%CACHE_DIR%" "%APP_ROOT%"


set TEMP_DIR=%PROJECT_ROOT%\temp
set TOOL_ROOT=%PROJECT_ROOT%\tool_%STELLA_CURRENT_PLATFORM_SUFFIX%\%STELLA_CURRENT_OS%
set DATA_ROOT=%PROJECT_ROOT%\data
set ASSETS_ROOT=%PROJECT_ROOT%\assets

set ASSETS_REPOSITORY=%PROJECT_ROOT%\..\assets_repository
for %%A in ( %ASSETS_REPOSITORY%\ ) do set ASSETS_REPOSITORY=%%~dpA

:: OTHERS
set WGET="%TOOL_ROOT%\wget\bin\wget.exe"
set UZIP="%TOOL_ROOT%\unzip\bin\unzip.exe"
set U7ZIP="%TOOL_ROOT%\sevenzip\7z.exe"
set PATCH="%TOOL_ROOT%\patch\bin\patch.exe"
set GNUMAKE="%TOOL_ROOT%\make\bin\make.exe"

set FEATURE_LIST_ENABLED=
set DEFAULT_VERBOSE_MODE=0

:: VIRTUALIZATION ----------------------
set "VIRTUAL_WORK_ROOT=%PROJECT_ROOT%\virtual"
set "VIRTUAL_TEMPLATE_ROOT=%VIRTUAL_WORK_ROOT%\template"
set "VIRTUAL_ENV_ROOT=%VIRTUAL_WORK_ROOT%\env"

set "VIRTUAL_INTERNAL_ROOT=%STELLA_ROOT%\stella-virtual"
set "VIRTUAL_INTERNAL_TEMPLATE_ROOT=%VIRTUAL_INTERNAL_ROOT%\template"
set "VIRTUAL_CONF_FILE=%VIRTUAL_INTERNAL_ROOT%\virtual.ini"

set PACKER_CMD=packer
set VAGRANT_CMD=vagrant

set "PACKER_CACHE_DIR=%CACHE_DIR%"

:: choose a default hypervisor for packer and vagrant
:: vmware or virtualbox
set VIRTUAL_DEFAULT_HYPERVISOR=virtualbox



