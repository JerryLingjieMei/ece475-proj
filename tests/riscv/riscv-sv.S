//=========================================================================
// riscv-sv.S
//=========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN

        // setvl 8, r0
        lbu x0, 8(x0)

        // luivi v0, 5, x0
        csrrsi x0, 5, 0

        la    x2, tdata_0

        // sv v0, 0(x2)
        sb x0, 0(x2)

        la    x15, tdata_0

        lw    x5, 0(x15)      
        lw    x6, 4(x15)   
        lw    x7, 8(x15)   
        lw    x8, 12(x15)                                           
        lw    x9, 16(x15)                                              
        lw    x10, 20(x15)                                            
        lw    x11, 24(x15)                                             
        lw    x12, 28(x15)                                             

        //TEST_CHECK_EQ( x5, 0x00000005 )

        //TEST_CHECK_EQ( x6, 0x00000005 )
                                   
        //TEST_CHECK_EQ( x7, 0x00000005 )

        //TEST_CHECK_EQ( x8, 0x00000005 )

        //TEST_CHECK_EQ( x9, 0x00000005 )

        //TEST_CHECK_EQ( x10, 0x00000005 )

        //TEST_CHECK_EQ( x11, 0x00000005 )

        //TEST_CHECK_EQ( x12, 0x00000005 )

        TEST_RISCV_END

        //-----------------------------------------------------------------
        // Test data
        //-----------------------------------------------------------------

        .section .data
        .align 4

tdata_0:  .word 0xdeadbeef

