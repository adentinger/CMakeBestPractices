// SPDX-License-Identifier: MIT

#include <inttypes.h>  // NOLINT Just "uint<N>_t"

#include <gtest/gtest.h>

#include "lib2/hdr.h"

#include "exe/dummy_fibo_sum.hpp"

// NOLINTNEXTLINE GTest macro itself fails clang-tidy
TEST(ExeTest, DummyTestToEnsureDllsAreLoadedCorrectly) {
	EXPECT_EQ(lib2::fibo_sum(0), 0);
	EXPECT_EQ(lib2::fibo_sum(1), 1);
	EXPECT_EQ(lib2::fibo_sum(2), 2);
	EXPECT_EQ(lib2::fibo_sum(3), 4);
	EXPECT_EQ(lib2::fibo_sum(4), 7);
	EXPECT_EQ(lib2::fibo_sum(5), 12);
}

// NOLINTNEXTLINE GTest macro itself fails clang-tidy
TEST(ExeTest, DummyFiboSumTest) {
	auto val = exe::dummy_fibo_sum();
	EXPECT_EQ(val.term, 7);
	EXPECT_EQ(val.value, 33);
}

int main(int argc, char** argv) {
	::testing::InitGoogleTest(&argc, argv);
	return RUN_ALL_TESTS();
}
