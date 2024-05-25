//addi $2, $0, 8
//addi $3, $0, 2
//div $2, $3
//mflo $4
//sw $4, 12($0)
//
//0x20020008
//0x20030002
//0x0043001A
//0x00002012
//0xAC04000C

module div0_tb;
	reg clk;
	reg reset;
	integer i;
	wire [31:0] writedata, dataadr;
	wire memwrite;
	// instantiate device to be tested
	div0 dut(clk, reset, writedata, dataadr, memwrite);
	
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
		if (memwrite) begin
			$display("%h %h\n", writedata,dataadr);
			if (dataadr === 12 & writedata === 4) begin
				$display ("Simulation succeeded");
				$stop;
			end else if (dataadr !== 80) begin
				$display ("Failed hehe %h and %h",writedata,dataadr);
				$stop;
			end
		end
	end
endmodule