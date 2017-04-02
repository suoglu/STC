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
        clk_ACP <= ~clk_ACP; //invert clk, create edge
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
  reg [10:0] sampleNumber; //Sample number is checked only for important points
                          //(e.g. signal change due to path loss)

  always@(posedge clk)
    begin
        if(pulseAct)
          begin
            signal <= 12'b111111111111;
          end
        else
          begin
          //Note: Case statement below is automatically generated
            case (sampleNumber)
              11'd0: signal <= 12'd4048;
              11'd1: signal <= 12'd3952;
              11'd2: signal <= 12'd3860;
              11'd3: signal <= 12'd3770;
              11'd4: signal <= 12'd3682;
              11'd5: signal <= 12'd3598;
              11'd6: signal <= 12'd3515;
              11'd7: signal <= 12'd3435;
              11'd8: signal <= 12'd3357;
              11'd9: signal <= 12'd3282;
              11'd10: signal <= 12'd3208;
              11'd11: signal <= 12'd3137;
              11'd12: signal <= 12'd3067;
              11'd13: signal <= 12'd3000;
              11'd14: signal <= 12'd2934;
              11'd15: signal <= 12'd2870;
              11'd16: signal <= 12'd2808;
              11'd17: signal <= 12'd2747;
              11'd18: signal <= 12'd2689;
              11'd19: signal <= 12'd2631;
              11'd20: signal <= 12'd2575;
              11'd21: signal <= 12'd2521;
              11'd22: signal <= 12'd2468;
              11'd23: signal <= 12'd2417;
              11'd24: signal <= 12'd2367;
              11'd25: signal <= 12'd2318;
              11'd26: signal <= 12'd2270;
              11'd27: signal <= 12'd2224;
              11'd28: signal <= 12'd2178;
              11'd29: signal <= 12'd2134;
              11'd30: signal <= 12'd2091;
              11'd31: signal <= 12'd2049;
              11'd32: signal <= 12'd2008;
              11'd33: signal <= 12'd1969;
              11'd34: signal <= 12'd1930;
              11'd35: signal <= 12'd1892;
              11'd36: signal <= 12'd1855;
              11'd37: signal <= 12'd1819;
              11'd38: signal <= 12'd1784;
              11'd39: signal <= 12'd1749;
              11'd40: signal <= 12'd1716;
              11'd41: signal <= 12'd1683;
              11'd42: signal <= 12'd1651;
              11'd43: signal <= 12'd1620;
              11'd44: signal <= 12'd1589;
              11'd45: signal <= 12'd1560;
              11'd46: signal <= 12'd1530;
              11'd47: signal <= 12'd1502;
              11'd48: signal <= 12'd1474;
              11'd49: signal <= 12'd1447;
              11'd50: signal <= 12'd1427;
              11'd51: signal <= 12'd1395;
              11'd52: signal <= 12'd1370;
              11'd53: signal <= 12'd1345;
              11'd54: signal <= 12'd1321;
              11'd55: signal <= 12'd1297;
              11'd56: signal <= 12'd1274;
              11'd57: signal <= 12'd1251;
              11'd58: signal <= 12'd1229;
              11'd59: signal <= 12'd1208;
              11'd60: signal <= 12'd1187;
              11'd61: signal <= 12'd1166;
              11'd62: signal <= 12'd1146;
              11'd63: signal <= 12'd1126;
              11'd64: signal <= 12'd1107;
              11'd65: signal <= 12'd1088;
              11'd66: signal <= 12'd1069;
              11'd67: signal <= 12'd1051;
              11'd68: signal <= 12'd1033;
              11'd69: signal <= 12'd1016;
              11'd70: signal <= 12'd999;
              11'd71: signal <= 12'd982;
              11'd72: signal <= 12'd966;
              11'd73: signal <= 12'd950;
              11'd74: signal <= 12'd934;
              11'd75: signal <= 12'd919;
              11'd76: signal <= 12'd904;
              11'd77: signal <= 12'd889;
              11'd78: signal <= 12'd875;
              11'd79: signal <= 12'd860;
              11'd80: signal <= 12'd847;
              11'd81: signal <= 12'd833;
              11'd82: signal <= 12'd820;
              11'd83: signal <= 12'd807;
              11'd84: signal <= 12'd794;
              11'd85: signal <= 12'd781;
              11'd86: signal <= 12'd769;
              11'd87: signal <= 12'd757;
              11'd88: signal <= 12'd745;
              11'd89: signal <= 12'd734;
              11'd90: signal <= 12'd722;
              11'd91: signal <= 12'd711;
              11'd92: signal <= 12'd700;
              11'd93: signal <= 12'd690;
              11'd94: signal <= 12'd679;
              11'd95: signal <= 12'd669;
              11'd96: signal <= 12'd659;
              11'd97: signal <= 12'd649;
              11'd98: signal <= 12'd639;
              11'd99: signal <= 12'd630;
              11'd100: signal <= 12'd620;
              11'd101: signal <= 12'd613;
              11'd102: signal <= 12'd602;
              11'd103: signal <= 12'd593;
              11'd104: signal <= 12'd584;
              11'd105: signal <= 12'd576;
              11'd106: signal <= 12'd567;
              11'd107: signal <= 12'd559;
              11'd108: signal <= 12'd551;
              11'd109: signal <= 12'd543;
              11'd110: signal <= 12'd535;
              11'd111: signal <= 12'd528;
              11'd112: signal <= 12'd520;
              11'd113: signal <= 12'd513;
              11'd114: signal <= 12'd506;
              11'd115: signal <= 12'd498;
              11'd116: signal <= 12'd491;
              11'd117: signal <= 12'd485;
              11'd118: signal <= 12'd478;
              11'd119: signal <= 12'd471;
              11'd120: signal <= 12'd465;
              11'd121: signal <= 12'd458;
              11'd122: signal <= 12'd452;
              11'd123: signal <= 12'd446;
              11'd124: signal <= 12'd440;
              11'd125: signal <= 12'd434;
              11'd126: signal <= 12'd428;
              11'd127: signal <= 12'd422;
              11'd128: signal <= 12'd416;
              11'd129: signal <= 12'd411;
              11'd130: signal <= 12'd405;
              11'd131: signal <= 12'd400;
              11'd132: signal <= 12'd394;
              11'd133: signal <= 12'd389;
              11'd134: signal <= 12'd384;
              11'd135: signal <= 12'd379;
              11'd136: signal <= 12'd374;
              11'd137: signal <= 12'd369;
              11'd138: signal <= 12'd364;
              11'd139: signal <= 12'd360;
              11'd140: signal <= 12'd355;
              11'd141: signal <= 12'd350;
              11'd142: signal <= 12'd346;
              11'd143: signal <= 12'd341;
              11'd144: signal <= 12'd337;
              11'd145: signal <= 12'd333;
              11'd146: signal <= 12'd328;
              11'd147: signal <= 12'd324;
              11'd148: signal <= 12'd320;
              11'd149: signal <= 12'd316;
              11'd150: signal <= 12'd312;
              11'd151: signal <= 12'd308;
              11'd152: signal <= 12'd304;
              11'd153: signal <= 12'd301;
              11'd154: signal <= 12'd297;
              11'd155: signal <= 12'd293;
              11'd156: signal <= 12'd290;
              11'd157: signal <= 12'd286;
              11'd158: signal <= 12'd283;
              11'd159: signal <= 12'd279;
              11'd160: signal <= 12'd276;
              11'd161: signal <= 12'd272;
              11'd162: signal <= 12'd269;
              11'd163: signal <= 12'd266;
              11'd164: signal <= 12'd263;
              11'd165: signal <= 12'd259;
              11'd166: signal <= 12'd256;
              11'd167: signal <= 12'd253;
              11'd168: signal <= 12'd250;
              11'd169: signal <= 12'd247;
              11'd170: signal <= 12'd244;
              11'd171: signal <= 12'd242;
              11'd172: signal <= 12'd239;
              11'd173: signal <= 12'd236;
              11'd174: signal <= 12'd233;
              11'd175: signal <= 12'd230;
              11'd176: signal <= 12'd228;
              11'd177: signal <= 12'd225;
              11'd178: signal <= 12'd223;
              11'd179: signal <= 12'd220;
              11'd180: signal <= 12'd217;
              11'd181: signal <= 12'd215;
              11'd182: signal <= 12'd213;
              11'd183: signal <= 12'd210;
              11'd184: signal <= 12'd208;
              11'd194: signal <= 12'd206;
              11'd185: signal <= 12'd205;
              11'd186: signal <= 12'd203;
              11'd187: signal <= 12'd201;
              11'd188: signal <= 12'd199;
              11'd189: signal <= 12'd196;
              11'd190: signal <= 12'd194;
              11'd191: signal <= 12'd192;
              11'd192: signal <= 12'd190;
              11'd193: signal <= 12'd188;
              11'd195: signal <= 12'd184;
              11'd196: signal <= 12'd182;
              11'd197: signal <= 12'd180;
              11'd198: signal <= 12'd178;
              11'd199: signal <= 12'd176;
              11'd200: signal <= 12'd174;
              11'd201: signal <= 12'd172;
              11'd202: signal <= 12'd170;
              11'd203: signal <= 12'd168;
              11'd204: signal <= 12'd166;
              11'd205: signal <= 12'd165;
              11'd206: signal <= 12'd163;
              11'd207: signal <= 12'd161;
              11'd208: signal <= 12'd159;
              11'd209: signal <= 12'd158;
              11'd210: signal <= 12'd156;
              11'd211: signal <= 12'd154;
              11'd212: signal <= 12'd153;
              11'd213: signal <= 12'd151;
              11'd214: signal <= 12'd150;
              11'd215: signal <= 12'd148;
              11'd216: signal <= 12'd147;
              11'd217: signal <= 12'd145;
              11'd218: signal <= 12'd144;
              11'd219: signal <= 12'd142;
              11'd220: signal <= 12'd141;
              11'd221: signal <= 12'd139;
              11'd222: signal <= 12'd138;
              11'd223: signal <= 12'd136;
              11'd224: signal <= 12'd135;
              11'd225: signal <= 12'd134;
              11'd226: signal <= 12'd132;
              11'd227: signal <= 12'd131;
              11'd228: signal <= 12'd130;
              11'd229: signal <= 12'd128;
              11'd230: signal <= 12'd127;
              11'd231: signal <= 12'd126;
              11'd232: signal <= 12'd124;
              11'd233: signal <= 12'd123;
              11'd234: signal <= 12'd122;
              11'd235: signal <= 12'd121;
              11'd236: signal <= 12'd120;
              11'd237: signal <= 12'd118;
              11'd238: signal <= 12'd117;
              11'd240: signal <= 12'd115;
              11'd241: signal <= 12'd114;
              11'd242: signal <= 12'd113;
              11'd243: signal <= 12'd112;
              11'd244: signal <= 12'd111;
              11'd245: signal <= 12'd109;
              11'd246: signal <= 12'd108;
              11'd247: signal <= 12'd107;
              11'd248: signal <= 12'd106;
              11'd249: signal <= 12'd105;
              11'd250: signal <= 12'd104;
              11'd251: signal <= 12'd103;
              11'd252: signal <= 12'd102;
              11'd253: signal <= 12'd101;
              11'd254: signal <= 12'd100;
              11'd255: signal <= 12'd99;
              11'd257: signal <= 12'd98;
              11'd258: signal <= 12'd97;
              11'd259: signal <= 12'd96;
              11'd260: signal <= 12'd95;
              11'd261: signal <= 12'd94;
              11'd262: signal <= 12'd93;
              11'd263: signal <= 12'd92;
              11'd264: signal <= 12'd91;
              11'd266: signal <= 12'd90;
              11'd267: signal <= 12'd89;
              11'd268: signal <= 12'd88;
              11'd269: signal <= 12'd87;
              11'd270: signal <= 12'd86;
              11'd272: signal <= 12'd85;
              11'd273: signal <= 12'd84;
              11'd274: signal <= 12'd83;
              11'd276: signal <= 12'd82;
              11'd277: signal <= 12'd81;
              11'd278: signal <= 12'd80;
              11'd280: signal <= 12'd79;
              11'd281: signal <= 12'd78;
              11'd283: signal <= 12'd77;
              11'd284: signal <= 12'd76;
              11'd286: signal <= 12'd75;
              11'd287: signal <= 12'd74;
              11'd289: signal <= 12'd73;
              11'd290: signal <= 12'd72;
              11'd292: signal <= 12'd71;
              11'd293: signal <= 12'd70;
              11'd295: signal <= 12'd69;
              11'd297: signal <= 12'd68;
              11'd298: signal <= 12'd67;
              11'd300: signal <= 12'd66;
              11'd302: signal <= 12'd65;
              11'd304: signal <= 12'd64;
              11'd306: signal <= 12'd63;
              11'd307: signal <= 12'd62;
              11'd309: signal <= 12'd61;
              11'd311: signal <= 12'd60;
              11'd313: signal <= 12'd59;
              11'd315: signal <= 12'd58;
              11'd317: signal <= 12'd57;
              11'd320: signal <= 12'd56;
              11'd322: signal <= 12'd55;
              11'd324: signal <= 12'd54;
              11'd326: signal <= 12'd53;
              11'd329: signal <= 12'd52;
              11'd331: signal <= 12'd51;
              11'd333: signal <= 12'd50;
              11'd336: signal <= 12'd49;
              11'd338: signal <= 12'd48;
              11'd341: signal <= 12'd47;
              11'd344: signal <= 12'd46;
              11'd347: signal <= 12'd45;
              11'd349: signal <= 12'd44;
              11'd352: signal <= 12'd43;
              11'd355: signal <= 12'd42;
              11'd359: signal <= 12'd41;
              11'd362: signal <= 12'd40;
              11'd365: signal <= 12'd39;
              11'd369: signal <= 12'd38;
              11'd373: signal <= 12'd37;
              11'd376: signal <= 12'd36;
              11'd379: signal <= 12'd35;
              11'd383: signal <= 12'd34;
              11'd387: signal <= 12'd33;
              11'd392: signal <= 12'd32;
              11'd396: signal <= 12'd31;
              11'd401: signal <= 12'd30;
              11'd405: signal <= 12'd29;
              11'd410: signal <= 12'd28;
              11'd415: signal <= 12'd27;
              11'd421: signal <= 12'd26;
              11'd427: signal <= 12'd25;
              11'd433: signal <= 12'd24;
              11'd439: signal <= 12'd23;
              11'd445: signal <= 12'd22;
              11'd452: signal <= 12'd21;
              11'd460: signal <= 12'd20;
              11'd468: signal <= 12'd19;
              11'd476: signal <= 12'd18;
              11'd485: signal <= 12'd17;
              11'd495: signal <= 12'd16;
              11'd504: signal <= 12'd16;
              11'd505: signal <= 12'd15;
              11'd516: signal <= 12'd14;
              11'd529: signal <= 12'd13;
              11'd542: signal <= 12'd12;
              11'd557: signal <= 12'd11;
              11'd574: signal <= 12'd10;
              11'd593: signal <= 12'd9;
              11'd614: signal <= 12'd8;
              11'd639: signal <= 12'd7;
              11'd668: signal <= 12'd6;
              11'd704: signal <= 12'd5;
              11'd749: signal <= 12'd4;
              11'd808: signal <= 12'd3;
              11'd893: signal <= 12'd2;
              11'd1038: signal <= 12'd1;
              11'd1419: signal <= 12'd0;
            endcase
          end
    end

    always@(posedge clk)
      begin
        if(pulseAct)
          begin //sampleNumber reset when pulseAct is high
            sampleNumber <= 11'b0;
          end
        else //if pulseAct is low increase each cycle untill sampleNumber
          begin //is equal to 11'b11111111111, all regs are high
            sampleNumber <= sampleNumber + {10'b0, (~(&sampleNumber))};
          end
      end

endmodule // clutter
