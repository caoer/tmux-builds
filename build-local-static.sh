#!/usr/bin/env bash
set -euo pipefail

TMUX_REPO="${TMUX_REPO:-/Users/Shared/projects/OpenSourceProjects/tmux}"
INSTALL_PATH="${INSTALL_PATH:-$HOME/.local/bin/tmux}"
BUILD_DIR="/tmp/tmux-static-$(date +%s)"

echo "==> Build dir: $BUILD_DIR"
mkdir -p "$BUILD_DIR/src"

# utf8proc
echo "==> Building static utf8proc..."
cd "$BUILD_DIR/src"
curl -sL "https://github.com/JuliaStrings/utf8proc/releases/download/v2.11.2/utf8proc-2.11.2.tar.gz" | tar xz
cd utf8proc-2.11.2
make -j$(sysctl -n hw.ncpu) >/dev/null 2>&1
make prefix="$BUILD_DIR" install >/dev/null 2>&1
rm -f "$BUILD_DIR"/lib/libutf8proc*.dylib

# libevent
echo "==> Building static libevent..."
cd "$BUILD_DIR/src"
curl -sL "https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz" | tar xz
cd libevent-2.1.12-stable
./configure --prefix="$BUILD_DIR" --disable-shared --disable-openssl --disable-libevent-regress --disable-samples >/dev/null 2>&1
make -j$(sysctl -n hw.ncpu) >/dev/null 2>&1
make install >/dev/null 2>&1

# jemalloc
echo "==> Building static jemalloc..."
cd "$BUILD_DIR/src"
curl -sL "https://github.com/jemalloc/jemalloc/releases/download/5.3.0/jemalloc-5.3.0.tar.bz2" | tar xj
cd jemalloc-5.3.0
./configure --prefix="$BUILD_DIR" --disable-shared --enable-static --disable-cxx >/dev/null 2>&1
make -j$(sysctl -n hw.ncpu) >/dev/null 2>&1
make install >/dev/null 2>&1

echo "==> Static libraries built:"
ls -lh "$BUILD_DIR/lib"/*.a

# Build tmux
echo "==> Building tmux..."
cd "$TMUX_REPO"
make clean >/dev/null 2>&1 || true
touch aclocal.m4 configure Makefile.in

PKG_CONFIG_PATH="$BUILD_DIR/lib/pkgconfig" \
  CFLAGS="-O3 -march=native -mtune=native" \
  ./configure --enable-utf8proc --enable-jemalloc

# Modify final link to force-load jemalloc
# Replace the link line to add force_load before -ljemalloc
JEMALLOC_PATH="$BUILD_DIR/lib/libjemalloc.a"
perl -i -pe "s|-ljemalloc|-Wl,-force_load,$JEMALLOC_PATH|g" Makefile

make -j$(sysctl -n hw.ncpu)

echo "==> Version:"
./tmux -V

echo "==> Dependencies:"
otool -L ./tmux

echo "==> Jemalloc symbols:"
nm ./tmux | grep "je_malloc" | head -3 || echo "No je_malloc symbols (might be in .a)"

# Install
mkdir -p "$(dirname "$INSTALL_PATH")"
cp ./tmux "$INSTALL_PATH"

echo ""
echo "==> Installed to $INSTALL_PATH"
ls -lh "$INSTALL_PATH"
cd /tmp && "$INSTALL_PATH" -V
