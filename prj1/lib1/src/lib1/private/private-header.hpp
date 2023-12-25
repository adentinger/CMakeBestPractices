#ifndef LIB1_PRIVATE_HEADER_HPP_
#define LIB1_PRIVATE_HEADER_HPP_

// This header, because it is inside the src/ directory, is a private header.
// It may be used for internal processing reasons during the build of
// the library, but will not be installed along with it.

#if LIB1_MACRO != 42 || !defined(LIB1_EXPORT)
#error "Macros not set properly for lib1"
#endif

#endif

