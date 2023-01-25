set(SRC_SUBDIR src)

file(GLOB_RECURSE CXX_SOURCES CONFIGURE_DEPENDS
  "${SRC_SUBDIR}/*.cpp")
file(GLOB_RECURSE CXX_HEADERS_PUBLIC CONFIGURE_DEPENDS
  "${PROJECT_INCLUDE_DIR}/*.h"
  "${PROJECT_INCLUDE_DIR}/*.hpp")
file(GLOB_RECURSE CXX_HEADERS_PRIVATE CONFIGURE_DEPENDS
  "${SRC_SUBDIR}/*.h"
  "${SRC_SUBDIR}/*.hpp")

include(${LIB1_INSTALL_DIR}/lib/cmake/lib1/lib1Targets.cmake)

add_library(lib2 ${CXX_SOURCES})

target_link_libraries(lib2
  PUBLIC lib1)

target_sources(lib2
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
  PRIVATE
    FILE_SET private_headers
    TYPE HEADERS
    BASE_DIRS src
    FILES ${CXX_HEADERS_PRIVATE})

install(TARGETS lib2
  EXPORT lib2Targets
  FILE_SET HEADERS
  DESTINATION include)
install(EXPORT lib2Targets
  DESTINATION lib/cmake/lib2)

