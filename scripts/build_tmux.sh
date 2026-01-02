#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${PREFIX:-}" ]]; then
    echo "Error: PREFIX must be set" >&2
    exit 1
fi

if [[ -z "${TMUX_VERSION:-}" ]]; then
    echo "Error: TMUX_VERSION must be set" >&2
    exit 1
fi

mkdir -p "$PREFIX/src"
cd "$PREFIX/src"

if [[ "${TMUX_VERSION}" == "preview" || "${TMUX_VERSION}" == next-* ]]; then
    git clone https://github.com/tmux/tmux.git
    cd tmux
    sh autogen.sh
else
    wget "https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz"
    tar xzf "tmux-${TMUX_VERSION}.tar.gz"
    cd "tmux-${TMUX_VERSION}"
fi

IS_MACOS=false
if [[ "$(uname)" == "Darwin" ]]; then
    IS_MACOS=true
fi

CONFIGURE_FLAGS=(
    --prefix=${PREFIX}
    --includedir="${PREFIX}/include"
    --libdir="${PREFIX}/lib"
    --enable-jemalloc
    LIBEVENT_LIBS="-L${PREFIX}/lib -levent"
    LIBNCURSES_CFLAGS="-I${PREFIX}/include/ncurses"
    LIBNCURSES_LIBS="-L${PREFIX}/lib -lncurses"
    LIBTINFO_CFLAGS="-I${PREFIX}/include/ncurses"
    LIBTINFO_LIBS="-L${PREFIX}/lib -ltinfo"
    CFLAGS="-I${PREFIX}/include"
    LDFLAGS="-L${PREFIX}/lib"
    CPPFLAGS="-I${PREFIX}/include"
)

if $IS_MACOS; then
    CONFIGURE_FLAGS+=(
        --enable-utf8proc
        LIBUTF8PROC_CFLAGS="-I${PREFIX}/include"
        LIBUTF8PROC_LIBS="${PREFIX}/lib/libutf8proc.a"
    )
else
    CONFIGURE_FLAGS+=(
        --enable-static
    )
fi

PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig" ./configure "${CONFIGURE_FLAGS[@]}"

if $IS_MACOS; then
    # Force-load jemalloc to ensure all symbols are linked (needed for malloc interposition)
    JEMALLOC_PATH="${PREFIX}/lib/libjemalloc.a"
    perl -i -pe "s|-ljemalloc|-Wl,-force_load,$JEMALLOC_PATH|g" Makefile
    make -j$(sysctl -n hw.ncpu)
else
    make -j$(nproc)
fi

make install

rm -rf "$PREFIX/src"
