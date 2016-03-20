@echo off
call %*
goto :eof

REM https://www.rust-lang.org
REM TODO MSVC builds of Rust additionally require an installation of Visual Studio 2013 (or later) so rustc can use its linker. 

:feature_rust
	set "FEAT_NAME=rust"
	set "FEAT_LIST_SCHEMA=1_7_0_MSVC@x64:binary 1_7_0_MSVC@x86:binary 1_7_0_GNU@x64:binary 1_7_0_GNU@x86:binary"
	set "FEAT_DEFAULT_VERSION=1_7_0_GNU"
	set "FEAT_DEFAULT_ARCH=x64"
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_rust_1_7_0_MSVC
	set "FEAT_VERSION=1_7_0_MSVC"


	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=
	
	set "FEAT_BINARY_URL_x64=https://static.rust-lang.org/dist/rustc-1.7.0-x86_64-pc-windows-msvc.tar.gz"
	set "FEAT_BINARY_URL_FILENAME_x64=rustc-1.7.0-x86_64-pc-windows-msvc.tar.gz"
	set FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP
	set "FEAT_BINARY_URL_x86=https://static.rust-lang.org/dist/rustc-1.7.0-i686-pc-windows-msvc.tar.gz"
	set "FEAT_BINARY_URL_FILENAME_x86=rustc-1.7.0-i686-pc-windows-msvc.tar.gz"
	set FEAT_BINARY_URL_PROTOCOL_x86=HTTP_ZIP

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\rust.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"
goto :eof






:feature_rust_1_7_0_GNU
	set "FEAT_VERSION=1_7_0_GNU"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=
	
	set "FEAT_BINARY_URL_x64=https://static.rust-lang.org/dist/rustc-1.7.0-x86_64-pc-windows-gnu.tar.gz"
	set "FEAT_BINARY_URL_FILENAME_x64=rustc-1.7.0-x86_64-pc-windows-gnu.tar.gz"
	set FEAT_BINARY_URL_PROTOCOL_x64=HTTP_ZIP
	set "FEAT_BINARY_URL_x86=https://static.rust-lang.org/dist/rustc-1.7.0-i686-pc-windows-gnu.tar.gz"
	set "FEAT_BINARY_URL_FILENAME_x86=rustc-1.7.0-i686-pc-windows-gnu.tar.gz"
	set FEAT_BINARY_URL_PROTOCOL_x86=HTTP_ZIP

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\rustc\bin\rustc.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\rustc\bin"
goto :eof


:feature_rust_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "STRIP FORCE_NAME !FEAT_BINARY_URL_FILENAME!"
goto :eof


