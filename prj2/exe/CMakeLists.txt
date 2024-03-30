# SPDX-License-Identifier: MIT

# include("${CMAKE_SOURCE_DIR}/cmake/tree.cmake")
# ade_set_source_files(lib1 C_CXX_SOURCES CXX_HEADERS_PUBLIC CXX_HEADERS_PRIVATE)

# # This builds an 'object library', which is basically a collection of object
# # files. The 'exe' library will link against it.
# #
# # There are three reasons for doing this despite making the rest of the
# # code below a little more complicated:
# #
# # 1) When building an executable, how would we run unit tests on the sources
# # of the executable unless we put them in a library such as an object library,
# # and then linked the unit test executable against that library?
# #
# # 2) When building a shared library, if the library exports only a part of its
# # symbols (as is the case by default with Windows DLLs, and is apparently
# # also possible with other compilers like GCC), then how would we run
# # unit tests on the symbols that are not exported if the unit test executable
# # is linking against that shared library? See this answer from a
# # well-known CMake maintainer:
# # https://discourse.cmake.org/t/unit-testing-internal-functions-of-a-dll/3805/2?u=anthonyd973
# #
# # 3) Again when building a shared library, DLLs on Windows need to be in the
# # same directory as the executable for the executable to find them at runtime.
# # If we linked the unit test executable against the DLL, the DLL wouldn't be
# # in the same directory as the test executable, so the test executable wouldn't
# # be able to run. Instead, we should build an object library and link the
# # test executable against that.
# add_library(exe__objlib_internal OBJECT ${C_CXX_SOURCES})
# # See comments of exe below. We're going to have to export the object library
# # anyway, so let's create an alias for it too.
# add_library(prj2::exe__objlib_internal ALIAS exe__objlib_internal)
# set_target_properties(exe__objlib_internal
#   PROPERTIES
#     LINKER_LANGUAGE CXX)

# # If we want to write tests for the sources that make up the executable, we
# # need to put the executable's sources inside a library as explained above.
# # However that library obviously should not contain the executable's main()
# # function, which means the globs need to not find the file containing
# # main.cpp, which we solve by putting main.cpp inside a separate directory.
# #
# # So it's either putting main.cpp in a separate directory to be able to use
# # the globs, or listing all sources directly inside add_library() and headers
# # directly inside target_sources() to avoid main.cpp being in the library's
# # sources. Listing the sources and headers is famously the CMake
# # recommendation, but we don't like doing that because it's error-prone and
# # there is (to our knowledge) no possible static check to verify that all the
# # sources were listed correctly. E.g. one could easily forget to list header
# # files, which means some header files which are supposed to be installed never
# # get installed, which wouldn't necessarily be detected right away until a user
# # complains about it.
# add_executable(exe main.cpp)
# # Libraries/exes built outside *this* CMake build (aka "external dependencies")
# # will link against this one prepended with the "prj2::" namespace. In order
# # for libraries/exes built inside *this* CMake build (aka "internal
# # dependencies") to have their dependencies look exactly the same as external
# # dependencies, let's create an alias target that looks exactly like the
# # external target.
# #
# # https://youtu.be/bsXLMQ6WgIk?t=3124
# add_executable(prj2::exe ALIAS exe)
# target_link_libraries(exe PUBLIC exe__objlib_internal)
# target_link_libraries(exe__objlib_internal PUBLIC prj2::lib2)

# set_target_properties(exe
#   PROPERTIES
#     CXX_STANDARD 17
#     CXX_STANDARD_REQUIRED ON)
# set_target_properties(exe__objlib_internal
#   PROPERTIES
#     CXX_STANDARD 17
#     CXX_STANDARD_REQUIRED ON)

# target_sources(exe__objlib_internal
#   PUBLIC
#     FILE_SET public_headers
#     TYPE HEADERS
# 	# "src/" is the include directory to use for the headers in this
# 	# file set. This also means that the files will be installed without an
# 	# initial "src" directory at the begining.
#     BASE_DIRS src
#     FILES ${CXX_HEADERS_PUBLIC}
# 	# The headers that are available only for compilation of this library.
# 	# The executable's main.cpp won't be able to find headers in this
# 	# directory.
#   PRIVATE
#     FILE_SET private_headers
#     TYPE HEADERS
#     BASE_DIRS src
#     FILES ${CXX_HEADERS_PRIVATE})

# # Properties used only when building shared libraries.
# #
# # For Apple and Unix-like platforms (although maybe not Cygwin?), an RPATH
# # metadata variable can be set inside the linked executable/library to specify
# # a search path for dependant shared libraries. However, this cannot be a
# # relative path because it would be relative to where the executable is run
# # from, which isn't what we want. So instead we specify a special string to
# # make the path relative to where the executable is located.
# #
# # Note that we use CACHE variables here. This is to allow whoever is
# # configuring the CMake build to override the values if they want to, while
# # still providing a sane default.
# if(APPLE)
#   # There is also "@rpath" that is a bit more flexible, but really the equivalent
#   # of "$ORIGIN" for Unix is "@executable_path".
#   set(EXE_INSTALL_RPATH @executable_path/../lib CACHE STRING "RPATH to use for this target.")
# elseif(UNIX AND NOT CYGWIN)
#   # "$ORIGIN" is a special string that means "the directory containing the
#   # executable that is running".
#   set(EXE_INSTALL_RPATH $ORIGIN/../lib CACHE STRING "RPATH to use for this target.")
# elseif(WIN32)
#   # DLL platforms don't support RPATH.
#   set(EXE_INSTALL_RPATH "")
# else()
#   # Nothing to do
# endif()

# set_target_properties(exe
#   PROPERTIES
#   INSTALL_RPATH "${EXE_INSTALL_RPATH}")

# find_package(AdeClangFormat 1.1 CONFIG REQUIRED)
# ade_clang_format_git_targets(TARGETS
#   exe
#   exe__objlib_internal)

# # Providing a CACHE option for this, since this is a nice convenience that
# # some users might want.
# #
# # Default is OFF, which means it's up to the user to make sure that the
# # dependant DLLs are installed in the same directory as the executable. This
# # is the default because that's what happens on Unix-like systems as well,
# # so keeping that OFF makes it nice and consistent.
# option(exe_INSTALL_RUNTIME_DEPENDENCIES
#   "If ON, install any runtime dependency that this executable depends on along with it."
#   OFF)

# if (exe_INSTALL_RUNTIME_DEPENDENCIES)
#   # On Windows, DLLs need to be in the same directory as the executable for it
#   # to run. This is not a perfect solution because 1) this is inconsistent with
#   # what happens on Unix-like systems (where the shared libraries would need to
#   # be installed in one of the directories specified in the RPATH), 2) a
#   # package manager like vcpkg would want to manage the dependencies themselves
#   # (that's what they are there for right?), and 3) because it's possible that
#   # something else provides the same DLL file, so packaging the DLLs would mean
#   # that the DLLs that end up in the final installation tree would depend on
#   # installation order, which sounds pretty bad.
#   install(FILES $<TARGET_RUNTIME_DLLS:exe>
# 	DESTINATION bin)
# endif()

# install(TARGETS exe
#   EXPORT prj2Targets
#   # https://youtu.be/IZXNsim9TWI?t=2475
#   COMPONENT prj2
#   DESTINATION bin)

# add_subdirectory(test)

add_subdirectory(lua)
add_subdirectory(src)
