// SPDX-License-Identifier: MIT

#include <exception>
#include <iostream>

#include "lib2/hdr.h"

#include "exe/dummy_fibo_sum.hpp"

#if !defined(LIB1_MACRO) || LIB1_MACRO != 42
#	error "!defined(LIB1_MACRO)"
#endif  // !LIB1_MACRO

int main() {
	try {
		auto val = exe::dummy_fibo_sum();
		std::cout << "fibo_sum(" << val.term << ") = " << val.value << "\n";
	}
	catch (const std::exception& e) {
		// Using std::cerr, or calling e.what(), may throw an exception.
		try {
			std::cerr << __FILE__ << "(" << __LINE__ << "): " << e.what()
					  << '\n';
		}
		catch (...) {
			std::terminate();
		}
		std::terminate();
	}
	catch (...) {
		std::terminate();
	}
	return 0;
}
