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
wget "https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz"
tar xzf "tmux-${TMUX_VERSION}.tar.gz"
cd "tmux-${TMUX_VERSION}"

# TODO: Install and enable utf8proc on macos
./configure \
    --prefix=${PREFIX} \
    --disable-utf8proc \
    --includedir="${PREFIX}/include" \
    --libdir="${PREFIX}/lib" \
    CFLAGS="-I${PREFIX}/include" \
    LDFLAGS="-L${PREFIX}/lib" \
    CPPFLAGS="-I${PREFIX}/include" \
    LIBEVENT_LIBS="-L${PREFIX}/lib -levent" \
    LIBNCURSES_CFLAGS="-I${PREFIX}/include/ncurses" \
    LIBNCURSES_LIBS="-L${PREFIX}/lib -lncurses" \
    LIBTINFO_CFLAGS="-I${PREFIX}/include/ncurses" \
    LIBTINFO_LIBS="-L${PREFIX}/lib -ltinfo"

make -j$(nproc)
make install

rm -rf "$PREFIX/src"
