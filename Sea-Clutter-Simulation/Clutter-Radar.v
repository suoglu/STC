// Yigit Suoglu, Furkan Mert Algan
// All modules in this file designed to work with 50MHz clock frequency
`timescale 1ns / 1ps

// This module simulates sea clutter and radar interface
module radar(arp, acp, trig, rst, clk);
  input clk, rst; //clk feq is 50 MHz, period is 20ns
  output reg trig; //Master Trigger signal
  output arp, acp; //Azimuth Reset Pulse, Azimuth Change Pulse
  reg [11:0] acpState; //for 4096 angles
  wire clk_ACP; //Clock signal for acp
  //period equal to time between ACP signals (~488.280ns, 24412 cycle @ 50Mhz)


  assign arp = (acpState == 12'b0) & acp; //ARP is high only when ACP is high and ACP counter is at zero

  always@(posedge clk_ACP or posedge rst) //ACP state
  begin
    if(rst)
      acpState <= 12'b0;
    else
      acpState <= acpState + 12'b1;
  end

  assign acp = clk_ACP; //for simplicity ACP signal is same as its clock


  acpClkgen_half acpC(.rst(rst), .clk(clk), .clk_ACP(clk_ACP)); //for 50% duty cycle of ACP
//acpClkgen_one acpC(.rst(rst), .clk(clk), .clk_ACP(clk_ACP)); //for 1% duty cycle of ACP

endmodule

//this module generates Clock signal for ACP
//created clock has period of 488.280ns and duty cycle of 50%
//note: created clock accuracy depends on on-board oscillator
module acpClkgen_half(rst, clk, clk_ACP);
  input rst, clk; //control signals
  output reg clk_ACP;
  reg [13:0] acpClk; //Counter state
  always@(posedge clk or posedge rst) //ACP clk generation
  begin
    if(rst) //if reset
      begin
        clk_ACP <= 0; //clk is low
        acpClk <= 14'b0; //counter is initialised
      end
    else if(acpClk == 14'd12207) //if counter is reached count number
      begin
        acpClk <= 14'b0; //reset count
        clk_ACP = ~clk_ACP; //invert clk, create edge
      end
    else //otherwise
        acpClk <= acpClk + 14'b1; //count up
  end
endmodule

//this module generates Clock signal for ACP
//created clock has period of 488.280ns and duty cycle of ~1%
//note: created clock accuracy depends on on-board oscillator
module acpClkgen_one(rst, clk, clk_ACP);
  input rst, clk; //control signals
  output reg clk_ACP;
  reg [14:0] acpClk; //Counter state
  always@(posedge clk or posedge rst) //ACP clk generation
  begin
    if(rst) //if reset
      begin
        acpClk <= 15'b0; //counter is initialised
      end
    else if(acpClk == 15'd24412) //if counter is reached count number
      begin
        acpClk <= 15'b0; //reset count
      end
    else //otherwise
        acpClk <= acpClk + 15'b1; //count up

    if(rst) //if reset
      begin
        clk_ACP <= 1; //clk is high
      end
    else if(acpClk == 15'd24412) //if counter is reached count number
      begin
        clk_ACP <= 1; //create posedge
      end
    else if(acpClk == 15'd244) //≈1% of total period
      begin
        clk_ACP <= 0; //create negedge
      end
    end
endmodule
