//=========================================================================
// riscv-add.S
//=========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN
        // setvl 8, r0
        lbu x0, 8(x0)
        // luivi v0, 0, x0
        csrrsi x0, 0, 0
        // luivi v3, 1, x0
        csrrsi x3, 1, 0
        // redsum v2, v0, v3
        mulhu x2, x0, x3
        // mvxs r1, v4
        csrrc x1, 0, x4
        TEST_CHECK_EQ(x1, 8)
        // setvl 7, r0
        lbu x0, 7(x0)
        // redsum v2, v0, v3
        mulhu x2, x0, x3
        // mvxs r1, v4
        csrrc x1, 0, x4
        TEST_CHECK_EQ(x1, 7)
        li x1,6
        // setvl 0, r1
        lbu x0, 0(x1)
        // redsum v2, v0, v3
        mulhu x2, x0, x3
        // mvxs r1, v4
        csrrc x1, 0, x4
        TEST_CHECK_EQ(x1, 6)
        TEST_RISCV_END

