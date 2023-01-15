set(SRC_SUBDIR "src")

file(GLOB_RECURSE CXX_SOURCES CONFIGURE_DEPENDS
  "${SRC_SUBDIR}/*.cpp")
file(GLOB_RECURSE CXX_HEADERS CONFIGURE_DEPENDS
  "${SRC_SUBDIR}/*.h"
  "${SRC_SUBDIR}/*.hpp")

add_executable(exe "${CXX_SOURCES}")
target_link_libraries(exe lib2)
install(TARGETS exe
  DESTINATION bin)

