**WARNING : not stable**

**For now, the code really really needs to be cleaned, more unit test, and documentation**

# Stella

Stella is a collection of tools, libraries and a framework for command line application, environment management or sandboxing.

Main idea is to provide a simple way to create an isolated environment for you application. Every dependencies reside inside a single folder. Nothing is installed on the system. And you do not need sudo/root permissions.

Just declare your dependencies, from stella recipes, and stella will download, build and/or install them. Stella set also your environment right for each dependencies.

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


## Tested Platforms

Mainly tested platforms are :

* Ubuntu
* RedHat / Centos
* MacOs
* Windows 7 / 10



## License

Copyright 2013-2016 Sylvain Boucault @ StudioEtrange

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
