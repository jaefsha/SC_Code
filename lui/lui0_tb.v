

//lui $4, 0xffff
//sw $4, 12($0) //write address 12 = 0xffff0000
//0x3C04FFFF
//0xAC04000C


module lui0_tb;
	reg clk;
	reg reset;
	integer i;
	wire [31:0] writedata, dataadr;
	wire memwrite;
	// instantiate device to be tested
	lui0 dut(clk, reset, writedata, dataadr, memwrite);
	
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
			if (dataadr === 12 & writedata === 32'hffff0000) begin
				$display ("Simulation succeeded");
				$stop;
			end else if (dataadr !== 80) begin
				$display ("Failed hehe %h and %h",writedata,dataadr);
				$stop;
			end
		end
	end
endmodule