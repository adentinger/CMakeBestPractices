# SPDX-License-Identifier: MIT

cmake_minimum_required(VERSION 3.23)

# This is required to be before the first project() call of the CMake build.
set(CMAKE_TOOLCHAIN_FILE
  "${CMAKE_CURRENT_SOURCE_DIR}/../vcpkg/scripts/buildsystems/vcpkg.cmake"
  CACHE STRING "Vcpkg toolchain file.")

project(lib1
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

file(GLOB_RECURSE CXX_SOURCES CONFIGURE_DEPENDS
  "src/*.cpp")
file(GLOB_RECURSE CXX_HEADERS_PUBLIC CONFIGURE_DEPENDS
  "include/*.h"
  "include/*.hpp")
file(GLOB_RECURSE CXX_HEADERS_PRIVATE CONFIGURE_DEPENDS
  "src/*.h"
  "src/*.hpp")

add_library(lib1 ${CXX_SOURCES})
# Libraries built outside *this* CMake build (aka "external dependencies") will
# link against this one prepended with the "lib1::" namespace. In order for
# libraries built inside *this* CMake build (aka "internal dependencies") to
# have their dependencies look exactly the same as external dependencies, let's
# create an alias target that looks exactly like the external target.
#
# https://youtu.be/bsXLMQ6WgIk?t=3124
#
# Since this CMake build doesn't have any other library/executable, that means
# doing this is useless, but this is just to keep things consistent no matter what.
add_library(lib1::lib1 ALIAS lib1)

find_package(AdeClangFormat 2.0 CONFIG REQUIRED)
ade_clang_format_targets(TARGETS lib1
  POSTFIX format)

set_target_properties(lib1
  PROPERTIES
  CXX_STANDARD 17
  CXX_STANDARD_REQUIRED ON)

get_target_property(LIB_TYPE lib1 TYPE)
if (LIB_TYPE STREQUAL SHARED_LIBRARY)
  set(LIB_SHARED_MACRO "LIB1_SHARED")
else()
  # Providing a CACHE option for this, since some users might want this.
  #
  # Default is OFF because this can sometimes have overhead:
  # https://stackoverflow.com/a/15890369/2252948.
  option(lib1_BUILD_WITH_PIC
	"Whether to build this static library with position-independent code in case it is linked against by a shared library."
	OFF)
  set_target_properties(lib1
	PROPERTIES
      POSITION_INDEPENDENT_CODE "${lib1_BUILD_WITH_PIC}")
endif()

target_compile_definitions(lib1
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

target_sources(lib1
  # The headers that are available to consumer targets and for compilation of
  # this library.
  # This also adds the correct include directory to whatever target is
  # consuming this library.
  # This will work even if the headers have spaces in their names/paths.
  # This also works if there are no headers.
  PUBLIC
    FILE_SET HEADERS
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

set(PACKAGE_CMAKE_SCRIPTS_DIR lib/cmake/lib1)

install(TARGETS lib1
  EXPORT lib1Targets
  FILE_SET HEADERS
  DESTINATION include)
install(EXPORT lib1Targets
  # Why to have "::" is described here:
  # https://youtu.be/bsXLMQ6WgIk?t=1578
  NAMESPACE lib1::
  DESTINATION "${PACKAGE_CMAKE_SCRIPTS_DIR}")

set(EXPORT_FILE "${PACKAGE_CMAKE_SCRIPTS_DIR}/lib1Targets.cmake")

include(CMakePackageConfigHelpers)
configure_package_config_file(cmake/lib1Config.cmake.in
  "${CMAKE_CURRENT_BINARY_DIR}/lib1Config.cmake"
  INSTALL_DESTINATION "${PACKAGE_CMAKE_SCRIPTS_DIR}"
  PATH_VARS EXPORT_FILE)
# Write a CMake script containing the version information & checking for
# this project. This is used in the find_package() call of the project that
# uses this package to do version checking:
# https://cmake.org/cmake/help/latest/command/find_package.html#config-mode-version-selection
write_basic_package_version_file(lib1ConfigVersion.cmake
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
  "${CMAKE_CURRENT_BINARY_DIR}/lib1ConfigVersion.cmake"
  "${CMAKE_CURRENT_BINARY_DIR}/lib1Config.cmake"
  DESTINATION "${PACKAGE_CMAKE_SCRIPTS_DIR}")

# Needed by WIX .msi installers. This is not a special CMake variable; it is
# used below.
set(CPACK_PROJECT_GUID "a33548b9-3a57-4cb9-8d42-36e47b783a54")

# https://cmake.org/cmake/help/latest/module/CPack.html
set(CPACK_PACKAGE_VENDOR "Anthony Dentinger"
  CACHE STRING "Name of the package vendor.")
# Not documented, but used for Debian package creation as the default value
# of the (mandatory) CPACK_DEBIAN_PACKAGE_MAINTAINER variable.
set(CPACK_PACKAGE_CONTACT "adentinger.dev@gmail.com"
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

