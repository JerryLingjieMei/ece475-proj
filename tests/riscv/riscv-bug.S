//=========================================================================
// riscv-bug.S
//=========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN
        li x2, 1
        li x3, 2
        mul x4, x2, x3
        add x4, x2, x3
        nop
        TEST_CHECK_EQ( x4, 3 )
        TEST_RISCV_END