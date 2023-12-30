# SPDX-License-Identifier: MIT

# https://cmake.org/cmake/help/book/mastering-cmake/chapter/Finding%20Packages.html#built-in-find-modules
set(tommath_FOUND ON)
find_library(tommath_LIB tommath)
find_path(tommath_INCL tommath.h)
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(tommath
  FOUND_VAR
    tommath_FOUND
  REQUIRED_VARS
    tommath_LIB
    tommath_INCL
)

set(tommath_LIBRARIES "${tommath_LIB}")
set(tommath_INCLUDE_DIRS "${tommath_INCL}")

file(GLOB_RECURSE tommath_HEADERS
  LIST_DIRECTORIES false
  "${tommath_INCLUDE_DIRS}/*.h"
  "${tommath_INCLUDE_DIRS}/*.hpp")

# Allows doing target_link_libraries(<target> PRIVATE tommath::tommath)
# instead of manually using the tommath_* variables. 
add_library(tommath::tommath STATIC IMPORTED)
target_sources(tommath::tommath
  INTERFACE
    FILE_SET "public_headers"
    TYPE "HEADERS"
    BASE_DIRS "${tommath_INCL}"
    FILES ${tommath_HEADERS}
)

# Not sure why we need this, but we get CMake errors when we don't. Note
# that these properties are only correct as long as the library is a static
# library. If it is a shared library, then look at these properties for how to
# set them.
set_property(TARGET tommath::tommath APPEND PROPERTY
  IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(tommath::tommath PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${tommath_LIB}"
  IMPORTED_LOCATION_RELEASE "${tommath_LIB}"
)

unset(tommath_LIB)
unset(tommath_INCL)
unset(tommath_HEADERS)
