# SPDX-License-Identifier: MIT

file(GLOB_RECURSE CXX_SOURCES CONFIGURE_DEPENDS
  "src/*.cpp")
file(GLOB_RECURSE CXX_HEADERS_PRIVATE CONFIGURE_DEPENDS
  "src/*.h"
  "src/*.hpp")

# We prepend the target name with the name of the target that is being tested.
# This is:
# 1) because no two targets can have the same name (which would
# otherwise be a problem in a CMake build that has multiple targets).
# 2) because the target name "test" is reserved when testing is enabled, which
# we should always enable regardless of whether the project has tests or not so
# that 'ctest' correctly returns 0 (if there are no tests, that means all tests
# passed).
add_executable(lib2_test ${CXX_SOURCES})
target_sources(lib2_test
  PRIVATE
    FILE_SET private_headers
	TYPE HEADERS
	BASE_DIRS src
	FILES ${CXX_HEADERS_PRIVATE})

find_package(GTest CONFIG REQUIRED)
target_link_libraries(lib2_test
  # PUBLIC vs PRIVATE vs INTERFACE doesn't really matter for an executable
  # since nothing can link against an executable, so let's just put everything
  # PRIVATE.
  PRIVATE
    prj2::lib2__objlib_internal
    # The installation logs of vcpkg mentioned to use these libraries.
    GTest::gtest
    GTest::gtest_main
    GTest::gmock
    GTest::gmock_main)

# The executable needs to have any DLLs in its directory in order to run, so
# copy them. Note that this copies them to the *binary directory*, not the
# final installation.
#
# TODO The GitHub actions don't have CMake 3.26 yet, which would allow the
# command 'cmake -E copy -t <dir> <files>...' that supports the '<files>...'
# being empty (such as on non-Win32).
if (WIN32)
  add_custom_command(
	TARGET lib2_test POST_BUILD
	COMMAND ${CMAKE_COMMAND} -E copy
      $<TARGET_RUNTIME_DLLS:lib2_test> $<TARGET_FILE_DIR:lib2_test>
	COMMAND_EXPAND_LISTS
  )
endif()

include(GoogleTest)
# Creates a task that will query the test executable (<exe> --gtest_list_tests)
# to find what the tests are.
#
# This requires that the test executable is able to run on the host running
# the CMake build; if the test executable is cross-compiled then this will not
# work of course.
#
# In that case, the 'gest_add_tests()' function would do the trick, since it
# finds test cases by scaning the target's sources with regular expressions,
# however doing that means that it may miss some test cases (e.g. if the source
# invokes the TEST() macro through another macro).
#
# See: https://cmake.org/cmake/help/latest/module/GoogleTest.html#command:gtest_discover_tests
gtest_discover_tests(lib2_test)

