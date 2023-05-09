//=========================================================================
// riscv-add.S
//=========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN
        // setvl 8, r0
        lbu x0, 8(x0)

        // luivi v0, 1, x0
        csrrsi x0, 1, 0
        li x3, 0
        // andvx v2, v0, x3
        mulhsu x2, x0, x3
        // mvxs r4, v2, 0
        csrrc x4, 0, x2
        TEST_CHECK_EQ(x4, 0)

        // luivi v0, 1, x0
        csrrsi x0, 1, 0
        // andvi v2, v0, 1
        lhu x2, 1(x0)
        // mvxs r4, v2, 0
        csrrc x4, 0, x2
        TEST_CHECK_EQ(x4, 1)

        TEST_RISCV_END

