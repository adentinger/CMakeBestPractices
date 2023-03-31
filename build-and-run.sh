#!/bin/bash -e
# SPDX-License-Identifier: MIT

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
SOURCE_ROOT_DIR="$SCRIPT_DIR"
cd "${SOURCE_ROOT_DIR}"

source "$SCRIPT_DIR/scripts/functions.sh"

parse_args "$@"
set_system_info

set_environment

set_cmake
check_cmake_version

check_vcpkg
# Nothing to do to install vcpkg packages; the packages will be installed
# as part of the CMake build (I suppose as part of running the vcpkg toolchain
# file).

clean

big_message "AdeClangFormat build"
run_or_print cd "${SOURCE_ROOT_DIR}"/AdeClangFormat
run_or_print export CMAKE_BUILD_TYPE="${ADECLANGFORMAT_CONFIG}"
run_or_print "${CMAKE_CMD}" -S . -B build --install-prefix "${SOURCE_ROOT_DIR}/install"
run_or_print "${CMAKE_CMD}" --build build --config "${ADECLANGFORMAT_CONFIG}" -j10
run_or_print "${CTEST_CMD}" --test-dir build --build-config "${ADECLANGFORMAT_CONFIG}" -j10
run_or_print "${CMAKE_CMD}" --install build --config "${ADECLANGFORMAT_CONFIG}"

big_message "prj1 workflow ${PRJ1_WORKFLOW}"
run_or_print cd "${SOURCE_ROOT_DIR}"/prj1
run_or_print export CMAKE_BUILD_TYPE="${PRJ1_CONFIG}"
run_or_print "${CMAKE_CMD}" --preset "${PRJ1_CONFIGURE_PRESET}"
run_or_print "${CMAKE_CMD}" --build build --config "${PRJ1_CONFIG}" -j10
run_or_print "${CTEST_CMD}" --test-dir build --build-config "${PRJ1_CONFIG}" -j10
run_or_print "${CMAKE_CMD}" --install build --config "${PRJ1_CONFIG}"

big_message "prj2 workflow ${PRJ2_WORKFLOW}"
run_or_print cd "${SOURCE_ROOT_DIR}"/prj2
run_or_print export CMAKE_BUILD_TYPE="${PRJ2_CONFIG}"
run_or_print "${CMAKE_CMD}" --preset "${PRJ2_CONFIGURE_PRESET}"
run_or_print "${CMAKE_CMD}" --build build --config "${PRJ2_CONFIG}" -j10
run_or_print "${CTEST_CMD}" --test-dir build --build-config "${PRJ2_CONFIG}" -j10
run_or_print "${CMAKE_CMD}" --install build --config "${PRJ2_CONFIG}"

big_message "Running executable"
run_or_print cd "${SOURCE_ROOT_DIR}"
run_or_print ./install/bin/exe

