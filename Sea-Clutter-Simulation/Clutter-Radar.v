// Yigit Suoglu, Furkan Mert Algan
// All modules in this file designed to work with 50MHz clock frequency
`timescale 1ns / 1ps

//This module simulates sea clutter and radar interface
module radar(arp, acp, trig, rst, clk, video);
  input clk, rst; //clk feq is 50 MHz, period is 20ns
  output trig; //Master Trigger signal
  output arp, acp; //Azimuth Reset Pulse, Azimuth Change Pulse
  reg [11:0] acpState; //for 4096 angles
  output [11:0] video;
  wire clk_ACP, clk_vid; //Clock signal for acp, video
  //clk_ACP period equal to time between ACP signals (~488.280ns, 24412 cycle @ 50Mhz)


  assign arp = (acpState == 12'b0) & acp; //ARP is high only when ACP is high and ACP counter is at zero

  always@(posedge clk_ACP or posedge rst) //ACP state
  begin
    if(rst)
      acpState <= 12'b0;
    else
      acpState <= acpState + 12'b1;
  end

  assign acp = clk_ACP; //for simplicity ACP signal is same as its clock

  clk_div_vid clkDivider(.clk(clk), .rst(rst), .clk_vid(clk_vid));

  acpClkgen_half acpC(.rst(rst), .clk(clk), .clk_ACP(clk_ACP)); //for 50% duty cycle of ACP
  //acpClkgen_one acpC(.rst(rst), .clk(clk), .clk_ACP(clk_ACP)); //for 1% duty cycle of ACP

  master_triger mtig(.clk(clk), .rst(rst), .arp(arp), .trig(trig));
  clutter cltgen(.clk(clk_vid), .rst(rst), .trig(trig), .video(video), .pulseAct(trig));
  //Note: This system assumes master trigger is high while transmitting pulse
endmodule

//This module generates Clock signal for ACP
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

//This module generates Clock signal for ACP
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


//This module creates trigger signal
//trigger waits ARP signal to be high at least once to start after a reset
//parameters can be adjusted
module master_triger(clk, rst, arp, trig);
  parameter counterSize = 15; //register size for counter
  parameter trigerPeriod = 15'd24412; //trigger period in cycles (or period/20ns)
  parameter trigerHwidth = 15'd50; //cycle count (or period/20ns) of high tigger signal
  //note: cycle count of low trigger signal = trigerPeriod - trigerH-width;

  input clk, rst, arp; //control signals
  output trig; //master trigger output
  reg [(counterSize-1):0] counter; //counter
  reg trig_en; //master trigger is enabled
  reg trig_reg;

  always@(posedge clk or posedge rst)
    begin
    //counter control
      if(rst)
        begin
          counter <= 0;
        end
      else if(counter == trigerPeriod) //if period is done
        begin
          counter <= 0; //reset counter
        end
      else if(trig_en) //if trigger is enabled
        begin
          counter <= counter + 1; //count up
        end
    end

  always@(posedge clk or posedge rst)
    begin
      if(rst) //if reset
        begin  //disenable trigger
          trig_en <= 0;
        end
      else if(arp) //if arp is high
        begin //enable counter
          trig_en <= 1;
        end
    end

  assign trig = (trig_en & trig_reg); //if counter is not enabled output is always low

  always@(posedge clk or posedge rst) //trig_reg
    begin
      if(rst) //if reset
        begin //set triger register
          trig_reg <= 1;
        end
      else if(counter == trigerPeriod) //if period is ended
        begin //set trigger register
          trig_reg <= 1;
        end
      else if(counter == trigerHwidth) //if trigger high time ended
        begin //reset trigger register
          trig_reg <= 0;
        end
    end
endmodule


//This module is a clock divider for video signal
//Divides clk by 8, for 50MHz (20ns) clk output is 25Mhz(40ns)
module clk_div_vid(clk, rst, clk_vid);
  input clk, rst;
  output reg clk_vid;

  always@(posedge clk or posedge rst)
    begin
      if(rst)
        begin
          clk_vid <= 0;
        end
      else
        begin
          clk_vid <= ~clk_vid;
        end
    end
endmodule

//This module generates 12bit radar video with a sea clutter model
//Video signal reset with master trigger signal
//pulseAct signal should be high during to pulse
//Clk period is 40ns (25Mhz)
//Each clock cycle radar shows ~48 meters
module clutter(clk, rst, trig, video, pulseAct);
  input clk, rst, trig, pulseAct; //control signals
  output reg [11:0] video; //clutter video
  reg [11:0] signal;
  reg [13:0] sample;

  always@(posedge clk)
    begin
        if(pulseAct)
          begin
            signal <= 12'b111111111111;
          end
        else
          begin

          end
    end

endmodule // clutter
