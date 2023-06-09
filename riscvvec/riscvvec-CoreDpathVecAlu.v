//=========================================================================
// 7-Stage RISCV ALU
//=========================================================================

`ifndef RISCV_CORE_DPATH_VECALU_V
`define RISCV_CORE_DPATH_VECALU_V

//-------------------------------------------------------------------------
// Main alu
//-------------------------------------------------------------------------

module riscv_CoreDpathVecAlu
(
  input  [255:0]     vin0,
  input  [255:0]     vin1,
  input  [31:0]      in0,
  input              in0_ven,
  input  [31:0]      in1,
  input              in1_ven,
  input  [3:0]       fn,
  input  [3:0]       vl,
  output reg [31:0]      out,
  output reg [255:0] vout
);
  // -- Decoder ----------------------------------------------------------
  genvar i;
  generate
  for( i = 0; i < 8; i = i + 1)
    begin
      // MSB and LSB of current element being worked on
      localparam lsb = i * 32;
      localparam msb = lsb + 31;

      // Element currently being worked on
      wire [31:0] elem_a = ( !in0_ven )     ? in0         :
                           ( fn == 4'd11 )  ? vin0[31:0]  :
                                              vin0[msb:lsb];
      wire [31:0] elem_b = in1_ven ? vin1[msb:lsb] : in1;

      // We use one adder to perform both additions and subtractions
      wire [31:0] xB  = (fn == 4'd4) ? ( ~elem_b + 1 ) : elem_b;
      wire [31:0] sum = elem_a + xB;

      wire diffSigns = elem_a[31] ^ elem_b[31];

      reg [31:0] o;
      always @(*)
        begin
          case (fn)
            4'd0: o = sum;
            4'd4: o = diffSigns? { 31'b0, elem_a[31] } : { 31'b0, sum[31] };
            4'd6: o = elem_a & elem_b;
            4'd11:    begin
                        if( i == 0 ) //Change if vm is implemented
                          o = sum;
                        else
                          o += sum;
                      end
            4'd12: o = {31'b0, elem_a == elem_b};
            4'd13: o = i;
            default: o = 32'bx;
          endcase

          if (in1[2:0]==i) begin
            out = vin0[msb:lsb];
          end

          if ( fn == 4'd11 )
            vout[31:0] = o;
          else
            vout[msb:lsb] = (i<=vl)? o: 32'bx;
        end
    end
  endgenerate

endmodule

`endif
