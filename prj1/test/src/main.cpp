// SPDX-License-Identifier: MIT

#include <inttypes.h>  // NOLINT Just "uint<N>_t"
#include <stdexcept>
#include <type_traits>

#include <gtest/gtest.h>

#include "lib1/hdr.h"

// NOLINTNEXTLINE GTest macro itself fails clang-tidy
TEST(FiboTest, Base2CasesWork) {
	EXPECT_EQ(lib1::fibo(0), 0);
	EXPECT_EQ(lib1::fibo(1), 1);
}

// NOLINTNEXTLINE GTest macro itself fails clang-tidy
TEST(FiboTest, NonBase2CasesWork) {
	// clang-format off
	EXPECT_EQ(lib1::fibo( 2), 1);
	EXPECT_EQ(lib1::fibo( 3), 2);
	EXPECT_EQ(lib1::fibo( 4), 3);
	EXPECT_EQ(lib1::fibo( 5), 5);
	EXPECT_EQ(lib1::fibo(10), 55);
	EXPECT_EQ(lib1::fibo(20), 6'765);
	EXPECT_EQ(lib1::fibo(50), 12'586'269'025);
	EXPECT_EQ(lib1::fibo(90), 2'880'067'194'370'816'120);
	EXPECT_EQ(lib1::fibo(92), 7'540'113'804'746'346'429);
	EXPECT_EQ(lib1::fibo(93), 12'200'160'415'121'876'738ULL);
	// clang-format on
	// NOLINTNEXTLINE GTest macro itself fails clang-tidy
	EXPECT_THROW(lib1::fibo(94), std::domain_error);
}

int main(int argc, char** argv) {
	::testing::InitGoogleTest(&argc, argv);
	return RUN_ALL_TESTS();
}
