# Stella

Stella is a collection of tools, libraries and a framework for command line application.
It supports Nix (including MacOS) and Windows platform, and provide usefull tools and functions for bash and batch application.

On Nix systems, Stella try to run on any bash system with no dependencies. It does not change your operating system and do not require sudo/root. Platforms mainly tested are Ubuntu, MacOs, Centos and  Alpine.

On Windows, stella have the same features in batch. Platform mainly tested is Windows 7.

The only dependencies you will need is a standard build system if you want to install a package from source. And Stella can help you too install it (even on windows)

It includes
* a package manager (120+ recipes) - see available recipe in nix/pool/feature-recipe or win/pool/feature-recipe
* app system - you can declare nested dependencies of your app, auto build/install them, maintain properties
* a full build system (make, autotools, cmake, ninja, ...) - can turn binary into portable, tweak dependencies
* features to deploy/execute code remotely (ssh) and "cloudly" (vagrant/docker)
* a bunch of bash/batch functions through an API

For now, the code really needs to be cleaned ! And more unit test to be written ! And documentation too !

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

## Installation

### Nix - Standalone installation

	curl -sSL https://raw.githubusercontent.com/StudioEtrange/stella/master/nix/pool/stella-bridge.sh | bash -s -- standalone [stella folder]

## Nix - Bootstrap a brand new application

As a library or tools collection inside your project

	cd your_project
	curl -sSL https://raw.githubusercontent.com/StudioEtrange/stella/master/nix/pool/stella-bridge.sh | bash -s -- bootstrap [stella folder]


### Nix - Bootstrap an existing application built with stella

	cd your_project
	./stella-link.sh bootstrap


### Windows - Standalone installation


	powershell -Command "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/StudioEtrange/stella/master/win/pool/stella-bridge.bat', 'stella-bridge.bat')" && stella-bridge.bat standalone & del /q stella-bridge.bat


### Windows - Bootstrap a brand new application

	cd your_project
	powershell -Command "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/StudioEtrange/stella/master/win/pool/stella-bridge.bat', 'stella-bridge.bat')" && stella-bridge.bat bootstrap & del /q stella-bridge.bat


### Windows - Bootstrap an existing application built with stella

	cd your_project
	stella-link.bat bootstrap


## Requirements

_NOTE : You dont really need this, because all previous installation methods will install requirements_

### Windows requirements

* Auto install :

	stella.bat stella install dep

### Ubuntu/Debian requirements

* Auto install :

	./stella.sh stella install dep

### MacOS requirements

* Auto install :

	./stella.sh stella install dep
