//=========================================================================
// riscv-add.S
//=========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN
        // setvl 8, r0
        lbu x0, 8(x0)

        // idv v0
        csrrci x0, 0, 0
        // mvxs r4, v0, 0
        csrrc x4, 0, x0
        TEST_CHECK_EQ(x4, 0)
        // mvxs r4, v0, 1
        csrrc x4, 1, x0
        TEST_CHECK_EQ(x4, 1)

        TEST_RISCV_END

