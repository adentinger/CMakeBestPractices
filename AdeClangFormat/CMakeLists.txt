# SPDX-License-Identifier: MIT

cmake_minimum_required(VERSION 3.25)
project(AdeClangFormat
  VERSION 2.0
  LANGUAGES NONE
  DESCRIPTION "Simple clang-format integration into CMake."
  HOMEPAGE_URL "https://github.com/AnthonyD973/CMakeBestPracticesTests")

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

# https://cmake.org/cmake/help/latest/module/CPack.html
set(CPACK_PACKAGE_VENDOR "Anthony Dentinger"
  CACHE STRING "Name of the package vendor.")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY
  "Simple clang-format integration into CMake."
  CACHE STRING "Short package description.")
set(CPACK_PACKAGE_CHECKSUM SHA256
  CACHE STRING "Checksum file algorithm.")
set(CPACK_VERBATIM_VARIABLES ON
  CACHE BOOL "If enabled, escapes contents of CPACK_* variables.")
set(CPACK_THREADS 0
  CACHE STRING "Number of threads if supported by package generator. 0 = #CPUs.")
include(CPack)

