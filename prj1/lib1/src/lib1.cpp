// SPDX-License-Identifier: MIT

#include <stdexcept>
#include <utility>
#include <vector>

#include "lib1/hdr.h"
#include "lib1/private/private-header.hpp"

namespace lib1 {

uint64_t fibo(uint32_t n) {
	const uint32_t overflow_threshold = 94;
	if (n >= overflow_threshold) {
		throw std::domain_error("lib1::fibo was attempted to be overflowed");
	}

	uint64_t v0 = 0;
	uint64_t v1 = 1;
	for (std::size_t i = 1; i < n; ++i) {
		v0 = std::exchange(v1, v0 + v1);
	}
	if (n >= 1) {
		return v1;
	}
	return v0;
}

}  // namespace lib1
