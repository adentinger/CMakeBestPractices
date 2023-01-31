#ifndef LIB1_HDR_H
#define LIB1_HDR_H

#include <cstddef>
#include <inttypes.h> // NOLINT(modernize-deprecated-headers) Just "uint<N>_t".

#include "lib1/defines.h"

namespace lib1 {
LIB1_SHRSYM std::size_t fibo(uint32_t n);
}

#endif // !LIB1_HDR_H

