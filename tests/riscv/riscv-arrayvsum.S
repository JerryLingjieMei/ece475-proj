//=========================================================================
// riscv-arrayvsum.S
//=========================================================================

#include "riscv-macros.h"
        TEST_RISCV_BEGIN

        // setvl 8, r0
        lbu x0, 8(x0)

        // luivi v0, 0, x0
        csrrsi x0, 0, 0

        // luivi v3, 0, x0
        csrrsi x3, 0, 0
        
        la x1, tdata_1
        li x4, 8

        loop:
        // lv v1, 0(x1)
        lb x1, 0(x1)

        // redsum v2, v0, v1
        mulhu x2, x0, x1

        // vaddvv v3, v3, v1
        mulh x3, x3, x1

        addi x1, x1, 64
        addi x4, x4, -1
        bne x4, x0, loop

        // mvxs r5, v3
        csrrc x5, 0, x3

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
