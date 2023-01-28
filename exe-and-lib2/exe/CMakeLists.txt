file(GLOB_RECURSE CXX_SOURCES CONFIGURE_DEPENDS
  "src/*.cpp")
file(GLOB_RECURSE CXX_HEADERS CONFIGURE_DEPENDS
  "src/*.h"
  "src/*.hpp")

add_executable(exe ${CXX_SOURCES})
target_link_libraries(exe lib2::lib2)

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
  set(EXE_INSTALL_RPATH @executable_path/../lib CACHE STRING "RPATH to use for this target.")
elseif(UNIX AND NOT CYGWIN)
  # "$ORIGIN" is a special string that means "the directory containing the
  # executable that is running".
  set(EXE_INSTALL_RPATH $ORIGIN/../lib CACHE STRING "RPATH to use for this target.")
elseif(WIN32)
  # DLL platforms don't support RPATH.
  set(EXE_INSTALL_RPATH "")
else()
  get_target_property(LIB_SHARED lib2::lib2 TYPE)
  if ("${LIB_SHARED}" STREQUAL SHARED_LIBRARY)
	message(FATAL_ERROR
	  "Unsupported target platform ${CMAKE_SYSTEM_NAME} for linking against "
	  "shared libraries.")
  endif()
  set(EXE_INSTALL_RPATH "")
endif()

set_target_properties(exe
  PROPERTIES
  INSTALL_RPATH "${EXE_INSTALL_RPATH}")

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

