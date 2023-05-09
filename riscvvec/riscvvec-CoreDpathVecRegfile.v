//=========================================================================
// 7-Stage RISCV Register File
//=========================================================================

`ifndef RISCV_CORE_DPATH_VECREGFILE_V
`define RISCV_CORE_DPATH_VECREGFILE_V

module riscv_CoreDpathVectorRegfile
(
  input           clk,
  input  [ 4:0]   raddr0,  // Read 0 address (combinational input)
  output [255:0]  rdata0,  // Read 0 vec (combinational on raddr)
  input  [ 4:0]   raddr1,  // Read 1 address (combinational input)
  output [255:0]  rdata1,  // Read 1 vec (combinational on raddr)
  input           wen_p,   // Write enable (sample on rising clk edge)
  input  [ 4:0]   waddr_p, // Write address (sample on rising clk edge)
  input  [255:0]  wdata_p,  // Write vec (sample on rising clk edge)
  input           wvlen_p,
  input  [31:0]   wvl_p,
  output [3:0]    vl
);

  // We use an array of 32 bit register for the regfile itself
  reg [255:0] registers[31:0];
  reg [3:0]   vl;

  // Combinational read ports
  assign rdata0 = registers[raddr0];
  assign rdata1 = registers[raddr1];

  // Write port is active only when wen is asserted
  always @( posedge clk )
  begin
    if ( wen_p && (waddr_p != 5'b0) )
      registers[waddr_p] <= wdata_p;
    if (wvlen_p)
      vl  <=  (wvl_p>=8)? 4'd8 : wvl_p[3:0];
  end

  // Debugging of vecrfile
  wire [255:0] reg0 = registers[0];
  wire [255:0] reg1 = registers[1];
  wire [255:0] reg2 = registers[2];
  wire [255:0] reg3 = registers[3];
  wire [255:0] reg4 = registers[4];
  wire [255:0] reg5 = registers[5];
  wire [255:0] reg22 = registers[22];

  

endmodule

`endif

