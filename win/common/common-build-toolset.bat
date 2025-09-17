@echo off
call %*
goto :eof


:: TOOLSET ------------------------------------------------------------------------------------------------------------------------------
:toolset_install
	call %STELLA_COMMON%\common-feature.bat :push_schema_context
	set "_toolset_install_save_app_feature_root=!STELLA_APP_FEATURE_ROOT!"
	set "_toolset_install_save_force=!FORCE!"
	set "FORCE="

	set "STELLA_APP_FEATURE_ROOT=!STELLA_INTERNAL_TOOLSET_ROOT!"
	call %STELLA_COMMON%\common-feature.bat :feature_install %~1 "NON_DECLARED"

	set "STELLA_APP_FEATURE_ROOT=!_toolset_install_save_app_feature_root!"
	set "FORCE=!_toolset_install_save_force!"
	call %STELLA_COMMON%\common-feature.bat :pop_schema_context
goto :eof

:toolset_info
	call %STELLA_COMMON%\common-feature.bat :push_schema_context
	set "_toolset_info_save_app_feature_root=!STELLA_APP_FEATURE_ROOT!"
	set "STELLA_APP_FEATURE_ROOT=!STELLA_INTERNAL_TOOLSET_ROOT!"

	call %STELLA_COMMON%\common-feature.bat :feature_info %~1 "TOOLSET"

	set "STELLA_APP_FEATURE_ROOT=!_toolset_info_save_app_feature_root!"
	call %STELLA_COMMON%\common-feature.bat :pop_schema_context
goto :eof


:toolset_init
	set "_schema_toolset=%~1"

	call %STELLA_COMMON%\common-feature.bat :push_schema_context
	set "_toolset_init_save_app_feature_root=!STELLA_APP_FEATURE_ROOT!"
	set "STELLA_APP_FEATURE_ROOT=!STELLA_INTERNAL_TOOLSET_ROOT!"


	call %STELLA_COMMON%\common-feature.bat :internal_feature_context "!_schema_toolset!"

	call %STELLA_COMMON%\common-feature.bat :feature_inspect !FEAT_SCHEMA_SELECTED!

	if "!TEST_FEATURE!"=="1" (

		if not "!FEAT_BUNDLE!"=="" (
			call %STELLA_COMMON%\common-feature.bat :push_schema_context

			set "FEAT_BUNDLE_MODE=!FEAT_BUNDLE!"
			for %%p in (!FEAT_BUNDLE_ITEM!) do (
				REM call :feature_init %%p "HIDDEN"
				call %STELLA_COMMON%\common-feature.bat :internal_feature_context "%%p"
				if not "!FEAT_SEARCH_PATH!"=="" set "STELLA_BUILD_TOOLSET_PATH=!FEAT_SEARCH_PATH!;!STELLA_BUILD_TOOLSET_PATH!"
				for %%e in (!FEAT_ENV_CALLBACK!) do (
					call %STELLA_FEATURE_RECIPE%\feature_!FEAT_NAME!.bat :%%e
				)
			)
			set "FEAT_BUNDLE_MODE="

			call %STELLA_COMMON%\common-feature.bat :pop_schema_context
		)

		if not "!FEAT_SEARCH_PATH!"=="" set "STELLA_BUILD_TOOLSET_PATH=!FEAT_SEARCH_PATH!;!STELLA_BUILD_TOOLSET_PATH!"

		REM TODO : warn : env vars should be uninitialized later because use of a toolset is temporary
		for %%p in (!FEAT_ENV_CALLBACK!) do (
			call %STELLA_FEATURE_RECIPE%\feature_!FEAT_NAME!.bat :%%p
		)

	)

	set "STELLA_APP_FEATURE_ROOT=!_toolset_init_save_app_feature_root!"
	call %STELLA_COMMON%\common-feature.bat :pop_schema_context
goto :eof

REM check some toolset features availability
:check_toolset
	set "STELLA_BUILD_CHECK_TOOLSET=!STELLA_BUILD_CHECK_TOOLSET! !_add_toolset!"
goto :eof

:add_toolset
	set "_add_toolset=%~1"
	set "STELLA_BUILD_EXTRA_TOOLSET=!STELLA_BUILD_EXTRA_TOOLSET! !_add_toolset!"
goto :eof

:set_toolset
	set "_toolset=%~1"
	set "OPT=%~2"

	:: configure tool
	set _flag_configure=
	:: build tool
	set _flag_build=
	:: compiler frontend
	set _flag_frontend=

	set "STELLA_BUILD_CONFIG_TOOL_SCHEMA="
	set "STELLA_BUILD_BUILD_TOOL_SCHEMA="
	set "STELLA_BUILD_COMPIL_FRONTEND_SCHEMA="

	if "!_toolset!"=="CUSTOM" (
		set "STELLA_BUILD_TOOLSET=CUSTOM"
		for %%O in (%OPT%) do (
			if "!_flag_configure!"=="ON" (
				set "STELLA_BUILD_CONFIG_TOOL_SCHEMA=%%O"
				set "_flag_configure=OFF"
			)
			if "%%O"=="CONFIG_TOOL" (
				set "_flag_configure=ON"
			)
			if "!_flag_build!"=="ON" (
				set "STELLA_BUILD_BUILD_TOOL_SCHEMA=%%O"
				set "_flag_build=OFF"
			)
			if "%%O"=="BUILD_TOOL" (
				set "_flag_build=ON"
			)
			if "!_flag_frontend!"=="ON" (
				set "STELLA_BUILD_COMPIL_FRONTEND_SCHEMA=%%O"
				set "_flag_frontend=OFF"
			)
			if "%%O"=="COMPIL_FRONTEND" (
				set "_flag_frontend=ON"
			)
		)
	)

	if "!_toolset!"=="NONE" (
		set "STELLA_BUILD_TOOLSET=NONE"
		set "STELLA_BUILD_CONFIG_TOOL_SCHEMA="
		set "STELLA_BUILD_BUILD_TOOL_SCHEMA="
		set "STELLA_BUILD_COMPIL_FRONTEND_SCHEMA="
	)
	if "!_toolset!"=="MS" (
		set "STELLA_BUILD_TOOLSET=MS"
		set "STELLA_BUILD_CONFIG_TOOL_SCHEMA=cmake"
		set "STELLA_BUILD_BUILD_TOOL_SCHEMA=nmake"
		set "STELLA_BUILD_COMPIL_FRONTEND_SCHEMA=cl"
	)

	if "!_toolset!"=="MINGW-W64" (
		set "STELLA_BUILD_TOOLSET=MINGW-W64"
		set "STELLA_BUILD_CONFIG_TOOL_SCHEMA="
		set "STELLA_BUILD_BUILD_TOOL_SCHEMA=mingw-make"
		set "STELLA_BUILD_COMPIL_FRONTEND_SCHEMA=mingw-gcc"
	)

	if "!_toolset!"=="MSYS2" (
		set "STELLA_BUILD_TOOLSET=MSYS2"
		set "STELLA_BUILD_CONFIG_TOOL_SCHEMA=configure"
		set "STELLA_BUILD_BUILD_TOOL_SCHEMA=msys-mingw-make"
		set "STELLA_BUILD_COMPIL_FRONTEND_SCHEMA=msys-mingw-gcc"
	)



	REM TODO autoselect ninja instead of make if using cmake


	REM STELLA_BUILD_CONFIG_TOOL
	set "STELLA_BUILD_CONFIG_TOOL_BIN_FAMILY="
	set "_t="
	call %STELLA_COMMON%\common-feature.bat :translate_schema "!STELLA_BUILD_CONFIG_TOOL_SCHEMA!" "_t"
	if "!_t!"=="cmake" (
		set "STELLA_BUILD_CONFIG_TOOL_BIN_FAMILY=cmake"
	)
	if "!_t!"=="configure" (
		set "STELLA_BUILD_CONFIG_TOOL_BIN_FAMILY=configure"
	)
	set "STELLA_BUILD_CONFIG_TOOL=!_t!"

	REM STELLA_BUILD_BUILD_TOOL
	set "STELLA_BUILD_BUILD_TOOL_BIN_FAMILY="
	set "_t="
	call %STELLA_COMMON%\common-feature.bat :translate_schema "!STELLA_BUILD_BUILD_TOOL_SCHEMA!" "_t"
	if "!_t!"=="nmake" (
		set "STELLA_BUILD_BUILD_TOOL_BIN_FAMILY=nmake"
	)
	if "!_t!"=="ninja" (
		set "STELLA_BUILD_BUILD_TOOL_BIN_FAMILY=ninja"
	)
	if "!_t!"=="jom" (
		set "STELLA_BUILD_BUILD_TOOL_BIN_FAMILY=jom"
	)
	if "!_t!"=="mingw-make" (
		set "STELLA_BUILD_BUILD_TOOL_BIN_FAMILY=make"
	)
	if "!_t!"=="msys-mingw-make" (
		set "STELLA_BUILD_BUILD_TOOL_BIN_FAMILY=make"
	)
	if "!_t!"=="msys-make" (
		set "STELLA_BUILD_BUILD_TOOL_BIN_FAMILY=make"
	)
	set "STELLA_BUILD_BUILD_TOOL=!_t!"


	REM STELLA_BUILD_COMPIL_FRONTEND
	REM STELLA_BUILD_COMPIL_FRONTEND_BIN_FAMILY has an impact on flag passed to compiler
	set "STELLA_BUILD_COMPIL_FRONTEND_BIN_FAMILY="
	set "_t="
	call %STELLA_COMMON%\common-feature.bat :translate_schema "!STELLA_BUILD_COMPIL_FRONTEND_SCHEMA!" "_t"
	if "!_t!"=="cl" (
		set "STELLA_BUILD_COMPIL_FRONTEND_BIN_FAMILY=cl"
	)
	if "!_t!"=="msys-gcc" (
		set "STELLA_BUILD_COMPIL_FRONTEND_BIN_FAMILY=gcc"
	)
	if "!_t!"=="mingw-gcc" (
		set "STELLA_BUILD_COMPIL_FRONTEND_BIN_FAMILY=gcc"
	)
	if "!_t!"=="msys-mingw-gcc" (
		set "STELLA_BUILD_COMPIL_FRONTEND_BIN_FAMILY=gcc"
	)
	set "STELLA_BUILD_COMPIL_FRONTEND=!_t!"

goto :eof



:enable_current_toolset

	echo ** Require build toolset : !STELLA_BUILD_TOOLSET! [ config tool scbema :!STELLA_BUILD_CONFIG_TOOL_SCHEMA! build tool schema :!STELLA_BUILD_BUILD_TOOL_SCHEMA! compil frontend schema : !STELLA_BUILD_COMPIL_FRONTEND_SCHEMA! ]
	set "_active_vs="
	REM if "!STELLA_BUILD_TOOLSET!"=="MS" (
		REM TODO require visual studio
		REM set "_active_vs=1"
	REM )

	REM STELLA_BUILD_CONFIG_TOOL
	if not "!STELLA_BUILD_CONFIG_TOOL!"=="" (
		if "!STELLA_BUILD_CONFIG_TOOL!"=="cmake" (
			call :toolset_install "!STELLA_BUILD_CONFIG_TOOL_SCHEMA!"
			call :toolset_init "!STELLA_BUILD_CONFIG_TOOL_SCHEMA!"
		) else (

			if not "!STELLA_BUILD_CONFIG_TOOL!"=="configure" (
				echo ********* ERROR UNSUPPORTED STELLA_BUILD_CONFIG_TOOL_SCHEMA : !STELLA_BUILD_CONFIG_TOOL_SCHEMA! *******************
			)
		)
	)

	REM TODO REVIEW INSTALL STEP
	REM STELLA_BUILD_BUILD_TOOL
	if not "!STELLA_BUILD_BUILD_TOOL!"=="" (
		if "!STELLA_BUILD_BUILD_TOOL!"=="nmake" (
			REM TODO require visual studio
			set "_active_vs=1"
		) else (
			if "!STELLA_BUILD_BUILD_TOOL!"=="mingw-make" (
				call :toolset_install "mingw-w64"
				call :toolset_init "mingw-w64"
			) else (
				if "!STELLA_BUILD_BUILD_TOOL!"=="msys-make" (
					call :toolset_install "msys2"
					call :toolset_init "msys2"
					REM TODO install msys2 make
				) else (
					if "!STELLA_BUILD_BUILD_TOOL!"=="msys-mingw-make" (
						call :toolset_install "msys2"
						call :toolset_init "msys2"
						REM TODO install msys2 mingw make
					) else (
						if "!STELLA_BUILD_BUILD_TOOL!"=="ninja" (
							call :toolset_install "!STELLA_BUILD_BUILD_TOOL_SCHEMA!"
							call :toolset_init "!STELLA_BUILD_BUILD_TOOL_SCHEMA!"
						) else (
							if "!STELLA_BUILD_BUILD_TOOL!"=="jom" (
								call :toolset_install "!STELLA_BUILD_BUILD_TOOL_SCHEMA!"
								call :toolset_init "!STELLA_BUILD_BUILD_TOOL_SCHEMA!"
							) else (
								echo ********* ERROR UNSUPPORTED STELLA_BUILD_BUILD_TOOL_SCHEMA : !STELLA_BUILD_BUILD_TOOL_SCHEMA! *******************
							)
						)
					)
				)
			)
		)
	)

	REM STELLA_BUILD_COMPIL_FRONTEND
	if not "!STELLA_BUILD_COMPIL_FRONTEND!"=="" (
		if "!STELLA_BUILD_COMPIL_FRONTEND!"=="cl" (
			REM TODO require visual studio
			set "_active_vs=1"
		) else (
			if "!STELLA_BUILD_COMPIL_FRONTEND!"=="mingw-gcc" (
				call :toolset_install "mingw-w64"
				call :toolset_init "mingw-w64"
			) else (
				if "!STELLA_BUILD_COMPIL_FRONTEND!"=="msys-gcc" (
					call :toolset_install "msys2"
					call :toolset_init "msys2"
					REM TODO install msys2 gcc
				) else (
					if "!STELLA_BUILD_COMPIL_FRONTEND!"=="msys-mingw-gcc" (
						call :toolset_install "msys2"
						call :toolset_init "msys2"
						REM TODO install msys2 mmingw gcc
					) else (
						echo ********* ERROR UNSUPPORTED STELLA_BUILD_COMPIL_FRONTEND_SCHEMA : !STELLA_BUILD_COMPIL_FRONTEND_SCHEMA! *******************
					)
				)
			)
		)
	)

	echo ** Require build toolset : !STELLA_BUILD_TOOLSET! [ config tool scbema :!STELLA_BUILD_CONFIG_TOOL_SCHEMA! build tool schema :!STELLA_BUILD_BUILD_TOOL_SCHEMA! compil frontend schema : !STELLA_BUILD_COMPIL_FRONTEND_SCHEMA! ]

	echo ** Require extra toolset : !STELLA_BUILD_EXTRA_TOOLSET!
	for %%s in (!STELLA_BUILD_EXTRA_TOOLSET!) do (
		call :toolset_install "%%s"
		call :toolset_init "%%s"
	)

	echo ** All toolset are installed


	echo ** Set toolsets search path
	set "_save_path_CURRENT_TOOLSET=!PATH!"
	REM set visual studio path and env vars
	if "!_active_vs!"=="1" (
		call :vs_env_vars !STELLA_BUILD_ARCH!
	)
	set "PATH=!STELLA_BUILD_TOOLSET_PATH!;!PATH!"




	echo ** Check toolset feature availability: !STELLA_BUILD_CHECK_TOOLSET!
	for %%s in (!STELLA_BUILD_CHECK_TOOLSET!) do (
		echo TODO check toolset feature : %%s
	)




	echo ** Init specific toolset env var
	REM TODO REVIEW
	if "!STELLA_BUILD_COMPIL_FRONTEND_BIN_FAMILY!"=="gcc" (
		if "!STELLA_BUILD_COMPIL_FRONTEND!"=="msys-gcc" (
			call :toolset_info "msys2"
		)
		if "!STELLA_BUILD_COMPIL_FRONTEND!"=="mingw-gcc" (
			call :toolset_info "mingw-w64"
			REM set "AR=!TOOLSET_FEAT_INSTALL_ROOT!\bin\ar"
			REM set "AS=!TOOLSET_FEAT_INSTALL_ROOT!\bin\as"
			REM set "LIBRARY_PATH=!LIBRARY_PATH!;!TOOLSET_FEAT_INSTALL_ROOT!\lib\gcc\x86_64-w64-mingw32\4.9.2"
			REM set CMAKE_C_COMPILER=mingw32-gcc
			REM set CMAKE_CXX_COMPILER=mingw32-gcc
			REM activate gcc libs search folder at link time
			REM export LIBRARY_PATH="$LIBRARY_PATH:$TOOLSET_FEAT_INSTALL_ROOT/lib"
		)
		if "!STELLA_BUILD_COMPIL_FRONTEND!"=="msys-mingw-gcc" (
			call :toolset_info "msys2"
		)
		set "CC=!TOOLSET_FEAT_INSTALL_ROOT!\bin\gcc"
		set "CXX=!TOOLSET_FEAT_INSTALL_ROOT!\bin\gcc"
		set "CPP=!TOOLSET_FEAT_INSTALL_ROOT!\bin\gcc"
	)

	if "!STELLA_BUILD_COMPIL_FRONTEND!"=="cl" (
		set CC=cl
		set CXX=cl
		set CPP=cl
		REM set CMAKE_C_COMPILER=cl
		REM set CMAKE_CXX_COMPILER=cl
		REM https://msdn.microsoft.com/en-us/library/d7ahf12s.aspx
		REM set AS=ml
		REM set BC=bc
		REM set RC=rc
	)

goto :eof

:disable_current_toolset
	echo ** Disable current toolset path
	set "PATH=!_save_path_CURRENT_TOOLSET!"
goto :eof
