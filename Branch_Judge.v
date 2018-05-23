`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/23/2018 09:27:20 PM
// Design Name: 
// Module Name: Branch_Judge
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Branch_Judge(
        zero_i,
        ALU_result_i,
        Branch_type_i,
        ifBranch_o
    );
    
input zero_i;
input [32-1:0] ALU_result_i;
input [3-1:0] Branch_type_i;
output ifBranch_o;

reg     ifBranch_o;

always@(*) begin
    case(Branch_type_i)
        3'b001: ifBranch_o <= (zero_i == 1) ? 1 : 0;    //beq
        3'b010: ifBranch_o <= (zero_i == 0) ? 1 : 0;    //bne & bnez
        3'b011: ifBranch_o <= (ALU_result_i == 1 || zero_i == 1) ? 1: 0;   //ble (less equal
        3'b101: ifBranch_o <= (ALU_result_i == 1) ? 1: 0;    //bltz (less
        default: ifBranch_o <= 0;
    endcase
end

endmodule
