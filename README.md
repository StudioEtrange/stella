# Stella

Stella is a collection of tools, libraries and a framework for command line application.
It supports Nix (including MacOS) and Windows platform, and provide usefull tools and functions for bash and batch application




## Nix - Standalone installation

	curl -sSL https://raw.githubusercontent.com/StudioEtrange/stella/master/nix/pool/stella-bridge.sh | bash -s -- standalone [stella folder]

## Nix - Bootstrap an application

As a library or tools collection inside your project

	cd your_project
	curl -sSL https://raw.githubusercontent.com/StudioEtrange/stella/master/nix/pool/stella-bridge.sh | bash -s -- bootstrap [stella folder]


## Windows - Standalone installation

	
	powershell -Command "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/StudioEtrange/stella/master/win/pool/stella-bridge.bat', 'stella-bridge.bat')" && stella-bridge.bat standalone & del /q stella-bridge.bat
	

## Windows - Bootstrap an application

	cd your_project
	powershell -Command "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/StudioEtrange/stella/master/win/pool/stella-bridge.bat', 'stella-bridge.bat')" && stella-bridge.bat bootstrap & del /q stella-bridge.bat
