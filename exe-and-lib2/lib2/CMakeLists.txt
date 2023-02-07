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

find_package(SilClangFormat 2.0 CONFIG REQUIRED)
sil_clang_format_targets(TARGETS lib2
  POSTFIX format)

get_target_property(LIB_TYPE lib2 TYPE)
if(LIB_TYPE STREQUAL SHARED_LIBRARY)
  set(LIB_SHARED_MACRO "LIB2_SHARED")
else()
  # Providing a CACHE option for this, since some users might want this.
  #
  # Default is OFF because this can sometimes have overhead:
  # https://stackoverflow.com/a/15890369/2252948.
  option(lib2_BUILD_WITH_PIC
	"Whether to build this static library with position-independent code in case it is linked against by a shared library."
	OFF)
  set_target_properties(lib2
	PROPERTIES
      POSITION_INDEPENDENT_CODE "${lib2_BUILD_WITH_PIC}")
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
  get_target_property(LIB_SHARED lib2::lib2 TYPE)
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
# uses this package to do version checking:
# https://cmake.org/cmake/help/latest/command/find_package.html#config-mode-version-selection
write_basic_package_version_file(exelib2ConfigVersion.cmake
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
configure_package_config_file(cmake/exelib2Config.cmake.in
  "${CMAKE_CURRENT_BINARY_DIR}/exelib2Config.cmake"
  INSTALL_DESTINATION "${PACKAGE_CMAKE_SCRIPTS_DIR}"
  PATH_VARS EXPORT_FILE)

install(FILES
  "${CMAKE_CURRENT_BINARY_DIR}/exelib2ConfigVersion.cmake"
  "${CMAKE_CURRENT_BINARY_DIR}/exelib2Config.cmake"
  DESTINATION "${PACKAGE_CMAKE_SCRIPTS_DIR}")

