cmake_minimum_required(VERSION 3.23)

project(lib1 LANGUAGES CXX)
set(SRC_SUBDIR src)

file(GLOB_RECURSE CXX_SOURCES CONFIGURE_DEPENDS "${SRC_SUBDIR}/*.cpp")
file(GLOB_RECURSE CXX_HEADERS CONFIGURE_DEPENDS "${SRC_SUBDIR}/*.h")

add_library(lib1 "${CXX_SOURCES}")

target_sources(lib1 PUBLIC
  FILE_SET HEADERS
  # Don't install "include/lib1/${SRC_SUBDIR}/hdr.h", install
  # "include/lib1/hdr.h" instead.
  BASE_DIRS "${SRC_SUBDIR}"
  FILES "${CXX_HEADERS}")

install(TARGETS lib1 EXPORT lib1Export
  FILE_SET HEADERS
  DESTINATION include/lib1)
install(EXPORT lib1Export
  DESTINATION cmake/lib1)

