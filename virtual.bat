@setlocal enableExtensions enableDelayedExpansion
@echo off
echo ***************************************************************
echo ** EXECUTING : %~n0
echo ** Requirement : Vagrant 1.6 from http://www.vagrantup.com/
echo ** Recommanded : vagrant-vbguest plugin https://github.com/dotless-de/vagrant-vbguest http://kvz.io/blog/2013/01/16/vagrant-tip-keep-virtualbox-guest-additions-in-sync/
echo 					vagrant plugin install vagrant-vbguest
echo ** Requirement : Virtualbox 4.3.12 from https://www.virtualbox.org/
call %~dp0\conf.bat


:: docker installation on windows : http://docs.docker.io/en/latest/installation/windows/

:: arguments
set "params=action:"create-env run-env stop-env destroy-env info-env list-env create-box get-box list-box destroy-box list-distrib""
set "options=-v: -vv: -distrib:"%DISTRIB_LIST%" -f: -envname:_ANY_ -envcpu:_ANY_ -envmem:_ANY_ -vmgui: -l:"
call %STELLA_COMMON%\argopt.bat :argopt %*
if "%ARGOPT_FLAG_ERROR%"=="1" goto :usage
if "%ARGOPT_FLAG_HELP%"=="1" goto :usage

:: setting env
call %STELLA_COMMON%\common.bat :init_env


::other command line arguments
set VM_ENV_NAME=%-envname%
set ENV_CPU=%-envcpu%
set ENV_MEM=%-envmem%
if "%-vmgui%"=="" set VM_HEADLESS=false
if "%ENV_CPU%"=="" set ENV_CPU=1
if "%ENV_MEM%"=="" set ENV_MEM=384
set DISTRIB=%-distrib%

if not "%DISTRIB%"=="" (
	call :_set_matrix %DISTRIB%
)


REM --------------- BOX MANAGEMENT -------------------------
if "%action%"=="create-box" (
	call :_virtual_init_folder
	call :create_box
	goto :end
)

if "%action%"=="get-box" (
	call :get_box
	goto :end
)

if "%action%"=="list-box" (
	call :list_box
	goto :end
)


REM --------------- ENV MANAGEMENT -------------------------

if "%action%"=="list-distrib" (
	echo %DISTRIB_LIST%
	goto :end
)

if "%action%"=="create-env" (
	call :_virtual_init_folder
	call :create_env
	goto :end
)

if "%action%"=="list-env" (
	call :list_env
	goto :end
)

if "%action%"=="destroy-env" (
	call :_virtual_init_folder
	call :destroy_env
	goto :end
)

if "%action%"=="run-env" (
	call :_virtual_init_folder
	call :run_env
	goto :end
)

if "%action%"=="stop-env" (
	call :_virtual_init_folder
	call :stop_env
	goto :end
)

if "%action%"=="info-env" (
	call :_virtual_init_folder
	call :info_env
	goto :end
)



goto :usage


REM ------------------------------------ INTERNAL FUNCTIONS -----------------------
:usage
   echo USAGE :
   echo %~n0 %ARGOPT_HELP_SYNTAX%
goto :end

:_virtual_init_folder
	if not exist "%VIRTUAL_WORK_ROOT%" mkdir "%VIRTUAL_WORK_ROOT%"
	if not exist "%VIRTUAL_ENV_ROOT%" mkdir "%VIRTUAL_ENV_ROOT%"
	if not exist "%VIRTUAL_TEMPLATE_ROOT%" mkdir "%VIRTUAL_TEMPLATE_ROOT%"
goto :eof

:_set_matrix
	set "_distrib=%~1"

	call %STELLA_COMMON%\common.bat :get_key "%VIRTUAL_CONF_FILE%" "%_distrib%" "PACKER_TEMPLATE"
	call %STELLA_COMMON%\common.bat :get_key "%VIRTUAL_CONF_FILE%" "%_distrib%" "PACKER_TEMPLATE_URI"
	call %STELLA_COMMON%\common.bat :get_key "%VIRTUAL_CONF_FILE%" "%_distrib%" "PACKER_TEMPLATE_URI_PROTOCOL"

	call %STELLA_COMMON%\common.bat :get_key "%VIRTUAL_CONF_FILE%" "%_distrib%" "PACKER_BUILDER"
	call %STELLA_COMMON%\common.bat :get_key "%VIRTUAL_CONF_FILE%" "%_distrib%" "PACKER_PREBUILD_CALLBACK"
	call %STELLA_COMMON%\common.bat :get_key "%VIRTUAL_CONF_FILE%" "%_distrib%" "PACKER_POSTBUILD_CALLBACK"

	call %STELLA_COMMON%\common.bat :get_key "%VIRTUAL_CONF_FILE%" "%_distrib%" "VAGRANT_BOX_NAME"
	call %STELLA_COMMON%\common.bat :get_key "%VIRTUAL_CONF_FILE%" "%_distrib%" "VAGRANT_BOX_FILENAME"
	call %STELLA_COMMON%\common.bat :get_key "%VIRTUAL_CONF_FILE%" "%_distrib%" "VAGRANT_BOX_URI"
	call %STELLA_COMMON%\common.bat :get_key "%VIRTUAL_CONF_FILE%" "%_distrib%" "VAGRANT_BOX_URI_PROTOCOL"
	call %STELLA_COMMON%\common.bat :get_key "%VIRTUAL_CONF_FILE%" "%_distrib%" "VAGRANT_BOX_OUTPUT_DIR"

	call %STELLA_COMMON%\common.bat :get_key "%VIRTUAL_CONF_FILE%" "%_distrib%" "VAGRANT_BOX_USERNAME"
	call %STELLA_COMMON%\common.bat :get_key "%VIRTUAL_CONF_FILE%" "%_distrib%" "VAGRANT_BOX_PASSWORD"

goto :eof

:_prebuilt_boot2docker
	%VAGRANT_CMD% up
	%VAGRANT_CMD% ssh -c "cd /vagrant && sudo ./build-iso.sh"
	%VAGRANT_CMD% destroy --force
goto :eof

:_import_box_into_vagrant
	set "_BOX_NAME=%~1"
	set "_BOX_FILEPATH=%~2"

	if exist "%_BOX_FILEPATH%" (
		%VAGRANT_CMD% box add %_BOX_NAME% "%_BOX_FILEPATH%"
		echo ** Box imported into vagrant under name %_BOX_NAME%
	) else (
		echo ** ERROR : Box %_BOX_FILEPATH% does not exist
	)
goto :eof

:: TODO do we need this ? vagrant init do this
:_create_vagrantfile
	set "VAGRANT_FILEPATH=%VIRTUAL_ENV_ROOT%\%VM_ENV_NAME%\Vagrantfile"

	> %VAGRANT_FILEPATH% echo(VAGRANTFILE_API_VERSION = "2"
	>> %VAGRANT_FILEPATH% echo(Vagrant.configure(VAGRANTFILE_API_VERSION^) do ^|config^|
	>> %VAGRANT_FILEPATH% echo(		config.vm.box = "%VAGRANT_BOX_NAME%"
	>> %VAGRANT_FILEPATH% echo(		config.vm.synced_folder "%STELLA_ROOT:\=/%", "/home/vagrant/lib-stella" >> Vagrantfile
	>> %VAGRANT_FILEPATH% echo(		config.vm.synced_folder "%APP_ROOT:\=/%", "/home/vagrant/%APP_NAME%" >> Vagrantfile
	>> %VAGRANT_FILEPATH% echo(		config.vm.synced_folder "%CACHE_DIR:\=/%", "/home/vagrant/%APP_NAME%-CACHE" >> Vagrantfile
	>> %VAGRANT_FILEPATH% echo(		config.vm.synced_folder "%PROJECT_ROOT:\=/%", "/home/vagrant/%APP_NAME%-WORK" >> Vagrantfile
	>> %VAGRANT_FILEPATH% echo(		config.vm.provider :virtualbox do ^|vb^|
	>> %VAGRANT_FILEPATH% echo(			vb.gui = %VM_HEADLESS%
	>> %VAGRANT_FILEPATH% echo(			vb.name = "%VM_ENV_NAME%"
	>> %VAGRANT_FILEPATH% echo(			vb.customize ["modifyvm", :id, "--memory", %ENV_MEM%]
	REM >> %VAGRANT_FILEPATH% echo(			vb.customize ["modifyvm", :id, "--vram", 8]
	>> %VAGRANT_FILEPATH% echo(			vb.customize ["modifyvm", :id, "--cpus", %ENV_CPU%]
	REM >> %VAGRANT_FILEPATH% echo(			vb.customize ["modifyvm", :id, "--cpuexecutioncap", 100]
	>> %VAGRANT_FILEPATH% echo(		end
	>> %VAGRANT_FILEPATH% echo(		["vmware_fusion", "vmware_workstation"].each do ^|vmware^|
	>> %VAGRANT_FILEPATH% echo(			config.vm.provider :vmware do ^|v^|
	>> %VAGRANT_FILEPATH% echo(				v.gui = %VM_HEADLESS%
	>> %VAGRANT_FILEPATH% echo(				v.vmx["memsize"] = %ENV_MEM%
	>> %VAGRANT_FILEPATH% echo(				v.vmx["numvcpus"] = %ENV_CPU%
	>> %VAGRANT_FILEPATH% echo(			end
	>> %VAGRANT_FILEPATH% echo(		end
	>> %VAGRANT_FILEPATH% echo(end

goto :eof

REM ------------------------------------ ADMINISTRATION OF BOX WITH PACKER -----------------------
:: get a prebuilt box
:get_box
	if "%VAGRANT_BOX_URI%"=="" (
		echo ** Error We do not have any URL for a prebuilt box corresponding to this distribution
		goto :eof
	)
	if "%FORCE%"=="1" (
		del /f /q /s "%CACHE_DIR%\%VAGRANT_BOX_FILENAME%"
	)
	call %STELLA_COMMON%\common.bat :get_ressource "%DISTRIB%" "%VAGRANT_BOX_URI%" "%VAGRANT_BOX_URI_PROTOCOL%" "%CACHE_DIR%"
	call :_import_box_into_vagrant %VAGRANT_BOX_NAME% "%CACHE_DIR%\%VAGRANT_BOX_FILENAME%"
goto :eof


:list_box
	%VAGRANT_CMD% box list
goto :eof

:create_box
	if "%PACKER_TEMPLATE%"=="" (
		echo ** Error please select a distribution
		goto :eof
	)

	echo ** Packing a vagrant box for %VIRTUAL_DEFAULT_HYPERVISOR% with Packer
		
	if "%FORCE%"=="1" (
		del /f /q /s "%CACHE_DIR%\%VAGRANT_BOX_FILENAME%"
	)

	if not "%PACKER_TEMPLATE_URI_PROTOCOL%"=="_INTERNAL_" (
		call %STELLA_COMMON%\common.bat :get_ressource %DISTRIB% %PACKER_TEMPLATE_URI% %PACKER_TEMPLATE_URI_PROTOCOL% "%VIRTUAL_TEMPLATE_ROOT%\%DISTRIB%"
		set "PACKER_TEMPLATE_URI=%VIRTUAL_TEMPLATE_ROOT%\%DISTRIB%\%PACKER_TEMPLATE%"
	) else (
		set "PACKER_TEMPLATE_URI=%VIRTUAL_INTERNAL_TEMPLATE_ROOT%\%PACKER_TEMPLATE_URI%\%PACKER_TEMPLATE%"
	)
	
	for %%A in ( %PACKER_TEMPLATE% ) do set PACKER_TEMPLATE=%%~nxA
	for %%A in ( %PACKER_TEMPLATE_URI% ) do set PACKER_TEMPLATE_URI=%%~dpA

	set "VAGRANT_BOX_OUTPUT_DIR=%PACKER_TEMPLATE_URI%\%VAGRANT_BOX_OUTPUT_DIR%"


	if not exist "%CACHE_DIR%\%VAGRANT_BOX_FILENAME%" (
		cd /D "%PACKER_TEMPLATE_URI%"

		if not "%PACKER_PREBUILD_CALLBACK%"=="" call :%PACKER_PREBUILD_CALLBACK%
		set PACKER_PREBUILD_CALLBACK=

		%PACKER_CMD% validate -only=%PACKER_BUILDER% %PACKER_TEMPLATE%
		%PACKER_CMD% build -only=%PACKER_BUILDER% %PACKER_TEMPLATE%

		if not "%PACKER_POSTBUILD_CALLBACK%"=="" call :%PACKER_POSTBUILD_CALLBACK%
		set PACKER_POSTBUILD_CALLBACK=

		copy_folder_content_into "%VAGRANT_BOX_OUTPUT_DIR%" "%CACHE_DIR%" "*.box"
		xcopy /q /y /e /i "%VAGRANT_BOX_OUTPUT_DIR%\*.box" "%CACHE_DIR%\"
		del /f /q /s "%VAGRANT_BOX_OUTPUT_DIR%\*.box"

		if exist "%CACHE_DIR%\%VAGRANT_BOX_FILENAME%" (
			echo ** Box created
		)
	) else (
		echo ** Box already created
	)

	call :_import_box_into_vagrant %VAGRANT_BOX_NAME% "%CACHE_DIR%\%VAGRANT_BOX_FILENAME%"
goto :eof




REM ------------------------------------ ADMINISTRATION OF ENV WITH VAGRANT -----------------------

:list_env
	%VAGRANT_CMD% global-status
goto :eof

:info_env
	if "%VM_ENV_NAME%"=="" (
		echo ** ERROR Please specify an env name
		goto :eof
	)

	cd /D "%VIRTUAL_ENV_ROOT%\%VM_ENV_NAME%"
	%VAGRANT_CMD% status
	%VAGRANT_CMD% ssh-config
goto :eof


:create_env
	if "%VM_ENV_NAME%"=="" (
		echo ** ERROR Please specify an env name
		goto :eof
	)

	if "%VAGRANT_BOX_NAME%"=="" (
		echo ** Error please select a distribution
		goto :eof
	)

	if "%FORCE%"=="1" (
		call :destroy_env
	)

	if exist "%VIRTUAL_ENV_ROOT%\%VM_ENV_NAME%" (
		echo ** Env %VM_ENV_NAME% already exist
		
	) else (

		:: Re importing box into vagrant in case of
		if exist "%CACHE_DIR%\%VAGRANT_BOX_FILENAME%" (
			call :_import_box_into_vagrant %VAGRANT_BOX_NAME% "%CACHE_DIR%\%VAGRANT_BOX_FILENAME%"
		)

		if not exist "%VIRTUAL_ENV_ROOT%\%VM_ENV_NAME%" mkdir "%VIRTUAL_ENV_ROOT%\%VM_ENV_NAME%"
		
		cd /D  "%VIRTUAL_ENV_ROOT%\%VM_ENV_NAME%"
		call :_create_vagrantfile
		REM %VAGRANT_CMD% init %VAGRANT_BOX_NAME%

		echo ** Env %VM_ENV_NAME% is initialized

	)
	
goto :eof


:destroy_env
	if exist "%VIRTUAL_ENV_ROOT%\%VM_ENV_NAME%" (
		cd /D "%VIRTUAL_ENV_ROOT%\%VM_ENV_NAME%"
		%VAGRANT_CMD% destroy -f
		cd /D "%VIRTUAL_ENV_ROOT%"
		call %STELLA_COMMON%\common.bat :del_folder "%VIRTUAL_ENV_ROOT%\%VM_ENV_NAME%"
		echo ** Env %VM_ENV_NAME% is destroyed
	)
goto :eof


:stop_env
	if "%VM_ENV_NAME%"=="" (
		echo ** ERROR Please specify an env name
		goto :eof
	)
	if not exist "%VIRTUAL_ENV_ROOT%\%VM_ENV_NAME%" (
		echo ** ERROR Env %VM_ENV_NAME% does not exist
		goto :eof
	)

	cd /D "%VIRTUAL_ENV_ROOT%\%VM_ENV_NAME%"
	%VAGRANT_CMD% halt

	echo ** Env %VM_ENV_NAME% is stopped

goto :eof

:run_env
	if "%VM_ENV_NAME%"=="" (
		echo ** ERROR Please specify an env name
		goto :eof
	)
	if not exist "%VIRTUAL_ENV_ROOT%\%VM_ENV_NAME%" (
		echo ** ERROR Env %VM_ENV_NAME% does not exist
		goto :eof
	)

	cd /D "%VIRTUAL_ENV_ROOT%\%VM_ENV_NAME%"
	%VAGRANT_CMD% up --provider %VIRTUAL_DEFAULT_HYPERVISOR%

	echo ** Env %VM_ENV_NAME% is running
	call :info_env

	echo ** Now you can CD into "%VIRTUAL_ENV_ROOT%\%VM_ENV_NAME%"
	echo ** and do 'vagrant ssh'
	if "%-l%"=="1" (
		call %STELLA_COMMON%\common.bat :bootstrap_env "%VM_ENV_NAME%" "%VIRTUAL_ENV_ROOT%\%VM_ENV_NAME%"
		echo ** You should type 'vagrant ssh' in the new opened command line to get into your VM
	)
goto :eof

:end
echo ** END **
cd /D %_CURRENT_RUNNING_DIR%
@echo on
@endlocal
