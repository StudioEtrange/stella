@echo off
if not "%~1"==":bootstrap" if not "%~1"==":standalone" (
	@setlocal enableExtensions enableDelayedExpansion
	set _STELLA_CURRENT_FILE_DIR=%~dp0
	set _STELLA_CURRENT_FILE_DIR=%_STELLA_CURRENT_FILE_DIR:~0,-1%
	if "%_STELLA_CURRENT_RUNNING_DIR%"=="" set _STELLA_CURRENT_RUNNING_DIR=%cd%

	set "ACTION=%~1"
	set "PROVIDED_PATH=%~2"
) else (
	set _STELLA_CURRENT_FILE_DIR=%~dp0
	set _STELLA_CURRENT_FILE_DIR=%_STELLA_CURRENT_FILE_DIR:~0,-1%
	if "%_STELLA_CURRENT_RUNNING_DIR%"=="" set _STELLA_CURRENT_RUNNING_DIR=%cd%

	set "ACTION=%~1"
	set "PROVIDED_PATH=%~2"
	
	call %*
	goto :eof
)


REM Usage :

REM stella-bridge.bat standalone [install path]
REM	call stella-bridge.bat :standalone [install path]
REM			--- path where to install STELLA the system. If not provided use .\lib-stella by default

REM stella-bridge.bat bootstrap [install path]
REM	call stella-bridge.bat :bootstrap [install path]
REM  		--- absolute or relative to app path where to install STELLA the system. If not provided, use setted value in link file (.-stella-link.bat) or in .\lib-stella by default
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
	if "%PROVIDED_PATH%"=="" (
		set "%PROVIDED_PATH%=%_STELLA_CURRENT_RUNNING_DIR%\lib-stella"
	)

	call :___rel_to_abs_path "_stella_install_path" "%PROVIDED_PATH%" "%_STELLA_CURRENT_RUNNING_DIR%"

	REM TODO call get_stella
	git clone https://bitbucket.org/StudioEtrange/lib-stella.git "!_stella_install_path!"
	
	call "!_stella_install_path!\conf.bat"
	call %STELLA_COMMON%\common-app.bat :ask_install_system_requirements
goto :eof



REM Bootstrap a stella project ------------------
:bootstrap

	set IS_STELLA_LINK_FILE=FALSE
	set IS_STELLA_LINKED=FALSE
	set STELLA_ROOT=

	if "%PROVIDED_PATH%"=="" (
		set "%PROVIDED_PATH%=%_STELLA_CURRENT_RUNNING_DIR%\lib-stella"
	)

	REM Check if PROJECT in current dir is linked to STELLA -------------------------
	if exist "%_STELLA_CURRENT_RUNNING_DIR%\stella-link.bat" (
		set IS_STELLA_LINK_FILE=TRUE
		call %_STELLA_CURRENT_RUNNING_DIR%\stella-link.bat
		if not "!STELLA_ROOT!"=="" (
			if exist "!STELLA_ROOT!\stella.bat" (
				set IS_STELLA_LINKED=TRUE
			)
		)
	)

	if "%IS_STELLA_LINKED%"=="TRUE" (
		echo ** This app/project is  linked to a STELLA installation located in !STELLA_ROOT!	
		call "!STELLA_ROOT!\conf.bat"
	) else (

		REM Try to determine install path of STELLA
		if "%IS_STELLA_LINK_FILE%"=="TRUE" (
			REM install STELLA into STELLA_ROOT defined in link file
			call :___rel_to_abs_path "_stella_install_path" "!STELLA_ROOT!" "%_STELLA_CURRENT_RUNNING_DIR%"
		) else (
			REM install STELLA into default path
			call :___rel_to_abs_path "_stella_install_path" "%PROVIDED_PATH%" "%_STELLA_CURRENT_RUNNING_DIR%"
		)

		REM TODO call get_stella
		git clone https://bitbucket.org/StudioEtrange/lib-stella.git "!_stella_install_path!"
	
		call "!_stella_install_path!\conf.bat"
	)	
		
	call %STELLA_COMMON%\common-app.bat :ask_install_system_requirements
	call %STELLA_COMMON%\common-app.bat :ask_init_app

goto :eof


REM Various functions ------------------
:get_stella
	set "_ver=%~1"
	set "_path=%~2"
	

	if "%_ver"=="git" (
		git clone https://bitbucket.org/StudioEtrange/lib-stella.git "%_path%"
	) else (
		pushd
		cd /d %_path%
		powershell -Command "(New-Object Net.WebClient).DownloadFile('http://studio-etrange.org/stella/stella-win-"%_ver%".zip.exe', 'stella-win-"%_ver%".zip.exe')"
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
		if not defined _abs_root_path set "_abs_root_path=%_STELLA_CURRENT_RUNNING_DIR%"
		for /f "tokens=*" %%A in ("!_abs_root_path!.\%_rel_path%") do set "%_result_var_rel_to_abs_path%=%%~fA"
	)
goto :eof

@echo on
	if not "%~1"==":bootstrap" if not "%~1"==":standalone" (
	@endlocal
)
