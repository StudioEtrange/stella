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

* Manually install :

	apt-get -y install mercurial unzip p7zip-full git wget
	apt-get -y install bison util-linux build-essential gcc-multilib g++-multilib g++ pkg-config

### MacOS requirements

* Auto install :

	./stella.sh stella install dep

* Manually installed : 

Install HomeBrew [HomeBrew website](http://brew.sh)

	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

Install some brew formulas

	brew install gnu-getopt p7zip
