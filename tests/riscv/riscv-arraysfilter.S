//=========================================================================
// riscv-arraysfilter.S
//=========================================================================

#include "riscv-macros.h"
        TEST_RISCV_BEGIN

        li x2, 0
        li x5, 32
        li x4, 64

        loop:
        slt x1, x2, x5
        addi x2, x2, 1
        addi x4, x4, -1
        bne x4, x0, loop

        TEST_RISCV_END

        //-----------------------------------------------------------------
        // Test data
        //-----------------------------------------------------------------

        .section .data
        .align 4

tdata_1:  .word 0x11111110
tdata_2:  .word 0x22222220
tdata_3:  .word 0x33333330
