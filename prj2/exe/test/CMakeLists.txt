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
add_executable(exe_test ${CXX_SOURCES})
target_sources(exe_test
  PRIVATE
    FILE_SET private_headers
	TYPE HEADERS
	BASE_DIRS src
	FILES ${CXX_HEADERS_PRIVATE})

set_target_properties(exe_test
  PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON)

find_package(AdeClangFormat 1.0 CONFIG REQUIRED)
ade_clang_format_git_targets(TARGETS exe_test)

find_package(GTest CONFIG REQUIRED)
target_link_libraries(exe_test
  # PUBLIC vs PRIVATE vs INTERFACE doesn't really matter for an executable
  # since nothing can link against an executable, so let's just put everything
  # PRIVATE.
  PRIVATE
    prj2::exe__objlib_internal
    # The installation logs of vcpkg mentioned to use these libraries.
    GTest::gtest
    GTest::gtest_main
    GTest::gmock
    GTest::gmock_main)

# The executable needs to have any DLLs in its directory in order to run, so
# copy them. Note that this copies them to the *binary directory*, not the
# final installation.
add_custom_command(
  TARGET exe_test POST_BUILD
  # Using the CMake 3.26 'copy -t', which supports copying no files. It was
  # added specifically to support copying DLLs:
  # https://gitlab.kitware.com/cmake/cmake/-/issues/23543
  COMMAND ${CMAKE_COMMAND} -E copy -t
    $<TARGET_FILE_DIR:exe_test> $<TARGET_RUNTIME_DLLS:exe_test>
  COMMAND_EXPAND_LISTS
)

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
gtest_discover_tests(exe_test)

