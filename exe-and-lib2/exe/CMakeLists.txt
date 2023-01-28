file(GLOB_RECURSE CXX_SOURCES CONFIGURE_DEPENDS
  "src/*.cpp")
file(GLOB_RECURSE CXX_HEADERS CONFIGURE_DEPENDS
  "src/*.h"
  "src/*.hpp")

add_executable(exe ${CXX_SOURCES})
target_link_libraries(exe lib2::lib2)
set_target_properties(exe PROPERTIES
  INSTALL_RPATH ../lib)
install(TARGETS exe
  DESTINATION bin)
# On Windows, DLLs need to be in the same directory as the executable for it to
# run. Not super happy about having to pull a file from an external
# installation into this installation because a package manager like vcpkg
# would want to manage the dependencies themselves (that's what they are there
# for right?), but I don't really see an alternative at the moment, aside from
# making sure that the package of lib1 is installed to the same directory as
# the package of this project.
install(FILES $<TARGET_RUNTIME_DLLS:exe>
  DESTINATION bin)

