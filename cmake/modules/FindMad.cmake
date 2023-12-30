# SPDX-License-Identifier: MIT

find_package(PkgConfig REQUIRED QUIET)
# Parses libmad's pkg-config file and creates a PkgConfig::Mad target.
pkg_check_modules(Mad QUIET mad
  IMPORTED_TARGET)

add_library(Mad::Mad ALIAS PkgConfig::Mad)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Mad
  REQUIRED_VARS
    PKG_CONFIG_FOUND
    Mad_FOUND
    Mad_LIBRARIES
)
