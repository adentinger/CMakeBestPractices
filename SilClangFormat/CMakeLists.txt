# SPDX-License-Identifier: MIT

cmake_minimum_required(VERSION 3.25)
project(SilClangFormat
  VERSION 1.0
  LANGUAGES NONE)

# Reason to do that whether we have tests or not:
# https://youtu.be/IZXNsim9TWI?t=2426
enable_testing()

include(CMakePackageConfigHelpers)
configure_package_config_file(SilClangFormatConfig.cmake.in
  "${CMAKE_CURRENT_BINARY_DIR}/SilClangFormatConfig.cmake"
  INSTALL_DESTINATION share/cmake/SilClangFormat)
# Write a CMake script containing the version information & checking for
# this project. This is used in the find_package() call of the project that
# uses this package to do version checking:
# https://cmake.org/cmake/help/latest/command/find_package.html#config-mode-version-selection
write_basic_package_version_file(SilClangFormatConfigVersion.cmake
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMinorVersion)

install(FILES
  "${CMAKE_CURRENT_BINARY_DIR}/SilClangFormatConfigVersion.cmake"
  "${CMAKE_CURRENT_BINARY_DIR}/SilClangFormatConfig.cmake"
  DESTINATION share/cmake/SilClangFormat)

