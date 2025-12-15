#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${PREFIX:-}" ]]; then
    echo "Error: PREFIX must be set" >&2
    exit 1
fi

if [[ -z "${NCURSES_VERSION:-}" ]]; then
    echo "Error: NCURSES_VERSION must be set" >&2
    exit 1
fi

mkdir -p "$PREFIX/src"
cd "$PREFIX/src"
wget "https://invisible-island.net/archives/ncurses/ncurses-${NCURSES_VERSION}.tar.gz"
tar xzf "ncurses-${NCURSES_VERSION}.tar.gz"
cd "ncurses-${NCURSES_VERSION}"

./configure \
    --prefix=${PREFIX} \
    --includedir=${PREFIX}/include \
    --libdir=${PREFIX}/lib \
    --without-ada \
    --without-cxx \
    --without-cxx-binding \
    --without-tests \
    --without-manpages \
    --without-debug \
    --disable-lib-suffixes \
    --disable-db-install \
    --with-termlib \
    --with-default-terminfo-dir=/usr/share/terminfo \
    --with-terminfo-dirs=/etc/terminfo:/lib/terminfo:/usr/share/terminfo

make -j$(nproc)
make install

rm -rf "$PREFIX/src"
