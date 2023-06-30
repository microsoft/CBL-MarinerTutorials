# Build-in-container
The build-in-container tool provides a developer tool to quickly build Mariner packages and images. It is easy-to-use, and distribution and platform agnostic. It sets up a build environment in an expedient manner using a container.

Please install docker on your system before using the tool.

## Usage
The run.sh script presents these options
-t      creates container image
-b      creates container, builds Mariner and outputs to out/
-i      create an interactive Mariner build container
-c      cleans up the current workspace
--help  shows help on usage

**Place specs to build under SPECS/**

**The output from the build will be available under out/ (RPMS, SRPMS and images)**

**Logs are published under logs/**

## Details on what goes on inside the container:
### Creating container image
'create-build-container.sh' creates an image that the docker can use to launch the Mariner build container. It downloads a Mariner2.0 container image, and makes suitable modifications to it. The output image is tagged as 'msft/mariner-toolchain:2.0'

### Running container in the specified mode
'mariner-docker-run.sh' starts a docker container using the image produced in Step(1). 

In the _build_ mode, it sets up the Mariner build system inside the container, builds all the specs under SPECS/ and all the images under toolkit/imageconfigs/, and outputs to out/.

In the _interactive_ mode, it sets up the Mariner build system inside the container, and starts the container at /sources/scripts/toolkit/. The user can invoke Mariner `make` commands to build packages, images and more. Please see the [section](https://github.com/microsoft/CBL-MarinerTutorials/tree/main/buildInContainer/build-in-container#sample-make-commands) for sample `make` commands, and visit [Mariner Docs](https://github.com/microsoft/CBL-Mariner/blob/2.0/toolkit/docs/building/building.md) for the complete set of commands. 

### Helper scripts

- 'scripts/setup.sh' installs the required pacakges, downloads the Mariner toolkit from GitHub (if missing), downloads Mariner2.0 toolchain RPMs, and sets up the environment variables required for Mariner builds.

- 'scripts/build.sh' The build starts with cloning the Mariner GitHub repository, and downloading the toolchain. Using the tools from Mariner toolkit, it reads the spec files under SPECS/, installs the build dependepdencies, builds the specs and packages them into an RPM. Each pacakge is built inside a chroot environment. This is achieved by the '

## Advantages:
- It is convenient and fast for developement environment
- It gives the user an option to build Mariner without having to go into the details of the build system

## Disadvantages:
- The number of chroots is limited to 12
- It is using chroot jails inside containers, and containers are known to be slow

## Sample make commands:
`make build-packages -j$(nproc)` would build specs under SPECS/ and populate out/ with the built SRPMs and RPMs

`make image -j$(nproc) REBUILD_TOOLS=n REBUILD_PACKAGES=n CONFIG_FILE=imageconfigs/image-config.json` would build image config under scripts/toolkit/imageconfigs/ and place it under out/
