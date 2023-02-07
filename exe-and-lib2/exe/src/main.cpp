// SPDX-License-Identifier: MIT

// #include <exception>
#include <iostream>

#include "lib2/hdr.h"

#if !defined(LIB1_MACRO) || LIB1_MACRO != 42
#	error "!defined(LIB1_MACRO)"
#endif  // !LIB1_MACRO

int main() {
	try {
		const uint32_t fibo_n = 5000;
		std::cout << "fibo_sum(5000) = " << lib2::fibo_sum(fibo_n) << "\n";
	} catch (...) {
		std::terminate();
	}
	return 0;
}
