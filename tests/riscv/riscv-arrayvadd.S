//=========================================================================
// riscv-arrayvadd.S
//=========================================================================

#include "riscv-macros.h"
        TEST_RISCV_BEGIN

        // setvl 8, r0
        lbu x0, 8(x0)

        la x1, tdata_1
        la x2, tdata_2
        la x3, tdata_3
        li x4, 8
        loop:
        // lv v1, 0(x1)
        lb x1, 0(x1)

        // lv v2, 0(x2)
        lb x2, 0(x2)

        // vaddvv v3, v1, v2
        mulh x3, x1, x2

        // sv v3, 0(x3)
        sb x3, 0(x3)

        addi x1, x1, 64
        addi x2, x2, 64
        addi x3, x3, 64
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
