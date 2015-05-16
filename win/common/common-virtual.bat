@echo off
call %*
goto :eof

:_virtual_init_folder
	if not exist "%VIRTUAL_WORK_ROOT%" mkdir "%VIRTUAL_WORK_ROOT%"
	if not exist "%VIRTUAL_ENV_ROOT%" mkdir "%VIRTUAL_ENV_ROOT%"
	if not exist "%VIRTUAL_TEMPLATE_ROOT%" mkdir "%VIRTUAL_TEMPLATE_ROOT%"
goto :eof



:_set_matrix
	set "_distrib=%~1"

	set PACKER_TEMPLATE=
	set PACKER_TEMPLATE_URI=
	set PACKER_TEMPLATE_URI_PROTOCOL=
	set PACKER_BUILDER=
	set PACKER_PREBUILD_CALLBACK=
	set PACKER_POSTBUILD_CALLBACK=
	set VAGRANT_BOX_NAME=
	set VAGRANT_BOX_FILENAME=
	set VAGRANT_BOX_URI=
	set VAGRANT_BOX_URI_PROTOCOL=
	set VAGRANT_BOX_OUTPUT_DIR=
	set VAGRANT_BOX_USERNAME=
	set VAGRANT_BOX_PASSWORD=

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



:__prebuilt_boot2docker
	%VAGRANT_CMD% up
	%VAGRANT_CMD% ssh -c "cd /vagrant && sudo ./build-iso.sh"
	%VAGRANT_CMD% destroy --force
goto :eof

REM ------------------------------------ ADMINISTRATION OF ENV WITH VAGRANT -----------------------

:list_env
	%VAGRANT_CMD% global-status
goto :eof

:info_env
	set "_env_id=%~1"
	if "%_env_id%"=="" (
		echo ** ERROR Please specify an env id
		goto :eof
	)

	cd /D "%VIRTUAL_ENV_ROOT%\%_env_id%"
	%VAGRANT_CMD% status
	%VAGRANT_CMD% ssh-config
goto :eof

REM ARG3 : option
REM	HEAD : hypervisor with gui ON (default OFF)
REM	MEM XXXX : size of memory in Mo
REM	CPU XX : nb of cpu
:create_env
	set "_env_id=%~1"
	set "_distrib_id=%~2"
	set "_opt=%~3"

	set _opt_head=OFF
	set _flag_mem=OFF
	set _flag_cpu=OFF
	set _mem=
	set _cpu=
	for %%O in (%_opt%) do (
		if "!_flag_mem!"=="ON" (
			set _mem=%%O
			set _flag_mem=ON
		)
		if "!_flag_cpu!"=="ON" (
			set _cpu=%%O
			set _flag_cpu=ON
		)
		if "%%O"=="HEAD" set _opt_head=ON
		if "%%O"=="MEM" set _flag_mem=ON
		if "%%O"=="CPU" set _flag_cpu=ON
	)

	if "%_env_id%"=="" (
		echo ** ERROR Please specify an env id
		goto :eof
	)

	call :_set_matrix %_distrib_id%

	if "%VAGRANT_BOX_NAME%"=="" (
		echo ** Error please select a distribution id
		goto :eof
	)

	call :_virtual_init_folder

	if "%FORCE%"=="1" (
		call :destroy_env %_env_id%
	)

	if exist "%VIRTUAL_ENV_ROOT%\%_env_id%" (
		echo ** Env %_env_id% already exist
		
	) else (

		:: Re importing box into vagrant in case of
		if exist "%STELLA_APP_CACHE_DIR%\%VAGRANT_BOX_FILENAME%" (
			call :_import_box_into_vagrant %VAGRANT_BOX_NAME% "%STELLA_APP_CACHE_DIR%\%VAGRANT_BOX_FILENAME%"
		)

		if not exist "%VIRTUAL_ENV_ROOT%\%_env_id%" mkdir "%VIRTUAL_ENV_ROOT%\%_env_id%"
		
		cd /D  "%VIRTUAL_ENV_ROOT%\%_env_id%"
		REM TODO call vagrant init ?
		REM %VAGRANT_CMD% init %VAGRANT_BOX_NAME%
		set "VAGRANT_FILEPATH=%VIRTUAL_ENV_ROOT%\%_env_id%\Vagrantfile"

		> %VAGRANT_FILEPATH% echo(VAGRANTFILE_API_VERSION = "2"
		>> %VAGRANT_FILEPATH% echo(Vagrant.configure(VAGRANTFILE_API_VERSION^) do ^|config^|
		>> %VAGRANT_FILEPATH% echo(		config.vm.box = "%VAGRANT_BOX_NAME%"
		>> %VAGRANT_FILEPATH% echo(		config.vm.synced_folder "%STELLA_ROOT:\=/%", "/home/vagrant/lib-stella" >> Vagrantfile
		>> %VAGRANT_FILEPATH% echo(		config.vm.synced_folder "%STELLA_APP_ROOT:\=/%", "/home/vagrant/%STELLA_APP_NAME%" >> Vagrantfile
		>> %VAGRANT_FILEPATH% echo(		config.vm.synced_folder "%STELLA_APP_CACHE_DIR:\=/%", "/home/vagrant/%STELLA_APP_NAME%-CACHE" >> Vagrantfile
		>> %VAGRANT_FILEPATH% echo(		config.vm.synced_folder "%STELLA_APP_WORK_ROOT:\=/%", "/home/vagrant/%STELLA_APP_NAME%-WORK" >> Vagrantfile
		>> %VAGRANT_FILEPATH% echo(		config.vm.provider :virtualbox do ^|vb^|
		>> %VAGRANT_FILEPATH% echo(			vb.gui = %VM_HEADLESS%
		>> %VAGRANT_FILEPATH% echo(			vb.name = "%_env_id%"
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


		echo ** Env %_env_id% is initialized

	)
	
goto :eof


:run_env
	set "_env_id=%~1"
	set "_login_into=%~2"

	if "%_env_id%"=="" (
		echo ** ERROR Please specify an env id
		goto :eof
	)

	call :_virtual_init_folder

	if not exist "%VIRTUAL_ENV_ROOT%\%_env_id%" (
		echo ** ERROR Env %_env_id% does not exist
		goto :eof
	)

	cd /D "%VIRTUAL_ENV_ROOT%\%_env_id%"
	%VAGRANT_CMD% up --provider %VIRTUAL_DEFAULT_HYPERVISOR%

	echo ** Env %_env_id% is running
	call :info_env

	echo ** Now you can CD into "%VIRTUAL_ENV_ROOT%\%_env_id%"
	echo ** and do 'vagrant ssh'
	if "%_login_into%"=="TRUE" (
		call %STELLA_COMMON%\common.bat :bootstrap_env "%_env_id%" "%VIRTUAL_ENV_ROOT%\%_env_id%"
		echo ** You should type 'vagrant ssh' in the new opened command line to get into your VM
	)
goto :eof

:destroy_env
	set "_env_id=%~1"

	if exist "%VIRTUAL_ENV_ROOT%\%_env_id%" (
		cd /D "%VIRTUAL_ENV_ROOT%\%_env_id%"
		%VAGRANT_CMD% destroy -f
		cd /D "%VIRTUAL_ENV_ROOT%"
		call %STELLA_COMMON%\common.bat :del_folder "%VIRTUAL_ENV_ROOT%\%_env_id%"
		echo ** Env %_env_id% is destroyed
	)
goto :eof


:stop_env
	set "_env_id=%~1"

	if "%_env_id%"=="" (
		echo ** ERROR Please specify an env id
		goto :eof
	)

	call :_virtual_init_folder

	if not exist "%VIRTUAL_ENV_ROOT%\%_env_id%" (
		echo ** ERROR Env %_env_id% does not exist
		goto :eof
	)

	cd /D "%VIRTUAL_ENV_ROOT%\%_env_id%"
	%VAGRANT_CMD% halt

	echo ** Env %_env_id% is stopped

goto :eof


:: TODO review mounted folder
:: TODO do we need this ? vagrant init do this
:_create_vagrantfile
	set "_env_id=%~1"

	set "VAGRANT_FILEPATH=%VIRTUAL_ENV_ROOT%\%_env_id%\Vagrantfile"

	> %VAGRANT_FILEPATH% echo(VAGRANTFILE_API_VERSION = "2"
	>> %VAGRANT_FILEPATH% echo(Vagrant.configure(VAGRANTFILE_API_VERSION^) do ^|config^|
	>> %VAGRANT_FILEPATH% echo(		config.vm.box = "%VAGRANT_BOX_NAME%"
	>> %VAGRANT_FILEPATH% echo(		config.vm.synced_folder "%STELLA_ROOT:\=/%", "/home/vagrant/lib-stella" >> Vagrantfile
	>> %VAGRANT_FILEPATH% echo(		config.vm.synced_folder "%STELLA_APP_ROOT:\=/%", "/home/vagrant/%STELLA_APP_NAME%" >> Vagrantfile
	>> %VAGRANT_FILEPATH% echo(		config.vm.synced_folder "%STELLA_APP_CACHE_DIR:\=/%", "/home/vagrant/%STELLA_APP_NAME%-CACHE" >> Vagrantfile
	>> %VAGRANT_FILEPATH% echo(		config.vm.synced_folder "%STELLA_APP_WORK_ROOT:\=/%", "/home/vagrant/%STELLA_APP_NAME%-WORK" >> Vagrantfile
	>> %VAGRANT_FILEPATH% echo(		config.vm.provider :virtualbox do ^|vb^|
	>> %VAGRANT_FILEPATH% echo(			vb.gui = %VM_HEADLESS%
	>> %VAGRANT_FILEPATH% echo(			vb.name = "%_env_id%"
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

:list_distrib
	set "%~1=%__STELLA_DISTRIB_LIST%"
goto :eof

:: get a prebuilt box
:get_box
	set "_distrib_id=%~1"

	call :_set_matrix %_distrib_id%

	if "%VAGRANT_BOX_URI%"=="" (
		echo ** Error We do not have any URL for a prebuilt box corresponding to this distribution
		goto :eof
	)
	if "%FORCE%"=="1" (
		del /f /q "%STELLA_APP_CACHE_DIR%\%VAGRANT_BOX_FILENAME%"
	)
	call %STELLA_COMMON%\common.bat :get_resource "%_distrib_id%" "%VAGRANT_BOX_URI%" "%VAGRANT_BOX_URI_PROTOCOL%" "%STELLA_APP_CACHE_DIR%"
	call :_import_box_into_vagrant %VAGRANT_BOX_NAME% "%STELLA_APP_CACHE_DIR%\%VAGRANT_BOX_FILENAME%"
goto :eof


:list_box
	%VAGRANT_CMD% box list
goto :eof

:create_box
	set "_distrib_id=%~1"

	call :_set_matrix %_distrib_id%

	if "%PACKER_TEMPLATE%"=="" (
		echo ** Error please select a distribution
		goto :eof
	)

	echo ** Packing a vagrant box for %VIRTUAL_DEFAULT_HYPERVISOR% with Packer
		
	if "%FORCE%"=="1" (
		del /f /q "%STELLA_APP_CACHE_DIR%\%VAGRANT_BOX_FILENAME%"
	)

	if not "%PACKER_TEMPLATE_URI_PROTOCOL%"=="_INTERNAL_" (
		call %STELLA_COMMON%\common.bat :get_resource %DISTRIB% %PACKER_TEMPLATE_URI% %PACKER_TEMPLATE_URI_PROTOCOL% "%VIRTUAL_TEMPLATE_ROOT%\%DISTRIB%"
		set "PACKER_TEMPLATE_URI=%VIRTUAL_TEMPLATE_ROOT%\%DISTRIB%\%PACKER_TEMPLATE%"
	) else (
		set "PACKER_TEMPLATE_URI=%VIRTUAL_INTERNAL_TEMPLATE_ROOT%\%PACKER_TEMPLATE_URI%\%PACKER_TEMPLATE%"
	)
	
	for %%A in ( %PACKER_TEMPLATE% ) do set PACKER_TEMPLATE=%%~nxA
	for %%A in ( %PACKER_TEMPLATE_URI% ) do set PACKER_TEMPLATE_URI=%%~dpA

	set "VAGRANT_BOX_OUTPUT_DIR=%PACKER_TEMPLATE_URI%\%VAGRANT_BOX_OUTPUT_DIR%"


	if not exist "%STELLA_APP_CACHE_DIR%\%VAGRANT_BOX_FILENAME%" (
		cd /D "%PACKER_TEMPLATE_URI%"

		if not "%PACKER_PREBUILD_CALLBACK%"=="" call :%PACKER_PREBUILD_CALLBACK%
		set PACKER_PREBUILD_CALLBACK=

		%PACKER_CMD% validate -only=%PACKER_BUILDER% %PACKER_TEMPLATE%
		%PACKER_CMD% build -only=%PACKER_BUILDER% %PACKER_TEMPLATE%

		if not "%PACKER_POSTBUILD_CALLBACK%"=="" call :%PACKER_POSTBUILD_CALLBACK%
		set PACKER_POSTBUILD_CALLBACK=

		call %STELLA_COMMON%\common.bat :copy_folder_content_into "%VAGRANT_BOX_OUTPUT_DIR%" "%STELLA_APP_CACHE_DIR%" "*.box"
		xcopy /q /y /e /i "%VAGRANT_BOX_OUTPUT_DIR%\*.box" "%STELLA_APP_CACHE_DIR%\"
		del /f /q "%VAGRANT_BOX_OUTPUT_DIR%\*.box"

		if exist "%STELLA_APP_CACHE_DIR%\%VAGRANT_BOX_FILENAME%" (
			echo ** Box created
		)
	) else (
		echo ** Box already created
	)

	call :_import_box_into_vagrant %VAGRANT_BOX_NAME% "%STELLA_APP_CACHE_DIR%\%VAGRANT_BOX_FILENAME%"
goto :eof





