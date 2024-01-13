# Use pkg-config to find installed gtk+3 if available
#
# Once found, the following are defined:
#  GTK3_FOUND
#  GTK3_INCLUDE_DIRS
#  GTK3_LIBRARIES

find_package(PkgConfig REQUIRED QUIET)
pkg_check_modules(GTK3 QUIET gtk+-3.0
  IMPORTED_TARGET)
add_library(GTK3::GTK3 ALIAS PkgConfig::GTK3)
