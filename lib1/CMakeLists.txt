cmake_minimum_required(VERSION 3.23)

project(lib1 LANGUAGES CXX)
set(PROJECT_INCLUDE_DIR include)
set(SRC_SUBDIR src)

file(GLOB_RECURSE CXX_SOURCES CONFIGURE_DEPENDS
  "${SRC_SUBDIR}/*.cpp")
file(GLOB_RECURSE CXX_HEADERS_PUBLIC CONFIGURE_DEPENDS
  "${PROJECT_INCLUDE_DIR}/*.h"
  "${PROJECT_INCLUDE_DIR}/*.hpp")
file(GLOB_RECURSE CXX_HEADERS_PRIVATE CONFIGURE_DEPENDS
  "${SRC_SUBDIR}/*.h"
  "${SRC_SUBDIR}/*.hpp")

add_library(lib1 ${CXX_SOURCES})

target_compile_definitions(lib1 PUBLIC LIB1_MACRO=42)

target_sources(lib1
  # The headers that are available to consumer targets and for compilation of
  # this library.
  # This also adds the correct include directory to whatever target is
  # consuming this library.
  # This will work even if the headers have spaces in their names/paths.
  # This also works if there are no headers.
  PUBLIC
    FILE_SET HEADERS
    BASE_DIRS include
    FILES ${CXX_HEADERS_PUBLIC}
	# The headers that are available only for compilation of this library.
	# Won't be installed.
  PRIVATE
    FILE_SET private_headers
    TYPE HEADERS
    BASE_DIRS src
    FILES ${CXX_HEADERS_PRIVATE})

install(TARGETS lib1
  EXPORT lib1Targets
  FILE_SET HEADERS
  DESTINATION include)
install(EXPORT lib1Targets
  DESTINATION lib/cmake/lib1)

