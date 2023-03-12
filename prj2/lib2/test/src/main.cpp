// SPDX-License-Identifier: MIT

#include <inttypes.h>  // NOLINT(modernize-deprecated-headers) Just "uint<N>_t"

#include <gtest/gtest.h>

#include "lib2/hdr.h"

// NOLINTNEXTLINE GTest macro itself fails clang-tidy
TEST(FiboSumTest, Base2CasesWork) {
	EXPECT_EQ(lib2::fibo_sum(0), 0);
	EXPECT_EQ(lib2::fibo_sum(1), 1);
}

// NOLINTNEXTLINE GTest macro itself fails clang-tidy
TEST(FiboSumTest, NonBase2CasesWork) {
	EXPECT_EQ(lib2::fibo_sum(2), 2);
	EXPECT_EQ(lib2::fibo_sum(3), 4);
	EXPECT_EQ(lib2::fibo_sum(4), 7);
	EXPECT_EQ(lib2::fibo_sum(5), 12);
}

int main(int argc, char** argv) {
	::testing::InitGoogleTest(&argc, argv);
	return RUN_ALL_TESTS();
}

