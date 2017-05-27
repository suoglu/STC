`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   04:22:54 05/20/2017
// Design Name:   radar_board
// Module Name:   C:/Users/suoglu/Documents/Xilinx/SeaClutter/sim_board.v
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

module sim_board;

	// Inputs
	reg reset;
	reg clk;
	reg readSW;
	reg arp_r;
	reg acp_r;
	reg trig_r;
	reg ADC_OUT;
	reg stcSW;

	// Outputs
	wire arp;
	wire acp;
	wire trig;
	wire SPIin;
	wire DAC_CLR;
	wire SPIclk;
	wire DAC_CS;
	wire [6:0] LED;
	wire ADC_CS;
	wire ADC_rst;
	wire AD_CONV;

	// Instantiate the Unit Under Test (UUT)
	radar_board uut (
		.arp(arp), 
		.acp(acp), 
		.trig(trig), 
		.reset(reset), 
		.clk(clk), 
		.SPIin(SPIin), 
		.DAC_CLR(DAC_CLR), 
		.SPIclk(SPIclk), 
		.DAC_CS(DAC_CS), 
		.LED(LED), 
		.readSW(readSW), 
		.ADC_CS(ADC_CS), 
		.arp_r(arp_r), 
		.acp_r(acp_r), 
		.trig_r(trig_r), 
		.ADC_rst(ADC_rst), 
		.AD_CONV(AD_CONV), 
		.ADC_OUT(ADC_OUT),
		.stcSW(stcSW)
	);

	always #10 clk = ~clk;
	always #15 ADC_OUT = ~ADC_OUT;
	
	initial begin
		// Initialize Inputs
		reset = 1;
		clk = 0;
		readSW = 0;
		arp_r = 0;
		acp_r = 0;
		trig_r = 0;
		ADC_OUT = 0;
		stcSW = 1;
		// Wait 100 ns for global reset to finish
		#100;
        reset = 0;
		// Add stimulus here
	#10000;
	stcSW = 0;
	end
      
endmodule

