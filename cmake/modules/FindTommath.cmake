# SPDX-License-Identifier: MIT

# https://cmake.org/cmake/help/book/mastering-cmake/chapter/Finding%20Packages.html#built-in-find-modules
set(Tommath_FOUND ON)
find_library(Tommath_LIB Tommath)
find_path(Tommath_INCL Tommath.h)
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Tommath
  FOUND_VAR
    Tommath_FOUND
  REQUIRED_VARS
    Tommath_LIB
    Tommath_INCL
)

set(Tommath_LIBRARIES "${Tommath_LIB}")
set(Tommath_INCLUDE_DIRS "${Tommath_INCL}")

file(GLOB_RECURSE Tommath_HEADERS
  LIST_DIRECTORIES false
  "${Tommath_INCLUDE_DIRS}/*.h"
  "${Tommath_INCLUDE_DIRS}/*.hpp")

# Allows doing target_link_libraries(<target> PRIVATE tommath::tommath)
# instead of manually using the Tommath_* variables. 
add_library(tommath::tommath STATIC IMPORTED)
target_sources(tommath::tommath
  INTERFACE
    FILE_SET "public_headers"
    TYPE "HEADERS"
    BASE_DIRS "${Tommath_INCL}"
    FILES ${Tommath_HEADERS}
)

# Not sure why we need this, but we get CMake errors when we don't. Note
# that these properties are only correct as long as the library is a static
# library. If it is a shared library, then look at these properties for how to
# set them.
set_property(TARGET tommath::tommath APPEND PROPERTY
  IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(tommath::tommath PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${Tommath_LIB}"
  IMPORTED_LOCATION_RELEASE "${Tommath_LIB}"
)

unset(Tommath_LIB)
unset(Tommath_INCL)
unset(Tommath_HEADERS)
