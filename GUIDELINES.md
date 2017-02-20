# Unix Coding guidelines

## Targeted Shell

Stella is intended to work at least with `bash`. But we will try to stick when it is possible to `POSIX` shell.


## Guide rules

| avoid  | use | note |
| ------ | --- | ------- |
| ==  | =  ||
| [[ ]] | [ ] | [[ is not POSIX but largely supported across shell. Often it is recommended to use [[  over [. But for now we stick to POSIX |


## Usefull Links

* Tools

http://man.he.net/man1/checkbashisms ===> test portability
https://github.com/duggan/shlint ===> test portability
https://github.com/SublimeLinter/SublimeLinter-shellcheck
http://carlosbecker.com/posts/lint-shell-scripts

* Bash to posix

https://wiki.ubuntu.com/DashAsBinSh
http://mywiki.wooledge.org/Bashism
http://wiki.bash-hackers.org/scripting/obsolete

* Shebang

http://stackoverflow.com/questions/733824/how-to-run-a-shell-script-on-a-unix-console-or-mac-terminal

* Best practices for bash only

https://github.com/progrium/bashstyle