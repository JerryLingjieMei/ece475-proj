//=========================================================================
// 7-Stage RISCV Register File
//=========================================================================

`ifndef RISCV_CORE_DPATH_REGFILE_V
`define RISCV_CORE_DPATH_REGFILE_V

module riscv_CoreDpathVectorRegfile
(
  input         clk,
  input  [ 4:0] raddr0,  // Read 0 address (combinational input)
  output [255:0]rvec0,  // Read 0 vec (combinational on raddr)
  input  [ 4:0] raddr1,  // Read 1 address (combinational input)
  output [255:0]rvec1,  // Read 1 vec (combinational on raddr)
  input         wen_p,   // Write enable (sample on rising clk edge)
  input  [ 4:0] waddr_p, // Write address (sample on rising clk edge)
  input  [255:0]wvec_p  // Write vec (sample on rising clk edge)
  input         wvlen_p,
  input  [4:0]  wvl_p,
  output [4:0]  vl
);

  // We use an array of 32 bit register for the regfile itself
  reg [255:0] registers[31:0];
  reg [4:0]   vl;

  // Combinational read ports
  assign rvec0 = ( raddr0 == 0 ) ? 255'b0 : registers[raddr0];
  assign rvec1 = ( raddr1 == 0 ) ? 255'b0 : registers[raddr1];

  // Write port is active only when wen is asserted
  always @( posedge clk )
  begin
    if ( wen_p && (waddr_p != 5'b0) )
      registers[waddr_p] <= wvec_p;
    if (wvlen_p)
      vl  <=  wvl_p;
  end

endmodule

`endif

