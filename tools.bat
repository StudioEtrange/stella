@setlocal enableExtensions enableDelayedExpansion
@echo off
echo ***************************************************************
echo ** EXECUTING : %~n0

call %~dp0\conf.bat

:: arguments
set "params=action:"init install""
set "options=-extra:"ninja jom cmake packer perl ruby2 nasm python27 vagrant-git ruby19 openssh" -arch:"#x64 x86" -f: -v: -vv:"
call %STELLA_COMMON%\argopt.bat :argopt %*
if "%ARGOPT_FLAG_ERROR%"=="1" goto :usage
if "%ARGOPT_FLAG_HELP%"=="1" goto :usage

:: setting env
call %STELLA_COMMON%\common.bat :init_env

::setting verbose mode
call %STELLA_COMMON%\common.bat :set_verbose_mode %VERBOSE_MODE%

if "%action%"=="init" (
	call :init_tools
	goto :end
)

if "%action%"=="install" (
	if "%-extra%"=="ninja" call %STELLA_COMMON%\common-extra.bat :ninja
	if "%-extra%"=="jom" call %STELLA_COMMON%\common-extra.bat :jom
	if "%-extra%"=="cmake" call %STELLA_COMMON%\common-extra.bat :cmake
	if "%-extra%"=="packer" call %STELLA_COMMON%\common-extra.bat :packer
	if "%-extra%"=="perl" call %STELLA_COMMON%\common-extra.bat :perl
	if "%-extra%"=="nasm" call %STELLA_COMMON%\common-extra.bat :nasm
	if "%-extra%"=="python27" call %STELLA_COMMON%\common-extra.bat :python27
	if "%-extra%"=="vagrant-git" call %STELLA_COMMON%\common-extra.bat :vagrant_git
	if "%-extra%"=="openssh" call %STELLA_COMMON%\common-extra.bat :openssh
	if "%-extra%"=="ruby2" (
		call %STELLA_COMMON%\common-extra.bat :ruby2
		call %STELLA_COMMON%\common-extra.bat :rdevkit2
	)
	if "%-extra%"=="ruby19" (
		call %STELLA_COMMON%\common-extra.bat :ruby19
		call %STELLA_COMMON%\common-extra.bat :rdevkit19
	)
	goto :end
)

goto :usage


:usage
   echo USAGE :
   echo %~n0 %ARGOPT_HELP_SYNTAX%
goto :end


:wget
	echo ** Install wget
	if "%FORCE%"=="1" call %STELLA_COMMON%\common.bat :del_folder "%TOOL_ROOT%\wget"
	if not exist "%TOOL_ROOT%\wget\bin\wget.exe" (
		"%UZIP%" -o "%POOL_DIR%\tool\wget-1.11.4-1-bin.zip" -d "%TOOL_ROOT%\wget"
		"%UZIP%" -o "%POOL_DIR%\tool\wget-1.11.4-1-dep.zip" -d "%TOOL_ROOT%\wget" 
	) else (
		echo ** Already installed
	)
goto :eof


:gnumake
	echo ** Install gnumake
	set VERSION=3.81
	set INSTALL_DIR="%TOOL_ROOT%\make"
	if "%FORCE%"=="1" call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	if not exist "%INSTALL_DIR%\bin\make.exe" (
		set URL=http://downloads.sourceforge.net/project/gnuwin32/make/3.81/make-3.81-bin.zip
		set FILE_NAME=make-3.81-bin.zip
		call %STELLA_COMMON%\common.bat :download_uncompress "!URL!" "!FILE_NAME!" "%INSTALL_DIR%"
		
		set URL=http://sourceforge.net/projects/gnuwin32/files/make/3.81/make-3.81-dep.zip
		set FILE_NAME=make-3.81-dep.zip
		call %STELLA_COMMON%\common.bat :download_uncompress "!URL!" "!FILE_NAME!" "%INSTALL_DIR%"
	) else (
		echo ** Already installed
	)
goto :eof

:unzip
	echo ** Install unzip
	if "%FORCE%"=="1" call %STELLA_COMMON%\common.bat :del_folder "%TOOL_ROOT%\unzip"
	if not exist "%TOOL_ROOT%\unzip\bin\unzip.exe" (
		call %STELLA_COMMON%\common.bat :copy_folder_content_into "%POOL_DIR%\tool\unzip-5.51-1-bin" "%TOOL_ROOT%\unzip\"
	) else (
		echo ** Already installed
	)
goto :eof

:sevenzip
	echo ** Install sevenzip
	if "%FORCE%"=="1" call %STELLA_COMMON%\common.bat :del_folder "%TOOL_ROOT%\sevenzip"
	if not exist "%TOOL_ROOT%\sevenzip\7z.exe" (
		call %STELLA_COMMON%\common.bat :copy_folder_content_into "%POOL_DIR%\tool\sevenzip" "%TOOL_ROOT%\sevenzip\"
	) else (
		echo ** Already installed
	)
goto :eof


:patch
	echo ** Install gnu patch
	if "%FORCE%"=="1" call %STELLA_COMMON%\common.bat :del_folder "%TOOL_ROOT%\patch"
	if not exist "%TOOL_ROOT%\patch\bin\patch.exe" (
		"%UZIP%" -o "%POOL_DIR%\tool\patch-2.5.9-7-bin.zip" -d "%TOOL_ROOT%\patch"
	) else (
		echo ** Already installed
	)
goto:eof



:init_tools
	echo ** Initialize Tools
	if not exist "%TOOL_ROOT%" mkdir "%TOOL_ROOT%"
	
	call :unzip
	call :wget
	call :sevenzip
	call :patch
	call :gnumake
goto :eof



:end
echo ** END **
cd /D %CUR_DIR%
@echo on
@endlocal
