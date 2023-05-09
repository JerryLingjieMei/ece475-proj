//=========================================================================
// riscv-arrayvsum.S
//=========================================================================

#include "riscv-macros.h"
        TEST_RISCV_BEGIN

        li x5, 0
        la x1, tdata_1
        li x4, 64

        loop:
        lw x6, 0(x1)
        add x5, x5, x6
        addi x1, x1, 8
        addi x4, x4, -1
        bne x4, x0, loop

        la x2, tdata_2
        sw x5, 0(x2)

        TEST_RISCV_END

        //-----------------------------------------------------------------
        // Test data
        //-----------------------------------------------------------------

        .section .data
        .align 4

tdata_1:  .word 0x11111110
tdata_2:  .word 0x22222220
tdata_3:  .word 0x33333330
