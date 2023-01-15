set(SRC_SUBDIR "src")

file(GLOB_RECURSE CXX_SOURCES CONFIGURE_DEPENDS
  "${SRC_SUBDIR}/*.cpp")
file(GLOB_RECURSE CXX_HEADERS CONFIGURE_DEPENDS
  "${SRC_SUBDIR}/*.h"
  "${SRC_SUBDIR}/*.hpp")

include("${LIB1_INSTALL_DIR}/cmake/lib1/lib1Export.cmake")

add_library(lib2 "${CXX_SOURCES}")
target_link_libraries(lib2
  PUBLIC lib1)

target_sources(lib2 PUBLIC
  FILE_SET HEADERS
  # Don't install "include/lib2/${SRC_SUBDIR}/hdr.h", install
  # "include/lib2/hdr.h" instead.
  BASE_DIRS "${SRC_SUBDIR}"
  FILES "${CXX_HEADERS}")

install(TARGETS lib2
  EXPORT lib2Export
  FILE_SET HEADERS
  DESTINATION include/lib2)
install(EXPORT lib2Export
  DESTINATION cmake/lib2)

