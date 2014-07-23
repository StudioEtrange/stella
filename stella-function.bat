@echo off
call %*
goto :eof


:STELLA_is_path_abs
	echo XX %*
	call %STELLA_COMMON% :is_path_abs %*
goto :eof