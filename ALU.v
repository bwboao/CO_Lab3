//Subject:     CO project 2 - ALU
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      0516224 0516223
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

`define ADD 4'b0010
`define SUB 4'b0011

`define AND 4'b0000
`define OR 4'b0001
`define SLT 4'b0110

`define BEQ 4'b1010
`define BNE 4'b1011

`define SRA 4'b1111

`define SR 4'b0100
`define SUP 4'b0111

`define MUL 4'b1110


module ALU(
    src1_i,
	src2_i,
	ctrl_i,
	result_o,
	zero_o,
	shift_i
	);
     
//I/O ports
input  [32-1:0]  src1_i;
input  [32-1:0]  src2_i;
input  [4-1:0]   ctrl_i;
input	 [5-1:0]		shift_i;

output [32-1:0]	 result_o;
output           zero_o;

//Internal signals
reg    [32-1:0]  result_o;
reg              zero_o;
reg              bne;
reg    [32-1:0]  Minus_result;

//Parameter
wire	signed [32-1:0] ssrc1_i;
wire	signed [32-1:0] ssrc2_i;
wire	signed [5-1:0] sshift_i;

assign ssrc1_i = src1_i;
assign ssrc2_i = src2_i;
assign sshift_i = shift_i;
//Main function
always @(*)begin
    case(ctrl_i)
        `ADD:   result_o <= src1_i + src2_i;
        `SUB:   result_o <= src1_i - src2_i;
		  `MUL:	 result_o <= src1_i * src2_i;
        `AND:   result_o <= src1_i & src2_i;
        `OR:    result_o <= src1_i | src2_i;
        `SLT:   result_o <= (ssrc1_i<ssrc2_i) ? 1 : 0;
        //`BEQ:	 result_o <= (src1_i - src2_i); // ? 1'b1 : 1'b0;
        //`BNE:	 result_o <= (src1_i - src2_i);
		  `SRA:   result_o <= ssrc2_i>>>sshift_i;
        `SR: result_o <= ssrc2_i >>> ssrc1_i;
        `SUP: result_o <= src2_i << 16;
        default: result_o <= 0;
    endcase
     Minus_result <= src1_i - src2_i;
     zero_o <= (Minus_result == 0) ? 1'b1 : 1'b0;
end
endmodule





                    
                    