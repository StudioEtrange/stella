**WARNING : not stable**

**For now, the code really really needs to be cleaned, more unit test, and documentation**

# Stella

Stella is a collection of tools for command line application, environment management or sandboxing.

Main idea is to provide a simple way to create an isolated environment for you application. Every dependencies reside inside a single folder. Nothing is installed on the system. And you do not need sudo/root permissions.

Just declare your dependencies, from stella recipes, and stella will download, build and/or install them. Stella set also your environment right for each dependencies. Stella act as a package manager.

All you need is internet and git.

Work on Nix/Macos (bash scripts) and Windows systems (bat scripts).

## Features

* A package manager (120+ recipes)
* An app system for dependencies declaration, and isolated environment
* A full integrated build system (make, autotools, cmake, ninja, ...)
* A bunch of bash/bat functions through an API

## Commands

For the whole list of commands use

```
./stella.sh -h
stella.bat -h
```


## Installation

### Easy way : with git

nix system :

```
git clone https://github.com/StudioEtrange/stella
```

windows system :

```
git clone https://github.com/StudioEtrange/stella
stella.bat stella install dep
```

### With git but behind a proxy

nix system :

```
https_proxy="http://my.proxy.com"  http_proxy="http://my.proxy.com" git clone https://github.com/StudioEtrange/stella
```

windows system :

```
set "https_proxy=http://my.proxy.com"
set "http_proxy=http://my.proxy.com"
git clone https://github.com/StudioEtrange/stella
stella.bat stella install dep
```

## Examples

### Installation of a feature

A package is named a 'feature' in stella.
This will download, build and install zlib v1.2.8.


```
./stella.sh feature install zlib#1_2_8
```

### Create a sample app

This will create a folder my_app, and generate some samples inside

```
./stella.sh app init my_app --approot=../my_app --samples
```

### Add a feature to an app

This will install lib jpeg and jq inside your folder app

```
cd my_app
./stella-link.sh feature install jq
```

To use this feature you can use it from your app' shell script (see sample-app.sh) :

```
#!/bin/bash
_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $_CURRENT_FILE_DIR/stella-link.sh include
jq
```

or launch a shell with all your environment variables setted :

```
cd my_app
./stella-link.sh boot shell local
jq
```

## More Usage Examples


You can find in https://github.com/StudioEtrange/stella-app some examples of shell scripts and shell app using Stella

## Tested Platforms

Mainly tested platforms are :

* Ubuntu
* RedHat / Centos
* MacOs
* Windows 7 / 10



## License

Copyright 2013-2017 Sylvain Boucault @ StudioEtrange

	Licensed under the Apache License, Version 2.0 (the "License"); you may not
	use this file except in compliance with the License. You may obtain a copy of
	the License at

	http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
	WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
	License for the specific language governing permissions and limitations under
	the License.

.
