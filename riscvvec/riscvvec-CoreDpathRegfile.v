//=========================================================================
// 7-Stage RISCV Register File
//=========================================================================

`ifndef RISCV_CORE_DPATH_REGFILE_V
`define RISCV_CORE_DPATH_REGFILE_V

module riscv_CoreDpathRegfile
(
  input         clk,
  input  [ 4:0] raddr0,  // Read 0 address (combinational input)
  output [31:0] rdata0,  // Read 0 data (combinational on raddr)
  input  [ 4:0] raddr1,  // Read 1 address (combinational input)
  output [31:0] rdata1,  // Read 1 data (combinational on raddr)
  input         wen_p,   // Write enable (sample on rising clk edge)
  input  [ 4:0] waddr_p, // Write address (sample on rising clk edge)
  input  [31:0] wdata_p  // Write data (sample on rising clk edge)
);

  // We use an array of 32 bit register for the regfile itself
  reg [31:0] registers[31:0];

  // Combinational read ports
  assign rdata0 = ( raddr0 == 0 ) ? 32'b0 : registers[raddr0];
  assign rdata1 = ( raddr1 == 0 ) ? 32'b0 : registers[raddr1];

  // Write port is active only when wen is asserted
  always @( posedge clk )
  begin
    if ( wen_p && (waddr_p != 5'b0) )
      registers[waddr_p] <= wdata_p;
  end

  //Debugging Rfile
  wire [31:0] reg0 = registers[0];
  wire [31:0] reg1 = registers[1];
  wire [31:0] reg2 = registers[2];
  wire [31:0] reg3 = registers[3];
  wire [31:0] reg4 = registers[4];
  wire [31:0] reg5 = registers[5];
  wire [31:0] reg6 = registers[6];
  wire [31:0] reg7 = registers[7];
  wire [31:0] reg8 = registers[8];
  wire [31:0] reg9 = registers[9];
  wire [31:0] reg10 = registers[10];
  wire [31:0] reg11 = registers[11];
  wire [31:0] reg12 = registers[12];
  wire [31:0] reg22 = registers[22];


endmodule

`endif

