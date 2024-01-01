// SPDX-License-Identifier: MIT

#include <inttypes.h>  // NOLINT Just "uint<N>_t"

#include <gtest/gtest.h>

int main(int argc, char** argv) {
	::testing::InitGoogleTest(&argc, argv);
	return RUN_ALL_TESTS();
}
