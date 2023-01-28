cmake_minimum_required(VERSION 3.23)

project(lib1
  VERSION 1.0
  LANGUAGES CXX)

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
# uses this project to do version checking:
# https://cmake.org/cmake/help/latest/command/find_package.html#config-mode-version-selection
write_basic_package_version_file(lib1ConfigVersion.cmake
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMinorVersion)

install(FILES
  "${CMAKE_CURRENT_BINARY_DIR}/lib1ConfigVersion.cmake"
  "${CMAKE_CURRENT_BINARY_DIR}/lib1Config.cmake"
  DESTINATION "${PACKAGE_CMAKE_SCRIPTS_DIR}")

