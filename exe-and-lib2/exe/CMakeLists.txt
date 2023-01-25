file(GLOB_RECURSE CXX_SOURCES CONFIGURE_DEPENDS
  "src/*.cpp")
file(GLOB_RECURSE CXX_HEADERS CONFIGURE_DEPENDS
  "src/*.h"
  "src/*.hpp")

add_executable(exe ${CXX_SOURCES})
target_link_libraries(exe lib2::lib2)
install(TARGETS exe
  DESTINATION bin)

