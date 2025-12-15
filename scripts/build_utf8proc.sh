#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${PREFIX:-}" ]]; then
    echo "Error: PREFIX must be set"
    exit 1
fi

if [[ -z "${UTF8PROC_VERSION:-}" ]]; then
    echo "Error: UTF8PROC_VERSION must be set"
    exit 1
fi

mkdir -p "$PREFIX/src"
cd "$PREFIX/src"
wget "https://github.com/JuliaStrings/utf8proc/releases/download/v${UTF8PROC_VERSION}/utf8proc-${UTF8PROC_VERSION}.tar.gz"
tar xzf "utf8proc-${UTF8PROC_VERSION}.tar.gz"
cd "utf8proc-${UTF8PROC_VERSION}"

make -j$(sysctl -n hw.ncpu)
make prefix=${PREFIX} install

rm -rf "$PREFIX/src"
