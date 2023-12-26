// SPDX-License-Identifier: MIT

#include <algorithm>
#include <inttypes.h>  // NOLINT Just "uint<N>_t"
#include <iostream>
#include <numeric>
#include <vector>

#include "lib1/hdr.h"

#include "lib2/hdr.h"
#include "lib2/private/private-header.hpp"

#if !defined(LIB1_MACRO) || LIB1_MACRO != 42
#	error "!defined(LIB1_MACRO)"
#endif  // !defined(LIB1_MACRO) || LIB1_MACRO != 42

namespace lib2 {

/**
 * @brief Computes the sum of fibonacci sequence values for fibo(0) to
 * fibo(n) exclusive.
 */
uint64_t fibo_sum(uint32_t n) {
	// Super inefficient implementation in O(n^2) calls to lib1::fibo(), but
	// efficiency isn't the purepose of this project; it's mostly the CMake
	// config that is.
	std::vector<std::size_t> fibo_values;
	fibo_values.resize(n);

	size_t curr_n = 0;
	auto f = [&curr_n]() { return lib1::fibo(++curr_n); };
	std::generate_n(fibo_values.begin(), fibo_values.size(), f);
	const std::size_t sum = std::accumulate(
		fibo_values.cbegin(), fibo_values.cend(), static_cast<std::size_t>(0));
	return sum;
}

}  // namespace lib2
