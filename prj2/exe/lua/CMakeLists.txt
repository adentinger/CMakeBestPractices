file(GLOB_RECURSE C_CXX_SOURCES CONFIGURE_DEPENDS
  "src/*.c"
  "src/*.cpp")
file(GLOB_RECURSE C_CXX_HEADERS_PUBLIC_SRC CONFIGURE_DEPENDS
  "src/*.h"
  "src/*.hpp")
file(GLOB_RECURSE C_CXX_HEADERS_PUBLIC_ETC CONFIGURE_DEPENDS
  "etc/*.h"
  "etc/*.hpp")

add_library(lua STATIC ${C_CXX_SOURCES})
add_library(prj2::lua ALIAS lua)

# StepMania includes lua.h with 'extern "C"' around it, so we want to use C
# linking.
set_target_properties(lua PROPERTIES LINKER_LANGUAGE C)

target_sources(lua
  PUBLIC
    FILE_SET public_headers_src
    TYPE HEADERS
    BASE_DIRS src
    FILES ${C_CXX_HEADERS_PUBLIC_SRC}

    FILE_SET public_headers_etc
    TYPE HEADERS
    BASE_DIRS etc
    FILES ${C_CXX_HEADERS_PUBLIC_ETC})

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
  set(LUA_INSTALL_RPATH @executable_path/../lib CACHE STRING "RPATH to use for this target.")
elseif(UNIX AND NOT CYGWIN)
  # "$ORIGIN" is a special string that means "the directory containing the
  # executable that is running".
  set(LUA_INSTALL_RPATH $ORIGIN/../lib CACHE STRING "RPATH to use for this target.")
elseif(WIN32)
  # DLL platforms don't support RPATH.
  set(LUA_INSTALL_RPATH "")
else()
  get_target_property(LIB_SHARED prj2::lua TYPE)
  if ("${LIB_SHARED}" STREQUAL SHARED_LIBRARY)
	message(FATAL_ERROR
	  "Unsupported target platform ${CMAKE_SYSTEM_NAME} for linking against "
	  "shared libraries.")
  endif()
  set(LUA_INSTALL_RPATH "")
endif()

set_target_properties(lua
  PROPERTIES
  INSTALL_RPATH "${LUA_INSTALL_RPATH}")

install(TARGETS lua
  EXPORT prj2Targets
  FILE_SET public_headers_src
  FILE_SET public_headers_etc
  # https://youtu.be/IZXNsim9TWI?t=2475
  COMPONENT lua
  DESTINATION include)
