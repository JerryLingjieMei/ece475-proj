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
  output [31:0]      out,
  output reg [255:0] vout
);
  // -- Decoder ----------------------------------------------------------
  reg [31:0] s = 32'd0;
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

      reg [31:0] o = 32'd0;
      always @(*) begin
          case (fn)
            4'd0:     o = sum;
            4'd4:     o = diffSigns? { 31'b0, elem_a[31] } : { 31'b0, sum[31] };
            4'd11:    begin
                        sums[i] = elem_b;
                        sums[8] = elem_a;
                      end
            4'd12:    o = {31'b0, elem_a == elem_b};
            4'd13:    o = i;
            default:  o = 32'bx;
          endcase

          if ( fn == 4'd11 )
            vout[31:0] = s;
          else
            vout[msb:lsb] = (i<vl)? o: 32'bx;
        end
    end
  endgenerate


  // For loop did not work but this works I guess
  always @(*) begin
    s = 32'd0;
    if( fn == 4'd11) begin
      case (vl)
        4'd1: s = sums[8] + sums[0];
        4'd2: s = sums[8] + sums[0] + sums[1];
        4'd3: s = sums[8] + sums[0] + sums[1] + sums[2];
        4'd4: s = sums[8] + sums[0] + sums[1] + sums[2] + sums[3];
        4'd5: s = sums[8] + sums[0] + sums[1] + sums[2] + sums[3] + sums[4];
        4'd6: s = sums[8] + sums[0] + sums[1] + sums[2] + sums[3] + sums[4] + sums[5];
        4'd7: s = sums[8] + sums[0] + sums[1] + sums[2] + sums[3] + sums[4] + sums[5] + sums[6];
        4'd8: s = sums[8] + sums[0] + sums[1] + sums[2] + sums[3] + sums[4] + sums[5] + sums[6] + sums[7];
        default: s = 32'bx;
      endcase
    end
  end
  

  assign out = vin0[31:0];

  //Debugging
  reg [31:0] sums [8:0];
  wire [31:0] sum0 = sums[0];
  wire [31:0] sum1 = sums[1];
  wire [31:0] sum2 = sums[2];
  wire [31:0] sum3 = sums[3];
  wire [31:0] sum4 = sums[4];
  wire [31:0] sum5 = sums[5];
  wire [31:0] sum6 = sums[6];
  wire [31:0] sum7 = sums[7];
  wire [31:0] sum8 = sums[8];

  reg [31:0] os [7:0];
  wire [31:0] o0 = os[0];
  wire [31:0] o1 = os[1];
  wire [31:0] o2 = os[2];
  wire [31:0] o3 = os[3];
  wire [31:0] o4 = os[4];
  wire [31:0] o5 = os[5];
  wire [31:0] o6 = os[6];
  wire [31:0] o7 = os[7];

endmodule

`endif
