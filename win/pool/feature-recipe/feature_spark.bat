@echo off
call %*
goto :eof


:feature_spark
	set "FEAT_NAME=spark"
	set "FEAT_LIST_SCHEMA=1_3_0_HADOOP_2_4/binary 1_3_1_HADOOP_2_4/binary"
	set "FEAT_DEFAULT_VERSION=1_3_1_HADOOP_2_4"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof

:feature_spark_1_3_0_HADOOP_2_4
	set "FEAT_VERSION=1_3_0_HADOOP_2_4"

	set "FEAT_SOURCE_URL="
	set "FEAT_SOURCE_URL_FILENAME="
	set "FEAT_SOURCE_CALLBACK="	
	set "FEAT_BINARY_URL=http://d3kbcqa49mib13.cloudfront.net/spark-1.3.0-bin-hadoop2.4.tgz"
	set "FEAT_BINARY_URL_FILENAME=spark-1.3.0-bin-hadoop2.4.tgz"
	set "FEAT_BINARY_CALLBACK="

	REM embed his own scala version
	set "FEAT_DEPENDENCIES="
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\spark-shell"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin;!FEAT_INSTALL_ROOT!\sbin"
	set "FEAT_ENV="
	
	set "FEAT_BUNDLE_LIST="
goto :eof

:feature_spark_1_3_1_HADOOP_2_4
	set "FEAT_VERSION=1_3_1_HADOOP_2_4"

	set "FEAT_SOURCE_URL="
	set "FEAT_SOURCE_URL_FILENAME="
	set "FEAT_SOURCE_CALLBACK="
	set "FEAT_BINARY_URL=http://d3kbcqa49mib13.cloudfront.net/spark-1.3.1-bin-hadoop2.4.tgz"
	set "FEAT_BINARY_URL_FILENAME=spark-1.3.1-bin-hadoop2.4.tgz"
	set "FEAT_BINARY_CALLBACK="

	REM embed his own scala version
	set "FEAT_DEPENDENCIES="
	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\spark-shell"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin;!FEAT_INSTALL_ROOT!\sbin"
	set "FEAT_ENV="
	
	set "FEAT_BUNDLE_LIST="
goto :eof

:feature_spark_install_binary
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set "SRC_DIR="
	set "BUILD_DIR="

	call %STELLA_COMMON%\common.bat :download_uncompress "%FEAT_BINARY_URL%" "%FEAT_BINARY_URL_FILENAME%" "%INSTALL_DIR%" "DEST_ERASE STRIP"
		
goto :eof

