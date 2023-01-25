file(GLOB_RECURSE CXX_SOURCES CONFIGURE_DEPENDS
  "src/*.cpp")
file(GLOB_RECURSE CXX_HEADERS_PUBLIC CONFIGURE_DEPENDS
  "include/*.h"
  "include/*.hpp")
file(GLOB_RECURSE CXX_HEADERS_PRIVATE CONFIGURE_DEPENDS
  "src/*.h"
  "src/*.hpp")

include(${LIB1_INSTALL_DIR}/lib/cmake/lib1/lib1Targets.cmake)

add_library(lib2 ${CXX_SOURCES})
# Libraries built outside *this* CMake build (aka "external dependencies") will
# link agains this one prepended with the "lib2::" namespace. In order for
# libraries build inside *this* CMake build (aka "internal dependencies") to
# have their dependencies look exactly the same as external dependencies, let's
# create an alias target that looks exactly like the external, exported,
# target.
#
# https://youtu.be/bsXLMQ6WgIk?t=3124
add_library(lib2::lib2 ALIAS lib2)

target_link_libraries(lib2
  PUBLIC lib1::lib1)

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

install(TARGETS lib2
  EXPORT lib2Targets
  FILE_SET HEADERS
  DESTINATION include)
install(EXPORT lib2Targets
  # Why to have "::" is described here:
  # https://youtu.be/bsXLMQ6WgIk?t=1578
  NAMESPACE lib2::
  DESTINATION lib/cmake/lib2)

