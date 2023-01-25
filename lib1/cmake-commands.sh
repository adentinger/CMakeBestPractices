#!/bin/bash

SCRIPT_DIR="$(cd "$(basename "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"

cd "${SCRIPT_DIR}" && cmake --workflow --preset ninja-release && cmake --install build

# cd "$HOME/Git/foo/lib1" && rm -rf build include/ bin lib cmake && mkdir build && cd build/ && cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$(realpath "$(pwd)/..")" -DCMAKE_EXPORT_COMPILE_COMMANDS=On -DBUILD_SHARED_LIBS=Off .. && cmake --build . && cmake --install .

