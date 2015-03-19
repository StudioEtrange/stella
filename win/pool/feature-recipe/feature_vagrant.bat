@echo off
call %*
goto :eof



:feature_vagrant
	set "FEAT_NAME=vagrant"
	set "FEAT_LIST_SCHEMA=git/source"
	set "FEAT_DEFAULT_VERSION=git"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=source"
goto :eof


:feature_vagrant_git
	set "FEAT_VERSION=git"

	set "FEAT_SOURCE_URL=https://github.com/mitchellh/vagrant/archive/master.zip"
	set "FEAT_SOURCE_URL_FILENAME=vagrant-git-master.zip"
	set FEAT_SOURCE_PATCH_CALLBACK=
	set FEAT_BINARY_URL=
	set FEAT_BINARY_URL_FILENAME=
	set FEAT_BINARY_CALLBACK=

	REM TODO need ruby need redevkit2
	set FEAT_DEPENDENCIES=
	set "FEAT_INSTALL_ROOT=!FEAT_INSTALL_ROOT!\bin\vagrant"
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\vagrant"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"

	set FEAT_BUNDLE_LIST=
goto :eof



:_call_vagrant_from_git
	call %STELLA_COMMON%\common-feature.bat :feature_info vagrant#git/source
	set "BUNDLE_GEMFILE=!FEAT_INSTALL_ROOT!\Gemfile"
	call bundle exec vagrant %*
	set BUNDLE_GEMFILE=
goto :eof



