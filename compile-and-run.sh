#!/bin/bash -e
# SPDX-License-Identifier: MIT

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
ADECLANGFORMAT_WORKFLOW=default
LIB1_WORKFLOW=shared
LIB2EXE_WORKFLOW=shared

big_message() {
	echo
	echo "--------"
	echo "$@"
	echo "--------"
	echo
}

set_cmake() {
	if [ ! -z "${CMAKE_DIR}" ]; then
		export CMAKE_CMD="${CMAKE_DIR}/bin/cmake"
	else
		export CMAKE_CMD="$(which cmake)"
	fi
	echo CMAKE_CMD: "$CMAKE_CMD"
}

# The CMakePresets.json files check the CMake version, however cmake itself
# does not support the presets file until CMake 3.19.
check_cmake_version() {
	local min_major=3
	local min_minor=19

	local version_string="$("${CMAKE_CMD}" --version | grep -oP '(?<=^cmake version ).*')"
	local major_number="$(echo "${version_string}" | grep -oP '^\d+(?=[\.$])')"
	local minor_number="$(echo "${version_string}" | grep -oP '(?<=^'"${major_number}"'\.)\d+(?=[\.$])')"
	if [ "${major_number}" -gt "${min_major}" ] || [ "${major_number}" -eq "${min_major}" ] && [ "${minor_number}" -ge "${min_minor}" ]; then
		echo "OK, CMake version is ${version_string} >= ${min_major}.${min_minor}."
	else
		echo "ERROR, CMake version is ${version_string} which is less than the minimum required of ${min_major}.${min_minor}." >&2
		exit 1
	fi
}

set_cmake
big_message "Assuming cmake command is \"${CMAKE_CMD}\""
check_cmake_version

cd "${SCRIPT_DIR}"

rm -rf {AdeClangFormat,lib1,exe-and-lib2}/build install
big_message "AdeClangFormat workflow ${ADECLANGFORMAT_WORKFLOW}"
cd "${SCRIPT_DIR}"/AdeClangFormat
"${CMAKE_CMD}" --workflow --preset "${ADECLANGFORMAT_WORKFLOW}"
"${CMAKE_CMD}" --install build --config "${CMAKE_CONFIG_TYPE}"
big_message "lib1 workflow ${LIB1_WORKFLOW}"
cd "${SCRIPT_DIR}"/lib1
"${CMAKE_CMD}" --workflow --preset "${LIB1_WORKFLOW}"
"${CMAKE_CMD}" --install build --config "${CMAKE_CONFIG_TYPE}"
big_message "exe-and-lib2 workflow ${LIB2EXE_WORKFLOW}"
cd "${SCRIPT_DIR}"/exe-and-lib2
"${CMAKE_CMD}" --workflow --preset "${LIB2EXE_WORKFLOW}"
"${CMAKE_CMD}" --install build --config "${CMAKE_CONFIG_TYPE}"
big_message "Running executable"
cd "${SCRIPT_DIR}"
./install/bin/exe

