//`define ALULEN  31
//`include "memfile.dat"

//Special Instruction: div instruction, multiplying 32 bit integers to get a 32 bit remainder in hi and a 32 bit quotient in lo

//top module: no change
module div0(input clk, reset,output [31:0] writedata, dataadr,output memwrite);
	wire [31:0] pc, instr, readdata;
	// instantiate processor and memories
	mips mips (clk, reset, pc, instr, memwrite, dataadr,writedata, readdata);
	imem imem (pc[7:2], instr);
	dmem dmem (clk, memwrite, dataadr, writedata,readdata);
endmodule

//dmem: no change
module dmem (input clk, we,input [31:0] a, wd,output [31:0] rd);
	reg [31:0] RAM[63:0];
	assign rd = RAM[a[31:2]]; // word aligned
	always @ (posedge clk)
	if (we)
	RAM[a[31:2]] <= wd;
endmodule


//imem: change the memory location of instructions
module imem (input [5:0] a,output [31:0] rd);
	reg [31:0] RAM[63:0];
	integer i;
	initial
		begin
			$readmemh ("C:/Users/Jaefar_Shameem/Documents/Jaefar_Important_Documents/Computer_Science/Computer_Architecture/HW_Lab/questions/div0/memfile.dat",RAM);
		end
	assign rd = RAM[a]; // word aligned
endmodule

//mips: control signals spregwrite, readhilo and spra need to be added
//conventions:
	//readhilo = ( hi or lo is to be read)?1:0
	//spregwrite = (hi or lo is to be written to )?1:0
	//spra = (hi is read )?1:0
	
module  mips(input clk, reset,
				output [31:0] pc,
				input [31:0] instr,	
				output memwrite,
				output [31:0] aluout, writedata,
				input [31:0] readdata);
	
	wire memtoreg, branch,
	alusrc, regdst, regwrite, jump;
	wire spregwrite, readhilo, spra;
	wire [2:0] alucontrol;
	controller c(instr[31:26], instr[5:0], zero,memtoreg, memwrite, pcsrc,alusrc, regdst, regwrite,spregwrite, jump,alucontrol,spra,readhilo);
	datapath dp(clk, reset, memtoreg, pcsrc,alusrc, regdst, regwrite,spregwrite, jump,alucontrol,zero, pc, instr,aluout, writedata, readdata, spra, readhilo);

endmodule

//controller: control signals need to be added
module controller (input [5:0] op, funct,
						input zero,
						output memtoreg, memwrite,
						output pcsrc, alusrc,
						output regdst, regwrite,spregwrite,
						output jump,
						output [2:0] alucontrol,
						output spra, readhilo);
						
	wire [1:0] aluop;
	wire branch;
	maindec md (op,funct, memtoreg, memwrite, branch,alusrc, regdst, regwrite,spregwrite, jump,aluop, spra, readhilo);
	aludec ad (op,funct, aluop, alucontrol);
	assign pcsrc = branch & zero;
endmodule

//maindec: div, mfhi, mflo, readhilo, spra, spregwrite
module maindec(input [5:0] op,funct,
				output memtoreg, memwrite,
				output branch, alusrc,
				output regdst, regwrite,spregwrite,
				output jump,
				output [1:0] aluop,
				output reg spra,
				output readhilo);
				
	reg [10:0] controls;
	assign {regwrite, regdst, alusrc,branch, memwrite,memtoreg, jump, aluop,spregwrite,readhilo} = controls;
	always @ (*)
		case(op)
			6'b000000:
			begin
				case(funct)
					6'b011010: controls <=11'b01000001010; //div
					default:
						begin
							case(funct)
								6'b010000:
									begin
										spra<=1'b1;
										controls<=11'b11000001001;//move from high
									end
								6'b010010:
									begin
										spra<=1'b0;
										controls <=11'b11000001001;//move from low
									end
								default: controls <=11'b11000001000;//usual  R-Types
							endcase
						end
				endcase
			end
			6'b100011: controls <=11'b10100100000; //LW
			6'b101011: controls <=11'b00101000000; //SW
			6'b000100: controls <=11'b00010000100; //BEQ
			6'b001000: controls <=11'b10100000000; //ADDI
			6'b001100: controls <=11'b10100000000; //ANDI
			6'b001101: controls <=11'b10100000000; //ORI
			6'b001110: controls <=11'b10100000000; //XORI
			6'b000010: controls <=11'b00000010000; //J
			default: controls  <=11'bxxxxxxxxx; //???
		endcase
endmodule

	
//aludec: div must be added
module aludec (input [5:0] op, input [5:0] funct,
					input [1:0] aluop,
					output reg [2:0] alucontrol);
					
	always @ (*)
		case (op) 
		6'b001100:	alucontrol <= 3'b000; // ANDI
		6'b001101:	alucontrol <= 3'b001; // ORI
		6'b001110:	alucontrol <= 3'b011; // XORI
		default: case (aluop)
			2'b00: alucontrol <= 3'b010; // add
			2'b01: alucontrol <= 3'b110; // sub
			default: case(funct) // RTYPE
				6'b100000: alucontrol <= 3'b010; // ADD
				6'b100010: alucontrol <= 3'b110; // SUB
				6'b100100: alucontrol <= 3'b000; // AND
				6'b100101: alucontrol <= 3'b001; // OR
				6'b101010: alucontrol <= 3'b111; // SLT
				6'b000100: alucontrol <= 3'b101; // SLL
				6'b011010: alucontrol <= 3'b100; // DIV
				default: alucontrol <= 3'bxxx; // ???
			endcase
		endcase
	endcase
endmodule





//datapath: control signals need to be added, spregfile needs to be added
	//pc calculation has no change
	//register file inputs have change
	//special register file needs to be added
module datapath (input clk, reset,
						input memtoreg, pcsrc,
						input alusrc, regdst,
						input regwrite,spregwrite, jump,
						input [2:0] alucontrol,
						output zero,
						output [31:0] pc,
						input [31:0] instr,
						output [31:0] aluout, writedata,
						input [31:0] readdata,
						input spra, readhilo);
							
	wire [4:0] writereg;
	wire [31:0] pcnext, pcnextbr, pcplus4, pcbranch;
	wire [31:0] signimm, signimmsh;
	wire [31:0] srca, srcb,wd0,wd1,sprd;
	wire [31:0] result, resulthilo;
	
	// next PC 
	flopr #(32) pcreg(clk, reset, pcnext, pc);
	adder pcadd1 (pc, 32'b100, pcplus4);
	sl2 immsh(signimm, signimmsh);
	adder pcadd2(pcplus4, signimmsh, pcbranch);
	mux2 #(32) pcbrmux(pcplus4, pcbranch, pcsrc,pcnextbr);
	mux2 #(32) pcmux(pcnextbr, {pcplus4[31:28],instr[25:0], 2'b00},jump, pcnext);
	
	// register file 
	regfile reg_file(clk, regwrite, instr[25:21], instr[20:16], writereg, resulthilo, srca, writedata);

	mux2 #(5) wrmux(instr[20:16], instr[15:11], regdst, writereg);//choose between rt, rd and register 31 (ra) to find destination of write operation
	mux2 #(32) resmux(aluout, readdata, memtoreg, result);//choose between aluoutput and readdata to find result
	mux2 #(32) wrmuxhilo(result, sprd, readhilo,resulthilo);//choose between result and sprd to find resulthilo
	signext se(instr[15:0], signimm);//signextend the immediate value
	mux2 #(32) srcbmux(writedata, signimm, alusrc, srcb); //choose between writedata and signimm to find the second alu source
	
	//ALU
	//inputs: srca, srcb, alucontrol
	//outputs: aluout, wd0, wd1, zero
	alu alu(srca, srcb,alucontrol, aluout, wd0, wd1, zero);
	
	//SPECIAL REGISTER FILE
	//inputs: clk, spregwrite, spra, wd0,wd1
	//outputs: sprd, which is the data inside the requested special purpose register
	spregfile sprf(clk, spregwrite, spra, wd0, wd1, sprd);
endmodule



//regfile: no changes
module regfile (input clk,
					input we3,
					input [4:0] ra1, ra2, wa3,
					input [31:0] wd3,
					output [31:0] rd1, rd2);
					
					reg [31:0] rf[31:0];
	// three ported register file
	// read two ports combinationally
	// write third port on rising edge of clock
	// register 0 hardwired to 0
	always @ (posedge clk)
	if (we3) rf[wa3] <= wd3;
		assign rd1 = (ra1 != 0) ? (rf[ra1]) : 0;
		assign rd2 = (ra2 != 0) ? (rf[ra2]): 0;

endmodule



//supplementary modules: spregfile is added


//module spregfile
//inputs: clk, write enable, read poit, write data0, writedata1
//output: readdata
module spregfile(	input clk,
						input we, ra,
						input [31:0] wd0, wd1,
						output [31:0] rd
);
	//two special purpose registers, so 2 registers of 32 bits
	reg[31:0] rf[1:0];
	//if write enabled, then we assign high and low their values
	
	always @(posedge clk) begin
		if(we==1'b1)
			rf[1'b0] <=wd0;
			rf[1'b1] <=wd1;
		end
	//we output rd, 0 corresponds to low, 1 corresponds to high
	assign rd = (ra!= 1'b0) ? rf[1'b1]:rf[1'b0];
	
endmodule


module adder (input [31:0] a, b,output [31:0] y);
		assign y=a + b;
endmodule

module sl2 (input [31:0] a,
	output [31:0] y);
	// shift left by 2
	assign y = {a[29:01], 2'b00};
endmodule


module signext (input [15:0] a,output [31:0] y);
	assign y={{16{a[15]}}, a};
endmodule


module flopr # (parameter WIDTH = 8)(input clk, reset,input [WIDTH-1:0] d,output reg [WIDTH-1:0] q);
	always @ (posedge clk, posedge reset)
		if (reset) q<=0;
		else q <= d;
endmodule



module mux2 # (parameter WIDTH = 8)(input [WIDTH-1:0] d0, d1,input s,output [WIDTH-1:0] y);
	assign y = s ? d1 : d0;
endmodule



//	ALU:
//inputs: a,b,shamt,alu_control
//outputs: result, wd0, wd1, zero
//working: precompute the results, then just assign result, wd0, wd1 and zero
//change: div instruction is added
					
module alu(i_data_A, i_data_B, i_alu_control,o_result,wd0,wd1,o_zero_flag);

input [31:0] i_data_A;					// A operand 
input [31:0] i_data_B;					// B operand
output reg [31:0] o_result,wd0,wd1;				// ALU result
input [2:0] i_alu_control;				// Control signal

output wire o_zero_flag;				// Zero flag 
assign o_zero_flag = ~|o_result;

wire [63:0] quotient, remainder;
assign quotient = i_data_A/i_data_B;
assign remainder = i_data_A%i_data_B;

always @(*) begin
	// Start initialization:
	casex(i_alu_control)
		3'b010:	// ADD
			begin
				o_result = i_data_A + i_data_B;
			end
		3'b110:	// SUB
			begin
				o_result = i_data_A - i_data_B;
			end
		3'b000:	// AND
			begin
				o_result = i_data_A & i_data_B;
			end
		3'b001:	// OR 
			begin
				o_result = i_data_A | i_data_B;
			end
		3'b111:	// SLT
			begin
				o_result = i_data_A < i_data_B ? 32'h00000001 : 32'h00000000;	
			end
		3'b011:	// XOR 
			begin
				o_result = i_data_A ^ i_data_B;
			end
		3'b100:	// DIV
			begin
					o_result <=quotient[31:0];
					wd0<=quotient[31:0];
					wd1<=remainder[31:0];
				end
		default:
			begin
				o_result = {32{1'bx}};	// x-state, (nor 1, nor 0)
			end
	endcase
end

endmodule