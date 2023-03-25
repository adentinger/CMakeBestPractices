# SPDX-License-Identifier: MIT

cmake_minimum_required(VERSION 3.25)

project(AdeClangFormat
  VERSION 3.0
  LANGUAGES NONE
  DESCRIPTION "Simple clang-format integration into CMake."
  HOMEPAGE_URL "https://github.com/AnthonyD973/CMakeBestPracticesTests")
# Note that this variable is not a special CMake variable.
set(PROJECT_LICENSE_FILE "${CMAKE_SOURCE_DIR}/../LICENSE.txt"
  CACHE FILEPATH "Path to the license file for this project.")

# Reason to do that whether we have tests or not:
# https://youtu.be/IZXNsim9TWI?t=2426
enable_testing()

# https://youtu.be/bsXLMQ6WgIk?t=2809
set(CMAKE_DEBUG_POSTFIX -d)

configure_file(AdeClangFormatConfig.cmake.in
  "${CMAKE_CURRENT_BINARY_DIR}/AdeClangFormatConfig.cmake"
  @ONLY
  USE_SOURCE_PERMISSIONS)
include(CMakePackageConfigHelpers)
# Write a CMake script containing the version information & checking for
# this project. This is used in the find_package() call of the project that
# uses this package to do version checking:
# https://cmake.org/cmake/help/latest/command/find_package.html#config-mode-version-selection
write_basic_package_version_file(AdeClangFormatConfigVersion.cmake
  VERSION ${PROJECT_VERSION}
  # Define the version compatibility checking policy.
  #
  # Obviously, in a project this should be decided once and ideally only
  # once, since changing this policy (or at least, making it less restrictive
  # than it has once been) would otherwise be a compatibility break in the very
  # thing that checks compatibility. Breaking compatibility of this policy is
  # something, we suppose, could only be possible when introducing an extra
  # level of indirection that provides the consistency, such as a package
  # manager that already knows about newer versions of the package even if that
  # newer version is not the one installed, or a "version-checking server" of
  # some kind that would do this same thing.
  COMPATIBILITY SameMajorVersion)

install(FILES
  "${CMAKE_CURRENT_BINARY_DIR}/AdeClangFormatConfig.cmake"
  "${CMAKE_CURRENT_BINARY_DIR}/AdeClangFormatConfigVersion.cmake"
  DESTINATION share/cmake/AdeClangFormat)

# Needed by WIX .msi installers. This is not a special CMake variable; it is
# used below.
set(CPACK_PROJECT_GUID "133f3336-b93e-45aa-bb94-09e5020b55c1")

# https://cmake.org/cmake/help/latest/module/CPack.html
set(CPACK_PACKAGE_VENDOR "Anthony Dentinger"
  CACHE STRING "Name of the package vendor.")
# Not documented, but used for Debian package creation as the default value
# of the (mandatory) CPACK_DEBIAN_PACKAGE_MAINTAINER variable.
set(CPACK_PACKAGE_CONTACT "a.dentinger@gmail.com"
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
set(CPACK_DEBIAN_PACKAGE_RECOMMENDS "cmake (>= 3.17)"
  CACHE STRING "Used in .deb package. Recommended (but not required) package.")

# https://cmake.org/cmake/help/latest/cpack_gen/rpm.html#variable:CPACK_RPM_PACKAGE_REQUIRES
#
# According to the CMake doc, SUGGESTS is not always supported, so just use
# REQUIRES.
set(CPACK_RPM_PACKAGE_REQUIRES "cmake >= 3.17"
  CACHE STRING "Used in .rpm package. Required package.")
set(CPACK_RPM_PACKAGE_SUGGESTS ""
  CACHE STRING "Used in .rpm package. Suggested package.")

# Must be different for each project. Allows detecting and replacing existing
# installations.
set(CPACK_WIX_UPGRADE_GUID "${CPACK_PROJECT_GUID}"
  CACHE STRING "Used in WIX .msi installers. Project GUID.")

include(CPack)

add_subdirectory(test)

