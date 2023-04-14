#!/bin/bash -e
# SPDX-License-Identifier: MIT

usage() {
	local script_basename="$(basename "$0")"
	echo "USAGE" >&2
	echo "${script_basename}" >&2
	echo "" >&2
	echo "${script_basename} (-n | --dry-run)" >&2
	echo "" >&2
	echo "${script_basename} (-h | --help)" >&2
	echo "" >&2
	echo "" >&2
	echo "OPTIONS" >&2
	echo "  -h | --help Prints this help message and exits." >&2
	echo "" >&2
	echo "  -n | --dry-run Prints the commands that would be run without running them." >&2
}

parse_args() {
	IS_DRY_RUN=0
	while [ $# -ge 1 ]; do
		case "${1}" in
		--help | -h)
			usage
			exit 0
			;;
		-n | --dry-run)
			IS_DRY_RUN=1
			;;
		*)
			echo "Unknown argument \"${1}\"." >&2
			echo "" >&2
			usage
			exit 1
			;;
		esac

		shift
	done
}

big_message() {
	echo
	echo "--------"
	echo "$@"
	echo "--------"
	echo
}

run_or_print() {
	if [ "$IS_DRY_RUN" != 0 ]; then
		# Only print the command.
		echo "Would run: $@"
	else
		# Actually run the command.
		"$@"
	fi
}

set_system_info() {
    # BASED ON https://unix.stackexchange.com/questions/6345/how-can-i-get-distribution-name-and-version-number-in-a-simple-shell-script
    if [ -f /etc/os-release ]; then
        # freedesktop.org and systemd
        . /etc/os-release
        OS=GNU/Linux
        DISTRO="${NAME}"
        VER="${VERSION_ID}"
    elif type lsb_release >/dev/null 2>&1; then
        # linuxbase.org
        OS=GNU/Linux
        DISTRO="$(lsb_release -si)"
        VER="$(lsb_release -sr)"
    elif [ -f /etc/lsb-release ]; then
        # For some versions of Debian/Ubuntu without lsb_release command
        . /etc/lsb-release
        OS=GNU/Linux
        DISTRO=$DISTRIB_ID
        VER="${DISTRIB_RELEASE}"
    elif [ -f /etc/debian_version ]; then
        # Older Debian/Ubuntu/etc.
        OS=GNU/Linux
        DISTRO=Debian
        VER="$(cat /etc/debian_version)"
    elif [ -f /etc/SuSe-release ] || [ -f /etc/redhat-release ]; then
        # Older Red Hat, CentOS, etc.
        OS=GNU/Linux
        DISTRO="$(grep -oP '^\w+' /etc/redhat-release)"
        VER="$(grep -oP '\d+(\.\d+)*' /etc/redhat-release)"
    elif [ "$(uname -s)" == Darwin ]; then
        # Not sure whether the test for watchOS, tvOS etc is different.

        # MacOS doesn't seem to have uname -o
        OS=Darwin
        DISTRO="$(uname -s)"
        VER="(uname -r)"
    else
        # Fall back to uname, e.g. "Linux <version>",
        # also works for BSD, Cygwin, MINGW, etc.
        OS="$(uname -o)"
        DISTRO="$(uname -s)"
        VER="$(uname -r)"
		if [ "$OS" == "" ] || [ "$DISTRO" == "" ] || [ "$VER" == "" ]; then
			echo "One or more 'uname' command(s) failed." >&2
			exit 1
		fi
    fi
}

set_environment() {
	big_message "Checking environment variables"
	# The output of AdeClangFormat is the same regardless of the preset and
	# config/build-type, so just always pick the same one.
	ADECLANGFORMAT_CONFIG=Release
	if [ -z "${PRJ1_CONFIG+x}" ]; then
		echo PRJ1_CONFIG not defined, defaulting to \"Release\"
		PRJ1_CONFIG=Release
	fi
	if [ -z "${PRJ2_CONFIG+x}" ]; then
		echo PRJ2_CONFIG not defined, defaulting to \"Release\"
		PRJ2_CONFIG=Release
	fi
	if [ -z "${PRJ1_CONFIGURE_PRESET+x}" ]; then
		echo PRJ1_CONFIGURE_PRESET not defined, defaulting to \"shared\"
		PRJ1_CONFIGURE_PRESET=shared
	fi
	if [ -z "${PRJ2_CONFIGURE_PRESET+x}" ]; then
		echo PRJ2_CONFIGURE_PRESET not defined, defaulting to \"shared\"
		PRJ2_CONFIGURE_PRESET=shared
	fi
	if [ -z "${CPACK_GENERATORS+x}" ]; then
		echo CPACK_GENERATORS not defined, cpack won\'t be called
	fi
	if [ -z "${CMAKE_DIR+x}" ]; then
		echo "CMAKE_DIR: not specified."
	fi

	if [ "${VCPKG_DIR+x}" == "" ]; then
		export VCPKG_DIR="${SCRIPT_DIR}/vcpkg"
		echo "VCPKG_DIR not set; setting it to $VCPKG_DIR ." >&2
	fi
}

set_cmake() {
	big_message "Determining CMake executables"

	if [ ! -z "${CMAKE_DIR}" ]; then
		export CMAKE_CMD="${CMAKE_DIR}/bin/cmake"
		export CTEST_CMD="${CMAKE_DIR}/bin/ctest"
		export CPACK_CMD="${CMAKE_DIR}/bin/cpack"
	else
		export CMAKE_CMD="$(which cmake)"
		export CTEST_CMD="$(which ctest)"
		export CPACK_CMD="$(which cpack)"
	fi

	if [ ! -x "${CMAKE_CMD}" ]; then
		echo "cmake executable \"${CMAKE_CMD}\" does not exist or is not executable." >&2
		echo "You may specify the CMAKE_DIR environment variable (cmake would be \$CMAKE_DIR/bin/cmake)." >&2
		exit 1
	fi
	if [ ! -x "${CTEST_CMD}" ]; then
		echo "ctest executable \"${CTEST_CMD}\" does not exist or is not executable." >&2
		echo "You may specify the CMAKE_DIR environment variable (ctest would be \$CMAKE_DIR/bin/ctest)." >&2
		exit 1
	fi
	if [ ! -x "${CPACK_CMD}" ]; then
		echo "cpack executable \"${CPACK_CMD}\" does not exist or is not executable." >&2
		echo "You may specify the CMAKE_DIR environment variable (cpack would be \$CMAKE_DIR/bin/cpack)." >&2
		exit 1
	fi

	echo CMAKE_CMD: "$CMAKE_CMD"
	echo CTEST_CMD: "$CTEST_CMD"
	echo CPACK_CMD: "$CPACK_CMD"
}

# The CMakePresets.json files check the CMake version, however cmake itself
# does not support the presets file until CMake 3.19.
check_cmake_version() {
	CMAKE_CMD=cmake
	local min_major=3
	local min_minor=19

	# MacOS doesn't seem to have 'grep -P', so gotta use normal 'grep -o'.
	local version_string="$("${CMAKE_CMD}" --version | head -n1 | grep -o '[[:digit:]].*')"
	local major_number="$(echo "${version_string}" | grep -o '^[[:digit:]]\{1,\}')"
	local major_prefix_to_minor="${major_number}."
	local major_and_minor_number="$(echo "${version_string}" | grep -o '^'"${major_prefix_to_minor}"'[[:digit:]]\{1,\}')"
	local minor_number="${major_and_minor_number:${#major_prefix_to_minor}}"
	if [ "${major_number}" -gt "${min_major}" ] || [ "${major_number}" -eq "${min_major}" ] && [ "${minor_number}" -ge "${min_minor}" ]; then
		echo "OK, CMake version is ${version_string} >= ${min_major}.${min_minor}."
	else
		echo "ERROR, CMake version is ${version_string} which is less than the minimum required of ${min_major}.${min_minor}." >&2
		exit 1
	fi
}

# Expects to be run at the root of the sources (this repo's root directory).
check_vcpkg() {
	big_message "Checking vcpkg"

	export VCPKG_EXE="$VCPKG_DIR/vcpkg"

	echo "Assuming vcpkg executable is \"$VCPKG_EXE\" and running vcpkg bootstrap."
	if [ "$OS" == GNU/Linux ] || [ "$OS" == Darwin ]; then
		local vcpkg_bootstrap="$VCPKG_DIR/bootstrap-vcpkg.sh"
		run_or_print "${vcpkg_bootstrap}"
	elif [ "$OS" == Msys ]; then
		local vcpkg_bootstrap="$VCPKG_DIR/bootstrap-vcpkg.bat"
		# 'cmd /c <cmd>' but since we're on an Msys shell, we need to add an
		# extra '/' to '/c' so that the shell understands we aren't passing a
		# file path that needs to be transformed into backslashes.
		run_or_print cmd //c "${vcpkg_bootstrap}"
	else
		echo "Unexpected platform \"$OS\"." >&2
		exit 1
	fi

	if [ "$IS_DRY_RUN" == 0 ] && ! "${VCPKG_EXE}" version; then
		echo "vcpkg executable does not exist or does not work." >&2
		exit 1
	fi

	if [ ! -d vcpkg ]; then
		# Do not run the git command here: it is frequent to produce tarballs
		# of a repo's sources and then distribute the tarball. If we use a
		# 'git' command here, source tarballs would not work because the
		# extracted tarball is not a Git repo.
		echo "vcpkg/ dir does not exist; did you clone this repos's submodules?" >&2
		echo "Run: git submodule update --init --recursive" >&2
		exit 1
	fi
}

clean() {
	run_or_print rm -rf {AdeClangFormat,prj1,prj2}/{build,vcpkg_installed} install
}

