# This is borrowed from FreeRDP. - Find Xrandr Find the Xrandr libraries
#
# This module defines the following variables: Xrandr_FOUND        - true if
# Xrandr_INCLUDE_DIR & Xrandr_LIBRARY are found Xrandr_LIBRARIES    - Set when
# Xrandr_LIBRARY is found Xrandr_INCLUDE_DIRS - Set when Xrandr_INCLUDE_DIR is
# found
#
# Xrandr_INCLUDE_DIR  - where to find Xrandr.h, etc. Xrandr_LIBRARY      - the
# Xrandr library
#

# =============================================================================
# Copyright 2012 Alam Arias <Alam.GBC@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.
# =============================================================================

find_path(Xrandr_INCLUDE_DIRS
          NAMES X11/extensions/Xrandr.h
          PATH_SUFFIXES X11/extensions
          PATHS /opt/X11/include
          DOC "The Xrandr include directory")

find_library(Xrandr_LIBRARIES
             NAMES Xrandr
             PATHS /opt/X11/lib
             DOC "The Xrandr library")

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Xrandr
                                  DEFAULT_MSG
                                  Xrandr_LIBRARIES
                                  Xrandr_INCLUDE_DIRS)

mark_as_advanced(Xrandr_INCLUDE_DIRS Xrandr_LIBRARIES)
