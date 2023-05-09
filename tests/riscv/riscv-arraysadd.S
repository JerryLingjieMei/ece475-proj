//=========================================================================
// riscv-arraysadd.S
//=========================================================================

#include "riscv-macros.h"
        TEST_RISCV_BEGIN

        la x1, tdata_1
        la x2, tdata_2
        la x3, tdata_3
        li x4, 64

        loop:
        lw x5, 0(x1)
        lw x6, 0(x2)
        add x7, x5, x6
        sw x7, 0(x3)
        addi x1, x1, 8
        addi x2, x2, 8
        addi x3, x3, 8
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
