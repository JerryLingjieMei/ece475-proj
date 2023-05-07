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
        // redsum v4, v3, v0
        mulhu x4, x3, x0
        // mvxs r3, v2
        csrrc x3, 0, x2
        // mvxs r1, v4
        csrrc x1, 0, x4
        TEST_CHECK_EQ(x3, 8)
        TEST_CHECK_EQ(x1, 1)
        TEST_RISCV_END

