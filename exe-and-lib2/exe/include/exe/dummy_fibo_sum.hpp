// SPDX-License-Identifier: MIT

#ifndef EXE_DUMMYFOOSUM_HPP_
#define EXE_DUMMYFOOSUM_HPP_

#include <inttypes.h> // NOLINT(modernize-deprecated-headers) Just "uint<N>_t"

namespace exe {

struct dummy_fibo_sum_value {
	uint32_t term;
	uint64_t value;
};

/**
 * A silly function which returns a specific term and value of
 * lib2::fibo_sum().
 */
dummy_fibo_sum_value dummy_fibo_sum();

} // namespace exe

#endif  // !EXE_DUMMYFOOSUM_HPP_

