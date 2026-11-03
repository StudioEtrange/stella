# glibc-binary-compat

## Goal

Build and use a custom glibc runtime to run binaries on older Linux systems where the system glibc is too old.

Allow to build a custom glibc (script 1) and patch any binary to use the built glibc by linking to it (script 2).
A typical use case is running recent versions of Node.js on legacy systems such as RHEL/CentOS 7 where the system glibc is tool old for modern Node.js versions.

Another use case is making VS Code Remote SSH work on older Linux systems by ensuring that the Node.js binary bundled with VS Code Server is patched to use the custom glibc runtime. This is done by installing a hook executed at each SSH connection. (script 3)


## Scripts

  1. `build-custom-glibc-runtime.sh` : build a custom glibc runtime. Use `build-custom-glibc-runtime.sh -h` for script help.
  2. `patch-with-custom-glibc.sh` : patch a binary so that is uses the custom glibc runtime. Use `patch-with-custom-glibc.sh -h` for script help.
  3. `install-vscode-server-patch-hook.sh` : install a hook in `$HOME/.ssh/rc` to automatically, at each SSH conection, patch the Node.js binary used by VS Code Server under `$HOME/.vscode-server` (NOTE : at the first VS Code Remote SSH connexion,you may have to reconnect to SSH once again, see STEP 3 below)
  
---

## About VS Code Remote SSH to older linux system
  
VS Code Server needs linux minimal requirements : kernel >= 4.18, glibc >=2.28, libstdc++ >= 3.4.25, binutils >= 2.29
- You could downgrade your VS Code desktop version to match your system : i.e VS Code version 1.96.4 supports glibc 2.17)
- Or use glibc-binary-compat then follow the steps below


### STEP 1 : *Deploy vs code server patch mechanism*

1. connect with SSH to remote host
    ```
    cd $HOME
    git clone https://github.com/StudioEtrange/glibc-binary-compat.git
    ```

2. build custom glibc runtime
  * Set paramaters for your system in script `build-custom-glibc-runtime.sh` headar. Default parameters are suitable for rhel/centos 7 with glibc2.28 with gcc 8.5.0 for kernel 3.10
  * The script will autodownload glibc code source to build it.
    ```
    cd $HOME/glibc-binary-compat
    ./build-custom-glibc-runtime.sh "$HOME/custom-glibc228-runtime" "2.28"
    ```

    * ALTERNATIVE method for 2 :
      * method with distrobox instead of building directly on the host
      * choose an image same family OS/version than the OS to build a glibc compatible with the host
      ```
      distrobox rm buildenv --yes
      distrobox create --image oraclelinux:7.9 --name buildenv --yes
      distrobox enter buildenv
      ```
      * Then inside the distrobox container, you can run this script to build glibc, like above
      ```
      export NB_PROC="5" # By default, value is AUTO to use all your processor at build time
   	  ./build-custom-glibc-runtime.sh $HOME/custom-glibc228-runtime "2.28"
      ```


3. deploy custom glibc runtime
  * copy built version in a shared folder
    ```
    sudo cp -R $HOME/custom-glibc228-runtime /opt
    sudo chmod -R a+rx /opt/custom-glibc228-runtime
    ```

  * clean cache and build folder
    ```
    rm -rf $HOME/.build-custom-glibc-runtime
    ```

4. install a hook to patch vs code server at each SSH connection
    ```
    cd $HOME/glibc-binary-compat
    ./install-vscode-server-patch-hook.sh
    # To uninstall hook use : ./install-vscode-server-patch-hook.sh uninstall
    ```

### STEP 2 : *Tweak some VS Code settings*
  * MANDATORY : VS Code / User Settings / Remote.SSH : uncheck Use Exec Server (OR in settings.json : `"remote.SSH.useExecServer" : false`)

  * If you have error with wget at connection `wget unrecognized option "--no-config"` because wget is too old
    * VS Code / User Settings / Remote.SSH : check Curl And Wget Configuration Files (OR in settings.json : `"remote.SSH.useCurlAndWgetConfigurationFiles" : true`)
    
  * git integration in VS Code may not work if you have an old git version (<2.x) in the PATH of your old linux system, you should update it or provide a new version in settings.json : `"git.path" : "/opt/git/bin/git"`



### STEP 3 : *Connect with SSH Remote to the host*
  * First time and at each new VS Code version you have to connect to the host first and it will fail because VS Code server is not yet patched
    * At this step you could close connection after first attempt to launch vs code server mentionning "GLIBC ERROR"
  * Then connect to the host and the patch will apply


### About VS Code Design Notes & Documentation

* some links :
  * https://code.visualstudio.com/docs/remote/faq#_can-i-run-vs-code-server-on-older-linux-distributions 
  * https://github.com/microsoft/vscode/pull/235232
  * https://github.com/microsoft/vscode/issues/238873

* VS Code server requires a sysroot with glibc 2.28
  * Solutions :
    * Classic build glibc 2.28
    * OR Build glibc using crosstool-NG 
      * crosstool ng configs from https://github.com/microsoft/vscode-linux-build-agent or https://github.com/hsfzxjy/vscode-remote-glibc-patch/tree/master/configs
    * OR Extract a precompiled sysroot from https://github.com/microsoft/vscode-linux-build-agent/releases
* we need patchelf to patch VS Code server binaries (patchelf >=v0.18.x) (https://github.com/NixOS/patchelf)

* about vs code server check requirements at launch : https://github.com/microsoft/vscode/blob/e6e9958f8fc8edd2f509ada8b3cf11f88ac8b06d/resources/server/bin/helpers/check-requirements-linux.sh#L20

* patch method 1 : autopatch method by vs code server based on environment variables  
  * Use environment variable
    ```
    VSCODE_SERVER_CUSTOM_GLIBC_LINKER : path to the dynamic linker (ld-linux.so) in the sysroot (used for --set-interpreter option with patchelf)
    VSCODE_SERVER_CUSTOM_GLIBC_PATH : path to the library locations in the sysroot (used as --set-rpath option with patchelf)
    VSCODE_SERVER_PATCHELF_PATH : path to the patchelf binary on the remote host
    ```
  * But it could be tricky to set these environnment variables at each SSH connection depending on your ssh server config or on your shell. in this case use method 2
  * https://github.com/microsoft/vscode/blob/e6e9958f8fc8edd2f509ada8b3cf11f88ac8b06d/resources/server/bin/code-server-linux.sh#L14
  * https://github.com/hsfzxjy/vscode-remote-glibc-patch

* patch method  2 : apply patch manually with script
  * https://github.com/ziwenhahaha/scripts/blob/master/setup_vscode_patch.sh