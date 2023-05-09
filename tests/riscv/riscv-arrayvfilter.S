//=========================================================================
// riscv-arrayvfilter.S
//=========================================================================

#include "riscv-macros.h"
        TEST_RISCV_BEGIN

        // setvl 8, r0
        lbu x0, 8(x0)

         // idv v0
        csrrci x0, 0, 0

        li x5, 32
        li x4, 8

        loop:
        // sltvx v1, v0, x5
        rem x1, x0, x5

        // addvi v0, v0, 8
        lh x0, 8(x0)

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
