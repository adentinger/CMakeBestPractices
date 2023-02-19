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
  PRIVATE
    # The installation logs of vcpkg mentioned to use these libraries.
    GTest::gtest
    GTest::gtest_main
    GTest::gmock
    GTest::gmock_main)

