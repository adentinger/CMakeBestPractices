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

find_package(SilClangFormat 1.0 CONFIG REQUIRED)
sil_clang_format_targets(TARGETS exe POST_BUILD)

install(TARGETS exe
  DESTINATION bin)

if(WIN32)
  # Providing a CACHE option for this, since this is a nice convenience that
  # some users might want.
  #
  # Default is OFF, which means it's up to the user to make sure that the
  # dependant DLLs are installed in the same directory as the executable. This
  # is the default because that's what would be required on Unix-like systems
  # as well, so keeping that OFF makes it nice and consistent.
  option(exe_INSTALL_DEPENDANT_DLLS
	"Whether to install any DLL that this executable depends on along with it."
	OFF)
else()
  set(exe_INSTALL_DEPENDANT_DLLS OFF)
endif()

if (exe_INSTALL_DEPENDANT_DLLS)
  # On Windows, DLLs need to be in the same directory as the executable for it
  # to run. This is not a perfect solution because 1) this is inconsistent with
  # what happens on Unix-like systems (where the shared libraries would need to
  # be installed in one of the directories specified in the RPATH), and 2) a
  # package manager like vcpkg would want to manage the dependencies themselves
  # (that's what they are there for right?).
  install(FILES $<TARGET_RUNTIME_DLLS:exe>
	DESTINATION bin)
endif()

