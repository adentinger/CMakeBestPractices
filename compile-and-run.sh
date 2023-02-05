#!/bin/bash -e
# SPDX-License-Identifier: MIT

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
SILCLANGFORMAT_WORKFLOW=ninja
LIB1_WORKFLOW=ninja-release-shared
LIB2EXE_WORKFLOW=ninja-release-shared

big_message() {
	echo
	echo "--------"
	echo "$@"
	echo "--------"
	echo
}

echo "Assuming cmake command is \"${CMAKE_BIN_DIR}cmake\""

cd "${SCRIPT_DIR}"

rm -rf {SilClangFormat,lib1,exe-and-lib2}/build install
big_message "SilClangFormat workflow ${SILCLANGFORMAT_WORKFLOW}"
cd "${SCRIPT_DIR}"/SilClangFormat
"${CMAKE_BIN_DIR}"cmake --workflow --preset "${SILCLANGFORMAT_WORKFLOW}"
# TODO Add this to workflow
"${CMAKE_BIN_DIR}"ctest --test-dir build
"${CMAKE_BIN_DIR}"cmake --install build
big_message "lib1 workflow ${LIB1_WORKFLOW}"
cd "${SCRIPT_DIR}"/lib1
"${CMAKE_BIN_DIR}"cmake --workflow --preset "${LIB1_WORKFLOW}"
# TODO Add this to workflow
"${CMAKE_BIN_DIR}"ctest --test-dir build
"${CMAKE_BIN_DIR}"cmake --install build
big_message "exe-and-lib2 workflow ${LIB2EXE_WORKFLOW}"
cd "${SCRIPT_DIR}"/exe-and-lib2
"${CMAKE_BIN_DIR}"cmake --workflow --preset "${LIB2EXE_WORKFLOW}"
# TODO Add this to workflow
"${CMAKE_BIN_DIR}"ctest --test-dir build
"${CMAKE_BIN_DIR}"cmake --install build
big_message "Running executable"
cd "${SCRIPT_DIR}"
./install/bin/exe

