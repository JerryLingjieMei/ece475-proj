//=========================================================================
// 7-Stage RISCV ALU
//=========================================================================

`ifndef RISCV_CORE_DPATH_ALU_V
`define RISCV_CORE_DPATH_ALU_V

//-------------------------------------------------------------------------
// addsub unit
//-------------------------------------------------------------------------

module riscv_CoreDpathAluAddSub
(
  input      [2:0]   addsub_fn, // 000 = addv, 001 = subv, 010 = sltv, 011 = seqv, 100 = addx, 101 = subx, 110 = sltx, 111 = seqx 
  input      [255:0] alu_a,     // A operand
  input      [255:0] alu_b,     // B operand (if scalar, assumed to be 0 padded to 256 bits)
  input              vm,        // vector mask
  input              vl,        // vector length
  output reg [255:0] result     // result
);

// Iterate through vector length
genvar i;
  generate
  for( i = 0; i < vl; i = i + 1) begin
    if(vm[i]) begin

      // MSB and LSB of current element being worked on
      localparam lsb = i * 32;
      localparam msb = lsb + 31;

      // Element currently being worked on
      wire elem_a = alu_a[msb,lsb];
      wire elem_b = (addsub_fn[2]) ? alu_b[31:0] : alu_b[msb,lsb];
      
      // We use one adder to perform both additions and subtractions
      wire [31:0] xB  = ( addsub_fn[1:0] != 2'b00 ) ? ( ~elem_b + 1 ) : elem_b;
      wire [31:0] sum = elem_a + xB;

      wire diffSigns = elem_a[31] ^ elem_b[31];

      always @(*)
      begin

        if (( addsub_fn[1:0] == 2'b00 ) || ( addsub_fn[1:0] == 2'b01 ))
          result[msb,lsb] = sum;

        // Logic for signed set less than
        else if ( addsub_fn[1:0] == 2'b10 )
        begin

          // If the signs of elem_a and elem_b are different then one is
          // negative and one is positive. If elem_a is the positive one then
          // it is not less than elem_b, and if elem_a is the negative one then
          // it is less than elem_b.

          if ( diffSigns )
            if ( elem_a[31] == 1'b0 )    // elem_a is positive
              result[msb,lsb] = { 31'b0, 1'b0 };
            else                        // elem_a is negative
              result[msb,lsb] = { 31'b0, 1'b1 };

          // If the signs of elem_a and elem_b are the same then we look at the
          // result from (elem_a - elem_b). If this is positive then elem_a is
          // not less than elem_b, and if this is negative then elem_a is
          // indeed less than elem_b.

          else
            if ( sum[31] == 1'b0 )      // (elem_a - elem_b) is positive
              result[msb,lsb] = { 31'b0, 1'b0 };
            else                        // (elem_a - elem_b) is negative
              result[msb,lsb] = { 31'b0, 1'b1 };

        end

        // Logic for set equal to
        else if ( addsub_fn[1:0] == 2'b11 )
          
          //If two elements are the same, set result to 1 else set to 0
          if(elem_a == elem_b)
            result[msb,lsb] = {31'b0, 31'b1};
          else
            result[msb,lsb] = {31'b0, 31'b0};
    
        else
          result[msb,lsb] = 32'bx;

      end
    end
  end
  endgenerate
endmodule

//-------------------------------------------------------------------------
// shifter unit
//-------------------------------------------------------------------------

/*
module riscv_CoreDpathAluShifter
(
  input  [ 1:0] shift_fn,  // 00 = lsl, 01 = lsr, 11 = asr
  input  [31:0] alu_a,     // Shift ammount
  input  [31:0] alu_b,     // Operand to shift
  output [31:0] result     // result
);

  // We need this to make sure that we get a signed right shift
  wire signed [31:0] signed_elem_b = elem_b;
  wire signed [31:0] signed_result = signed_elem_b >>> elem_a[4:0];

  assign result
    = ( shift_fn == 2'b00 ) ? ( elem_b << elem_a[4:0] ) :
      ( shift_fn == 2'b01 ) ? ( elem_b >> elem_a[4:0] ) :
      ( shift_fn == 2'b11 ) ? signed_result :
                              ( 32'bx );

endmodule
*/

//-------------------------------------------------------------------------
// logical unit
//-------------------------------------------------------------------------

module riscv_CoreDpathAluLogical
(
  input  [2:0]  logical_fn, // 000 = andv, 001 = orv, 010 = xorv, 011 = norv, 100 = andx, 101 = orx, 110 = xorx, 111 = norx
  input  [255:0] alu_a,
  input  [255:0] alu_b,
  output [255:0] result
);

genvar i;
  generate
  for( i = 0; i < vl; i = i + 1) begin
    if(vm[i]) begin

      // MSB and LSB of current element being worked on
      localparam lsb = i * 32;
      localparam msb = lsb + 31;

      // Element currently being worked on
      wire elem_a = alu_a[msb,lsb];
      wire elem_b = (addsub_fn[2]) ? alu_b[31:0] : alu_b[msb,lsb];

    end
  end

  endgenerate

  assign result[msb,lsb]
    = ( logical_fn[1:0] == 2'b00 ) ?  ( elem_a & elem_b ) :
      ( logical_fn[1:0] == 2'b01 ) ?  ( elem_a | elem_b ) :
      ( logical_fn[1:0] == 2'b10 ) ?  ( elem_a ^ elem_b ) :
      ( logical_fn[1:0] == 2'b11 ) ? ~( elem_a | elem_b ) :
                                 ( 32'bx );

endmodule

//-------------------------------------------------------------------------
// Main alu
//-------------------------------------------------------------------------

module riscv_CoreDpathVecAlu
(
  input  [255:0] in0,
  input  [255:0] in1,
  input  [3:0]   fn,
  input          vm,
  input          vl,
  output [255:0] out
);

  // -- Decoder ----------------------------------------------------------

  reg [1:0] out_mux_sel;
  reg [2:0] fn_addsub;
  reg [1:0] fn_shifter;
  reg [2:0] fn_logical;
  reg       fn_muldiv;

  reg [10:0] cs;

  always @(*)
  begin

    cs = 11'bx;
    case ( fn )
      // Vector
      4'd0  : cs = { 2'd0, 3'b000, 2'bxx, 3'bxxx, 1'bx  }; // ADDV
      4'd1  : cs = { 2'd0, 3'b001, 2'bxx, 3'bxxx, 1'bx  }; // SUBV
      4'd2  : cs = { 2'd0, 3'b010, 2'bxx, 3'bxxx, 1'bx  }; // SLTV
      4'd3  : cs = { 2'd0, 3'b011, 2'bxx, 3'bxxx, 1'bx  }; // SEQV
      4'd4  : cs = { 2'd2, 3'bxxx, 2'bxx, 3'b000, 1'bx  }; // ANDV
      // Scalar
      4'd5  : cs = { 2'd0, 3'b100, 2'bxx, 3'bxxx, 1'bx  }; // ADDX
      4'd6  : cs = { 2'd0, 3'b101, 2'bxx, 3'bxxx, 1'bx  }; // SUBX
      4'd7  : cs = { 2'd0, 3'b110, 2'bxx, 3'bxxx, 1'bx  }; // SLTX
      4'd8  : cs = { 2'd0, 3'b111, 2'bxx, 3'bxxx, 1'bx  }; // SEQX
      4'd9  : cs = { 2'd2, 3'bxxx, 2'bxx, 3'b100, 1'bx  }; // ANDX

      //4'd2  : cs = { 2'd1, 3'bxx, 2'b00, 2'bxx, 2'bxx  }; // SLL
      //4'd3  : cs = { 2'd2, 3'bxx, 2'bxx, 2'b01, 2'bxx  }; // OR
      //4'd4  : cs = { 2'd0, 3'b010, 2'bxx, 2'bxx, 2'bxx  }; // SLT
      //4'd5  : cs = { 2'd0, 3'b011, 2'bxx, 2'bxx, 2'bxx  }; // SLTU
      //4'd6  : cs = { 2'd2, 3'bxx, 2'bxx, 2'b00, 2'bxx  }; // AND
      //4'd7  : cs = { 2'd2, 3'bxx, 2'bxx, 2'b10, 2'bxx  }; // XOR
      //4'd8  : cs = { 2'd2, 3'bxx, 2'bxx, 2'b11, 2'bxx  }; // NOR
      //4'd9  : cs = { 2'd1, 3'bxx, 2'b01, 2'bxx, 2'bxx  }; // SRL
      //4'd10 : cs = { 2'd1, 3'bxx, 2'b11, 2'bxx, 2'bxx  }; // SRA
    endcase

    { out_mux_sel, fn_addsub, fn_shifter, fn_logical } = cs;

  end

  // -- Functional units -------------------------------------------------

  wire [255:0] addsub_out;

  riscv_CoreDpathAluAddSub addsub
  (
    .addsub_fn  (fn_addsub),
    .alu_a      (in0),
    .alu_b      (in1),
    .vm         (vm),
    .vl         (vl),
    .result     (addsub_out)
  );

  /*
  wire [255:0] shifter_out;

  riscv_CoreDpathAluShifter shifter
  (
    .shift_fn   (fn_shifter),
    .alu_a      (in1),
    .alu_b      (in0),
    .vm         (vm),
    .vl         (vl),
    .result     (shifter_out)
  );
  */
  wire [255:0] logical_out;

  riscv_CoreDpathAluLogical logical
  (
    .logical_fn (fn_logical),
    .alu_a      (in0),
    .alu_b      (in1),
    .vm         (vm),
    .vl         (vl),
    .result     (logical_out)
  );

  wire [255:0] muldiv_out;


  // -- Final output mux -------------------------------------------------

  assign out = ( out_mux_sel == 2'd0 ) ? addsub_out
  //           : ( out_mux_sel == 2'd1 ) ? shifter_out
             : ( out_mux_sel == 2'd2 ) ? logical_out
             :                           256'bx;

endmodule

`endif

