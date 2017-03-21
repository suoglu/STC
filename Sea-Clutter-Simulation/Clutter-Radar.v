// This module simulates a sea clutter and radar interface
// 50MHz clock freq
`timescale 1ns / 1ps

module radar(arp, acp, trig, rst, clk)
  input clk, rst; //clk feq is 50 MHz, period is 20ns
  output reg trig;
  output arp, acp;
  reg [11:0] acpState; //for 4096 angles
  reg clk_ACP; //period equal to time between ACP signals (~488.280ns) 24412 cycle
  

  assign arp = (acpState == 12'b0) & acp; //ARP is high only when ACP is high and ACP counter is at zero
  
  always@(posedge clk_ACP or posedge rst) //ACP state 
    if(rst)
      acpState <= 12'b0;
    else
      acpState <= acpState + 12'b1;
  end
  
  assign acp = clk_ACP;
  
  acpClkgen acpC(.rst(rst), .clk(clk), .clk_ACP(clk_ACP));
  
endmodule

//this module generates acp clk
module acpClkgen(rst, clk, clk_ACP)
  input rst, clk;
  output reg clk_ACP;
  reg [14:0] acpClk; 
  always@(posedge clk or posedge rst) //ACP clk generation
      if(rst)
        begin
          clk_ACP <= 0;
          acpClk <= 14'b0;
        end
    else if(acpClk == 14'12207)
        acpClk <= 14'b0;
        clk_ACP = ~clk_ACP;
      else
        acpClk <= acpClk + 12'b1;
    end
endmodule
