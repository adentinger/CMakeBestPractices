#ifndef LIB2_HDR_H
#define LIB2_HDR_H

#include <cstddef>
#include <inttypes.h> // NOLINT(modernize-deprecated-headers) Just "uint<N>_t".

#include "lib2/defines.h"

namespace lib2 {
LIB2_SHRSYM std::size_t fibo_sum(uint32_t n);
} // namespace lib2

#endif // !LIB2_HDR_H

