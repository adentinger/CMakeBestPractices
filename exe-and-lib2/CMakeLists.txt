# SPDX-License-Identifier: MIT

cmake_minimum_required(VERSION 3.23)

# This is required to be before the first project() call of the CMake build.
set(CMAKE_TOOLCHAIN_FILE
  "${CMAKE_CURRENT_SOURCE_DIR}/../vcpkg/scripts/buildsystems/vcpkg.cmake"
  CACHE STRING "Vcpkg toolchain file.")

project(exe
  VERSION 1.0
  LANGUAGES CXX
  HOMEPAGE_URL "https://github.com/AnthonyD973/CMakeBestPracticesTests"
  DESCRIPTION "A library and executable that import a library made with CMake.")
# Note that this variable is not a special CMake variable.
set(PROJECT_LICENSE_FILE "${CMAKE_SOURCE_DIR}/../LICENSE.txt"
  CACHE FILEPATH "Path to the license file for this project.")

# Reason to do that whether we have tests or not:
# https://youtu.be/IZXNsim9TWI?t=2426
enable_testing()

# https://youtu.be/bsXLMQ6WgIk?t=2809
set(CMAKE_DEBUG_POSTFIX -d)

add_subdirectory(lib2)
add_subdirectory(exe)

# Needed by WIX .msi installers. This is not a special CMake variable; it is
# used below.
set(CPACK_PROJECT_GUID "e39da514-9a5b-438f-b2fc-49a3872018e8")

# https://cmake.org/cmake/help/latest/module/CPack.html
set(CPACK_PACKAGE_VENDOR "Anthony Dentinger"
  CACHE STRING "Name of the package vendor.")
# Not documented, but used for Debian package creation as the default value
# of the (mandatory) CPACK_DEBIAN_PACKAGE_MAINTAINER variable.
set(CPACK_PACKAGE_CONTACT "adentinger.dev@gmail.com"
  CACHE STRING "Name or contact info of package maintainer.")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY
  "${PROJECT_DESCRIPTION}"
  CACHE STRING "Short package description.")
set(CPACK_RESOURCE_FILE_LICENSE "${PROJECT_LICENSE_FILE}"
  CACHE FILEPATH "Path to the license for package EULA.")
set(CPACK_PACKAGE_CHECKSUM SHA512
  CACHE STRING "Checksum file algorithm.")
# Not documented, but used for RPM package creation as the default value of the
# (optional) CPACK_RPM_PACKAGE_RELOCATABLE variable.
#
# Good packages are generally relocatable, but I suppose some highly
# system-specific packages might not be.
set(CPACK_PACKAGE_RELOCATABLE ON
  CACHE BOOL "If enabled, indicates that the package can be installed anywhere.")
set(CPACK_VERBATIM_VARIABLES ON
  CACHE BOOL "If enabled, escapes contents of CPACK_* variables.")
set(CPACK_THREADS 0
  CACHE STRING "Number of threads if supported by package generator. 0 = #CPUs.")

# https://www.debian.org/doc/debian-policy/ch-relationships.html#syntax-of-relationship-fields
set(CPACK_DEBIAN_PACKAGE_DEPENDS ""
  CACHE STRING "Used in .deb package. Required package.")
set(CPACK_DEBIAN_PACKAGE_RECOMMENDS ""
  CACHE STRING "Used in .deb package. Recommended (but not required) package.")

# https://cmake.org/cmake/help/latest/cpack_gen/rpm.html#variable:CPACK_RPM_PACKAGE_REQUIRES
#
# According to the CMake doc, SUGGESTS is not always supported, so just use
# REQUIRES.
set(CPACK_RPM_PACKAGE_REQUIRES ""
  CACHE STRING "Used in .rpm package. Required package.")
set(CPACK_RPM_PACKAGE_SUGGESTS ""
  CACHE STRING "Used in .rpm package. Suggested package.")

# Must be different for each project. Allows detecting and replacing existing
# installations.
set(CPACK_WIX_UPGRADE_GUID "${CPACK_PROJECT_GUID}"
  CACHE STRING "Used in WIX .msi installers. Project GUID.")

include(CPack)

find_package(GTest CONFIG REQUIRED)

