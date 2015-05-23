if [ ! "$_ORACLEJDK_INCLUDED_" == "1" ]; then 
_ORACLEJDK_INCLUDED_=1




# Recipe for Oracle Java SE Development Kit


function feature_oracle-jdk() {
	FEAT_NAME=oracle-jdk
	FEAT_LIST_SCHEMA="8u45@x86/binary 8u45@x64/binary 7u80@x86/binary 7u80@x64/binary"
	FEAT_DEFAULT_VERSION=8u45
	FEAT_DEFAULT_ARCH=x64
	FEAT_DEFAULT_FLAVOUR=binary
}

function feature_oraclesejdk_env() {
	export JAVA_HOME=$FEAT_INSTALL_ROOT
}



function feature_oracle-jdk_8u45() {
	FEAT_VERSION=8u45

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_CALLBACK=
	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		FEAT_BINARY_URL_x64="http://download.oracle.com/otn-pub/java/jdk/8u45-b15/jdk-8u45-windows-x64.exe"
		FEAT_BINARY_URL_FILENAME_x64=jdk-8u45-windows-x64.exe
		FEAT_BINARY_URL_x86="http://download.oracle.com/otn-pub/java/jdk/8u45-b15/jdk-8u45-windows-i586.exe"
		FEAT_BINARY_URL_FILENAME_86=jdk-8u45-windows-i586.exe
	fi

	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		FEAT_BINARY_URL_x64="http://download.oracle.com/otn-pub/java/jdk/8u45-b14/jdk-8u45-macosx-x64.dmg"
		FEAT_BINARY_URL_FILENAME_x64=jdk-8u45-macosx-x64.dmg
		FEAT_BINARY_URL_x86=
		FEAT_BINARY_URL_FILENAME_86=
	fi

	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/bin/java"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT/bin"
	FEAT_ENV=feature_oraclesejdk_env
	
	FEAT_BUNDLE_LIST=
}

function feature_oracle-jdk_7u80() {
	FEAT_VERSION=7u80

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_CALLBACK=
	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		FEAT_BINARY_URL_x64="http://download.oracle.com/otn-pub/java/jdk/7u80-b15/jdk-7u80-linux-x64.tar.gz"
		FEAT_BINARY_URL_FILENAME_x64=jdk-7u80-linux-x64.tar.gz
		FEAT_BINARY_URL_x86="http://download.oracle.com/otn-pub/java/jdk/7u80-b15/jdk-7u80-linux-i586.tar.gz"
		FEAT_BINARY_URL_FILENAME_86=jdk-7u80-linux-i586.tar.gz
	fi


	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST=$FEAT_INSTALL_ROOT/bin/java
	FEAT_SEARCH_PATH=$FEAT_INSTALL_ROOT/bin
	FEAT_ENV=feature_oraclesejdk_env
	
	FEAT_BUNDLE_LIST=
}




function feature_oracle-jdk_install_binary() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR=
	BUILD_DIR=

	if [ ! -f "$STELLA_APP_CACHE_DIR/$FEAT_BINARY_URL_FILENAME" ]; then

		if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
			wget --no-cookies --no-check-certificate --header Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie "$FEAT_BINARY_URL" -O "$STELLA_APP_CACHE_DIR%/$FEAT_BINARY_URL_FILENAME"
			__uncompress "$STELLA_APP_CACHE_DIR/$FEAT_BINARY_URL_FILENAME" "$FEAT_INSTALL_ROOT" "DEST_ERASE"
		fi
		if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
			curl -j -k -S -L -H "Cookie: oraclelicense=accept-securebackup-cookie; oraclelicense=accept-securebackup-cookie" -o "$STELLA_APP_CACHE_DIR/$FEAT_BINARY_URL_FILENAME" "$FEAT_BINARY_URL"
		fi
	fi

}


fi