[1mdiff --git a/conf.bat b/conf.bat[m
[1mindex f358e15..0327436 100644[m
[1m--- a/conf.bat[m
[1m+++ b/conf.bat[m
[36m@@ -96,7 +96,7 @@[m [mset "NPM=npm"[m
 [m
 [m
 :: FEATURE LIST ---------------------------------------------[m
[31m-set "__STELLA_FEATURE_LIST=msys2 miniconda fasttext wsusoffline rust tcpview libsquish bzip2 diffutils jpeg curl libogg mode-export freetype libpng zlib git docker-swarm socat nginx mingw-w64 go-build-chain go-crosscompile-chain go docker-bundle docker docker-machine oracle-jdk maven spark nikpeviewer dependencywalker conemu goconfig-cli ninja jom cmake packer perl ruby rubydevkit nasm python vagrant openssh wget unzip sevenzip patch make"[m
[32m+[m[32mset "__STELLA_FEATURE_LIST=ioccc-2014-deak msys2 miniconda fasttext wsusoffline rust tcpview libsquish bzip2 diffutils jpeg curl libogg mode-export freetype libpng zlib git docker-swarm socat nginx mingw-w64 go-build-chain go-crosscompile-chain go docker-bundle docker docker-machine oracle-jdk maven spark nikpeviewer dependencywalker conemu goconfig-cli ninja jom cmake packer perl ruby rubydevkit nasm python vagrant openssh wget unzip sevenzip patch make"[m[41m[m
 [m
 :: SYS PACKAGE --------------------------------------------[m
 :: list of available installable system package[m
[1mdiff --git a/win/common/common-build.bat b/win/common/common-build.bat[m
[1mindex a672dbc..f689b00 100644[m
[1m--- a/win/common/common-build.bat[m
[1m+++ b/win/common/common-build.bat[m
[36m@@ -65,22 +65,24 @@[m [mgoto :eof[m
 :: TOOLSET & BUILD TOOLS ----------------[m
 :: Available tools :[m
 :: 	CONFIG_TOOL : cmake, configure[m
[31m-:: 	BUILD_TOOL : nmake, ninja, jom, mingw-make, make[m
[31m-:: 	COMPIL_FRONTEND :  cl, gcc, mingw-gcc[m
[32m+[m[32m:: 	BUILD_TOOL : nmake, ninja, jom, mingw-make, msys-make, msys-mingw-make[m[41m[m
[32m+[m[32m:: 	COMPIL_FRONTEND :  cl, mingw-gcc, msys-gcc, msys-mingw-gcc[m[41m[m
 ::						in reality COMPIL_FRONTEND should be called COMPIL_DRIVER[m
 ::[m
 ::[m
 :: Available preconfigured build toolset on windows system :[m
 :: 	TOOLSET 		| CONFIG TOOL 				| BUILD TOOL 							| COMPIL FRONTEND[m
 ::	MS				|	cmake					|		nmake							|			cl[m
[31m-:: 	MSYS2			| 	configure				|		make							|			gcc[m
[31m-::	MINGW-W64		| 	NULL					|		mingw-make						|		( cl OR gcc ?) (default?)[m
[32m+[m[32m:: 	MSYS2			| 	configure				|		msys-mingw-make ?				|			msys-mingw-gcc ?[m[41m[m
[32m+[m[32m::	MINGW-W64		| 	NULL					|		mingw-make						|		mingw-gcc (default?)[m[41m[m
 :: NONE ===> disable build toolset and all tools[m
 [m
 :: TODO : MSYS2 TOOLSET[m
 ::		make AND gcc are installed from pacman : bundle : mingw64/mingw-w64-x86_64-toolchain or mingw32/mingw-w64-i686-toolchain[m
[31m-::				we do not use make/gcc versions from msys2, but from mingw-w64 inside msys2[m
[32m+[m[32m::				we do not use msys/make nor msys/gcc versions from msys2 (whose rely on msys2.dll), but from mingw-w64 inside msys2[m[41m[m
 ::				WARN : bundle mingw-w64-x86_64-toolchain install a lot of binaries which may generate conflicts (ex:python)[m
[32m+[m[32m::				NOTE : activate a mingw env when using msys2_shell.cmd ? https://www.booleanworld.com/get-unix-linux-environment-windows-msys2/[m[41m[m
[32m+[m[32m::					   in the same way as vs_env_vars function[m[41m[m
 :: MINGW-W64 TOOLSET[m
 ::		make AND gcc are part of default mingw-w64 env[m
 [m
[1mdiff --git a/win/common/common.bat b/win/common/common.bat[m
[1mindex 7ddbc4d..9d1c61b 100644[m
[1m--- a/win/common/common.bat[m
[1m+++ b/win/common/common.bat[m
[36m@@ -700,6 +700,16 @@[m [mgoto :eof[m
 			)[m
 		)[m
 [m
[32m+[m		[32mif "!EXTENSION!"==".bz2" ([m[41m[m
[32m+[m			[32mfor %%C in ( !_FILENAME! ) do set _FILENAME_BIS=%%~nC[m[41m[m
[32m+[m			[32mfor %%D in ( !_FILENAME_BIS! ) do set EXTENSION_BIS=%%~xD[m[41m[m
[32m+[m			[32mif "!EXTENSION_BIS!"==".tar" ([m[41m[m
[32m+[m				[32m"%SEVENZIP%" x "%FILE_PATH%" -y -so | "%SEVENZIP%" x -y -aoa -si -ttar -o"%UNZIP_DIR%"[m[41m[m
[32m+[m			[32m) else ([m[41m[m
[32m+[m				[32m"%SEVENZIP%" x "%FILE_PATH%" -y -o"%UNZIP_DIR%"[m[41m[m
[32m+[m			[32m)[m[41m[m
[32m+[m		[32m)[m[41m[m
[32m+[m[41m[m
 		if "!EXTENSION!"==".xz" ([m
 			for %%C in ( !_FILENAME! ) do set _FILENAME_BIS=%%~nC[m
 			for %%D in ( !_FILENAME_BIS! ) do set EXTENSION_BIS=%%~xD[m
[36m@@ -741,6 +751,15 @@[m [mgoto :eof[m
 				"%SEVENZIP%" x "%FILE_PATH%" -y -o"%STELLA_APP_TEMP_DIR%\%_FILENAME%"[m
 			)[m
 		)[m
[32m+[m		[32mif "!EXTENSION!"==".bz2" ([m[41m[m
[32m+[m			[32mfor %%C in ( !_FILENAME! ) do set _FILENAME_BIS=%%~nC[m[41m[m
[32m+[m			[32mfor %%D in ( !_FILENAME_BIS! ) do set EXTENSION_BIS=%%~xD[m[41m[m
[32m+[m			[32mif "!EXTENSION_BIS!"==".tar" ([m[41m[m
[32m+[m				[32m"%SEVENZIP%" x "%FILE_PATH%" -y -so | "%SEVENZIP%" x -y -aoa -si -ttar -o"%STELLA_APP_TEMP_DIR%\%_FILENAME%"[m[41m[m
[32m+[m			[32m) else ([m[41m[m
[32m+[m				[32m"%SEVENZIP%" x "%FILE_PATH%" -y -o"%STELLA_APP_TEMP_DIR%\%_FILENAME%"[m[41m[m
[32m+[m			[32m)[m[41m[m
[32m+[m		[32m)[m[41m[m
 		if "!EXTENSION!"==".xz" ([m
 			for %%C in ( !_FILENAME! ) do set _FILENAME_BIS=%%~nC[m
 			for %%D in ( !_FILENAME_BIS! ) do set EXTENSION_BIS=%%~xD[m
[1mdiff --git a/win/pool/feature-recipe/feature_msys2.bat b/win/pool/feature-recipe/feature_msys2.bat[m
[1mindex 89f8095..52d2a60 100644[m
[1m--- a/win/pool/feature-recipe/feature_msys2.bat[m
[1m+++ b/win/pool/feature-recipe/feature_msys2.bat[m
[36m@@ -23,7 +23,9 @@[m [mREM 		 a MINGW-W64 32 bits package (windows native) [ name : mingw32/mingw-w64-i[m
 [m
 [m
 REM MINGW-W64 is a native gcc tool chain for windows[m
[31m-REM MSYS2 vs MINGW-W64 : https://sourceforge.net/p/msys2/discussion/general/thread/dcf8f4d3/#8473/588e[m
[32m+[m[32mREM MSYS2 vs MINGW-W64 :[m[41m [m
[32m+[m[32mREM			https://sourceforge.net/p/msys2/discussion/general/thread/dcf8f4d3/#8473/588e[m
[32m+[m[32mREM			https://www.booleanworld.com/get-unix-linux-environment-windows-msys2/[m
 [m
 :feature_msys2[m
 	set "FEAT_NAME=msys2"[m
[36m@@ -68,5 +70,5 @@[m [mgoto :eof[m
 :feature_msys2_install_binary[m
 	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_BINARY_URL!" "!FEAT_BINARY_URL_PROTOCOL!" "!FEAT_INSTALL_ROOT!" "STRIP"[m
 	:: update catalog[m
[31m-	"!FEAT_INSTALL_ROOT!\msys2_shell.cmd" -where "!FEAT_INSTALL_ROOT!" -c "pacman -Sy"[m
[32m+[m	[32m"!FEAT_INSTALL_ROOT!\msys2_shell.cmd" -where "!FEAT_INSTALL_ROOT!" -c "HTTP_PROXY=!http_proxy! HTTPS_PROXY=!https_proxy! http_proxy=!http_proxy! https_proxy=!https_proxy! no_proxy=!no_proxy! pacman -Sy"[m
 goto :eof[m
