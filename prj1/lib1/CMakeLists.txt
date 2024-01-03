# SPDX-License-Identifier: MIT

include("${CMAKE_SOURCE_DIR}/cmake/tree.cmake")
ade_set_source_files(lib1 C_CXX_SOURCES CXX_HEADERS_PUBLIC CXX_HEADERS_PRIVATE)

# This builds an 'object library', which is basically a collection of object
# files. The 'lib1' library will link against it.
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
add_library(lib1__objlib_internal OBJECT ${C_CXX_SOURCES})
# See comments of lib1 below. We're going to have to export the object library
# anyway, so let's create an alias for it too.
add_library(prj1::lib1__objlib_internal ALIAS lib1__objlib_internal)
set_target_properties(lib1__objlib_internal PROPERTIES LINKER_LANGUAGE CXX)

add_library(lib1 extra/cpp/dummy.cpp)
# Libraries/exes built outside *this* CMake build (aka "external dependencies")
# will link against this one prepended with the "prj1::" namespace. In order
# for libraries/exes built inside *this* CMake build (aka "internal
# dependencies") to have their dependencies look exactly the same as external
# dependencies, let's create an alias target that looks exactly like the
# external target.
#
# https://youtu.be/bsXLMQ6WgIk?t=3124
#
# Since this CMake build doesn't have any other library/executable, that means
# doing this is useless, but this is just to keep things consistent no matter
# what.
add_library(prj1::lib1 ALIAS lib1)
target_link_libraries(lib1 PUBLIC lib1__objlib_internal)

find_package(AdeClangFormat 1.1 CONFIG REQUIRED)
ade_clang_format_git_targets(TARGETS
  lib1
  lib1__objlib_internal)

set_target_properties(lib1
  PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
    # On Windows, symbols have to be explicitly exported and imported (usually
    # by a macro used inside the library's headers that is defined to
    # "__declspec(dllexport)" when building the library, and
    # "__declspec(dllimport)" when using the built library). However,
    # libtommath doesn't explicitly export its symbols since it's primarily
    # meant to be built on *nix (https://github.com/libtom/libtommath/blob/8314bde5e5c8e5d9331460130a9d1066e324f091/doc/bn.tex#L105)
    # So we'll have to set WINDOWS_EXPORT_ALL_SYMBOLS ON so that CMake
    # automatically exports all function symbols. For global data symbols
    # (i.e., global variables), we have to tweak the code of libtomcrypt so
    # that the headers that provide them use "__declspec(dllimport)", as
    # required by CMake:
    # https://cmake.org/cmake/help/latest/prop_tgt/WINDOWS_EXPORT_ALL_SYMBOLS.html
    WINDOWS_EXPORT_ALL_SYMBOLS ON)
set_target_properties(lib1__objlib_internal
  PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON)

# The object library's type is obviously OBJECT_LIBRARY, never SHARED_LIBRARY,
# so checking whether the final library is built as a static or a shared
# library should be done on the final library, not its underlying object
# library.
get_target_property(LIB_TYPE lib1 TYPE)
if (LIB_TYPE STREQUAL SHARED_LIBRARY)
  set(LIB_SHARED_MACRO "LIB1_SHARED")
  # Shared libraries always build with position-independent code.
  # No need to provide a cache option for this in this case.
  set(lib1_BUILD_WITH_PIC ON)
else()
  # Providing a CACHE option for this, since some users might want this.
  #
  # Default is OFF because this can sometimes have overhead:
  # https://stackoverflow.com/a/15890369/2252948.
  option(lib1_BUILD_WITH_PIC
    "Whether to build this static library with position-independent code in case it is linked against by a shared library."
    OFF)
endif()

if(lib1_BUILD_WITH_PIC)
  # Yes, both the object library AND the final library need the same PIC
  # setting, otherwise linking will fail on non-DLL platforms when
  # building shared libraries:
  #
  # "relocation R_X86_64_PC32 against symbol
  # `_ZTISt12domain_error@@GLIBCXX_3.4' can not be used when making a
  # shared object; recompile with -fPIC"
  set_target_properties(lib1
    PROPERTIES
      POSITION_INDEPENDENT_CODE "${lib1_BUILD_WITH_PIC}")
  set_target_properties(lib1__objlib_internal
    PROPERTIES
      POSITION_INDEPENDENT_CODE "${lib1_BUILD_WITH_PIC}")
endif()

target_compile_definitions(lib1__objlib_internal
  PUBLIC
    LIB1_MACRO=42
    # Unquoted variable expansion; this is on purpose: if the variable is empty
    # or undefined, we *actually* want this to expand to nothing.
    ${LIB_SHARED_MACRO}
    # Apparently StepMania defined this macro to be used with libtommath. This
    # seems to affect which symbols get generated by the library, and which
    # ones appear in the libtommath headers, so let's make that public.
    LTM_DESC
  PRIVATE
    # This macro will be used as part of the compilation of this library, but
    # won't be used for libraries/executables that depend on it. This is
    # exactly what we want when building shared libraries on Windows: we want
    # headers to have __declspec(dllexport) when building the library, but
    # we want headers to have __declspec(dllimport) when using the library.
    LIB1_EXPORT)

target_sources(lib1__objlib_internal
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

install(TARGETS lib1 lib1__objlib_internal
  EXPORT prj1Targets
  FILE_SET public_headers
  COMPONENT lib1
  DESTINATION include)

add_subdirectory(test)
