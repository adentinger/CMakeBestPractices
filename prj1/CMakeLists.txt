# SPDX-License-Identifier: MIT

cmake_minimum_required(VERSION 3.26)

# This is required to be before the first project() call of the CMake build.
set(CMAKE_TOOLCHAIN_FILE
  "${CMAKE_CURRENT_SOURCE_DIR}/../vcpkg/scripts/buildsystems/vcpkg.cmake"
  CACHE STRING "Vcpkg toolchain file.")

project(prj1
  VERSION 1.0
  LANGUAGES CXX
  HOMEPAGE_URL "https://github.com/AnthonyD973/CMakeBestPracticesTests"
  DESCRIPTION "A library meant to be imported by another CMake project.")
# Note that this variable is not a special CMake variable.
set(PROJECT_LICENSE_FILE "${CMAKE_SOURCE_DIR}/../LICENSE.txt"
  CACHE FILEPATH "Path to the license file for this project.")

# Reason to do that whether we have tests or not:
# https://youtu.be/IZXNsim9TWI?t=2426
enable_testing()

# https://youtu.be/bsXLMQ6WgIk?t=2809
set(CMAKE_DEBUG_POSTFIX -d)

# Always good to specify a default, even if we're going to set these properties
# on all targets. Not all compilers have the same default C++ version, and we
# obviously want to avoid discrepancies as much as possible.
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

file(GLOB_RECURSE CXX_SOURCES CONFIGURE_DEPENDS
  "src/*.cpp")
file(GLOB_RECURSE CXX_HEADERS_PUBLIC CONFIGURE_DEPENDS
  "include/*.h"
  "include/*.hpp")
file(GLOB_RECURSE CXX_HEADERS_PRIVATE CONFIGURE_DEPENDS
  "src/*.h"
  "src/*.hpp")

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
add_library(lib1__objlib_internal OBJECT ${CXX_SOURCES})
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
    CXX_STANDARD_REQUIRED ON)
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
	# "include/" is the include directory to use for the headers in this
	# file set. This also means that the files will be installed without an
	# initial "include" directory at the begining.
    BASE_DIRS include
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

set(PACKAGE_CMAKE_SCRIPTS_DIR lib/cmake/prj1)
# Creation/installation of the CMake targets description script, which
# propagates to library/executable consumers the needed dependency
# and meta information on these targets (include dirs to add,
# flags to compile with, other libraries that are depended on, target
# properties, ...).
#
# Note that we must do this in the top-level CMakeLists.txt, because we can
# only specify install(EXPORT) once per CMake targets description script, and
# in our case we've decided to have a single such script containing the
# description of all installed targets.
install(EXPORT prj1Targets
  # Why to have "::" is described here:
  # https://youtu.be/bsXLMQ6WgIk?t=1578
  NAMESPACE prj1::
  DESTINATION "${PACKAGE_CMAKE_SCRIPTS_DIR}")

set(EXPORT_FILE "${PACKAGE_CMAKE_SCRIPTS_DIR}/prj1Targets.cmake")

include(CMakePackageConfigHelpers)
configure_package_config_file(cmake/prj1Config.cmake.in
  "${CMAKE_CURRENT_BINARY_DIR}/prj1Config.cmake"
  INSTALL_DESTINATION "${PACKAGE_CMAKE_SCRIPTS_DIR}"
  PATH_VARS EXPORT_FILE)
# Write a CMake script containing the version information & checking for
# this project. This is used in the find_package() call of the project that
# uses this package to do version checking:
# https://cmake.org/cmake/help/latest/command/find_package.html#config-mode-version-selection
write_basic_package_version_file(prj1ConfigVersion.cmake
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
  COMPATIBILITY SameMinorVersion)

install(FILES
  "${CMAKE_CURRENT_BINARY_DIR}/prj1ConfigVersion.cmake"
  "${CMAKE_CURRENT_BINARY_DIR}/prj1Config.cmake"
  DESTINATION "${PACKAGE_CMAKE_SCRIPTS_DIR}")

# Needed by WIX .msi installers. This is not a special CMake variable; it is
# used below.
set(CPACK_PROJECT_GUID "a33548b9-3a57-4cb9-8d42-36e47b783a54")

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
set(CPACK_DEBIAN_PACKAGE_RECOMMENDS ""
  CACHE STRING "Used in .deb package. Recommended (but not required) package.")

# https://cmake.org/cmake/help/latest/cpack_gen/rpm.html#variable:CPACK_RPM_PACKAGE_REQUIRES
#
# According to the CMake doc, SUGGESTS is not always supported, so just use
# REQUIRES.
set(CPACK_RPM_PACKAGE_REQUIRES ""
  CACHE STRING "Used in .rpm package. Required package.")
set(CPACK_RPM_PACKAGE_SUGGESTS ""
  CACHE STRING "Used in .rpm package. Suggested package.")

# Must be different for each project. Allows detecting and replacing existing
# installations.
set(CPACK_WIX_UPGRADE_GUID "${CPACK_PROJECT_GUID}"
  CACHE STRING "Used in WIX .msi installers. Project GUID.")

include(CPack)

add_subdirectory(test)

