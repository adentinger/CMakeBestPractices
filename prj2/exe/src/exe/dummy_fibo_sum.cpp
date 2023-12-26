// SPDX-License-Identifier: MIT

#include "exe/dummy_fibo_sum.hpp"

#include "lib2/hdr.h"

#if !defined(LIB1_MACRO) || LIB1_MACRO != 42
#	error "!defined(LIB1_MACRO)"
#endif  // !LIB1_MACRO

namespace exe {

dummy_fibo_sum_value dummy_fibo_sum() {
	const uint32_t term = 7;
	dummy_fibo_sum_value ret = {};
	ret.term = term;
	ret.value = lib2::fibo_sum(term);
	return ret;
}

}  // namespace exe
