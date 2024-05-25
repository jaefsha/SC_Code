//if jal works, you get 4 in address 8
//otherwise you get 8 in address 8
//main:
//0	addi $2, $0, 4
//4	jal end
//8	addi  $2, $2, 4 
//end:
//12	sw $2, 8(0)
//
//here, the current address of jal is 0004, or in binary, 1000
//you need to skip two instructions to go to 000C, or in binary, 1100
//so the immediate must be 11

//0x20020004
//0x0C000003
//0x20420004
//0xAC020008

module jal0_tb;
	reg clk;
	reg reset;
	integer i;
	wire [31:0] writedata, dataadr;
	wire memwrite;
	// instantiate device to be tested
	jal0 dut(clk, reset, writedata, dataadr, memwrite);
	
	// initialize test
	initial
	begin
		reset <= 1; # 22; reset <= 0;
	end
		// generate clock to sequence tests
	always
	begin
		clk <= 1; # 5; clk <= 0; # 5;
	end
		// check results
	always @ (negedge clk)
	begin
		//$display("%h ",pc);
		if (memwrite) begin
			$display("%h %h", writedata,dataadr);
			if (dataadr === 8 & writedata === 4) begin
				$display ("Simulation succeeded");
				$stop;
			end else if (dataadr !== 80) begin
				$display ("Failed hehe %h and %h",writedata,dataadr);
				$stop;
			end
		end
	end
endmodule