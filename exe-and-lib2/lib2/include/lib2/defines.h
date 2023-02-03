// SPDX-License-Identifier: MIT

#ifndef LIB2_DEFINES_H_
#define LIB2_DEFINES_H_

// https://cmake.org/cmake/help/latest/guide/tutorial/Selecting%20Static%20or%20Shared%20Libraries.html#mathfunctions-mathfunctions-h
#if defined(_WIN32) && defined(LIB2_SHARED)
#  if defined(LIB2_EXPORT)
#    define LIB2_SHRSYM __declspec(dllexport)
#  else
#    define LIB2_SHRSYM __declspec(dllimport)
#  endif
#else // non-DLL
#  define LIB2_SHRSYM
#endif

#endif // !LIB2_DEFINES_H_

