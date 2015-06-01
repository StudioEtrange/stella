@echo off
call %*
goto :eof


:feature_spark
	set "FEAT_NAME=spark"
	set "FEAT_LIST_SCHEMA=1_3_0_HADOOP_2_4:binary 1_3_1_HADOOP_2_4:binary"
	set "FEAT_DEFAULT_VERSION=1_3_1_HADOOP_2_4"
	set FEAT_DEFAULT_ARCH=
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_get_win_binaries_HADOOP_2_4
	call %STELLA_COMMON%\common.bat :get_resource "HADOOP 2.4 windows binaries" "http://github.com/Zutai/HadoopOnWindows/archive/master.zip" "HTTP_ZIP" "!FEAT_INSTALL_ROOT!\winbin" "DEST_ERASE STRIP FORCE_NAME win_binaries_hadoop24.zip"
	call %STELLA_COMMON%\common.bat :copy_folder_content_into "!FEAT_INSTALL_ROOT!\winbin\NativeDllAndExe" "!FEAT_INSTALL_ROOT!\bin"
goto:eof

:feature_env_hadoop
	set "HADOOP_HOME=!FEAT_INSTALL_ROOT!"
goto:eof

:feature_spark_1_3_0_HADOOP_2_4
	set "FEAT_VERSION=1_3_0_HADOOP_2_4"

	REM embed his own scala version
	set FEAT_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL=http://d3kbcqa49mib13.cloudfront.net/spark-1.3.0-bin-hadoop2.4.tgz"
	set "FEAT_BINARY_URL_FILENAME=spark-1.3.0-bin-hadoop2.4.tgz"
	set "FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP"
	
	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=feature_get_win_binaries_HADOOP_2_4
	set FEAT_ENV_CALLBACK=feature_env_hadoop

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\spark-shell"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin;!FEAT_INSTALL_ROOT!\sbin"
goto :eof

:feature_spark_1_3_1_HADOOP_2_4
	set "FEAT_VERSION=1_3_1_HADOOP_2_4"

	REM embed his own scala version
	set FEAT_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set "FEAT_BINARY_URL=http://d3kbcqa49mib13.cloudfront.net/spark-1.3.1-bin-hadoop2.4.tgz"
	set "FEAT_BINARY_URL_FILENAME=spark-1.3.1-bin-hadoop2.4.tgz"
	set "FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP"

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=feature_get_win_binaries_HADOOP_2_4
	set FEAT_ENV_CALLBACK=feature_env_hadoop
	
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\spark-shell"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin;!FEAT_INSTALL_ROOT!\sbin"
goto :eof

:feature_spark_install_binary
	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "DEST_ERASE STRIP"
	
	call %STELLA_COMMON%\common-feature :feature_callback

goto :eof



