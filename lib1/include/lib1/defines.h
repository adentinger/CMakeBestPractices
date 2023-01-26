#ifndef LIB1_DEFINES_H_
#define LIB1_DEFINES_H_

// https://cmake.org/cmake/help/latest/guide/tutorial/Selecting%20Static%20or%20Shared%20Libraries.html#mathfunctions-mathfunctions-h
#if defined(_WIN32)
#  if defined(LIB1_EXPORT)
#    define LIB1_SHRSYM __declspec(dllexport)
#  else
#    define LIB1_SHRSYM __declspec(dllimport)
#  endif
#else // non windows
#  define LIB1_SHRSYM
#endif

#endif // !LIB1_DEFINES_H_
