// SPDX-License-Identifier: MIT

#include "lib1/hdr.h"

#include <vector>
#include <utility>

namespace lib1 {

std::size_t fibo(uint32_t n) {
	std::size_t v0 = 1;
	std::size_t v1 = 1;
	for (std::size_t i = 2; i < n; ++i) {
		v0 = std::exchange(v1, v0 + v1);
	}
	if (n >= 1) {
		return v1;
	}
	return v0;
}

} // namespace lib1

