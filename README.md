# MinGW-W64 Docker Image

Builds [mingw-w64][] toolchain in docker for targeting 64-bit Windows from Ubuntu 20.04.

This docker image will contain following software built from source:

* [pkg-config][] v0.29.2
* [cmake][] v3.19.2
* [binutils][] v2.35.1
* [mingw-w64][] v8.0.0
* [gcc][] v10.2.0
* [nasm][] v2.15.02

Extra binaries:

* extra Ubuntu packages: `wget`, `patch`, `bison`, `flex`, `yasm`, `make`, `ninja`, `meson`, `zip`, `vim`, `nano`.
* [nvcc][] v11.2.0

Custom built binaries are installed into `/usr/local` prefix. [pkg-config][] will look for packages in `/mingw` prefix. `nvcc` is available in `/usr/local/cuda/bin` folder.

# Building
To build this docker image, type in the following command while inside the repository:

    docker build -t mingw-w64 .

This works on a Linux system with Docker already installed, or a Windows 10 system running Docker Desktop.

# Using

The `sources.list` inside the repo uses a mirror located in Australia. You may substitute this with your own sources.list file if you wish.

If you prefer to use the default ubuntu mirror, simply remove the following line from the Dockerfile `(Line 18)`:
`COPY sources.list /etc/apt/sources.list`

Execute following to run your shell script, makefile or other build script from current folder:

    docker run --rm -ti -v `pwd`:/mnt mmozeiko/mingw-w64 ./build.sh

For builds that use autotools, add the following arguments:

    --prefix=${MINGW} \
    --host=x86_64-w64-mingw32 \

For builds that use CMake, you can supply the included toolchain by adding the following argument:

    -DCMAKE_TOOLCHAIN_FILE=${MINGW_CMAKE}

Alternatively, if you prefer to manually set the settings yourself or if a CMake project doesn't properly process a line or two, add the following arguments:

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

[pkg-config]: https://www.freedesktop.org/wiki/Software/pkg-config/
[cmake]: https://cmake.org/
[binutils]: https://www.gnu.org/software/binutils/
[mingw-w64]: https://mingw-w64.org/
[gcc]: https://gcc.gnu.org/
[nasm]: https://nasm.us/
[nvcc]: https://docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html
