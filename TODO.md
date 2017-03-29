TODO

NOTE :
NIX RECIPE inspiration
* nixos (https://github.com/NixOS/nixpkgs)
* homebrew (https://github.com/Homebrew/homebrew-core)
* 0install (http://0install.net/)
* rudix (http://rudix.org/)
WIN RECIPE inspiration
* bluego (https://bitbucket.org/Vertexwahn/bluego)
mingw-w64 RECIPE :
* http://www.gaia-gis.it/spatialite-3.0.0-BETA/mingw64_how_to.html

msys2 + mingw-w64 RECIPES :
* https://github.com/Alexpux/MINGW-packages
* https://github.com/Alexpux/MSYS2-packages

# NOTE : homebrew flag setting system : https://github.com/Homebrew/homebrew/blob/master/Library/Homebrew/extend/ENV/super.rb


# NOTE update screenFetch
    rm -Rf nix/pool/artefact/screenFetch
    cd nix/pool/artefact
    git clone https://github.com/KittyKatt/screenFetch

## DEVENV

* Shellcheck -- https://github.com/koalaman/shellcheck

in Atom Editor

  ```
    brew install shellcheck
    apm install linter
    apm install linter-shellcheck
  ```

use
  `spellcheck stella.sh`

* checkbashisms

```
  brew install checkbashisms
  apm install linter
  apm install linter-checkbashisms
```

* shell code style guideline

in shell

  ```
    pip install bashate
  ```

use
  `bashate stella.sh`

[ ] nix : color & style
https://odb.github.io/shml/
[ ] nix : explore https://github.com/alebcay/awesome-shell
[ ] nix : shell framework https://github.com/shellfire-dev/shellfire
[ ] Update README
  [ ] history : FIRST PUSH OF stella pre version : https://bitbucket.org/StudioEtrange/ryzomcore-script/src/1308706a1dc3f1dde7d65b048e9b16f2a2f2f518

[ ] nix : bash-lib : https://github.com/aks/bash-lib
[ ] COMMENTS code
[ ] Format output (log system)
[ ] Test and remove DEST_ERASE in each feature_recipe : cause problem when bundled in merge mode. But only for binary ? keep it for source? only when get binary

[ ] Test and fix path with space
[ ] win : function require
[ ] function get_resource : change option STRIP to option NO_STRIP. STRIP will be by default if possible
[ ] win : review link feature library and lib isolation
[ ] win : portable mode review copy dependencies
[ ] win add recipes for these libs :
https://ryzomcore.atlassian.net/wiki/display/RC/MinGW+External+Libraries
https://ryzomcore.atlassian.net/wiki/display/RC/Create+External+Libs

[ ] win : build mingw-w64 compiler from source https://github.com/niXman/mingw-builds
[ ] nix : replace each echo informative message (not return string function) with log() call
[ ] Default build arch equivalent to current cpu arch ? (and change option name buildarch with forcearch) (set STELLA_BUILD_ARCH_DEFAULT)
[ ] feature system : FEAT_DEFAULT_ARCH must be fill with current cpu arch
[ ] feature built from source must pick an arch and be installed in a folder with version@arch -- buildarch option should be remove -- by default built arch should be current cpu arch
[ ] win : replace patch from gnuwin32 (pb with UAC)
[ ] nix : FORCE_RENAME on link_feature_library (see windows implementation)
[X] win : check library dynamic dependencies - use dependencywalker in console mode ? use dumpbin http://stackoverflow.com/a/475323 ? use CMAKE GetPrerequisites. FINISH check_linked_lib.cmake use it with cmake -P check_linked_lib.cmake -DMY_BINARY_LOCATION=<path>
[ ] nix : when ckecking dependencies dynamic -- print all libs
[ ] add possibility of a last step before/after install, to do some test like make test or make check (i.e : for gmp lib)
[ ] win : sys_install_vs2015community => this chocolatey recipe do not install all VC Tools by default
[ ] stella-env file : make it local or global with an option ?
[ ] "no_proxy" should be in stella-env file
[ ] proxy values in stella-env should be local or global
[X] win : link-app : add option to align workspace/cache path (like on nix)



[ ] ssh : launch stella app through ssh
https://thornelabs.net/2013/08/21/simple-ways-to-send-multiple-line-commands-over-ssh.html
http://stackoverflow.com/questions/4412238/whats-the-cleanest-way-to-ssh-and-run-multiple-commands-in-bash
http://tldp.org/LDP/abs/html/here-docs.html
http://stackoverflow.com/questions/305035/how-to-use-ssh-to-run-shell-script-on-a-remote-machine
SSHFS ? cache delivering only via HTTP ?

[ ] win : harmonization of internal recipe (patch, unzip, wget, ...)


[ ] configuration step for each feature recipe
    nix : use augeas https://github.com/hercules-team/augeas ? -- see ryba ? (nodejs) -- use simple sed ?
    win : ?

[ ] turn stella/nix/common/* folder into module ?
    module/core
    module/feature
    module/app
    module/boot

[ ] unit test : app/test/nix app/text/win
    nix : bats
    win : ?

[ ] speed up grep http://applocator.blogspot.fr/2013/10/speed-up-bash-scripts-that-use-grep.html

[ ] ryzom nix : openal, libgnu_regex (?), libmysql, lua51, lua52, luabind, stlport (?)
https://github.com/Shopify/homebrew-shopify/blob/master/mysql-client.rb
https://github.com/Homebrew/homebrew-core/blob/master/Formula/mysql.rb

[ ] macos : download homebrew binary (but special build and should depend on brew installed library ?) https://homebrew.bintray.com/bottles/libzip-1.0.1.el_capitan.bottle.tar.gz

[ ] portable feature installation : embedded all dependencies,including system ?

[ ] distinguish PATH env for current stella app with PATH from stella in 2 variable, and give the possibility to retrieve them in a separate way

[ ] win/nix : remove FORCE global option, add it as option for each function

[ ] change proxyport, proxyhost, proxyuser, proxypassword in stella.sh command line as a unique arg --proxy=uri, and use __uri_parse

[ ] download cache folder : first lookup in APP CACHE FOLDER, then in STELLA CACHE FOLDER. Linux [X] Win [ ]

[ ] shadow features : rename temporary some folder to deactivate features ? (for example, different build tools, to select the right one) or use symlink in case of build tools

[X] win : remove bin/ folder

[ ] nix : when using __link_feature_library with option FORCE_STATIC, there should be no rpath setted path, because lib is statically linked - no need of an internal registerd search path (=rpath)

[ ] lib parse binary https://github.com/soluwalana/pefile-go

[ ] progress bar :
http://stackoverflow.com/questions/238073/how-to-add-a-progress-bar-to-a-shell-script
https://github.com/dspinellis/pmonitor
http://stackoverflow.com/a/238140/5027535
https://gist.github.com/unhammer/b0ab6a6aa8e1eeaf236b
https://github.com/edouard-lopez/progress-bar.sh
http://stackoverflow.com/a/16348366/5027535
dtruss/strace : https://www.reddit.com/r/golang/comments/363dhp/how_do_i_make_go_get_to_display_the_progress_of/
spinner :
http://stackoverflow.com/a/3330834/5027535
https://github.com/marascio/bash-tips-and-tricks/tree/master/showing-progress-with-a-bash-spinner

[ ] git do not support always all options see __git_project_version

[ ] note on bootstrap applications
Bootstrap a brand new application and use stella as a library or tools collection inside your project
NIX :
	cd your_project
	curl -sSL https://raw.githubusercontent.com/StudioEtrange/stella/master/nix/pool/stella-bridge.sh | bash -s -- bootstrap [stella folder]

WIN:
  cd your_project
	powershell -Command "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/StudioEtrange/stella/master/win/pool/stella-bridge.bat', 'stella-bridge.bat')" && stella-bridge.bat bootstrap & del /q stella-bridge.bat

[ ] note on bootstrap a standalone stable stella
NIX
curl -sSL https://raw.githubusercontent.com/StudioEtrange/stella/master/nix/pool/stella-bridge.sh | bash -s -- standalone stella

WIN
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/StudioEtrange/stella/master/win/pool/stella-bridge.bat', 'stella-bridge.bat')" && stella-bridge.bat standalone & del /q stella-bridge.bat

[ ] openal
http://repo.or.cz/openal-soft.git
https://github.com/kcat/openal-soft

[ ] nix : init management detection (systemd, upstart, sysV)
http://unix.stackexchange.com/questions/196166/how-to-find-out-if-a-system-uses-sysv-upstart-or-systemd-initsystem
http://unix.stackexchange.com/questions/18209/detect-init-system-using-the-shell
