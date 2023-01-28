#!/bin/bash -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
LIB1_WORKFLOW=ninja-release-shared
LIB2EXE_WORKFLOW=ninja-release-shared

cd "${SCRIPT_DIR}"

rm -rf {lib1,exe-and-lib2}/build install
cd lib1
"${CMAKE_BIN_DIR}"cmake --workflow --preset "${LIB1_WORKFLOW}"
# TODO Add this to workflow
"${CMAKE_BIN_DIR}"ctest --test-dir build
"${CMAKE_BIN_DIR}"cmake --install build
cd "${SCRIPT_DIR}"/exe-and-lib2
"${CMAKE_BIN_DIR}"cmake --workflow --preset "${LIB2EXE_WORKFLOW}"
# TODO Add this to workflow
"${CMAKE_BIN_DIR}"ctest --test-dir build
"${CMAKE_BIN_DIR}"cmake --install build
cd "${SCRIPT_DIR}"
echo
echo "--------"
echo "Running executable"
echo "--------"
echo
./install/bin/exe

