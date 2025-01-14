FROM ubuntu:22.04
WORKDIR /mnt

SHELL [ "/bin/bash", "-c" ]

# Environment variables (Toolchain names, root location have an 'R' suffix)
ENV MINGW=i686-w64-mingw32
ENV MINGW_64=x86_64-w64-mingw32
ENV MINGW_R=/usr/local/i686-w64-mingw32
ENV MINGW_64_R=/usr/local/x86_64-w64-mingw32

ARG PKG_CONFIG_VERSION=0.29.2
ARG CMAKE_VERSION=3.23.1
ARG BINUTILS_VERSION=2.38
ARG MINGW_VERSION=10.0.0
ARG GCC_VERSION=12.1.0

COPY . /temp

RUN set -ex \
    && apt-get update \
    && echo "Upgrading & Installing required packages. Grab a coffee or whatever you fancy while you're waiting :)" \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade --no-install-recommends -qq -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -qq -y \
        ca-certificates gcc g++ zlib1g-dev libssl-dev libgmp-dev libmpfr-dev \
        libmpc-dev libisl-dev libssl3 libgmp10 libmpfr6 libmpc3 libisl23 xz-utils \
        ninja-build texinfo meson gnupg bzip2 patch \
        gperf bison file flex make yasm wget zip git dos2unix \
    \
    && mkdir /packages && cd /packages \
    && echo "Downloading required packages..." \
    && wget https://pkg-config.freedesktop.org/releases/pkg-config-${PKG_CONFIG_VERSION}.tar.gz \
    && wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz \
    && wget http://ftpmirror.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.xz \
    && wget https://sourceforge.net/projects/mingw-w64/files/mingw-w64/mingw-w64-release/mingw-w64-v${MINGW_VERSION}.tar.bz2 \
    && wget http://ftpmirror.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz \
    && cd .. \
    \
    && echo "Installing CMake..." \
    && tar xzf /packages/cmake-${CMAKE_VERSION}.tar.gz \
    && cd cmake-${CMAKE_VERSION} \
    && ./configure \
        --prefix=/usr/local \
        --parallel=`nproc` \
    && make -j`nproc` \
    && make install \
    && cd .. \
    && echo "Cleaning up..." \
    && rm -r cmake-${CMAKE_VERSION} \
    \
    && echo "Installing i686 MinGW-W64 Toolchain..." \
    && mkdir -p ${MINGW_R}/include ${MINGW_R}/lib/pkgconfig \
    && chmod 0777 -R /mnt ${MINGW_R} \
    && mkdir /build-i686 && cd /build-i686 \
    \
    && echo "Compiling pkg-config v${PKG_CONFIG_VERSION}..." \
    && tar xzf ../packages/pkg-config-${PKG_CONFIG_VERSION}.tar.gz && cd pkg-config-${PKG_CONFIG_VERSION} \
    && ./configure \
        --prefix=${MINGW_R} \
        --with-pc-path=${MINGW_R}/lib/pkgconfig \
        --with-internal-glib \
        --disable-shared \
        --disable-nls \
    && make -j`nproc` \
    && make install \
    && rm ${MINGW_R}/bin/x86_64-unknown-linux-gnu-pkg-config \
    && ln -f ${MINGW_R}/bin/pkg-config /usr/local/bin/${MINGW}-pkg-config \
    && cd .. \
    \
    && echo "Compiling Binutils..." \
    && tar xJf ../packages/binutils-${BINUTILS_VERSION}.tar.xz \
    && cd binutils-${BINUTILS_VERSION} \
    && ./configure \
        --prefix=/usr/local \
        --target=${MINGW} \
        --disable-shared \
        --enable-static \
        --disable-lto \
        --disable-plugins \
        --disable-multilib \
        --disable-nls \
        --disable-werror \
        --with-system-zlib \
    && make -j`nproc` \
    && make install \
    && cd .. \
    \
    && echo "Installing MinGW-W64 Headers..." \
    && tar xjf ../packages/mingw-w64-v${MINGW_VERSION}.tar.bz2 \
    && mkdir mingw-w64 && cd mingw-w64 \
    && ../mingw-w64-v${MINGW_VERSION}/mingw-w64-headers/configure \
        --prefix=${MINGW_R} \
        --host=${MINGW} \
        --enable-sdk=all \
    && make install \
    && cd .. \
    \
    && echo "Compiling GCC (Compiler)..." \
    && tar xJf ../packages/gcc-${GCC_VERSION}.tar.xz \
    && mkdir gcc && cd gcc \
    && ../gcc-${GCC_VERSION}/configure \
        --prefix=/usr/local \
        --target=${MINGW} \
        --enable-languages=c,c++ \
        --disable-shared \
        --enable-static \
        --enable-threads=posix \
        --with-system-zlib \
        --enable-libgomp \
        --enable-libatomic \
        --enable-graphite \
        --disable-libstdcxx-pch \
        --disable-libstdcxx-debug \
        --disable-multilib \
        --disable-lto \
        --disable-nls \
        --disable-werror \
    && make -j`nproc` all-gcc \
    && make install-gcc \
    && cd .. \
    \
    && echo "Compiling MinGW-W64 Runtime and Libraries..." \
    && cd mingw-w64 \
    && ../mingw-w64-v${MINGW_VERSION}/mingw-w64-crt/configure \
        --prefix=${MINGW_R} \
        --host=${MINGW} \
        --enable-wildcard \
        --enable-lib32 \
        --disable-lib64 \
    && make -j`nproc` \
    && make install \
    && ../mingw-w64-v${MINGW_VERSION}/mingw-w64-libraries/winpthreads/configure \
        --prefix=${MINGW_R} \
        --host=${MINGW} \
        --enable-static \
        --disable-shared \
    && make -j`nproc` \
    && make install \
    && cd .. \
    \
    && echo "Compiling GCC (Full)..." \
    && cd gcc \
    && make -j`nproc` \
    && make install \
    && cd .. \
    \
    && echo "Cleaning up..." \
    && cd / && rm -rf build-i686 \
    && echo "Copying FindDLL and CMake toolchain..." \
    && cp -r /temp/finddll/finddll.sh /usr/local/bin/finddll \
    && dos2unix /usr/local/bin/finddll \
    && chmod +x /usr/local/bin/finddll \
    && cp -r /temp/toolchains/i686.cmake ${MINGW_R}/toolchain.cmake \
    && dos2unix ${MINGW_R}/toolchain.cmake \
    \
    && echo "i686 MinGW-W64 toolchain has been successfully installed!" \
    \
    && echo "Installing x86_64 MinGW-W64 Toolchain..." \
    && mkdir -p ${MINGW_64_R}/include ${MINGW_64_R}/lib/pkgconfig \
    && chmod 0777 -R /mnt ${MINGW_64_R} \
    && mkdir /build-x86_64 && cd /build-x86_64 \
    \
    && echo "Compiling pkg-config v${PKG_CONFIG_VERSION}..." \
    && tar xzf ../packages/pkg-config-${PKG_CONFIG_VERSION}.tar.gz && cd pkg-config-${PKG_CONFIG_VERSION} \
    && ./configure \
        --prefix=${MINGW_64_R} \
        --with-pc-path=${MINGW_64_R}/lib/pkgconfig \
        --with-internal-glib \
        --disable-shared \
        --disable-nls \
    && make -j`nproc` \
    && make install \
    && rm ${MINGW_64_R}/bin/x86_64-unknown-linux-gnu-pkg-config \
    && ln -f ${MINGW_64_R}/bin/pkg-config /usr/local/bin/${MINGW_64}-pkg-config \
    && cd .. \
    \
    && echo "Compiling Binutils..." \
    && tar xJf ../packages/binutils-${BINUTILS_VERSION}.tar.xz \
    && cd binutils-${BINUTILS_VERSION} \
    && ./configure \
        --prefix=/usr/local \
        --target=${MINGW_64} \
        --disable-shared \
        --enable-static \
        --disable-lto \
        --disable-plugins \
        --disable-multilib \
        --disable-nls \
        --disable-werror \
        --with-system-zlib \
    && make -j`nproc` \
    && make install \
    && cd .. \
    \
    && echo "Installing MinGW-W64 Headers..." \
    && tar xjf ../packages/mingw-w64-v${MINGW_VERSION}.tar.bz2 \
    && mkdir mingw-w64 && cd mingw-w64 \
    && ../mingw-w64-v${MINGW_VERSION}/mingw-w64-headers/configure \
        --prefix=${MINGW_64_R} \
        --host=${MINGW_64} \
        --enable-sdk=all \
    && make install \
    && cd .. \
    \
    && echo "Compiling GCC (Compiler)..." \
    && tar xJf ../packages/gcc-${GCC_VERSION}.tar.xz \
    && echo "Patching..." \
    && mkdir gcc && cd gcc \
    && ../gcc-${GCC_VERSION}/configure \
        --prefix=/usr/local \
        --target=${MINGW_64} \
        --enable-languages=c,c++ \
        --disable-shared \
        --enable-static \
        --enable-threads=posix \
        --with-system-zlib \
        --enable-libgomp \
        --enable-libatomic \
        --enable-graphite \
        --disable-libstdcxx-pch \
        --disable-libstdcxx-debug \
        --disable-multilib \
        --disable-lto \
        --disable-nls \
        --disable-werror \
    && make -j`nproc` all-gcc \
    && make install-gcc \
    && cd .. \
    \
    && echo "Compiling MinGW-W64 Runtime and Libraries..." \
    && cd mingw-w64 \
    && ../mingw-w64-v${MINGW_VERSION}/mingw-w64-crt/configure \
        --prefix=${MINGW_64_R} \
        --host=${MINGW_64} \
        --enable-wildcard \
        --disable-lib32 \
        --enable-lib64 \
    && make -j`nproc` \
    && make install \
    && ../mingw-w64-v${MINGW_VERSION}/mingw-w64-libraries/winpthreads/configure \
        --prefix=${MINGW_64_R} \
        --host=${MINGW_64} \
        --enable-static \
        --disable-shared \
    && make -j`nproc` \
    && make install \
    && cd .. \
    \
    && echo "Compiling GCC (Full)..." \
    && cd gcc \
    && make -j`nproc` \
    && make install \
    && cd .. \
    \
    && echo "Cleaning up..." \
    && cd / && rm -rf build-x86_64 \
    && echo "Copying FindDLL and CMake toolchain..." \
    && cp -r /temp/finddll/finddll_64.sh /usr/local/bin/finddll_64 \
    && dos2unix /usr/local/bin/finddll_64 \
    && chmod +x /usr/local/bin/finddll_64 \
    && cp -r /temp/toolchains/x86_64.cmake ${MINGW_64_R}/toolchain.cmake \
    && dos2unix ${MINGW_64_R}/toolchain.cmake \
    \
    && echo "x86_64 MinGW-W64 toolchain has been successfully installed!" \
    \
    && echo "Cleaning up..." \
    && apt-get remove -qq --purge -y gcc g++ zlib1g-dev libssl-dev libgmp-dev libmpfr-dev libmpc-dev libisl-dev \
    && rm -rf /temp \
    && rm -rf /packages \
    \