`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:04:23 04/14/2017
// Design Name:   radar_board
// Module Name:   C:/Users/suoglu/Documents/Xilinx/SeaClutter/sim2.v
// Project Name:  SeaClutter
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: radar_board
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module sim2;

	// Inputs
	reg rst;
	reg clk;

	// Outputs
	wire arp;
	wire acp;
	wire trig;
	wire DACin;
	wire DAC_CLR;
	wire DACclk;
	wire DAC_CS;
	wire [6:0] LED;

	// Instantiate the Unit Under Test (UUT)
	radar_board uut (
		.arp(arp), 
		.acp(acp), 
		.trig(trig), 
		.rst(rst), 
		.clk(clk), 
		.DACin(DACin), 
		.DAC_CLR(DAC_CLR), 
		.DACclk(DACclk), 
		.DAC_CS(DAC_CS), 
		.LED(LED)
	);
	
		always #10 clk = ~clk;
	
	initial begin
		// Initialize Inputs
		rst = 1;
		clk = 0;

		// Wait 100 ns for global reset to finish
		#100;
      
		// Add stimulus here
		rst = 0;
	end
      
endmodule

