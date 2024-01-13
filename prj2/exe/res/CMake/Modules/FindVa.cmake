# Find the Video Acceleration library.

# The following will be set:

# Va_INCLUDE_DIR Va_LIBRARY Va_FOUND

find_path(Va_INCLUDE_DIR NAMES va/va.h)

set(Va_NAMES "${Va_NAMES}" "va" "libva")
find_library(Va_LIBRARY NAMES ${Va_NAMES})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Va DEFAULT_MSG Va_LIBRARY Va_INCLUDE_DIR)

mark_as_advanced(Va_LIBRARY Va_INCLUDE_DIR)
