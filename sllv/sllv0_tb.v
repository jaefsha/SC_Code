

//addi $2,$0, 4 //initialise $2 =4 
//addi $3,$0, 2 //initialise $3 =2 
//sllv $4,$2, $3 //$4=$2 << $3 ,$4= 4<<2=16 
//sw $4, 12($0) //write address 20 = 16

//0x20020004
//0x20030002
//0x00622004 
//0xAC04000C
module sllv0_tb;
	reg clk;
	reg reset;
	integer i;
	wire [31:0] writedata, dataadr;
	wire memwrite;
	// instantiate device to be tested
	sllv0 dut(clk, reset, writedata, dataadr, memwrite);
	
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
			if (dataadr === 12 & writedata === 16) begin
				$display ("Simulation succeeded");
				$stop;
			end else if (dataadr !== 80) begin
				$display ("Failed hehe %h and %h",writedata,dataadr);
				$stop;
			end
		end
	end
endmodule