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
if(APPLE)
  set_target_properties(exe
	PROPERTIES
      # There is also "@rpath" that is a bit more flexible, but really the equivalent
	  # of "$ORIGIN" for Unix is "@executable_path".
      INSTALL_RPATH @executable_path/../lib)
elseif(UNIX AND NOT CYGWIN)
  set_target_properties(exe
	PROPERTIES
	  # "$ORIGIN" is a special string that means "the directory containing the
	  # executable that is running".
      INSTALL_RPATH $ORIGIN/../lib)
elseif(WIN32)
  # Nothing to do yet; we'll handle DLLs below.
else()
  get_target_property(LIB_SHARED lib2::lib2 TYPE)
  if ("${LIB_SHARED}" STREQUAL SHARED_LIBRARY)
	message(FATAL_ERROR
	  "Unsupported target platform ${CMAKE_SYSTEM_NAME} for linking against "
	  "shared libraries.")
  endif()
endif()

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

