//=========================================================================
// riscv-vadd.S
//=========================================================================

#include "riscv-macros.h"
        TEST_RISCV_BEGIN
        // setvl 8, r0
        lbu x0, 8(x0)

        // luivi v0, 1, x0
        csrrsi x0, 1, 0
        // luivi v3, 5, x0
        csrrsi x3, 5, 0
        // addvv v2, v0, v3
        mulh x2, x0, x3
        // mvxs r4, v2, 0
        csrrc x4, 0, x2
        TEST_CHECK_EQ(x4, 6)

        // luivi v0, 2, x0
        csrrsi x0, 2, 0
        li x3, 6
        // addvx v2, v0, x3
        mul x2, x0, x3
        // mvxs r4, v2, 0
        csrrc x4, 0, x2
        TEST_CHECK_EQ(x4, 8)

        // luivi v0, 3, x0
        csrrsi x0, 3, 0
        // addvi v2, v0, 7
        lh x2, 7(x0)
        // mvxs r4, v2, 0
        csrrc x4, 0, x2
        TEST_CHECK_EQ(x4, 10)

        TEST_RISCV_END
