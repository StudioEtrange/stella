@echo off
call %*
goto :eof



:feature_vagrant
	set "FEAT_NAME=vagrant"
	set "FEAT_LIST_SCHEMA=snapshot:source"
	set "FEAT_DEFAULT_VERSION=snapshot"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=source"
goto :eof


:feature_vagrant_snapshot
	set "FEAT_VERSION=snapshot"

	REM TODO need ruby need rubydevkit2
	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set "FEAT_SOURCE_URL=https://github.com/mitchellh/vagrant/archive/master.zip"
	set "FEAT_SOURCE_URL_FILENAME=vagrant-git-master.zip"
	set "FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP"

	set FEAT_BINARY_URL=
	set FEAT_BINARY_URL_FILENAME=
	set FEAT_BINARY_URL_PROTOCOL=
	
	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	REM set "FEAT_INSTALL_ROOT=!FEAT_INSTALL_ROOT!\bin\vagrant"
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\vagrant"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"


goto :eof


:feature_vagrant_install_source
	call %STELLA_COMMON%\common.bat :get_resource "vagrant" "!FEAT_SOURCE_URL!" "!FEAT_SOURCE_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "DEST_ERASE STRIP FORCE_NAME !FEAT_SOURCE_URL_FILENAME!"
goto :eof


:_call_vagrant_from_git
	call %STELLA_COMMON%\common-feature.bat :feature_catalog_info vagrant#snapshot:source
	set "BUNDLE_GEMFILE=!FEAT_INSTALL_ROOT!\Gemfile"
	call bundle exec vagrant %*
	set BUNDLE_GEMFILE=
goto :eof



