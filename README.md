# Stella

Stella is a collection of tools, libraries and a framework for command line application.
It supports Nix (including MacOS) and Windows platform, and provide usefull tools and functions for bash and batch application

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


## Advanced Usage

### stella link

* Each stella application have a stella-link file. It is link to a stella version and a stella path. If you want to recreate this file, you should do

-
	./stella/stella.sh app link ./your-app



### Linked or Nested Applications

* If a stella application is launched by another stella application, the second one will automaticly share the stella installation of the first one.

* At launch, a stella application will look for a stella installation according to its stella-link file. But if at this location it found a stella application instead, it will look for a stella installation according to the last one.

* There is an API function link_app that could be use to link a stella application to a specific stella installation (by default to the current one)

_

	from app1.sh :
	$STELLA_API link_app "STELLA_ROOT $STELLA_APP_WORK_ROOT/app2"

Then app2.sh will use the same stella folder than app1.sh

* Two nested or linked stella applications will share the same cache folder. The first running cache stella application will be used.

* From app1 you can use STELLA API functions connected to another app2 (means : in the context of app2)

_

	from app1.sh :
	$STELLA_API api_connect $APP_PATH/app2
	$STELLA_API feature_inspect wget
	$STELLA_API api_disconnect
