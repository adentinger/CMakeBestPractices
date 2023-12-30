# SPDX-License-Identifier: MIT

# https://cmake.org/cmake/help/book/mastering-cmake/chapter/Finding%20Packages.html#built-in-find-modules
set(tomcrypt_FOUND ON)
find_library(tomcrypt_LIB tomcrypt)
find_path(tomcrypt_INCL tomcrypt.h)
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(tomcrypt
  FOUND_VAR
    tomcrypt_FOUND
  REQUIRED_VARS
    tomcrypt_LIB
    tomcrypt_INCL
)

set(tomcrypt_LIBRARIES "${tomcrypt_LIB}")
set(tomcrypt_INCLUDE_DIRS "${tomcrypt_INCL}")

file(GLOB_RECURSE tomcrypt_HEADERS
  LIST_DIRECTORIES false
  "${tomcrypt_INCLUDE_DIRS}/*.h"
  "${tomcrypt_INCLUDE_DIRS}/*.hpp")

# Allows doing target_link_libraries(<target> PRIVATE tomcrypt::tomcrypt)
# instead of manually using the tomcrypt_* variables.
add_library(tomcrypt::tomcrypt STATIC IMPORTED)
target_sources(tomcrypt::tomcrypt
  INTERFACE
    FILE_SET "public_headers"
    TYPE "HEADERS"
    BASE_DIRS "${tomcrypt_INCL}"
    FILES ${tomcrypt_HEADERS}
)

unset(tomcrypt_LIB)
unset(tomcrypt_INCL)
unset(tomcrypt_HEADERS)
