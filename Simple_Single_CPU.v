//Subject:     CO project 2 - Simple Single CPU
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      0516223 0516224
//----------------------------------------------
//Date:        5/1
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
module Simple_Single_CPU(
        clk_i,
		rst_i
		);
		
//I/O port
input         clk_i;
input         rst_i;

//Internal Signles
wire    [3-1:0]     ALUOp;
wire                ALUSrc;
wire                RegDst;
wire                RegWrite;
wire                RegWrite1;
wire                branch;
wire    [32-1:0]    pc_in;
wire    [32-1:0]    pc_out;
wire    [32-1:0]    Add1_sum;
wire    [32-1:0]    instr;
wire    [5-1:0]     Mux1_data;
wire    [32-1:0]    ALU_result;
wire    [32-1:0]    RSdata;
wire    [32-1:0]    RTdata;
wire    [4-1:0]     ALUCtrl;
wire    [32-1:0]    SignData;
wire    [32-1:0]    Mux2_data;
wire    [5-1:0]     Mux3_data;
wire                Zero;
wire    [32-1:0]    Add2_sum;
wire    [32-1:0]    Shift_data;

wire                MemRead;
wire                MemWrite;
wire                Memto_Reg;
wire    [32-1:0]    MemData;
wire    [32-1:0]    RegWriteData;
wire    [32-1:0]    RegWriteData1;

wire	  [32-1:0]	  pc_ifJump;
wire	  [32-1:0]	  pc_ifBranch;
wire					  jump;
wire					  jump1;
wire					  ifjr;

wire       [3-1:0]  Branch_type;
wire                Branch_result;
//Greate componentes
ProgramCounter PC(
       .clk_i(clk_i),      
	    .rst_i (rst_i),     
	    .pc_in_i(pc_in) ,   
	    .pc_out_o(pc_out) 
	    );
	
Adder Adder1(
       .src1_i(pc_out),     
	    .src2_i(32'd4),     
	    .sum_o(Add1_sum)    
	    );
	
Instr_Memory IM(
        .addr_i(pc_out),  
	    .instr_o(instr)    
	    );

MUX_2to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(instr[20:16]),
        .data1_i(instr[15:11]),
        .select_i(RegDst),
        .data_o(Mux1_data)
        );	
		
Reg_File RF(
        .clk_i(clk_i),      
		  .rst_i(rst_i) ,     
        .RSaddr_i(instr[25:21]) ,  
        .RTaddr_i(instr[20:16]) ,  
        .RDaddr_i(Mux3_data) ,  
        .RDdata_i(RegWriteData1)  , 
        .RegWrite_i (RegWrite1),
        .RSdata_o(RSdata) ,  
        .RTdata_o(RTdata)   
        );
	
Decoder Decoder(
        .instr_op_i(instr[31:26]),
	     .RegWrite_o(RegWrite), 
	     .ALU_op_o(ALUOp),
	     .ALUSrc_o(ALUSrc),   
	     .RegDst_o(RegDst),   
		  .Branch_o(branch),
		  .Memto_Reg_o(Memto_Reg),
        .MemRead_o(MemRead),
        .MemWrite_o(MemWrite),
        .Jump_o(jump),
        .Branch_type_o(Branch_type)
	    );

ALU_Ctrl AC(
        .funct_i(instr[5:0]),   
        .ALUOp_i(ALUOp),   
        .ALUCtrl_o(ALUCtrl),
        .jr_o(ifjr)
        );
	
Sign_Extend SE(
        .data_i(instr[15:0]),
        .data_o(SignData)
        );

MUX_2to1 #(.size(32)) Mux_ALUSrc(
        .data0_i(RTdata),
        .data1_i(SignData),
        .select_i(ALUSrc),
        .data_o(Mux2_data)
        );	
		
ALU ALU(
       .src1_i(RSdata),
	    .src2_i(Mux2_data),
	    .ctrl_i(ALUCtrl),
	    .result_o(ALU_result),
		.zero_o(Zero),
		.shift_i(instr[10:6])
	    );
		
Adder Adder2(
        .src1_i(Add1_sum),     
	    .src2_i(Shift_data),     
	    .sum_o(Add2_sum)      
	    );
		
Shift_Left_Two_32 Shifter(
        .data_i(SignData),
        .data_o(Shift_data)
        ); 		

wire Branchzero;        //AND gate for branch
assign Branchzero = branch & Branch_result;

MUX_2to1 #(.size(32)) Mux_PC_Source(
        .data0_i(Add1_sum),
        .data1_i(Add2_sum),
        .select_i(Branchzero),
        .data_o(pc_ifBranch)
        );
        
Data_Memory Data_Memory(
        .clk_i(clk_i),
        .addr_i(ALU_result),
        .data_i(RTdata),
        .MemRead_i(MemRead),
        .MemWrite_i(MemWrite),
        .data_o(MemData)
        );

MUX_2to1 #(.size(32)) Memto_Reg_source(
			.data0_i(ALU_result),
			.data1_i(MemData),
			.select_i(Memto_Reg),
			.data_o(RegWriteData)
			);
			
JumpAddre_toMemAddre J_to_PC(
			.jr_i(ifjr),
			.jr_addr_i(ALU_result),
			.pcP4_i(Add1_sum),
			.JumpAddre_i(instr[26-1:0]),
			.pc_MemAddre_o(pc_ifJump)
			);
			
MUX_2to1 #(.size(32)) Jump_or_otherPC(
			.data0_i(pc_ifBranch),
			.data1_i(pc_ifJump),
			.select_i(jump1),
			.data_o(pc_in)
			);
			// handling jr & nop Regwrite might be error
MUX_2to1 #(.size(1)) Mux_Reg_Write(
			.data0_i(RegWrite),
			.data1_i(1'b0),
			.select_i((instr[31:26]==6'b0 & instr[5:0]==6'b001000) | (instr[31:0]==32'b0)),
			.data_o(RegWrite1)
			);
			// Mux for knowing if jal
MUX_2to1 #(.size(32)) Mux_Write_Data(
			.data0_i(RegWriteData),
			.data1_i(Add1_sum),
			.select_i(instr[31:26]==6'b000011),
			.data_o(RegWriteData1)
			);
MUX_2to1 #(.size(5)) Mux_Write_Des(
			.data0_i(Mux1_data), //RDaddr
			.data1_i(5'b11111),
			.select_i(instr[31:26]==6'b000011),
			.data_o(Mux3_data)
			);
			//MUX for jr 
MUX_2to1 #(.size(1)) Mux_Jump_Jr(
			.data0_i(jump), //RDaddr
			.data1_i(1'b1),
			.select_i(ifjr),
			.data_o(jump1)	
			);
			
Branch_Judge Branch_Judge(
            .zero_i(Zero),
            .ALU_result_i(ALU_result),
            .Branch_type_i(Branch_type),
            .ifBranch_o(Branch_result)
            );
/*always @(clk_i) begin
    $display("%b ==> %d <=> %d ",RegWrite,Mux1_data,ALU_result);
*/

always @(clk_i) begin
	//$display("RegWriteData is %d, RegWriteData1 is %d", RegWriteData, RegWriteData1);
	//$display("RSaddr is %d ,RTaddr is %d", instr[25:21],instr[20:16]);
	$display("ALU_result is %d ,RTdata is %d", ALU_result,RTdata);
	$display("ifjr is %d ,jump1 is %d,pc_ifJump is %d", ifjr,jump1,pc_ifJump);
	$display("pc_out is %d, Branchzero is %d", pc_out, Branchzero);
	//$display("%b", instr);
end

endmodule
		  


