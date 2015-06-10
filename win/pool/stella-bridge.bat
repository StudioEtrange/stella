@setlocal enableExtensions enableDelayedExpansion
@echo off

	
set _STELLA_CURRENT_FILE_DIR=%~dp0
set _STELLA_CURRENT_FILE_DIR=%_STELLA_CURRENT_FILE_DIR:~0,-1%
if "%STELLA_CURRENT_RUNNING_DIR%"=="" set STELLA_CURRENT_RUNNING_DIR=%cd%

set "ACTION=%~1"
set "PROVIDED_PATH=%~2"



REM Usage :

REM stella-bridge.bat standalone [install path]
REM	call stella-bridge.bat standalone [install path]
REM			--- path where to install STELLA the system. If not provided use .\stella by default

REM stella-bridge.bat bootstrap [install path]
REM	call stella-bridge.bat bootstrap [install path]
REM  		--- absolute or relative to app path where to install STELLA the system. If not provided, use setted value in link file (.-stella-link.bat) or in .\stella by default
REM		 		after installing stella, it will set the project for use stella (if not already done)




REM Standard mode ------------------

if "%~1"=="standalone" (
	call :standalone
)


if "%~1"=="bootstrap" (
	call :bootstrap
)

goto :eof





REM install stella in standalone------------------
:standalone
	if "!PROVIDED_PATH!"=="" (
		set "PROVIDED_PATH=!STELLA_CURRENT_RUNNING_DIR!\stella"
	)

	call :___rel_to_abs_path "_STELLA_INSTALL_PATH" "!PROVIDED_PATH!" "!STELLA_CURRENT_RUNNING_DIR!"

	call :get_stella "GIT" "LATEST" "!_STELLA_INSTALL_PATH!"
	
	call "!_STELLA_INSTALL_PATH!\conf.bat"
	call %STELLA_COMMON%\common-app.bat :ask_install_requirements
goto :eof



REM Bootstrap a stella project ------------------
:bootstrap

	set IS_STELLA_LINK_FILE=FALSE
	set IS_STELLA_LINKED=FALSE
	set STELLA_ROOT=
	set IS_STELLA_JUST_INSTALLED=FALSE

	if "%PROVIDED_PATH%"=="" (
		set "PROVIDED_PATH=!STELLA_CURRENT_RUNNING_DIR!\stella"
	)

	REM Check if PROJECT in current dir is linked to STELLA -------------------------
	if exist "!STELLA_CURRENT_RUNNING_DIR!\stella-link.bat" (
		set IS_STELLA_LINK_FILE=TRUE
		call "!STELLA_CURRENT_RUNNING_DIR!\stella-link.bat" nothing
		if not "!STELLA_ROOT!"=="" (
			if exist "!STELLA_ROOT!\stella.bat" (
				set IS_STELLA_LINKED=TRUE
			)
		)
	)

	if "!IS_STELLA_LINKED!"=="TRUE" (
		echo ** This app/project is  linked to a STELLA installation located in !STELLA_ROOT!	
		call "!STELLA_ROOT!\conf.bat"
	) else (

		REM Try to determine install path of STELLA
		if "!IS_STELLA_LINK_FILE!"=="TRUE" (
			REM install STELLA into STELLA_ROOT defined in link file
			call :___rel_to_abs_path "_STELLA_INSTALL_PATH" "!STELLA_ROOT!" "!STELLA_CURRENT_RUNNING_DIR!"
		) else (
			REM install STELLA into default path
			call :___rel_to_abs_path "_STELLA_INSTALL_PATH" "!PROVIDED_PATH!" "!STELLA_CURRENT_RUNNING_DIR!"
		)

		if not exist "!_STELLA_INSTALL_PATH!\stella.bat" (
			if not "!STELLA_DEP_FLAVOUR!"=="" (
				call :get_stella "!STELLA_DEP_FLAVOUR!" "!STELLA_DEP_VERSION!" "!_STELLA_INSTALL_PATH!"
			)
			set IS_STELLA_JUST_INSTALLED=TRUE
		)
	
		call "!_STELLA_INSTALL_PATH!\conf.bat"
	)	
	
	if "!IS_STELLA_JUST_INSTALLED!"=="TRUE" (
		call %STELLA_COMMON%\common-app.bat :ask_install_requirements
	)
	if "!IS_STELLA_LINK_FILE!"=="FALSE" (
		call %STELLA_COMMON%\common-app.bat :ask_init_app
	)


goto :eof


REM Various functions ------------------
:get_stella
	REM OFFICIAL or GIT
	set "_flavour=%~1"
	REM a specific version or LATEST
	set "_ver=%~2"
	set "_path=%~3"

	if "%_flavour%"=="GIT" (
		git clone https://github.com/StudioEtrange/stella "%_path%"
		if not "%_ver%"=="" if not "%_ver%"=="LATEST" (
			cd /D "%_path%"
			git checkout %_ver%
		) 
	)

	if "%_flavour%"=="OFFICIAL" (
		pushd
		if not exist "%_path%" mkdir "%_path%"
		cd /D "%_path%"
		powershell -Command "(New-Object Net.WebClient).DownloadFile('http://"%__STELLA_URL%"/dist/%_ver%/stella-win-"%_ver%".7z.exe', 'stella-win-"%_ver%".zip.exe')"
		popd
	)

goto :eof

:___is_path_abs
	set "_result_var_is_path_abs=%~1"
	set "_test_path=%~2"
echo("%_test_path%"|findstr /i /r /c:^"^^\"[a-zA-Z]:[\\/][^\\/]" ^
                           /c:^"^^\"[\\][\\]" >nul ^
  && set "%_result_var_is_path_abs%=TRUE" || set "%_result_var_is_path_abs%=FALSE"
goto :eof

:___rel_to_abs_path
	set "_result_var_rel_to_abs_path=%~1"
	set "_rel_path=%~2"
	if defined %2 set "_rel_path=!%~2!"

	call :___is_path_abs "IS_ABS" "%_rel_path%"
	if "%IS_ABS%"=="TRUE" ( 
		set "_abs_root_path="
		for %%A in ( %_rel_path%\ ) do set "_temp_path=%%~dpA"
		set %_result_var_rel_to_abs_path%=!_temp_path:~0,-1!
	) else (
		set "_abs_root_path=%~3"
		if not defined _abs_root_path set "_abs_root_path=%STELLA_CURRENT_RUNNING_DIR%"
		for /f "tokens=*" %%A in ("!_abs_root_path!.\%_rel_path%") do set "%_result_var_rel_to_abs_path%=%%~fA"
	)
goto :eof

@echo on
@endlocal