
find_path(Xtst_INCLUDE_DIR NAMES X11/extensions/XTest.h
          PATHS /opt/X11/include
          PATH_SUFFIXES X11/extensions
          DOC "The libXtst include directory"
)

find_library(Xtst_LIBRARY NAMES Xtst
          PATHS /opt/X11/lib
          DOC "The libXtst library"
)

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(Xtst DEFAULT_MSG Xtst_LIBRARY Xtst_INCLUDE_DIR)

mark_as_advanced(Xtst_INCLUDE_DIR Xtst_LIBRARY)

