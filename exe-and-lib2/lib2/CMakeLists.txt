file(GLOB_RECURSE CXX_SOURCES CONFIGURE_DEPENDS
  "src/*.cpp")
file(GLOB_RECURSE CXX_HEADERS_PUBLIC CONFIGURE_DEPENDS
  "include/*.h"
  "include/*.hpp")
file(GLOB_RECURSE CXX_HEADERS_PRIVATE CONFIGURE_DEPENDS
  "src/*.h"
  "src/*.hpp")

add_library(lib2 ${CXX_SOURCES})
# Libraries built outside *this* CMake build (aka "external dependencies") will
# link against this one prepended with the "lib2::" namespace. In order for
# libraries built inside *this* CMake build (aka "internal dependencies") to
# have their dependencies look exactly the same as external dependencies, let's
# create an alias target that looks exactly like the external target.
#
# https://youtu.be/bsXLMQ6WgIk?t=3124
add_library(lib2::lib2 ALIAS lib2)

find_package(lib1 1.0 REQUIRED CONFIG)
target_link_libraries(lib2
  PUBLIC lib1::lib1)

get_target_property(LIB_TYPE lib2 TYPE)
if (LIB_TYPE STREQUAL SHARED_LIBRARY)
  set(LIB_SHARED_MACRO "LIB2_SHARED")
endif()

target_compile_definitions(lib2
  PUBLIC
	# Unquoted variable expansion; this is on purpose: if the variable is empty
	# or undefined, we *actually* want this to expand to nothing.
	${LIB_SHARED_MACRO}
  PRIVATE
    # This macro will be used as part of the compilation of this library, but
    # won't be used for libraries/executables that depend on it. This is
	# exactly what we want when building shared libraries on Windows: we want
	# headers to have __declspec(dllexport) when building the library, but
	# we want headers to have __declspec(dllimport) when using the library.
    LIB2_EXPORT)

target_sources(lib2
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

set(PACKAGE_CMAKE_SCRIPTS_DIR lib/cmake/lib2)

install(TARGETS lib2
  EXPORT lib2Targets
  FILE_SET HEADERS
  DESTINATION include)
install(EXPORT lib2Targets
  # Why to have "::" is described here:
  # https://youtu.be/bsXLMQ6WgIk?t=1578
  NAMESPACE lib2::
  DESTINATION "${PACKAGE_CMAKE_SCRIPTS_DIR}")

set(EXPORT_FILE "${PACKAGE_CMAKE_SCRIPTS_DIR}/lib1Targets.cmake")

include(CMakePackageConfigHelpers)
# Write a CMake script containing the version information & checking for
# this project. This is used in the find_package() call of the project that
# uses this project to do version checking:
# https://cmake.org/cmake/help/latest/command/find_package.html#config-mode-version-selection
write_basic_package_version_file(exelib2ConfigVersion.cmake
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMinorVersion)
configure_package_config_file(cmake/exelib2Config.cmake.in
  "${CMAKE_CURRENT_BINARY_DIR}/exelib2Config.cmake"
  INSTALL_DESTINATION "${PACKAGE_CMAKE_SCRIPTS_DIR}"
  PATH_VARS EXPORT_FILE)

install(FILES
  "${CMAKE_CURRENT_BINARY_DIR}/exelib2ConfigVersion.cmake"
  "${CMAKE_CURRENT_BINARY_DIR}/exelib2Config.cmake"
  DESTINATION "${PACKAGE_CMAKE_SCRIPTS_DIR}")

