# SPDX-License-Identifier: MIT

# https://cmake.org/cmake/help/book/mastering-cmake/chapter/Finding%20Packages.html#built-in-find-modules
set(Tomcrypt_FOUND ON)
find_library(Tomcrypt_LIB Tomcrypt)
find_path(Tomcrypt_INCL Tomcrypt.h)
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Tomcrypt
  FOUND_VAR
    Tomcrypt_FOUND
  REQUIRED_VARS
    Tomcrypt_LIB
    Tomcrypt_INCL
)

set(Tomcrypt_LIBRARIES "${Tomcrypt_LIB}")
set(Tomcrypt_INCLUDE_DIRS "${Tomcrypt_INCL}")

file(GLOB_RECURSE Tomcrypt_HEADERS
  LIST_DIRECTORIES false
  "${Tomcrypt_INCLUDE_DIRS}/*.h"
  "${Tomcrypt_INCLUDE_DIRS}/*.hpp")

# Allows doing target_link_libraries(<target> PRIVATE tomcrypt::tomcrypt)
# instead of manually using the Tomcrypt_* variables.
add_library(tomcrypt::tomcrypt STATIC IMPORTED)
target_sources(tomcrypt::tomcrypt
  INTERFACE
    FILE_SET "public_headers"
    TYPE "HEADERS"
    BASE_DIRS "${Tomcrypt_INCL}"
    FILES ${Tomcrypt_HEADERS}
)

# Not sure why we need this, but we get CMake errors when we don't. Note
# that these properties are only correct as long as the library is a static
# library. If it is a shared library, then look at these properties for how to
# set them.
set_property(TARGET tomcrypt::tomcrypt APPEND PROPERTY
  IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(tomcrypt::tomcrypt PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${Tomcrypt_LIB}"
  IMPORTED_LOCATION_RELEASE "${Tomcrypt_LIB}"
)

unset(Tomcrypt_LIB)
unset(Tomcrypt_INCL)
unset(Tomcrypt_HEADERS)
