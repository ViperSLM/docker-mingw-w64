# MinGW-W64 Docker Image (32-bit Windows only)
This Docker image builds a [mingw-w64][] toolchain which can target 32-bit Windows via Ubuntu 20.04

The following software is built from source:
* [pkg-config][] v0.29.2
* [cmake][] v3.21.3
* [binutils][] v2.37
* [mingw-w64][] v9.0.0
* [gcc][] v11.2.0

Extra binaries:

* extra Ubuntu packages: `wget`, `patch`, `bison`, `flex`, `yasm`, `make`, `ninja`, `meson`, `zip`, `dos2unix`.

Binaries that are custom built are installed into `/usr/local` which will have a prefix associated with it.

(`i686-w64-mingw32` for 32-bit)

This image also contains [pkg-config][] specifically compiled for this toolchain (prefixed) which looks for packages in the toolchain's root folder. 

# Building
To build this docker image, type in the following command while inside the repository:

    docker build -t [Image name] .

Note that the build process may take a while, depending on your computer's speed (The more CPU cores, the better),
to complete as it is compiling the i686 toolchain so maybe find something to do or grab yourself a drink as you wait out
the time.

Append [Image name] with a name you want to choose for the image. (e.g. mingw)

# Usage
There are many ways on how you can use this Docker image. You can use it to directly execute
gcc/g++ (or make, etc.) to cross-compile applications

Examples:

    docker run -ti --rm -v `"${PWD}":/mnt` [Image] i686-w64-mingw32-gcc test.c

For builds that use autotools, append the following arguments:

32-bit (i686):

    --prefix=${MINGW_R} \
    --host=${MINGW} \

For builds that use CMake, you can supply the included toolchain by appending this argument:

32-bit (i686):

    -DCMAKE_TOOLCHAIN_FILE=${MINGW_R}/toolchain.cmake

Alternatively, if you prefer to manually set the settings yourself or if a CMake project doesn't properly process a line or two, you can add the following arguments:

32-bit (i686):
    
    -DCMAKE_SYSTEM_NAME=Windows \
    -DCMAKE_SYSTEM_PROCESSOR=i686 \
    -DCMAKE_INSTALL_PREFIX=${MINGW_R} \
    -DCMAKE_FIND_ROOT_PATH=${MINGW_R} \
    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
    -DCMAKE_C_COMPILER=${MINGW}-gcc \
    -DCMAKE_CXX_COMPILER=${MINGW}-g++ \
    -DCMAKE_RC_COMPILER=${MINGW}-windres \

# FindDLL Shell Script
This shell script lists down required DLL files the specified executable needs.

For 32-bit executables (Shows up as PE32 via the file command):
	`finddll [.exe]`

[pkg-config]: https://www.freedesktop.org/wiki/Software/pkg-config/
[cmake]: https://cmake.org/
[binutils]: https://www.gnu.org/software/binutils/
[mingw-w64]: https://mingw-w64.org/
[gcc]: https://gcc.gnu.org/
