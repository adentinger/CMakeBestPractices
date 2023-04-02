#ifndef LIB2_PRIVATE_HEADER_HPP_
#define LIB2_PRIVATE_HEADER_HPP_

// This header, because it is inside the src/ directory, is a private header.
// It may be used for internal processing reasons during the build of
// the library, but will not be installed along with it.

#if !defined(LIB2_EXPORT) || LIB1_MACRO != 42 || defined(LIB1_EXPORT)
#error "Macros not set properly for lib2"
#endif

#endif

