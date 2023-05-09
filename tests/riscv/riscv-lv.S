//=========================================================================
// riscv-lv.S
//=========================================================================

#include "riscv-macros.h"

        TEST_RISCV_BEGIN
        // setvl 8, r0
        lbu x0, 8(x0)

        TEST_SW_OP( sw, 0x00000000,   0, tdata_0, 0x00000000 )
        TEST_SW_OP( sw, 0x00000001,   4, tdata_0, 0x00000001 )
        TEST_SW_OP( sw, 0x00000002,   8, tdata_0, 0x00000002 )
        TEST_SW_OP( sw, 0x00000003,  12, tdata_0, 0x00000003 )
        TEST_SW_OP( sw, 0x00000004,  16, tdata_0, 0x00000004 )
        TEST_SW_OP( sw, 0x00000005,  20, tdata_0, 0x00000005 )
        TEST_SW_OP( sw, 0x00000006,  24, tdata_0, 0x00000006 )
        TEST_SW_OP( sw, 0x00000007,  28, tdata_0, 0x00000007 )

        // TEST_LD_OP( lw,   0, tdata_0, 0x00000000 )
        la    x2, tdata_0;                                                    
        lw    x5, 0(x2);                                              
        TEST_CHECK_EQ( x5, 0x00000000 )

        //TEST_LD_OP( lw,   4, tdata_0, 0x00000001 )
        la    x2, tdata_0;                                                    
        lw    x6, 4(x2);                                              
        TEST_CHECK_EQ( x6, 0x00000001 )

        //TEST_LD_OP( lw,   8, tdata_0, 0x00000002 )
        la    x2, tdata_0;                                                    
        lw    x7, 8(x2);                                              
        TEST_CHECK_EQ( x7, 0x00000002 )

        //TEST_LD_OP( lw,  12, tdata_0, 0x00000003 )
        la    x2, tdata_0;                                                    
        lw    x8, 12(x2);                                              
        TEST_CHECK_EQ( x8, 0x00000003 )

        //TEST_LD_OP( lw,  16, tdata_0, 0x00000004 )
        la    x2, tdata_0;                                                    
        lw    x9, 16(x2);                                              
        TEST_CHECK_EQ( x9, 0x00000004 )

        //TEST_LD_OP( lw,  20, tdata_0, 0x00000005 )
        la    x2, tdata_0;                                                    
        lw    x10, 20(x2);                                              
        TEST_CHECK_EQ( x10, 0x00000005 )

        //TEST_LD_OP( lw,  24, tdata_0, 0x00000006 )
        la    x2, tdata_0;                                                    
        lw    x11, 24(x2);                                              
        TEST_CHECK_EQ( x11, 0x00000006 )

        //TEST_LD_OP( lw,  28, tdata_0, 0x00000007 )
        la    x2, tdata_0;                                                    
        lw    x12, 28(x2);                                              
        TEST_CHECK_EQ( x12, 0x00000007 )

        la    x2, tdata_0
        // lv v1, 0(x2)
        lb x1, 0(x2)

        // mvxs r3, v1
        csrrc x3, 0, x1

        TEST_CHECK_EQ(x3, 0)

        // mvxs r3, v1
        csrrc x3, 1, x1

        TEST_CHECK_EQ(x3, 1)

        TEST_RISCV_END

        //-----------------------------------------------------------------
        // Test data
        //-----------------------------------------------------------------

        .section .data
        .align 4

tdata_0:  .word 0xdeadbeef

