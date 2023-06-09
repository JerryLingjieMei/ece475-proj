//=========================================================================
// 7-Stage RISCV Datapath
//=========================================================================

`ifndef RISCV_CORE_DPATH_V
`define RISCV_CORE_DPATH_V

`include "riscvvec-CoreDpathPipeMulDiv.v"
`include "riscvvec-InstMsg.v"
`include "riscvvec-CoreDpathAlu.v"
`include "riscvvec-CoreDpathRegfile.v"
`include "riscvvec-CoreDpathVecRegfile.v"
`include "riscvvec-CoreDpathVecAlu.v"

module riscv_CoreDpath
(
  input clk,
  input reset,

  // Instruction Memory Port

  output [31:0] imemreq_msg_addr,

  // Data Memory Port

  output [31:0] dmemreq_msg_addr,
  output [255:0] dmemreq_msg_data,
  output   [3:0] dmemreq_vl,
  input    [2:0] dmemreq_msg_len_Xhl,
  input  [255:0] dmemresp_msg_data,

  // Controls Signals (ctrl->dpath)

  input   [1:0] pc_mux_sel_Phl,
  input   [1:0] op0_mux_sel_Dhl,
  input   [2:0] op1_mux_sel_Dhl,
  input  [31:0] inst_Dhl,
  input   [3:0] alu_fn_Xhl,
  input         alu_vsel_Xhl,
  input   [2:0] muldivreq_msg_fn_Dhl,
  input         muldivreq_val,
  output        muldivreq_rdy,
  output        muldivresp_val,
  input         muldivresp_rdy,
  input         muldiv_mux_sel_X3hl,
  input         execute_mux_sel_X3hl,
  input   [2:0] dmemreq_msg_len_Dhl,
  input   [2:0] dmemresp_mux_sel_Mhl,
  input         dmemresp_queue_en_Mhl,
  input         dmemresp_queue_val_Mhl,
  input         wb_mux_sel_Mhl,
  input         rf_wen_Whl,
  input         rf_vwen_Whl,
  input         rf_vlwen_Xhl,
  input  [ 4:0] rf_waddr_Whl,
  input         stall_Fhl,
  input         stall_Dhl,
  input         stall_Xhl,
  input         stall_Mhl,
  input         stall_Whl,
	input   [2:0] rdata0_byp_mux_sel_Dhl,
	input   [2:0] rdata1_byp_mux_sel_Dhl,
  input   [2:0] vdata0_byp_mux_sel_Dhl,
	input   [2:0] vdata1_byp_mux_sel_Dhl,
	input         op0_ven_Xhl,
	input         op1_ven_Xhl,

	input					stall_X2hl,
	input					stall_X3hl,

  // Control Signals (dpath->ctrl)

  output        branch_cond_eq_Xhl,
  output        branch_cond_ne_Xhl,
  output        branch_cond_lt_Xhl,
  output        branch_cond_ltu_Xhl,
  output        branch_cond_ge_Xhl,
  output        branch_cond_geu_Xhl,
  output [31:0] proc2csr_data_Whl
);

  //--------------------------------------------------------------------
  // PC Logic Stage
  //--------------------------------------------------------------------

  // PC mux

  wire [31:0] pc_plus4_Phl;
  wire [31:0] branch_targ_Phl;
  wire [31:0] jump_targ_Phl;
  wire [31:0] jumpreg_targ_Phl;
  wire [31:0] pc_mux_out_Phl;

  wire [31:0] reset_vector = 32'h00080000;

  // Pull mux inputs from later stages

  assign pc_plus4_Phl       = pc_plus4_Fhl;
  assign branch_targ_Phl    = branch_targ_Xhl;
  assign jump_targ_Phl      = jump_targ_Dhl;
  assign jumpreg_targ_Phl   = jumpreg_targ_Dhl;

  assign pc_mux_out_Phl
    = ( pc_mux_sel_Phl == 2'd0 ) ? pc_plus4_Phl
    : ( pc_mux_sel_Phl == 2'd1 ) ? branch_targ_Phl
    : ( pc_mux_sel_Phl == 2'd2 ) ? jump_targ_Phl
    : ( pc_mux_sel_Phl == 2'd3 ) ? jumpreg_targ_Phl
    :                              32'bx;

  // Send out imem request early

  assign imemreq_msg_addr
    = ( reset ) ? reset_vector
    :             pc_mux_out_Phl;

  //----------------------------------------------------------------------
  // F <- P
  //----------------------------------------------------------------------

  reg  [31:0] pc_Fhl;

  always @ (posedge clk) begin
    if( reset ) begin
      pc_Fhl <= reset_vector;
    end
    else if( !stall_Fhl ) begin
      pc_Fhl <= pc_mux_out_Phl;
    end
  end

  //--------------------------------------------------------------------
  // Fetch Stage
  //--------------------------------------------------------------------

  // PC incrementer

  wire [31:0] pc_plus4_Fhl;

  assign pc_plus4_Fhl = pc_Fhl + 32'd4;

  //----------------------------------------------------------------------
  // D <- F
  //----------------------------------------------------------------------

  reg [31:0] pc_Dhl;
  reg [31:0] pc_plus4_Dhl;

  always @ (posedge clk) begin
    if( !stall_Dhl ) begin
      pc_Dhl       <= pc_Fhl;
      pc_plus4_Dhl <= pc_plus4_Fhl;
    end
  end

  //--------------------------------------------------------------------
  // Decode Stage (Register Read)
  //--------------------------------------------------------------------

  // Parse instruction fields

  wire   [4:0] inst_rs1_Dhl;
  wire   [4:0] inst_rs2_Dhl;
  wire   [4:0] inst_rd_Dhl;
  wire   [4:0] inst_shamt_Dhl;
  wire  [31:0] imm_i_Dhl;
  wire  [31:0] imm_u_Dhl;
  wire  [31:0] imm_uj_Dhl;
  wire  [31:0] imm_s_Dhl;
  wire  [31:0] imm_sb_Dhl;

  // Branch and jump address generation

  wire [31:0] branch_targ_Dhl;
  wire [31:0] jump_targ_Dhl;

  assign branch_targ_Dhl = pc_Dhl + imm_sb_Dhl;
  assign jump_targ_Dhl   = pc_Dhl + imm_uj_Dhl;

  // Vector Register File
  wire [255:0]  rf_vdata0_Dhl;
  wire [255:0]  rf_vdata1_Dhl;

  // Register file

  wire [ 4:0] rf_raddr0_Dhl = inst_rs1_Dhl;
  wire [31:0] rf_rdata0_Dhl;
  wire [ 4:0] rf_raddr1_Dhl = inst_rs2_Dhl;
  wire [31:0] rf_rdata1_Dhl;

  // Jump reg address

  wire [31:0] jumpreg_targ_Dhl;

  wire [31:0] jumpreg_targ_pretruncate_Dhl = rdata0_byp_mux_out_Dhl + imm_i_Dhl;
  assign jumpreg_targ_Dhl  = {jumpreg_targ_pretruncate_Dhl[31:1], 1'b0};

  // Shift amount immediate

  wire [31:0] shamt_Dhl = { 27'b0, inst_shamt_Dhl };

  // Constant operand mux inputs

  wire [31:0] const0    = 32'd0;

	// rdata0 bypass
	wire [31:0] rdata0_byp_mux_out_Dhl
		= ( rdata0_byp_mux_sel_Dhl == 3'd0 ) ? rf_rdata0_Dhl
		: ( rdata0_byp_mux_sel_Dhl == 3'd1 ) ? execute_mux_out_Xhl
	  : ( rdata0_byp_mux_sel_Dhl == 3'd2 ) ? wb_mux_out_Mhl
	  : ( rdata0_byp_mux_sel_Dhl == 3'd3 ) ? wb_mux_out_X2hl
		: ( rdata0_byp_mux_sel_Dhl == 3'd4 ) ? execute_mux_out_X3hl
		: ( rdata0_byp_mux_sel_Dhl == 3'd5 ) ? wb_mux_out_Whl
		:																			 32'bx;	

	// rdata1 bypass
	wire [31:0] rdata1_byp_mux_out_Dhl
		= ( rdata1_byp_mux_sel_Dhl == 3'd0 ) ? rf_rdata1_Dhl
		: ( rdata1_byp_mux_sel_Dhl == 3'd1 ) ? execute_mux_out_Xhl
	  : ( rdata1_byp_mux_sel_Dhl == 3'd2 ) ? wb_mux_out_Mhl
	  : ( rdata1_byp_mux_sel_Dhl == 3'd3 ) ? wb_mux_out_X2hl
		: ( rdata1_byp_mux_sel_Dhl == 3'd4 ) ? execute_mux_out_X3hl
		: ( rdata1_byp_mux_sel_Dhl == 3'd5 ) ? wb_mux_out_Whl
		:																			 32'bx;

	wire [255:0] vdata0_byp_mux_out_Dhl
		= ( vdata0_byp_mux_sel_Dhl == 3'd0 ) ? rf_vdata0_Dhl
		: ( vdata0_byp_mux_sel_Dhl == 3'd1 ) ? execute_mux_vout_Xhl
	  : ( vdata0_byp_mux_sel_Dhl == 3'd2 ) ? wb_mux_vout_Mhl
	  : ( vdata0_byp_mux_sel_Dhl == 3'd3 ) ? wb_mux_vout_X2hl
		: ( vdata0_byp_mux_sel_Dhl == 3'd4 ) ? execute_mux_vout_X3hl
		: ( vdata0_byp_mux_sel_Dhl == 3'd5 ) ? wb_mux_vout_Whl
		:																			 256'bx;

	// vdata1 bypass
	wire [255:0] vdata1_byp_mux_out_Dhl
		= ( vdata1_byp_mux_sel_Dhl == 3'd0 ) ? rf_vdata1_Dhl
		: ( vdata1_byp_mux_sel_Dhl == 3'd1 ) ? execute_mux_vout_Xhl
	  : ( vdata1_byp_mux_sel_Dhl == 3'd2 ) ? wb_mux_vout_Mhl
	  : ( vdata1_byp_mux_sel_Dhl == 3'd3 ) ? wb_mux_vout_X2hl
		: ( vdata1_byp_mux_sel_Dhl == 3'd4 ) ? execute_mux_vout_X3hl
		: ( vdata1_byp_mux_sel_Dhl == 3'd5 ) ? wb_mux_vout_Whl
		:																			 256'bx;


  // Operand 0 mux

  wire [31:0] op0_mux_out_Dhl
    = ( op0_mux_sel_Dhl == 2'd0 ) ? rdata0_byp_mux_out_Dhl
    : ( op0_mux_sel_Dhl == 2'd1 ) ? pc_Dhl
    : ( op0_mux_sel_Dhl == 2'd2 ) ? pc_plus4_Dhl
    : ( op0_mux_sel_Dhl == 2'd3 ) ? const0
    :                               32'bx;

  // Operand 1 mux

  wire [31:0] op1_mux_out_Dhl
    = ( op1_mux_sel_Dhl == 3'd0 ) ? rdata1_byp_mux_out_Dhl
    : ( op1_mux_sel_Dhl == 3'd1 ) ? shamt_Dhl
    : ( op1_mux_sel_Dhl == 3'd2 ) ? imm_u_Dhl
    : ( op1_mux_sel_Dhl == 3'd3 ) ? imm_sb_Dhl
    : ( op1_mux_sel_Dhl == 3'd4 ) ? imm_i_Dhl
    : ( op1_mux_sel_Dhl == 3'd5 ) ? imm_s_Dhl
    : ( op1_mux_sel_Dhl == 3'd6 ) ? const0
    :                               32'bx;

  wire [255:0] op0_mux_vout_Dhl = vdata0_byp_mux_out_Dhl;
  wire [255:0] op1_mux_vout_Dhl = vdata1_byp_mux_out_Dhl;

  // wdata with bypassing

  wire [31:0] wdata_Dhl = rdata1_byp_mux_out_Dhl;
  wire [255:0] wvdata_Dhl = vdata1_byp_mux_out_Dhl;

  // Dmem data

  wire [255:0] dmemreq_data_Dhl = ( dmemreq_msg_len_Dhl == 3'd4) ? wvdata_Dhl : { {224{1'b0}}, wdata_Dhl };

  always @ (posedge clk) begin
    $display("%x %x %x %x %x %x ", op0_mux_vout_Dhl, op1_mux_vout_Dhl, op0_mux_out_Dhl, op1_mux_out_Dhl, op0_ven_Xhl, op1_ven_Xhl);
  end

  //----------------------------------------------------------------------
  // X <- D
  //----------------------------------------------------------------------

  reg [31:0] pc_Xhl;
  reg [31:0] branch_targ_Xhl;
  reg [31:0] op0_mux_out_Xhl;
  reg [31:0] op1_mux_out_Xhl;
  reg [255:0] op0_mux_vout_Xhl;
  reg [255:0] op1_mux_vout_Xhl;
  reg [255:0] dmemreq_data_Xhl;
  reg [31:0]  wdata_Xhl;
  reg [255:0] wvdata_Xhl;

  always @ (posedge clk) begin
    if( !stall_Xhl ) begin
      pc_Xhl          <= pc_Dhl;
      branch_targ_Xhl <= branch_targ_Dhl;
      op0_mux_out_Xhl <= op0_mux_out_Dhl;
      op1_mux_out_Xhl <= op1_mux_out_Dhl;
      op0_mux_vout_Xhl <= op0_mux_vout_Dhl;
      op1_mux_vout_Xhl <= op1_mux_vout_Dhl;
      dmemreq_data_Xhl <= dmemreq_data_Dhl;
      wdata_Xhl       <= wdata_Dhl;
      wvdata_Xhl      <= wvdata_Dhl;
    end
  end

  //----------------------------------------------------------------------
  // Execute Stage
  //----------------------------------------------------------------------

  // ALU

  wire [31:0] vec_alu_out_Xhl;
  wire [31:0] nvec_alu_out_Xhl;
  wire [31:0] alu_out_Xhl = alu_vsel_Xhl ? vec_alu_out_Xhl: nvec_alu_out_Xhl;
  wire [255:0] alu_vout_Xhl;

  // Branch condition logic

  wire   diffSigns_Xhl         = op0_mux_out_Xhl[31] ^ op1_mux_out_Xhl[31];
  assign branch_cond_eq_Xhl    = ( alu_out_Xhl == 32'd0 );
  assign branch_cond_ne_Xhl    = ~branch_cond_eq_Xhl;
  assign branch_cond_lt_Xhl    = diffSigns_Xhl ? op0_mux_out_Xhl[31] : alu_out_Xhl[31];
  assign branch_cond_ltu_Xhl   = diffSigns_Xhl ? op1_mux_out_Xhl[31] : alu_out_Xhl[31];
  assign branch_cond_ge_Xhl    = diffSigns_Xhl ? op1_mux_out_Xhl[31] : ~alu_out_Xhl[31];
  assign branch_cond_geu_Xhl   = diffSigns_Xhl ? op0_mux_out_Xhl[31] : ~alu_out_Xhl[31];

  // Send out memory request during X, response returns in M

  assign dmemreq_msg_addr = alu_out_Xhl;
  assign dmemreq_msg_data = dmemreq_data_Xhl;
  assign dmemreq_vl       = vl_Xhl;

  wire [31:0] execute_mux_out_Xhl = alu_out_Xhl;
  wire [255:0] execute_mux_vout_Xhl = alu_vout_Xhl;
  wire [3:0] vl_Xhl;

 
  //----------------------------------------------------------------------
  // M <- X
  //----------------------------------------------------------------------

  reg  [31:0] pc_Mhl;
  reg  [31:0] execute_mux_out_Mhl;
  reg  [255:0] execute_mux_vout_Mhl;
  reg  [255:0] wdata_Mhl;

  always @ (posedge clk) begin
    if( !stall_Mhl ) begin
      pc_Mhl              <= pc_Xhl;
      execute_mux_out_Mhl <= execute_mux_out_Xhl;
      execute_mux_vout_Mhl <= execute_mux_vout_Xhl;
      wdata_Mhl           <= wdata_Xhl;
    end
  end

  //----------------------------------------------------------------------
  // Memory Stage
  //----------------------------------------------------------------------

  // Data memory subword adjustment mux

  wire [31:0] dmemresp_lb_Mhl
    = { {24{dmemresp_msg_data[7]}}, dmemresp_msg_data[7:0] };

  wire [31:0] dmemresp_lbu_Mhl
    = { {24{1'b0}}, dmemresp_msg_data[7:0] };

  wire [31:0] dmemresp_lh_Mhl
    = { {16{dmemresp_msg_data[15]}}, dmemresp_msg_data[15:0] };

  wire [31:0] dmemresp_lhu_Mhl
    = { {16{1'b0}}, dmemresp_msg_data[15:0] };

  wire [31:0] dmemresp_lw_Mhl = dmemresp_msg_data[31:0];

  wire [31:0] dmemresp_mux_out_Mhl
    = ( dmemresp_mux_sel_Mhl == 3'd0 ) ? dmemresp_lw_Mhl
    : ( dmemresp_mux_sel_Mhl == 3'd1 ) ? dmemresp_lb_Mhl
    : ( dmemresp_mux_sel_Mhl == 3'd2 ) ? dmemresp_lbu_Mhl
    : ( dmemresp_mux_sel_Mhl == 3'd3 ) ? dmemresp_lh_Mhl
    : ( dmemresp_mux_sel_Mhl == 3'd4 ) ? dmemresp_lhu_Mhl
    :                                    32'bx;

   wire [255:0] dmemresp_mux_vout_Mhl 
    = ( dmemresp_mux_sel_Mhl == 3'd5 ) ? dmemresp_msg_data
    :                                    256'bx;

  //----------------------------------------------------------------------
  // Queue for data memory response
  //----------------------------------------------------------------------

  reg [31:0] dmemresp_queue_reg_Mhl;
  reg [255:0] dmemresp_queue_vreg_Mhl;

  always @ ( posedge clk ) begin
    if ( dmemresp_queue_en_Mhl ) begin
      dmemresp_queue_reg_Mhl <= dmemresp_mux_out_Mhl;
      dmemresp_queue_vreg_Mhl <= dmemresp_mux_vout_Mhl;
    end
  end

  //----------------------------------------------------------------------
  // Data memory queue mux
  //----------------------------------------------------------------------

  wire [31:0] dmemresp_queue_mux_out_Mhl
    = ( !dmemresp_queue_val_Mhl ) ? dmemresp_mux_out_Mhl
    : ( dmemresp_queue_val_Mhl )  ? dmemresp_queue_reg_Mhl
    :                               32'bx;
    
  wire [255:0] dmemresp_queue_mux_vout_Mhl
    = ( !dmemresp_queue_val_Mhl ) ? dmemresp_mux_vout_Mhl
    : ( dmemresp_queue_val_Mhl )  ? dmemresp_queue_vreg_Mhl
    :                               256'bx; 

  //----------------------------------------------------------------------
  // Writeback mux
  //----------------------------------------------------------------------

  wire [31:0] wb_mux_out_Mhl
    = ( wb_mux_sel_Mhl == 1'd0 ) ? execute_mux_out_Mhl
    : ( wb_mux_sel_Mhl == 1'd1 ) ? dmemresp_queue_mux_out_Mhl
    :                              32'bx;
    
   wire [255:0] wb_mux_vout_Mhl
    = ( wb_mux_sel_Mhl == 1'd0 ) ? execute_mux_vout_Mhl
    : ( wb_mux_sel_Mhl == 1'd1 ) ? dmemresp_queue_mux_vout_Mhl
    :                              256'bx;

	//----------------------------------------------------------------------
  // X2 <- M
  //----------------------------------------------------------------------

  reg  [31:0] pc_X2hl;
  reg  [31:0] wb_mux_out_X2hl;
  reg  [255:0] wb_mux_vout_X2hl;

  always @ (posedge clk) begin
    if( !stall_X2hl ) begin
      pc_X2hl                 <= pc_Mhl;
      wb_mux_out_X2hl         <= wb_mux_out_Mhl;
      wb_mux_vout_X2hl         <= wb_mux_vout_Mhl;
    end
  end

		
	//----------------------------------------------------------------------
  // X3 <- X2
  //----------------------------------------------------------------------

  reg  [31:0] pc_X3hl;
  reg  [31:0] wb_mux_out_X3hl;
  reg  [255:0] execute_mux_vout_X3hl;

  always @ (posedge clk) begin
    if( !stall_X3hl ) begin
      pc_X3hl                 <= pc_X2hl;
      wb_mux_out_X3hl         <= wb_mux_out_X2hl;
      execute_mux_vout_X3hl   <= wb_mux_vout_X2hl;
    end
  end
  

  wire [63:0] muldivresp_msg_result_X3hl;

  // Muldiv Result Mux

  wire [31:0] muldiv_mux_out_X3hl
    = ( muldiv_mux_sel_X3hl == 1'd0 ) ? muldivresp_msg_result_X3hl[31:0]
    : ( muldiv_mux_sel_X3hl == 1'd1 ) ? muldivresp_msg_result_X3hl[63:32]
    :                                   32'bx;

  // Execute Result Mux

  wire [31:0] execute_mux_out_X3hl
    = ( execute_mux_sel_X3hl == 1'd0 ) ? wb_mux_out_X3hl
    : ( execute_mux_sel_X3hl == 1'd1 ) ? muldiv_mux_out_X3hl
    :                                    32'bx;


  //----------------------------------------------------------------------
  // W <- X3
  //----------------------------------------------------------------------

  reg  [31:0] pc_Whl;
  reg  [31:0] wb_mux_out_Whl;
  reg  [255:0] wb_mux_vout_Whl;

  always @ (posedge clk) begin
    if( !stall_Whl ) begin
      pc_Whl                 <= pc_X3hl;
      wb_mux_out_Whl         <= execute_mux_out_X3hl;
      wb_mux_vout_Whl         <= execute_mux_vout_X3hl;
    end
  end

  //----------------------------------------------------------------------
  // Writeback Stage
  //----------------------------------------------------------------------

  // CSR write data

  assign proc2csr_data_Whl = wb_mux_out_Whl;

  //----------------------------------------------------------------------
  // Debug registers for instruction disassembly
  //----------------------------------------------------------------------

  reg [31:0] pc_debug;

  always @ ( posedge clk ) begin
    pc_debug <= pc_Whl;
  end
  
  //----------------------------------------------------------------------
  // Submodules
  //----------------------------------------------------------------------
  
  // Address Generation

  riscv_InstMsgFromBits inst_msg_from_bits
  (
    .msg      (inst_Dhl),
    .opcode   (),
    .rs1      (inst_rs1_Dhl),
    .rs2      (inst_rs2_Dhl),
    .rd       (inst_rd_Dhl),
    .funct3   (),
    .funct7   (),
    .shamt    (inst_shamt_Dhl),
    .imm_i    (imm_i_Dhl),
    .imm_s    (imm_s_Dhl),
    .imm_sb   (imm_sb_Dhl),
    .imm_u    (imm_u_Dhl),
    .imm_uj   (imm_uj_Dhl)
  );

  // Register File

  riscv_CoreDpathRegfile rfile
  (
    .clk     (clk),
    .raddr0  (rf_raddr0_Dhl),
    .rdata0  (rf_rdata0_Dhl),
    .raddr1  (rf_raddr1_Dhl),
    .rdata1  (rf_rdata1_Dhl),
    .wen_p   (rf_wen_Whl),
    .waddr_p (rf_waddr_Whl),
    .wdata_p (wb_mux_out_Whl)
  );

  riscv_CoreDpathVectorRegfile vecrfile
  (
    .clk     (clk),
    .raddr0  (rf_raddr0_Dhl),
    .rdata0  (rf_vdata0_Dhl),
    .raddr1  (rf_raddr1_Dhl),
    .rdata1  (rf_vdata1_Dhl),
    .wen_p   (rf_vwen_Whl && rf_wen_Whl),
    .waddr_p (rf_waddr_Whl),
    .wdata_p (wb_mux_vout_Whl),
    .wvlen_p (rf_vlwen_Xhl),
    .wvl_p   (alu_out_Xhl),
    .vl      (vl_Xhl)
  );

  // ALU

  riscv_CoreDpathAlu alu
  (
    .in0  (op0_mux_out_Xhl),
    .in1  (op1_mux_out_Xhl),
    .fn   (alu_fn_Xhl),
    .out  (nvec_alu_out_Xhl)
  );

	riscv_CoreDpathPipeMulDiv pmuldiv
	(
	  .clk											(clk									),
    .reset										(reset								),

		.muldivreq_msg_fn					(muldivreq_msg_fn_Dhl	),
    .muldivreq_msg_a					(op0_mux_out_Dhl			),
    .muldivreq_msg_b					(op1_mux_out_Dhl			),
    .muldivreq_val						(muldivreq_val				),
    .muldivreq_rdy						(muldivreq_rdy				),

    .muldivresp_msg_result		(muldivresp_msg_result_X3hl),
    .muldivresp_val						(muldivresp_val				),
    .muldivresp_rdy						(muldivresp_rdy				),

		.stall_Xhl								(stall_Xhl						),
    .stall_Mhl								(stall_Mhl						),
    .stall_X2hl								(stall_X2hl						),
    .stall_X3hl               (stall_X3hl           )
	);

  riscv_CoreDpathVecAlu vecalu
  (
    .vin0    (op0_mux_vout_Xhl),
    .vin1    (op1_mux_vout_Xhl),
    .in0     (op0_mux_out_Xhl),
    .in0_ven (op0_ven_Xhl),
    .in1     (op1_mux_out_Xhl),
    .in1_ven (op1_ven_Xhl),
    .fn      (alu_fn_Xhl),
    .vout    (alu_vout_Xhl),
    .vl      (vl_Xhl),
    .out     (vec_alu_out_Xhl)
  );

endmodule

`endif

// vim: set textwidth=0 ts=2 sw=2 sts=2 :