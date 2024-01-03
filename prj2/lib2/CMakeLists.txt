# SPDX-License-Identifier: MIT

include("${CMAKE_SOURCE_DIR}/cmake/tree.cmake")
ade_set_source_files(lib1 C_CXX_SOURCES CXX_HEADERS_PUBLIC CXX_HEADERS_PRIVATE)

# This builds an 'object library', which is basically a collection of object
# files. The 'lib2' library will link against it.
#
# There are three reasons for doing this despite making the rest of the
# code below a little more complicated:
#
# 1) When building an executable, how would we run unit tests on the sources
# of the executable unless we put them in a library such as an object library,
# and then linked the unit test executable against that library?
#
# 2) When building a shared library, if the library exports only a part of its
# symbols (as is the case by default with Windows DLLs, and is apparently
# also possible with other compilers like GCC), then how would we run
# unit tests on the symbols that are not exported if the unit test executable
# is linking against that shared library? See this answer from a
# well-known CMake maintainer:
# https://discourse.cmake.org/t/unit-testing-internal-functions-of-a-dll/3805/2?u=anthonyd973
#
# 3) Again when building a shared library, DLLs on Windows need to be in the
# same directory as the executable for the executable to find them at runtime.
# If we linked the unit test executable against the DLL, the DLL wouldn't be
# in the same directory as the test executable, so the test executable wouldn't
# be able to run. Instead, we should build an object library and link the
# test executable against that.
add_library(lib2__objlib_internal OBJECT ${C_CXX_SOURCES})
# See comments of lib2 below. We're going to have to export the object library
# anyway, so let's create an alias for it too.
add_library(prj2::lib2__objlib_internal ALIAS lib2__objlib_internal)
set_target_properties(lib2__objlib_internal
  PROPERTIES
    LINKER_LANGUAGE CXX)

add_library(lib2 extra/cpp/dummy.cpp)
# Libraries/exes built outside *this* CMake build (aka "external dependencies")
# will link against this one prepended with the "prj2::" namespace. In order
# for libraries/exes built inside *this* CMake build (aka "internal
# dependencies") to have their dependencies look exactly the same as external
# dependencies, let's create an alias target that looks exactly like the
# external target.
#
# https://youtu.be/bsXLMQ6WgIk?t=3124
add_library(prj2::lib2 ALIAS lib2)
target_link_libraries(lib2 PUBLIC lib2__objlib_internal)

find_package(prj1 1.0 REQUIRED CONFIG)
target_link_libraries(lib2__objlib_internal
  PUBLIC prj1::lib1)

find_package(AdeClangFormat 1.1 CONFIG REQUIRED)
ade_clang_format_git_targets(TARGETS
  lib2
  lib2__objlib_internal)

set_target_properties(lib2
  PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
    # On Windows, symbols have to be explicitly exported and imported (usually
    # by a macro used inside the library's headers that is defined to
    # "__declspec(dllexport)" when building the library, and
    # "__declspec(dllimport)" when using the built library). However,
    # libtomcrypt doesn't explicitly export its symbols since it's primarily
    # meant to be built on *nix.
    # So we'll have to set WINDOWS_EXPORT_ALL_SYMBOLS ON so that CMake
    # automatically exports all symbols. For global data symbols
    # (i.e., global variables), we have to tweak the code of libtomcrypt so
    # that the headers that provide them use "__declspec(dllimport)", as
    # required by CMake:
    # https://cmake.org/cmake/help/latest/prop_tgt/WINDOWS_EXPORT_ALL_SYMBOLS.html
    WINDOWS_EXPORT_ALL_SYMBOLS ON)
set_target_properties(lib2__objlib_internal
  PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON)

# The object library's type is obviously OBJECT_LIBRARY, never SHARED_LIBRARY,
# so checking whether the final library is built as a static or a shared
# library should be done on the final library, not its underlying object
# library.
get_target_property(LIB_TYPE lib2 TYPE)
if(LIB_TYPE STREQUAL SHARED_LIBRARY)
  set(LIB_SHARED_MACRO "LIB2_SHARED")
  # Shared libraries always build with position-independent code.
  # No need to provide a cache option for this in this case.
  set(lib2_BUILD_WITH_PIC ON)
else()
  # Providing a CACHE option for this, since some users might want this.
  #
  # Default is OFF because this can sometimes have overhead:
  # https://stackoverflow.com/a/15890369/2252948.
  option(lib2_BUILD_WITH_PIC
    "Whether to build this static library with position-independent code in case it is linked against by a shared library."
    OFF)
endif()

if(lib2_BUILD_WITH_PIC)
  # Yes, both the object library AND the final library need the same PIC
  # setting, otherwise linking will fail on non-DLL platforms when
  # building shared libraries:
  #
  # "relocation R_X86_64_PC32 against symbol
  # `_ZTISt12domain_error@@GLIBCXX_3.4' can not be used when making a
  # shared object; recompile with -fPIC"
  set_target_properties(lib2
    PROPERTIES
      POSITION_INDEPENDENT_CODE "${lib2_BUILD_WITH_PIC}")
  set_target_properties(lib2__objlib_internal
    PROPERTIES
      POSITION_INDEPENDENT_CODE "${lib2_BUILD_WITH_PIC}")
endif()

target_compile_definitions(lib2__objlib_internal
  PUBLIC
    # Unquoted variable expansion; this is on purpose: if the variable is empty
    # or undefined, we *actually* want this to expand to nothing.
    ${LIB_SHARED_MACRO}
    # These macros were found in StepMania's "libtomcrypt_VS2008.vcproj". We
    # don't know what they do, so just add them.
    _CRT_SECURE_NO_WARNINGS
    _CRT_NONSTDC_NO_DEPRECATE
    LTC_SOURCE
    LTC_NO_TEST
    LTC_NO_PROTOTYPES
  PRIVATE
    # This macro will be used as part of the compilation of this library, but
    # won't be used for libraries/executables that depend on it. This is
    # exactly what we want when building shared libraries on Windows: we want
    # headers to have __declspec(dllexport) when building the library, but
    # we want headers to have __declspec(dllimport) when using the library.
    LIB2_EXPORT)

target_sources(lib2__objlib_internal
  # The headers that are available to consumer targets and for compilation of
  # this library.
  # This also adds the correct include directory to whatever target is
  # consuming this library.
  # This will work even if the headers have spaces in their names/paths.
  # This also works if there are no headers.
  PUBLIC
    FILE_SET public_headers
    TYPE HEADERS
    # "src/" is the include directory to use for the headers in this
    # file set. This also means that the files will be installed without an
    # initial "src" directory at the begining.
    BASE_DIRS src
    FILES ${CXX_HEADERS_PUBLIC}
  # The headers that are available only for compilation of this library.
  # Won't be installed.
  PRIVATE
    FILE_SET private_headers
    TYPE HEADERS
    BASE_DIRS src
    FILES ${CXX_HEADERS_PRIVATE})

# Properties used only when building shared libraries.
#
# For Apple and Unix-like platforms (although maybe not Cygwin?), an RPATH
# metadata variable can be set inside the linked executable/library to specify
# a search path for dependant shared libraries. However, this cannot be a
# relative path because it would be relative to where the executable is run
# from, which isn't what we want. So instead we specify a special string to
# make the path relative to where the executable is located.
#
# Note that we use CACHE variables here. This is to allow whoever is
# configuring the CMake build to override the values if they want to, while
# still providing a sane default.
if(APPLE)
  # There is also "@rpath" that is a bit more flexible, but really the equivalent
  # of "$ORIGIN" for Unix is "@executable_path".
  set(LIB2_INSTALL_RPATH @executable_path/../lib CACHE STRING "RPATH to use for this target.")
elseif(UNIX AND NOT CYGWIN)
  # "$ORIGIN" is a special string that means "the directory containing the
  # executable that is running".
  set(LIB2_INSTALL_RPATH $ORIGIN/../lib CACHE STRING "RPATH to use for this target.")
elseif(WIN32)
  # DLL platforms don't support RPATH.
  set(LIB2_INSTALL_RPATH "")
else()
  get_target_property(LIB_SHARED prj2::lib2 TYPE)
  if ("${LIB_SHARED}" STREQUAL SHARED_LIBRARY)
	message(FATAL_ERROR
	  "Unsupported target platform ${CMAKE_SYSTEM_NAME} for linking against "
	  "shared libraries.")
  endif()
  set(LIB2_INSTALL_RPATH "")
endif()

set_target_properties(lib2
  PROPERTIES
  INSTALL_RPATH "${LIB2_INSTALL_RPATH}")

install(TARGETS lib2 lib2__objlib_internal
  EXPORT prj2Targets
  FILE_SET public_headers
  # https://youtu.be/IZXNsim9TWI?t=2475
  COMPONENT lib2
  DESTINATION include)

add_subdirectory(test)
