
//addi $2,$0, 4  $2=4
//addi $3, $0, 2 $3 = 2
//mult $2,$3     hi,lo = {32'b0,32'b8}
//mflo $4 		  $4 = 8
//sw $4, 12($0)  address 12 contains 8

module mult0_tb;
	reg clk;
	reg reset;
	integer i;
	wire [31:0] writedata, dataadr;
	wire memwrite;
	// instantiate device to be tested
	mult0 dut(clk, reset, writedata, dataadr, memwrite);
	
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
			if (dataadr === 12 & writedata === 8) begin
				$display ("Simulation succeeded");
				$stop;
			end else if (dataadr !== 80) begin
				$display ("Failed hehe %h and %h",writedata,dataadr);
				$stop;
			end
		end
	end
endmodule