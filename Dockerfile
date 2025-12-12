FROM debian:bookworm-slim AS base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
        bison \
        build-essential \
        tar \
        pkg-config \
        wget && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /build/{bin, include, lib, src}
WORKDIR /build/src


########
# musl #
########

FROM base AS musl-builder
ARG MUSL_VERSION=1.2.5

RUN wget https://musl.libc.org/releases/musl-${MUSL_VERSION}.tar.gz && \
    tar xf musl-${MUSL_VERSION}.tar.gz && \
    cd musl-${MUSL_VERSION} && \
    ./configure \
        --enable-gcc-wrapper \
        --disable-shared \
        --prefix=/build \
        --bindir=/build/bin \
        --includedir=/build/include && \
    make -j$(nproc) && \
    make install

ENV CC="/build/bin/musl-gcc -static"


############
# libevent #
############

FROM musl-builder AS libevent-builder
ARG LIBEVENT_VERSION=2.1.12

RUN wget https://github.com/libevent/libevent/releases/download/release-${LIBEVENT_VERSION}-stable/libevent-${LIBEVENT_VERSION}-stable.tar.gz && \
    tar xf libevent-${LIBEVENT_VERSION}-stable.tar.gz && \
    cd libevent-${LIBEVENT_VERSION}-stable && \
    ./configure \
        --prefix=/build \
        --includedir=/build/include \
        --libdir=/build/lib \
        --disable-shared \
        --disable-openssl \
        --disable-libevent-regress \
        --disable-samples && \
    make -j$(nproc) && \
    make install


###########
# ncurses #
###########

FROM libevent-builder AS ncurses-builder
ARG NCURSES_VERSION=6.5

RUN wget https://invisible-island.net/archives/ncurses/ncurses-${NCURSES_VERSION}.tar.gz && \
    tar xzf ncurses-${NCURSES_VERSION}.tar.gz && \
    cd ncurses-${NCURSES_VERSION} && \
    ./configure \
        --prefix=/build \
        --includedir=/build/include \
        --libdir=/build/lib \
        --enable-pc-files \
        --with-pkg-config=/build/lib/pkgconfig \
        --with-pkg-config-libdir=/build/lib/pkgconfig \
        --without-ada \
        --without-cxx \
        --without-cxx-binding \
        --without-tests \
        --without-manpages \
        --without-debug \
        --disable-lib-suffixes \
        --with-ticlib \
        --with-termlib \
        --with-default-terminfo-dir=/usr/share/terminfo \
        --with-terminfo-dirs=/etc/terminfo:/lib/terminfo:/usr/share/terminfo && \
    make -j$(nproc) && \
    make install


########
# tmux #
########

FROM ncurses-builder AS tmux-builder

ARG TMUX_VERSION
RUN test -n "${TMUX_VERSION}"

RUN wget https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz && \
    tar xzf tmux-${TMUX_VERSION}.tar.gz && \
    cd tmux-${TMUX_VERSION} && \
    ./configure \
        --prefix=/build \
        --enable-static \
        --includedir="/build/include" \
        --libdir="/build/lib" \
        CFLAGS="-I/build/include" \
        LDFLAGS="-L/build/lib" \
        CPPFLAGS="-I/build/include" \
        LIBEVENT_LIBS="-L/build/lib -levent" \
        LIBNCURSES_CFLAGS="-I/build/include/ncurses" \
        LIBNCURSES_LIBS="-L/build/lib -lncurses" \
        LIBTINFO_CFLAGS="-I/build/include/ncurses" \
        LIBTINFO_LIBS="-L/build/lib -ltinfo" && \
    make -j$(nproc) && \
    make install


##################
# Artifact image #
##################

FROM alpine:latest
COPY --from=tmux-builder /build/bin/tmux /artifacts/tmux
ENTRYPOINT ["/artifacts/tmux"]
CMD ["-V"]

