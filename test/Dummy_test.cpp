#include "../lib/Dummy.hpp"
#include <gtest/gtest.h>

struct ADummy : testing::Test {
  Dummy dummy;
};

TEST_F(ADummy, ReturnTheAnswer) {
  ASSERT_EQ(dummy.getTheAnswer(), 42);
}
