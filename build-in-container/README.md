# Build-in-container
The build-in-container tool provides a developer tool to quickly build Mariner packages. It is easy-to-use, and distribution and platform agnostic. It sets up a build environment in an expedient manner using a container.

Please install docker on your system before using the tool.

## Usage
The mariner-docker-builder.sh script presents these options <br />
<pre>
  -t                        creates container image <br />
  -b                        creates container, builds specs under [mariner_dir]/SPECS/, & places output under [mariner_dir]/out/ <br />
  -i                        creates an interactive Mariner build container <br />
  -c                        cleans up Mariner workspace at [mariner_dir], container images and instances <br />
  --help                    shows help on usage <br />

Optional arguments <br />
  --mariner_dir             directory to use for Mariner artifacts (SPECS, toolkit, ..). Default is the current directory <br />
  --RPM_repo_file           Path(s) to custom repo file(s) (must end in .repo). Please see [here](./README.md#sample-custom-repo) for sample custom repo file. Provide multiple files with space (" ") as delimiter. Please prefer RPM_repo_file over RPM_container_URL. <br />
  --RPM_container_URL       URL(s) of Azure blob storage container(s) to install RPMs from. Provide multiple URLs with space (" ") as delimiter <br />
  --disable_mariner_repo    disable default setting to use default Mariner package repos on packages.microsoft.com <br />
</pre>

- 'tool_dir' refers to the directory of the build-in-container tool <br/>
- 'mariner_dir' refers to the directory with Mariner artifacts (SPECS, toolkit, etc.) <br/>
- If mariner_dir is provided, it will be used for all Mariner artifacts like toolkit, SPECS, build, out and logs. Else, current directory will be used. <br />
- Place specs to build under $mariner_dir/SPECS/ <br />
- Please find SPEC sample [here](./../SPECS/hello_world_demo/) <br />
- The output from the build will be available under $mariner_dir/out/ (RPMS and SRPMS) <br />
- Logs are published under $mariner_dir/logs/ <br />

``` bash
# Setup the container for 1st use
./CBL-MarinerTutorials/build-in-container/mariner-docker-builder.sh -t
# Build `SPECS/**/*.spec` automatically
./CBL-MarinerTutorials/build-in-container/mariner-docker-builder.sh -b
ls CBL-MarinerTutorials/build-in-container/out/RPMS/x86_64/
# hello_world_demo-1.0.0-2.cm2.x86_64.rpm  hello_world_demo-debuginfo-1.0.0-2.cm2.x86_64.rpm

# Invoke the toolkit directly
./CBL-MarinerTutorials/build-in-container/mariner-docker-builder.sh -i
#  Run the tools manually
make build-packages SRPM_PACK_LIST="hello_world_demo" -j$(nproc)

# Clean up Mariner workspace, and docker image and container. This requires root privileges
sudo ./CBL-MarinerTutorials/mariner-docker-builder.sh --mariner_dir /path/to/CBL-Mariner -c

# Use optional arguments
## Provide path to Mariner directory. If this option is not used, the current directory is treated as Mariner directory
./CBL-MarinerTutorials/build-in-container/mariner-docker-builder.sh -i --mariner_dir /path/to/CBL-Mariner/

## Install RPMs from a custom repo, by providing path to .repo file
## Please ensure that custom repo file ends in '.repo' as per requirements of rpm/yum/tdnf/dnf
## Provide multiple paths with space (" ") as delimiter
./CBL-MarinerTutorials/build-in-container/mariner-docker-builder.sh -i --RPM_repo_file "path/to/custom-repo-file.repo[ path/to/another-custom-repo-file.repo]"

## Install RPMs from an Azure blob-storage container storing custom RPMs, by providing URL of the container
## Provide multiple URLs with space (" ") as delimiter
./CBL-MarinerTutorials/build-in-container/mariner-docker-builder.sh -i --RPM_container_URL "https://az-storage-account.blob.core.windows.net/az-container/[ https://az-storage-account.blob.core.windows.net/another-az-container/]"

## Disable default setting to use default Mariner package repos on packages.microsoft.com
./CBL-MarinerTutorials/build-in-container/mariner-docker-builder.sh -i --disable_mariner_repo

```

## Details on what goes on inside the container:
### Creating container image
'create-container.sh' creates an image that the docker can use to launch the Mariner build container. It downloads a Mariner2.0 container image, and makes suitable modifications to it. The output image is tagged as 'mcr.microsoft.com/mariner-container-build:2.0'

### Running container in the specified mode
'run-container.sh' starts a docker container using the image produced in Step(1).

In the _build_ mode, it sets up the Mariner build system inside the container, builds all the specs under $mariner_dir/SPECS/ and outputs to $mariner_dir/out/.

In the _interactive_ mode, it sets up the Mariner build system inside the container, and starts the container at /mariner/toolkit/. The user can invoke Mariner `make` commands to build packages, images and more. Please see the [section](README.md#sample-make-commands) for sample `make` commands, and visit [Mariner Docs](https://github.com/microsoft/CBL-Mariner/blob/2.0/toolkit/docs/building/building.md) for the complete set of commands.

### Helper scripts

- 'scripts/setup.sh' installs the required pacakges, downloads the Mariner toolkit from GitHub (if missing), downloads Mariner2.0 toolchain RPMs, and sets up the environment variables required for Mariner builds.

- 'scripts/build.sh' The build starts with cloning the Mariner GitHub repository, and downloading the toolchain. Using the tools from Mariner toolkit, it reads the spec files under SPECS/, installs the build dependepdencies, builds the specs and packages them into an RPM. Each pacakge is built inside a chroot environment.

## Advantages:
- It is convenient and fast for developement environment
- It gives the user an option to build Mariner without having to go into the details of the build system

## Disadvantages:
- The number of chroots is limited to 12
- It is using chroot jails inside containers, and containers are known to be slow

## Sample make commands:
`make build-packages -j$(nproc)` would build specs under SPECS/ and populate out/ with the built SRPMs and RPMs

## Sample custom repo: (custom-repo.repo)
``` bash
[custom-repo]
name=Custom Repo
baseurl=https://<IP Address>
enabled=1
gpgcheck=0
skip_if_unavailable=False
sslverify=0
```
