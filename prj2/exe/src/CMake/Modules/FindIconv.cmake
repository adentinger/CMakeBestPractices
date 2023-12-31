# Borrowed from https://github.com/onyx-
# intl/cmake_modules/blob/master/FindIconv.cmake

# Find Iconv on the system. When this is done, the following are defined:

# Iconv_FOUND - The system has Iconv. Iconv_INCLUDE_DIR - The Iconv include
# directory. Iconv_LIBRARIES - The library file to link to.

if(Iconv_INCLUDE_DIR AND Iconv_LIBRARIES)
  # Already in cache, so don't repeat the finding procedures.
  set(Iconv_FIND_QUIETLY TRUE)
endif()

find_path(Iconv_INCLUDE_DIR Iconv.h)
set(Iconv_NAMES ${Iconv_NAMES} Iconv libIconv libIconv-2 c)
find_library(Iconv_LIBRARIES NAMES ${Iconv_NAMES})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Iconv
                                  DEFAULT_MSG
                                  Iconv_LIBRARIES
                                  Iconv_INCLUDE_DIR)

mark_as_advanced(Iconv_INCLUDE_DIR Iconv_LIBRARIES)
