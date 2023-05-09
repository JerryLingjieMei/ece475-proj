//=========================================================================
// riscv-add.S
//=========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN
        // setvl 8, r0
        lbu x0, 8(x0)

        // luivi v0, 1, x0
        csrrsi x0, 1, 0
        // luivi v3, 5, x0
        csrrsi x3, 5, 0
        // sltvv v2, v0, v3
        remu x2, x0, x3
        // mvxs r4, v2, 0
        csrrc x4, 0, x2
        TEST_CHECK_EQ(x4, 1)

        // luivi v0, 2, x0
        csrrsi x0, 2, 0
        li x3, 2
        // sltvx v2, v0, x3
        rem x2, x0, x3
        // mvxs r4, v2, 0
        csrrc x4, 0, x2
        TEST_CHECK_EQ(x4, 0)

        // luivi v0, 3, x0
        csrrsi x0, 3, 0
        // sltvi v2, v0, 1
        sh x2, 1(x0)
        // mvxs r4, v2, 0
        csrrc x4, 0, x2
        TEST_CHECK_EQ(x4, 0)

        TEST_RISCV_END

