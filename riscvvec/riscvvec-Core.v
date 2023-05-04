//=========================================================================
// 7-Stage RISCV Core
//=========================================================================

`ifndef RISCV_CORE_V
`define RISCV_CORE_V

`include "vc-MemReqMsg.v"
`include "vc-MemRespMsg.v"
`include "riscvvec-CoreCtrl.v"
`include "riscvvec-CoreDpath.v"

module riscv_Core
(
  input         clk,
  input         reset,

  // Instruction Memory Request Port

  output [`VC_MEM_REQ_MSG_SZ(32,32)-1:0] imemreq_msg,
  output                                 imemreq_val,
  input                                  imemreq_rdy,

  // Instruction Memory Response Port

  input [`VC_MEM_RESP_MSG_SZ(32)-1:0] imemresp_msg,
  input                               imemresp_val,

  // Data Memory Request Port 1

  output [`VC_MEM_REQ_MSG_SZ(32,32)-1:0] dmemreq0_msg,
  output                                 dmemreq_val,
  input                                  dmemreq0_rdy,

  // Data Memory Response Port 1

  input [`VC_MEM_RESP_MSG_SZ(32)-1:0] dmemresp0_msg,
  input                               dmemresp0_val,

  // Data Memory Request Port 2

  output [`VC_MEM_REQ_MSG_SZ(32,32)-1:0] dmemreq1_msg,
  input                                  dmemreq1_rdy,

  // Data Memory Response Port 2

  input [`VC_MEM_RESP_MSG_SZ(32)-1:0] dmemresp1_msg,
  input                               dmemresp1_val,

  // Data Memory Request Port 3

  output [`VC_MEM_REQ_MSG_SZ(32,32)-1:0] dmemreq2_msg,
  input                                  dmemreq2_rdy,

  // Data Memory Response Port 3

  input [`VC_MEM_RESP_MSG_SZ(32)-1:0] dmemresp2_msg,
  input                               dmemresp2_val,

  // Data Memory Request Port 4

  output [`VC_MEM_REQ_MSG_SZ(32,32)-1:0] dmemreq3_msg,
  input                                  dmemreq3_rdy,

  // Data Memory Response Port 4

  input [`VC_MEM_RESP_MSG_SZ(32)-1:0] dmemresp3_msg,
  input                               dmemresp3_val,

  // Data Memory Request Port 5

  output [`VC_MEM_REQ_MSG_SZ(32,32)-1:0] dmemreq4_msg,
  input                                  dmemreq4_rdy,

  // Data Memory Response Port 5

  input [`VC_MEM_RESP_MSG_SZ(32)-1:0] dmemresp4_msg,
  input                               dmemresp4_val,

  // Data Memory Request Port 6

  output [`VC_MEM_REQ_MSG_SZ(32,32)-1:0] dmemreq5_msg,
  input                                  dmemreq5_rdy,

  // Data Memory Response Port 6

  input [`VC_MEM_RESP_MSG_SZ(32)-1:0] dmemresp5_msg,
  input                               dmemresp5_val,

  // Data Memory Request Port 7

  output [`VC_MEM_REQ_MSG_SZ(32,32)-1:0] dmemreq6_msg,
  input                                  dmemreq6_rdy,

  // Data Memory Response Port 7

  input [`VC_MEM_RESP_MSG_SZ(32)-1:0] dmemresp6_msg,
  input                               dmemresp6_val,

  // Data Memory Request Port 8

  output [`VC_MEM_REQ_MSG_SZ(32,32)-1:0] dmemreq7_msg,
  input                                  dmemreq7_rdy,

  // Data Memory Response Port 8

  input [`VC_MEM_RESP_MSG_SZ(32)-1:0] dmemresp7_msg,
  input                               dmemresp7_val,

  // CSR Status Register Output to Host

  output [31:0] csr_status
);

  wire [31:0] imemreq_msg_addr;
  wire [31:0] imemresp_msg_data;

  wire        dmemreq_msg_rw;
  wire  [2:0] dmemreq_msg_len;
  wire [31:0] dmemreq_msg_addr;
  wire  [3:0] dmemreq_vl;
  wire [255:0] dmemreq_msg_data;
  wire [255:0] dmemresp_msg_data;

  wire  [1:0] pc_mux_sel_Phl;
  wire  [1:0] op0_mux_sel_Dhl;
  wire  [2:0] op1_mux_sel_Dhl;
  wire [31:0] inst_Dhl;
  wire  [3:0] alu_fn_Xhl;
  wire        alu_vsel_Xhl;
  wire  [2:0] muldivreq_msg_fn_Dhl;
  wire        muldivreq_val;
  wire        muldivreq_rdy;
  wire        muldivresp_val;
  wire        muldivresp_rdy;
  wire        muldiv_mux_sel_X3hl;
  wire        execute_mux_sel_X3hl;
  wire  [2:0] dmemresp_mux_sel_Mhl;
  wire        dmemresp_queue_en_Mhl;
  wire        dmemresp_queue_val_Mhl;
  wire        wb_mux_sel_Mhl;
  wire        rf_wen_Whl;
  wire        rf_vwen_Whl;
  wire  [4:0] rf_waddr_Whl;
  wire        rf_vlwen_Xhl;
  wire        stall_Fhl;
  wire        stall_Dhl;
  wire        stall_Xhl;
  wire        stall_Mhl;
  wire        stall_Whl;

	wire				stall_X2hl;
	wire				stall_X3hl;
	wire  [2:0] rdata0_byp_mux_sel_Dhl;
	wire  [2:0] rdata1_byp_mux_sel_Dhl;
  wire  [2:0] vdata0_byp_mux_sel_Dhl;
	wire  [2:0] vdata1_byp_mux_sel_Dhl;
	wire        op0_ven_Xhl;
	wire        op1_ven_Xhl;

  wire        branch_cond_eq_Xhl;
  wire        branch_cond_ne_Xhl;
  wire        branch_cond_lt_Xhl;
  wire        branch_cond_ltu_Xhl;
  wire        branch_cond_ge_Xhl;
  wire        branch_cond_geu_Xhl;
  wire [31:0] proc2csr_data_Whl;

  //----------------------------------------------------------------------
  // Pack Memory Request Messages
  //----------------------------------------------------------------------

  vc_MemReqMsgToBits#(32,32) imemreq_msg_to_bits
  (
    .type (`VC_MEM_REQ_MSG_TYPE_READ),
    .addr (imemreq_msg_addr),
    .len  (2'd0),
    .data (32'bx),
    .bits (imemreq_msg)
  );

  /*
  vc_MemReqMsgToBits#(32,32) dmemreq_msg_to_bits
  (
    .type (dmemreq_msg_rw),
    .addr (dmemreq_msg_addr),
    .len  (dmemreq_msg_len),
    .data (dmemreq_msg_data),
    .bits (dmemreq_msg)
  );
  */

  vc_MemReqMsgToBits#(32,32) dmemreq0_msg_to_bits
  (
    .type (dmemreq_msg_rw),
    .addr (dmemreq_msg_addr),
    .len  (dmemreq_msg_len[1:0]),
    .data (dmemreq_msg_data[31:0]),
    .bits (dmemreq0_msg)
  );
  vc_MemReqMsgToBits#(32,32) dmemreq1_msg_to_bits
  (
    .type (( dmemreq_msg_rw && (dmemreq_vl >= 4'd2) && dmemreq_msg_len[2] )),
    .addr (( dmemreq_msg_addr + 32'h00000001 )),
    .len  (dmemreq_msg_len[1:0]),
    .data (dmemreq_msg_data[63:32]),
    .bits (dmemreq1_msg)
  );
  vc_MemReqMsgToBits#(32,32) dmemreq2_msg_to_bits
  (
    .type (( dmemreq_msg_rw && (dmemreq_vl >= 4'd3) && dmemreq_msg_len[2] )),
    .addr (( dmemreq_msg_addr + 32'h00000002 )),
    .len  (dmemreq_msg_len[1:0]),
    .data (dmemreq_msg_data[95:64]),
    .bits (dmemreq2_msg)
  );
  vc_MemReqMsgToBits#(32,32) dmemreq3_msg_to_bits
  (
    .type (( dmemreq_msg_rw && (dmemreq_vl >= 4'd4) && dmemreq_msg_len[2] )),
    .addr (( dmemreq_msg_addr + 32'h00000003 )),
    .len  (dmemreq_msg_len[1:0]),
    .data (dmemreq_msg_data[127:96]),
    .bits (dmemreq3_msg)
  );
  vc_MemReqMsgToBits#(32,32) dmemreq4_msg_to_bits
  (
    .type (( dmemreq_msg_rw && (dmemreq_vl >= 4'd5) && dmemreq_msg_len[2] )),
    .addr (( dmemreq_msg_addr + 32'h00000004 )),
    .len  (dmemreq_msg_len[1:0]),
    .data (dmemreq_msg_data[159:128]),
    .bits (dmemreq4_msg)
  );
  vc_MemReqMsgToBits#(32,32) dmemreq5_msg_to_bits
  (
    .type (( dmemreq_msg_rw && (dmemreq_vl >= 4'd6) && dmemreq_msg_len[2] )),
    .addr (( dmemreq_msg_addr + 32'h00000005 )),
    .len  (dmemreq_msg_len[1:0]),
    .data (dmemreq_msg_data[191:160]),
    .bits (dmemreq5_msg)
  );
  vc_MemReqMsgToBits#(32,32) dmemreq6_msg_to_bits
  (
    .type (( dmemreq_msg_rw && (dmemreq_vl >= 4'd7) && dmemreq_msg_len[2] )),
    .addr (( dmemreq_msg_addr + 32'h00000006 )),
    .len  (dmemreq_msg_len[1:0]),
    .data (dmemreq_msg_data[223:192]),
    .bits (dmemreq6_msg)
  );
  vc_MemReqMsgToBits#(32,32) dmemreq7_msg_to_bits
  (
    .type (( dmemreq_msg_rw && (dmemreq_vl >= 4'd8) && dmemreq_msg_len[2] )),
    .addr (( dmemreq_msg_addr + 32'h00000007 )),
    .len  (dmemreq_msg_len[1:0]),
    .data (dmemreq_msg_data[255:224]),
    .bits (dmemreq7_msg)
  );

  //----------------------------------------------------------------------
  // Unpack Memory Response Messages
  //----------------------------------------------------------------------

  vc_MemRespMsgFromBits#(32) imemresp_msg_from_bits
  (
    .bits (imemresp_msg),
    .type (),
    .len  (),
    .data (imemresp_msg_data)
  );

  /*
  vc_MemRespMsgFromBits#(32) dmemresp_msg_from_bits
  (
    .bits (dmemresp_msg),
    .type (),
    .len  (),
    .data (dmemresp_msg_data)
  );
  */

  vc_MemRespMsgFromBits#(32) dmemresp0_msg_from_bits
  (
    .bits (dmemresp0_msg),
    .type (),
    .len  (),
    .data (dmemresp_msg_data[31:0])
  );

  vc_MemRespMsgFromBits#(32) dmemresp1_msg_from_bits
  (
    .bits (dmemresp1_msg),
    .type (),
    .len  (),
    .data (dmemresp_msg_data[63:32])
  );

  vc_MemRespMsgFromBits#(32) dmemresp2_msg_from_bits
  (
    .bits (dmemresp2_msg),
    .type (),
    .len  (),
    .data (dmemresp_msg_data[95:64])
  );

  vc_MemRespMsgFromBits#(32) dmemresp3_msg_from_bits
  (
    .bits (dmemresp3_msg),
    .type (),
    .len  (),
    .data (dmemresp_msg_data[127:96])
  );

  vc_MemRespMsgFromBits#(32) dmemresp4_msg_from_bits
  (
    .bits (dmemresp4_msg),
    .type (),
    .len  (),
    .data (dmemresp_msg_data[159:128])
  );

  vc_MemRespMsgFromBits#(32) dmemresp5_msg_from_bits
  (
    .bits (dmemresp5_msg),
    .type (),
    .len  (),
    .data (dmemresp_msg_data[191:160])
  );

  vc_MemRespMsgFromBits#(32) dmemresp6_msg_from_bits
  (
    .bits (dmemresp6_msg),
    .type (),
    .len  (),
    .data (dmemresp_msg_data[223:192])
  );

  vc_MemRespMsgFromBits#(32) dmemresp7_msg_from_bits
  (
    .bits (dmemresp7_msg),
    .type (),
    .len  (),
    .data (dmemresp_msg_data[255:224])
  );

  //----------------------------------------------------------------------
  // Control Unit
  //----------------------------------------------------------------------

  wire dmemresp_val = dmemresp0_val && dmemresp1_val && dmemresp2_val && dmemresp3_val &&
                      dmemresp4_val && dmemresp5_val && dmemresp6_val && dmemresp7_val;

  wire dmemreq_rdy = dmemreq0_rdy && dmemreq1_rdy && dmemreq2_rdy && dmemreq3_rdy &&
                     dmemreq4_rdy && dmemreq5_rdy && dmemreq6_rdy && dmemreq7_rdy;

  riscv_CoreCtrl ctrl
  (
    .clk                    (clk),
    .reset                  (reset),

    // Instruction Memory Port

    .imemreq_val            (imemreq_val),
    .imemreq_rdy            (imemreq_rdy),
    .imemresp_msg_data      (imemresp_msg_data),
    .imemresp_val           (imemresp_val),

    // Data Memory Port

    .dmemreq_msg_rw         (dmemreq_msg_rw),
    .dmemreq_msg_len        (dmemreq_msg_len),
    .dmemreq_val            (dmemreq_val),
    .dmemreq_rdy            (dmemreq_rdy),
    .dmemresp_val           (dmemresp_val),

    // Controls Signals (ctrl->dpath)

    .pc_mux_sel_Phl         (pc_mux_sel_Phl),
    .op0_mux_sel_Dhl        (op0_mux_sel_Dhl),
    .op1_mux_sel_Dhl        (op1_mux_sel_Dhl),
    .inst_Dhl               (inst_Dhl),
    .alu_fn_Xhl             (alu_fn_Xhl),
    .alu_vsel_Xhl           (alu_vsel_Xhl),
    .muldivreq_msg_fn_Dhl   (muldivreq_msg_fn_Dhl),
    .muldivreq_val          (muldivreq_val),
    .muldivreq_rdy          (muldivreq_rdy),
    .muldivresp_val         (muldivresp_val),
    .muldivresp_rdy         (muldivresp_rdy),
    .muldiv_mux_sel_X3hl     (muldiv_mux_sel_X3hl),
    .execute_mux_sel_X3hl    (execute_mux_sel_X3hl),
    .dmemresp_mux_sel_Mhl   (dmemresp_mux_sel_Mhl),
    .dmemresp_queue_en_Mhl  (dmemresp_queue_en_Mhl),
    .dmemresp_queue_val_Mhl (dmemresp_queue_val_Mhl),
    .wb_mux_sel_Mhl         (wb_mux_sel_Mhl),
    .rf_wen_out_Whl         (rf_wen_Whl),
    .rf_vwen_Whl            (rf_vwen_Whl),
    .rf_vlwen_Xhl           (rf_vlwen_Xhl),
    .rf_waddr_Whl           (rf_waddr_Whl),
    .stall_Fhl              (stall_Fhl),
    .stall_Dhl              (stall_Dhl),
    .stall_Xhl              (stall_Xhl),
    .stall_Mhl              (stall_Mhl),
    .stall_Whl              (stall_Whl),

		.stall_X2hl							(stall_X2hl),
		.stall_X3hl             (stall_X3hl),
		.rdata0_byp_mux_sel_Dhl (rdata0_byp_mux_sel_Dhl),
		.rdata1_byp_mux_sel_Dhl (rdata1_byp_mux_sel_Dhl),
    .vdata0_byp_mux_sel_Dhl (vdata0_byp_mux_sel_Dhl),
		.vdata1_byp_mux_sel_Dhl (vdata1_byp_mux_sel_Dhl),
		.op0_ven_Xhl            (op0_ven_Xhl),
		.op1_ven_Xhl            (op1_ven_Xhl),

    // Control Signals (dpath->ctrl)

    .branch_cond_eq_Xhl	    (branch_cond_eq_Xhl),
    .branch_cond_ne_Xhl	    (branch_cond_ne_Xhl),
    .branch_cond_lt_Xhl	    (branch_cond_lt_Xhl),
    .branch_cond_ltu_Xhl	  (branch_cond_ltu_Xhl),
    .branch_cond_ge_Xhl	    (branch_cond_ge_Xhl),
    .branch_cond_geu_Xhl	  (branch_cond_geu_Xhl),
    .proc2csr_data_Whl      (proc2csr_data_Whl),

    // CSR Status

    .csr_status             (csr_status)
  );

  //----------------------------------------------------------------------
  // Datapath
  //----------------------------------------------------------------------

  riscv_CoreDpath dpath
  (
    .clk                     (clk),
    .reset                   (reset),

    // Instruction Memory Port

    .imemreq_msg_addr        (imemreq_msg_addr),

    // Data Memory Port

    .dmemreq_msg_addr        (dmemreq_msg_addr),
    .dmemreq_msg_data        (dmemreq_msg_data),
    .dmemreq_msg_len_Xhl     (dmemreq_msg_len),
    .dmemreq_vl              (dmemreq_vl),
    .dmemresp_msg_data       (dmemresp_msg_data),

    // Controls Signals (ctrl->dpath)

    .pc_mux_sel_Phl          (pc_mux_sel_Phl),
    .op0_mux_sel_Dhl         (op0_mux_sel_Dhl),
    .op1_mux_sel_Dhl         (op1_mux_sel_Dhl),
    .inst_Dhl                (inst_Dhl),
    .alu_fn_Xhl              (alu_fn_Xhl),
    .alu_vsel_Xhl            (alu_vsel_Xhl),
    .muldivreq_msg_fn_Dhl    (muldivreq_msg_fn_Dhl),
    .muldivreq_val           (muldivreq_val),
    .muldivreq_rdy           (muldivreq_rdy),
    .muldivresp_val          (muldivresp_val),
    .muldivresp_rdy          (muldivresp_rdy),
    .muldiv_mux_sel_X3hl      (muldiv_mux_sel_X3hl),
    .execute_mux_sel_X3hl     (execute_mux_sel_X3hl),
    .dmemresp_mux_sel_Mhl    (dmemresp_mux_sel_Mhl),
    .dmemresp_queue_en_Mhl   (dmemresp_queue_en_Mhl),
    .dmemresp_queue_val_Mhl  (dmemresp_queue_val_Mhl),
    .wb_mux_sel_Mhl          (wb_mux_sel_Mhl),
    .rf_wen_Whl              (rf_wen_Whl),
    .rf_vwen_Whl             (rf_vwen_Whl),
    .rf_vlwen_Xhl            (rf_vlwen_Xhl),
    .rf_waddr_Whl            (rf_waddr_Whl),
    .stall_Fhl               (stall_Fhl),
    .stall_Dhl               (stall_Dhl),
    .stall_Xhl               (stall_Xhl),
    .stall_Mhl               (stall_Mhl),
    .stall_Whl               (stall_Whl),

		.stall_X2hl						 	(stall_X2hl),
		.stall_X3hl             (stall_X3hl),
		.rdata0_byp_mux_sel_Dhl (rdata0_byp_mux_sel_Dhl),
		.rdata1_byp_mux_sel_Dhl (rdata1_byp_mux_sel_Dhl),
    .vdata0_byp_mux_sel_Dhl (vdata0_byp_mux_sel_Dhl),
		.vdata1_byp_mux_sel_Dhl (vdata1_byp_mux_sel_Dhl),
		.op0_ven_Xhl            (op0_ven_Xhl),
		.op1_ven_Xhl            (op1_ven_Xhl),


    // Control Signals (dpath->ctrl)

    .branch_cond_eq_Xhl	     (branch_cond_eq_Xhl),
    .branch_cond_ne_Xhl	     (branch_cond_ne_Xhl),
    .branch_cond_lt_Xhl	     (branch_cond_lt_Xhl),
    .branch_cond_ltu_Xhl	 (branch_cond_ltu_Xhl),
    .branch_cond_ge_Xhl	     (branch_cond_ge_Xhl),
    .branch_cond_geu_Xhl	 (branch_cond_geu_Xhl),
    .proc2csr_data_Whl       (proc2csr_data_Whl)
  );

endmodule

`endif

// vim: set textwidth=0 ts=2 sw=2 sts=2 :
