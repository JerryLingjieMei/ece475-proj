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
        // vaddvv v2, v3, v0
        mulh x2, x0, x3
        // mvxs r1, v2
        csrrc x3, 0, x2
        TEST_CHECK_EQ(x3, 6)
        TEST_RISCV_END

