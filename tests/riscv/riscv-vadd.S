//=========================================================================
// riscv-add.S
//=========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN
        li x1 1;
        li x2 2;
        // luivx v0, 0, r1
        csrrc x0, 0, x1
        // lui v1, 0, r2
        csrrc x1, 0, x2
        // vaddvv v2, v1, v0
        mulh x2, x0, x1
        TEST_RISCV_END

