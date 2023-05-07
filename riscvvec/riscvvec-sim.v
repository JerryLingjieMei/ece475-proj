//=========================================================================
// 7-Stage RISCV Processor Simulator
//=========================================================================

`include "riscvvec-Core.v"
//`include "vc-TestDualPortRandDelayMem.v"
`include "vc-TestSinglePortRandDelayMem.v"
//`include "vc-TestQuadPortRandDelayMem.v"
`include "vc-TestEightPortRandDelayMem.v"

module riscv_sim;

  //----------------------------------------------------------------------
  // Setup
  //----------------------------------------------------------------------

  reg clk   = 1'b0;
  reg reset = 1'b1;

  always #5 clk = ~clk;

  wire [31:0] status;

  //----------------------------------------------------------------------
  // Wires for connecting processor and memory
  //----------------------------------------------------------------------

  wire [`VC_MEM_REQ_MSG_SZ(32,32)-1:0] imemreq_msg;
  wire                                 imemreq_val;
  wire                                 imemreq_rdy;
  wire   [`VC_MEM_RESP_MSG_SZ(32)-1:0] imemresp_msg;
  wire                                 imemresp_val;

  
  /*
  wire [`VC_MEM_REQ_MSG_SZ(32,32)-1:0] dmemreq_msg;
  wire                                 dmemreq_val;
  wire                                 dmemreq_rdy;
  wire   [`VC_MEM_RESP_MSG_SZ(32)-1:0] dmemresp_msg;
  wire                                 dmemresp_val;
  */

  wire [`VC_MEM_REQ_MSG_SZ(32,32)-1:0] dmemreq0_msg;
  wire                                 dmemreq_val;
  wire                                 dmemreq0_rdy;
  wire   [`VC_MEM_RESP_MSG_SZ(32)-1:0] dmemresp0_msg;
  wire                                 dmemresp0_val;

  wire [`VC_MEM_REQ_MSG_SZ(32,32)-1:0] dmemreq1_msg;
  wire                                 dmemreq1_rdy;
  wire   [`VC_MEM_RESP_MSG_SZ(32)-1:0] dmemresp1_msg;
  wire                                 dmemresp1_val;

  wire [`VC_MEM_REQ_MSG_SZ(32,32)-1:0] dmemreq2_msg;
  wire                                 dmemreq2_rdy;
  wire   [`VC_MEM_RESP_MSG_SZ(32)-1:0] dmemresp2_msg;
  wire                                 dmemresp2_val;

  wire [`VC_MEM_REQ_MSG_SZ(32,32)-1:0] dmemreq3_msg;
  wire                                 dmemreq3_rdy;
  wire   [`VC_MEM_RESP_MSG_SZ(32)-1:0] dmemresp3_msg;
  wire                                 dmemresp3_val;

  wire [`VC_MEM_REQ_MSG_SZ(32,32)-1:0] dmemreq4_msg;
  wire                                 dmemreq4_rdy;
  wire   [`VC_MEM_RESP_MSG_SZ(32)-1:0] dmemresp4_msg;
  wire                                 dmemresp4_val;

  wire [`VC_MEM_REQ_MSG_SZ(32,32)-1:0] dmemreq5_msg;
  wire                                 dmemreq5_rdy;
  wire   [`VC_MEM_RESP_MSG_SZ(32)-1:0] dmemresp5_msg;
  wire                                 dmemresp5_val;

  wire [`VC_MEM_REQ_MSG_SZ(32,32)-1:0] dmemreq6_msg;
  wire                                 dmemreq6_rdy;
  wire   [`VC_MEM_RESP_MSG_SZ(32)-1:0] dmemresp6_msg;
  wire                                 dmemresp6_val;

  wire [`VC_MEM_REQ_MSG_SZ(32,32)-1:0] dmemreq7_msg;
  wire                                 dmemreq7_rdy;
  wire   [`VC_MEM_RESP_MSG_SZ(32)-1:0] dmemresp7_msg;
  wire                                 dmemresp7_val;

  //----------------------------------------------------------------------
  // Reset signals for processor and memory
  //----------------------------------------------------------------------

  reg reset_mem;
  reg reset_proc;

  always @ ( posedge clk ) begin
    reset_mem  <= reset;
    reset_proc <= reset_mem;
  end

  //----------------------------------------------------------------------
  // Processor
  //----------------------------------------------------------------------

  riscv_Core proc
  (
    .clk               (clk),
    .reset             (reset_proc),

    // Instruction request interface

    .imemreq_msg       (imemreq_msg),
    .imemreq_val       (imemreq_val),
    .imemreq_rdy       (imemreq_rdy),

    // Instruction response interface

    .imemresp_msg      (imemresp_msg),
    .imemresp_val      (imemresp_val),

    // Data request interface

    .dmemreq0_msg       (dmemreq0_msg),
    .dmemreq_val       (dmemreq_val),
    .dmemreq0_rdy       (dmemreq0_rdy),

    .dmemreq1_msg       (dmemreq1_msg),
    .dmemreq1_rdy       (dmemreq1_rdy),

    .dmemreq2_msg       (dmemreq2_msg),
    .dmemreq2_rdy       (dmemreq2_rdy),

    .dmemreq3_msg       (dmemreq3_msg),
    .dmemreq3_rdy       (dmemreq3_rdy),

    .dmemreq4_msg       (dmemreq4_msg),
    .dmemreq4_rdy       (dmemreq4_rdy),

    .dmemreq5_msg       (dmemreq5_msg),
    .dmemreq5_rdy       (dmemreq5_rdy),

    .dmemreq6_msg       (dmemreq6_msg),
    .dmemreq6_rdy       (dmemreq6_rdy),

    .dmemreq7_msg       (dmemreq7_msg),
    .dmemreq7_rdy       (dmemreq7_rdy),

    // Data response interface

    .dmemresp0_msg      (dmemresp0_msg),
    .dmemresp0_val      (dmemresp0_val),

    .dmemresp1_msg      (dmemresp1_msg),
    .dmemresp1_val      (dmemresp1_val),

    .dmemresp2_msg      (dmemresp2_msg),
    .dmemresp2_val      (dmemresp2_val),

    .dmemresp3_msg      (dmemresp3_msg),
    .dmemresp3_val      (dmemresp3_val),

    .dmemresp4_msg      (dmemresp4_msg),
    .dmemresp4_val      (dmemresp4_val),

    .dmemresp5_msg      (dmemresp5_msg),
    .dmemresp5_val      (dmemresp5_val),

    .dmemresp6_msg      (dmemresp6_msg),
    .dmemresp6_val      (dmemresp6_val),

    .dmemresp7_msg      (dmemresp7_msg),
    .dmemresp7_val      (dmemresp7_val),

    // CSR status register output to host

    .csr_status        (status)
  );

  // Instruction Memory

  vc_TestSinglePortRandDelayMem
  #(
    .p_mem_sz    (1<<20), // max 20-bit address to index into memory
    .p_addr_sz   (32),    // high order bits will get truncated in memory
    .p_data_sz   (32),
    .p_max_delay (0)
  )
  imem
  (
    .clk                (clk),
    .reset              (reset_mem),

    // Instruction request interface

    .memreq_val        (imemreq_val),
    .memreq_rdy        (imemreq_rdy),
    .memreq_msg        (imemreq_msg),

    // Instruction response interface

    .memresp_val       (imemresp_val),
    .memresp_rdy       (1'b1),
    .memresp_msg       (imemresp_msg)      
  );

  // Data Memory
  vc_TestEightPortRandDelayMem
  #(
    .p_mem_sz    (1<<20), // max 20-bit address to index into memory
    .p_addr_sz   (32),    // high order bits will get truncated in memory
    .p_data_sz   (32),
    .p_max_delay (0)
   )
   dmem
   (
    .clk         (clk),
    .reset       (reset),

    .memreq0_val  (dmemreq_val),
    .memreq0_rdy  (dmemreq0_rdy),
    .memreq0_msg  (dmemreq0_msg),

    .memresp0_val (dmemresp0_val),
    .memresp0_rdy (1'b1),
    .memresp0_msg (dmemresp0_msg),

    .memreq1_val  (dmemreq_val),
    .memreq1_rdy  (dmemreq1_rdy),
    .memreq1_msg  (dmemreq1_msg),

    .memresp1_val (dmemresp1_val),
    .memresp1_rdy (1'b1),
    .memresp1_msg (dmemresp1_msg),

    .memreq2_val  (dmemreq_val),
    .memreq2_rdy  (dmemreq2_rdy),
    .memreq2_msg  (dmemreq2_msg),

    .memresp2_val (dmemresp2_val),
    .memresp2_rdy (1'b1),
    .memresp2_msg (dmemresp2_msg),

    .memreq3_val  (dmemreq_val),
    .memreq3_rdy  (dmemreq3_rdy),
    .memreq3_msg  (dmemreq3_msg),

    .memresp3_val (dmemresp3_val),
    .memresp3_rdy (1'b1),
    .memresp3_msg (dmemresp3_msg),

    .memreq4_val  (dmemreq_val),
    .memreq4_rdy  (dmemreq4_rdy),
    .memreq4_msg  (dmemreq4_msg),

    .memresp4_val (dmemresp4_val),
    .memresp4_rdy (1'b1),
    .memresp4_msg (dmemresp4_msg),

    .memreq5_val  (dmemreq_val),
    .memreq5_rdy  (dmemreq5_rdy),
    .memreq5_msg  (dmemreq5_msg),

    .memresp5_val (dmemresp5_val),
    .memresp5_rdy (1'b1),
    .memresp5_msg (dmemresp5_msg),

    .memreq6_val  (dmemreq_val),
    .memreq6_rdy  (dmemreq6_rdy),
    .memreq6_msg  (dmemreq6_msg),

    .memresp6_val (dmemresp6_val),
    .memresp6_rdy (1'b1),
    .memresp6_msg (dmemresp6_msg),

    .memreq7_val  (dmemreq_val),
    .memreq7_rdy  (dmemreq7_rdy),
    .memreq7_msg  (dmemreq7_msg),

    .memresp7_val (dmemresp7_val),
    .memresp7_rdy (1'b1),
    .memresp7_msg (dmemresp7_msg)
   );

  /*
  // Data Memory 1

  vc_TestQuadPortRandDelayMem
  #(
    .p_mem_sz    (1<<20), // max 20-bit address to index into memory
    .p_addr_sz   (32),    // high order bits will get truncated in memory
    .p_data_sz   (32),
    .p_max_delay (0)
   )
   dmem1
  (
    .clk         (clk),
    .reset       (reset),

    .memreq0_val  (dmemreq_val),
    .memreq0_rdy  (dmemreq0_rdy),
    .memreq0_msg  (dmemreq0_msg),

    .memresp0_val (dmemresp0_val),
    .memresp0_rdy (1'b1),
    .memresp0_msg (dmemresp0_msg),

    .memreq1_val  (dmemreq_val),
    .memreq1_rdy  (dmemreq1_rdy),
    .memreq1_msg  (dmemreq1_msg),

    .memresp1_val (dmemresp1_val),
    .memresp1_rdy (1'b1),
    .memresp1_msg (dmemresp1_msg),

    .memreq2_val  (dmemreq_val),
    .memreq2_rdy  (dmemreq2_rdy),
    .memreq2_msg  (dmemreq2_msg),

    .memresp2_val (dmemresp2_val),
    .memresp2_rdy (1'b1),
    .memresp2_msg (dmemresp2_msg),

    .memreq3_val  (dmemreq_val),
    .memreq3_rdy  (dmemreq3_rdy),
    .memreq3_msg  (dmemreq3_msg),

    .memresp3_val (dmemresp3_val),
    .memresp3_rdy (1'b1),
    .memresp3_msg (dmemresp3_msg)
  );

  // Data Memory 2

  vc_TestQuadPortRandDelayMem
  #(
    .p_mem_sz    (1<<20), // max 20-bit address to index into memory
    .p_addr_sz   (32),    // high order bits will get truncated in memory
    .p_data_sz   (32),
    .p_max_delay (0)
   )
   dmem2
  (
    .clk         (clk),
    .reset       (reset),

    .memreq0_val  (dmemreq_val),
    .memreq0_rdy  (dmemreq4_rdy),
    .memreq0_msg  (dmemreq4_msg),

    .memresp0_val (dmemresp4_val),
    .memresp0_rdy (1'b1),
    .memresp0_msg (dmemresp4_msg),

    .memreq1_val  (dmemreq_val),
    .memreq1_rdy  (dmemreq5_rdy),
    .memreq1_msg  (dmemreq5_msg),

    .memresp1_val (dmemresp5_val),
    .memresp1_rdy (1'b1),
    .memresp1_msg (dmemresp5_msg),

    .memreq2_val  (dmemreq_val),
    .memreq2_rdy  (dmemreq6_rdy),
    .memreq2_msg  (dmemreq6_msg),

    .memresp2_val (dmemresp6_val),
    .memresp2_rdy (1'b1),
    .memresp2_msg (dmemresp6_msg),

    .memreq3_val  (dmemreq_val),
    .memreq3_rdy  (dmemreq7_rdy),
    .memreq3_msg  (dmemreq7_msg),

    .memresp3_val (dmemresp7_val),
    .memresp3_rdy (1'b1),
    .memresp3_msg (dmemresp7_msg)
  );
  */


  //----------------------------------------------------------------------
  // Start the simulation
  //----------------------------------------------------------------------

  integer fh;
  reg [1023:0] exe_filename;
  reg [1023:0] vcd_filename;
  reg   [31:0] max_cycles;
  reg          verbose;
  reg          stats;
  reg          vcd;
  reg    [1:0] disasm;

  integer i;

  initial begin

    // Load program into memory from the command line
    if ( $value$plusargs( "exe=%s", exe_filename ) ) begin

      // Check that file exists
      fh = $fopen( exe_filename, "r" );
      if ( !fh ) begin
        $display( "\n ERROR: Could not open vmh file (%s)! \n", exe_filename );
        $finish;
      end
      $fclose(fh);

      $readmemh( exe_filename, imem.mem.m );
      $readmemh( exe_filename, dmem.mem.m );

    end
    else begin
      $display( "\n ERROR: No executable specified! (use +exe=<filename>) \n" );
      $finish;
    end

    // Get max number of cycles to run simulation for from command line
    if ( !$value$plusargs( "max-cycles=%d", max_cycles ) ) begin
      max_cycles = 100000;
    end

    // Get stats flag
    if ( !$value$plusargs( "stats=%d", stats ) ) begin

      // Get verbose flag
      if ( !$value$plusargs( "verbose=%d", verbose ) ) begin
        verbose = 1'b0;
      end

      proc.ctrl.stats_en = 1'b0;
    end
    else begin
      verbose = 1'b1;
      proc.ctrl.stats_en = 1'b1;
    end

    // vcd dump
    if ( $value$plusargs( "vcd=%d", vcd ) ) begin
      vcd_filename = { exe_filename[1023:32], ".vcd" }; // Super hack, remove last 3 chars,
                                                        // replace with .vcd extension
      $dumpfile( vcd_filename );
      $dumpvars;
    end

    // Disassemble instructions
    if ( !$value$plusargs( "disasm=%d", disasm ) ) begin
      disasm = 2'b0;
    end

    // Stobe reset
    #5  reset = 1'b1;
    #20 reset = 1'b0;

  end

  //----------------------------------------------------------------------
  // Disassemble instructions
  //----------------------------------------------------------------------

  always @ ( posedge clk ) begin
    if ( disasm == 3 ) begin

      // Fetch Stage

      if ( proc.ctrl.bubble_Fhl )
        $write( "{  (-_-)   |" );
      else if ( proc.ctrl.squash_Fhl )
        $write( "{-%h-|", proc.dpath.pc_Fhl );
      else if ( proc.ctrl.stall_Fhl )
        $write( "{#%h |", proc.dpath.pc_Fhl );
      else
        $write( "{ %h |", proc.dpath.pc_Fhl );

      // Decode Stage

      if ( proc.ctrl.bubble_Dhl )
        $write( "  (-_-) " );
      else if ( proc.ctrl.squash_Dhl )
        $write( "-%s-", proc.ctrl.inst_msg_disasm_D.minidasm );
      else if ( proc.ctrl.stall_Dhl )
        $write( "#%s ", proc.ctrl.inst_msg_disasm_D.minidasm );
      else
        $write( " %s ", proc.ctrl.inst_msg_disasm_D.minidasm );

      $write( "|" );

      // Execute Stage

      if ( proc.ctrl.bubble_Xhl )
        $write( "  (-_-) " );
      else if ( proc.ctrl.squash_Xhl )
        $write( "-%s-", proc.ctrl.inst_msg_disasm_X.minidasm );
      else if ( proc.ctrl.stall_Xhl )
        $write( "#%s ", proc.ctrl.inst_msg_disasm_X.minidasm );
      else
        $write( " %s ", proc.ctrl.inst_msg_disasm_X.minidasm );

      $write( "|" );

      // Memory Stage

      if ( proc.ctrl.bubble_Mhl )
        $write( "  (-_-) " );
      else if ( proc.ctrl.squash_Mhl )
        $write( "-%s-", proc.ctrl.inst_msg_disasm_M.minidasm );
      else if ( proc.ctrl.stall_Mhl )
        $write( "#%s ", proc.ctrl.inst_msg_disasm_M.minidasm );
      else
        $write( " %s ", proc.ctrl.inst_msg_disasm_M.minidasm );

      $write( "|" );

      if ( proc.ctrl.bubble_X2hl )
        $write( "  (-_-) " );
      else if ( proc.ctrl.squash_X2hl )
        $write( "-%s-", proc.ctrl.inst_msg_disasm_X2.minidasm );
      else if ( proc.ctrl.stall_X2hl )
        $write( "#%s ", proc.ctrl.inst_msg_disasm_X2.minidasm );
      else
        $write( " %s ", proc.ctrl.inst_msg_disasm_X2.minidasm );

      $write( "|" );

      if ( proc.ctrl.bubble_X3hl )
        $write( "  (-_-) " );
      else if ( proc.ctrl.squash_X3hl )
        $write( "-%s-", proc.ctrl.inst_msg_disasm_X3.minidasm );
      else if ( proc.ctrl.stall_X3hl )
        $write( "#%s ", proc.ctrl.inst_msg_disasm_X3.minidasm );
      else
        $write( " %s ", proc.ctrl.inst_msg_disasm_X3.minidasm );

      $write( "|" );

      // Writeback Stage

      if ( proc.ctrl.bubble_Whl )
        $write( "  (-_-) " );
      else if ( proc.ctrl.squash_Whl )
        $write( "-%s-", proc.ctrl.inst_msg_disasm_W.minidasm );
      else if ( proc.ctrl.stall_Whl )
        $write( "#%s ", proc.ctrl.inst_msg_disasm_W.minidasm );
      else
        $write( " %s ", proc.ctrl.inst_msg_disasm_W.minidasm );

      $display( "}" );

    end
    else if ( disasm > 0 ) begin
      if ( proc.ctrl.inst_val_debug ) begin
        $display( "%h: %h: %s",
                   proc.dpath.pc_debug, proc.ctrl.ir_debug, proc.ctrl.inst_msg_disasm_debug.dasm );

        if ( disasm > 1 ) begin
          $display( "r00=%h r01=%h r02=%h r03=%h r04=%h r05=%h",
                     proc.dpath.rfile.registers[ 0], proc.dpath.rfile.registers[ 1],
                     proc.dpath.rfile.registers[ 2], proc.dpath.rfile.registers[ 3],
                     proc.dpath.rfile.registers[ 4], proc.dpath.rfile.registers[ 5] );
          $display( "r06=%h r07=%h r08=%h r09=%h r10=%h r11=%h",
                     proc.dpath.rfile.registers[ 6], proc.dpath.rfile.registers[ 7],
                     proc.dpath.rfile.registers[ 8], proc.dpath.rfile.registers[ 9],
                     proc.dpath.rfile.registers[10], proc.dpath.rfile.registers[11] );
          $display( "r12=%h r13=%h r14=%h r15=%h r16=%h r17=%h",
                     proc.dpath.rfile.registers[12], proc.dpath.rfile.registers[13],
                     proc.dpath.rfile.registers[14], proc.dpath.rfile.registers[15],
                     proc.dpath.rfile.registers[16], proc.dpath.rfile.registers[17] );
          $display( "r18=%h r19=%h r20=%h r21=%h r22=%h r23=%h",
                     proc.dpath.rfile.registers[18], proc.dpath.rfile.registers[19],
                     proc.dpath.rfile.registers[20], proc.dpath.rfile.registers[21],
                     proc.dpath.rfile.registers[22], proc.dpath.rfile.registers[23] );
          $display( "r24=%h r25=%h r26=%h r27=%h r28=%h r29=%h",
                     proc.dpath.rfile.registers[24], proc.dpath.rfile.registers[25],
                     proc.dpath.rfile.registers[26], proc.dpath.rfile.registers[27],
                     proc.dpath.rfile.registers[28], proc.dpath.rfile.registers[29] );
          $display( "r30=%h r31=%h",
                     proc.dpath.rfile.registers[30], proc.dpath.rfile.registers[31] );
        end

        $display( "-----" );
      end
    end
  end

  //----------------------------------------------------------------------
  // Stop running when status changes
  //----------------------------------------------------------------------

  real ipc;

  always @ ( * ) begin
    if ( !reset && ( status != 0 ) ) begin

      if ( status == 1'b1 )
        $display( "*** PASSED ***" );

      if ( status > 1'b1 )
        $display( "*** FAILED *** (status = %d)", status );

      if ( verbose == 1'b1 ) begin
        ipc = proc.ctrl.num_inst/$itor(proc.ctrl.num_cycles);

        $display( "--------------------------------------------" );
        $display( " STATS                                      " );
        $display( "--------------------------------------------" );

        $display( " status     = %d", status                     );
        $display( " num_cycles = %d", proc.ctrl.num_cycles       );
        $display( " num_inst   = %d", proc.ctrl.num_inst         );
        $display( " ipc        = %f", ipc                        );
      end

      #20 $finish;

    end
  end

  //----------------------------------------------------------------------
  // Safety net to catch infinite loops
  //----------------------------------------------------------------------

  reg [31:0] cycle_count = 32'b0;

  always @ ( posedge clk ) begin
    cycle_count = cycle_count + 1'b1;
  end

  always @ ( * ) begin
    if ( cycle_count > max_cycles ) begin
      #20;
      $display("*** FAILED *** (timeout)");
      $finish;
   end
  end

endmodule

