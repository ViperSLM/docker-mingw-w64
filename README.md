# MinGW-W64 Docker Image (Dual Architectures)
This Docker image builds a [mingw-w64][] toolchain which can target either 32-bit or 64-bit Windows via Ubuntu 20.04
(64-bit toolchain not implemented yet!)


The following software is built from source:
* [pkg-config][] v0.29.2
* [cmake][] v3.21.3
* [binutils][] v2.37
* [mingw-w64][] v9.0.0
* [gcc][] v11.2.0

Extra binaries:

* extra Ubuntu packages: `wget`, `patch`, `bison`, `flex`, `yasm`, `make`, `ninja`, `meson`, `zip`, `dos2unix`.

Binaries that are custom built are installed into '/usr/local' which will have a prefix associated with it (i686-w64-mingw32 for 32-bit, x86_64-w64-mingw32 for 64-bit)
This image also contains [pkg-config][] specifically compiled for both toolchains (prefixed) which looks for packages in either toolchain's root folder. 

# Building
To build this docker image, type in the following command while inside the repository:

    docker build -t [Image name] .

Append [Image name] with a name you want to choose for the image. (e.g. mingw)

# Usage
There are many ways on how you can use this Docker image. You can use it to directly execute
gcc/g++ or make, etc to cross-compile applications

Example: `docker run -ti --rm -v '${PWD}:/mnt' [Image] i686-w64-mingw32-gcc test.c`

For builds that use autotools, add the following arguments:

    --prefix=${MINGW} \
    --host=x86_64-w64-mingw32 \

For builds that use CMake, you can supply the included toolchain by adding the following argument:

    -DCMAKE_TOOLCHAIN_FILE=/usr/local/i686-w64-mingw32/toolchain.cmake

Alternatively, if you prefer to manually set the settings yourself or if a CMake project doesn't properly process a line or two, you can add the following arguments:

    -DCMAKE_SYSTEM_NAME=Windows \
    -DCMAKE_SYSTEM_PROCESSOR=AMD64 \
    -DCMAKE_INSTALL_PREFIX=${MINGW} \
    -DCMAKE_FIND_ROOT_PATH=${MINGW} \
    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
    -DCMAKE_C_COMPILER=x86_64-w64-mingw32-gcc \
    -DCMAKE_CXX_COMPILER=x86_64-w64-mingw32-g++ \
    -DCMAKE_RC_COMPILER=x86_64-w64-mingw32-windres \

# FindDLL Shell Script
This shell script lists down required DLL files the specified executable needs.

For 32-bit executables (Shows up as PE32 via the file command):
	`finddll [.exe]`

For 64-bit executables (Shows up as PE32+ via the file command):
	`finddll_64 [.exe]`

[pkg-config]: https://www.freedesktop.org/wiki/Software/pkg-config/
[cmake]: https://cmake.org/
[binutils]: https://www.gnu.org/software/binutils/
[mingw-w64]: https://mingw-w64.org/
[gcc]: https://gcc.gnu.org/
[nasm]: https://nasm.us/
[nvcc]: https://docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html
