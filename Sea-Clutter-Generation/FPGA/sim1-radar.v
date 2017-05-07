`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:57:55 04/03/2017
// Design Name:   radar
// Module Name:   C:/Users/suoglu/Documents/Xilinx/SeaClutter/sim1.v
// Project Name:  SeaClutter
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: radar
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module sim1;

	// Inputs
	reg rst;
	reg clk;

	// Outputs
	wire arp;
	wire acp;
	wire trig;
	wire [11:0] video;

	// Instantiate the Unit Under Test (UUT)
	radar uut (
		.arp(arp), 
		.acp(acp), 
		.trig(trig), 
		.rst(rst), 
		.clk(clk), 
		.video(video)
	);
	
	integer file;
	
	always #10 clk = ~clk;
	
	initial begin
		// Initialize Inputs
		file = $fopen("GeneratedVideoData.csv", "w");
		$fmonitor(file, "%d, ", video);
		rst = 1;
		clk = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		rst = 0;
		
		#1000000000;//wait 0.5ms before closing file
		$fclose (file);
	end
      
endmodule

