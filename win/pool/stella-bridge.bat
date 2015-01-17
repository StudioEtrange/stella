@echo off
if not "%~1"==":include" if not "%~1"==":bootstrap" if not "%~1"==":standalone" (
	@setlocal enableExtensions enableDelayedExpansion
) else (
	call %*
	goto :eof
)


REM Usage :
REM stella-bridge.bat include
REM	call stella :include

REM stella-bridge.bat standalone [install path]
REM	call stella-bridge.bat :standalone [install path]
REM			--- path where to install STELLA the system. If not provided use .\lib-stella by default

REM stella-bridge.bat bootstrap [install path]
REM	call stella-bridge.bat :bootstrap [install path]
REM  		--- absolute or relative to app path where to install STELLA the system. If not provided, use setted value in link file (.-stella-link.bat) or in .\lib-stella by default
REM		 		after installing stella, it will set the project for use stella (if not already done)

REM stella.bat ^<standard stella command^>

set _STELLA_CURRENT_FILE_DIR=%~dp0
set _STELLA_CURRENT_FILE_DIR=%_STELLA_CURRENT_FILE_DIR:~0,-1%
set _STELLA_CURRENT_RUNNING_DIR=%cd%

set IS_STELLA_LINKED=FALSE
set STELLA_ROOT=

set STELLA_APP_ROOT=%_STELLA_CURRENT_RUNNING_DIR%

REM Check if PROJECT in current dir is linked to STELLA -------------------------
if exist "%STELLA_APP_ROOT%\.stella-link.bat" (
	call %STELLA_APP_ROOT%\.stella-link.bat
	if not "!STELLA_ROOT!"=="" (
		if exist "!STELLA_ROOT!\stella.bat" (
			set IS_STELLA_LINKED=TRUE
		)
	)
)


REM Standard mode ------------------
if not "%~1"==":include" if not "%~1"=="include" if not "%~1"==":standalone" if not "%~1"=="standalone" if not "%~1"==":bootstrap" if not "%~1"=="bootstrap" (
	if "%IS_STELLA_LINKED%"=="TRUE" (
		call !STELLA_ROOT!\stella.bat %*
		@echo off
	) else (
		echo ** ERROR This app is not linked to a STELLA installation path
	)
)

if "%~1"==":include" (
	call :include
)
if "%~1"=="include" (
	call :include
)

if "%~1"==":standalone" (
	call :standalone %~2
)
if "%~1"=="standalone" (
	call :standalone %~2
)

if "%~1"==":bootstrap" (
	call :bootstrap %~2
)
if "%~1"=="bootstrap" (
	call :bootstrap %~2
)

goto :eof

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
		REM rm -f "$_path"/$stella-nix-"$_ver".gz.sh
	)

goto :eof

:ask_install_system_requirements
	set /p input="Do you wish to auto-install system requirements for stella ? [Y/n] "
	if not "%input%"=="n" (
		call !STELLA_COMMON!\platform.bat :__stella_system_requirement_by_os !STELLA_CURRENT_OS!
		call !STELLA_BIN!\feature.bat install required
		@echo off
	)
goto :eof

:ask_init_app
	set /p input="Do you wish to init your stella app (create properties files, link app to stella...) ? [Y/n] "
		if not "%input%"=="n" (
			for /D %%I IN ("%_STELLA_CURRENT_RUNNING_DIR%") do set _project_name=%%~nxI
			set /p input="What is your project name ? [!_project_name!] "
			if not "!input!"=="" (
				set "_project_name=!input!"
			)

			set /p input="Do you wish to generate a sample app for your project ? [y/N] "
			if "!input!"=="y" (
				call !STELLA_BIN!\app.bat init "!_project_name!"  -samples
			) else (
				call !STELLA_BIN!\app.bat init "!_project_name!"
			)
			@echo off
		)
goto :eof

REM install stella in standalone------------------
:standalone
	set "_provided_path=%~1"

	REM Try to determine install path of STELLA
	if "%_provided_path%"=="" (
		REM install STELLA into default path
		call :___rel_to_abs_path "_stella_install_path" ".\lib-stella" "%_STELLA_CURRENT_RUNNING_DIR%"
	) else (
		REM install STELLA into ARG#2
		call :___rel_to_abs_path "_stella_install_path" "%_provided_path%" "%_STELLA_CURRENT_RUNNING_DIR%"
	)

	if exist "!_stella_install_path!\stella.bat" (
		REM STELLA already installed, update it
		pushd
		cd /D "!_stella_install_path!"
		git pull
		popd
	) else (
		git clone https://bitbucket.org/StudioEtrange/lib-stella.git "!_stella_install_path!"
	)
	
	call "!_stella_install_path!\conf.bat"
	
	call :ask_install_system_requirements
	
	@echo off
goto :eof



REM Bootstrap a stella project ------------------
:bootstrap
	set "_provided_path=%~1"

	if "%IS_STELLA_LINKED%"=="TRUE" (
		echo ** This app/project is  linked to a STELLA installation located in !STELLA_ROOT!
		
		call "!STELLA_ROOT!\conf.bat"

		call :ask_install_system_requirements
		call :ask_init_app
		@echo off

	) else (

		REM Try to determine install path of STELLA
		if "%_provided_path%"=="" (
			if not "!STELLA_ROOT!"=="" (
				REM install STELLA into STELLA_ROOT, and re-link it to the app
				call :___rel_to_abs_path "_stella_install_path" "!STELLA_ROOT!" "%STELLA_APP_ROOT%"
			) else (
				REM install STELLA into default path, and link it to the app
				call :___rel_to_abs_path "_stella_install_path" ".\lib-stella" "%STELLA_APP_ROOT%"
			)
			git clone https://bitbucket.org/StudioEtrange/lib-stella.git "!_stella_install_path!"
		) else (

			REM install STELLA into ARG#2, and linked to the app
			call :___rel_to_abs_path "_stella_install_path" "%_provided_path%" "%STELLA_APP_ROOT%"
			if exist "!_stella_install_path!\stella.bat" (
				REM STELLA already installed, update it
				pushd
				cd /D "!_stella_install_path!"
				git pull
				popd
			) else (
				git clone https://bitbucket.org/StudioEtrange/lib-stella.git "!_stella_install_path!"
			)
		)
		
		call "!_stella_install_path!\conf.bat"
		
		call :ask_install_system_requirements
		call :ask_init_app
		@echo off
	)
goto :eof


REM Include mode ------------------
:include
	if "%IS_STELLA_LINKED%"=="TRUE" (
		call "!STELLA_ROOT!\conf.bat"
		call !STELLA_COMMON!\common.bat :init_stella_env
	) else (
		echo ** ERROR This app is not linked to a STELLA install path
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
if not "%~1"==":include" if not "%~1"==":bootstrap" if not "%~1"==":standalone" (
	@endlocal
)
