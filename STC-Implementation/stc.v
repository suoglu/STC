// Yigit Suoglu
// This module implements sensitivity time control function to input video
// This module designed to work with 50 MHz clock
module stc(clk, trig, vid_in, vid_out);
  parameter sampleLimit = 12'b111111111111;
  input clk, trig;
  input [11:0] vid_in;
  output [11:0] vid_out;
  reg [11:0] sampleCount; //each sample is ~6m apart
  reg [11:0] shiftControl; //enables corresponding shift
  //wires below for code readability
  wire [11:0] midTerm1[11:0];
  wire [2:0]  midTerm2[11:0];

  always@(posedge clk or posedge trig) //state transactions
    begin
      if(trig)
        begin
          sampleCount <= 0;
        end
      else
        begin
          //(|(sampleCount ^ sampleLimit)) = 0, when sampleCount = sampleLimit
          sampleCount <= sampleCount + (|(sampleCount ^ sampleLimit)); //0 otherwise
        end
    end

    always@(posedge clk) //stc filter shift control data
      begin

      end

      //note that addition of midTerm will never overflow
      assign vid_out = midTerm2[0] + midTerm2[1] + midTerm2[2];

      //generation of midTerm2s
      // by adding midTerm1s in groups
      assign midTerm2[0] = midTerm1[0] + midTerm1[1] + midTerm1[2] + midTerm1[3];
      assign midTerm2[1] = midTerm1[4] + midTerm1[5] + midTerm1[6] + midTerm1[7];
      assign midTerm2[2] = midTerm1[8] + midTerm1[9] + midTerm1[10] + midTerm1[11];

      //generation of midTerm1s
      // by shifting by index and enabiling with shiftControl
      assign midTerm1[0] = ((vid_in) & {12{shiftControl[0]}});
      assign midTerm1[1] = ((vid_in >> 1) & {12{shiftControl[1]}});
      assign midTerm1[2] = ((vid_in >> 2) & {12{shiftControl[2]}});
      assign midTerm1[3] = ((vid_in >> 3) & {12{shiftControl[3]}});
      assign midTerm1[4] = ((vid_in >> 4) & {12{shiftControl[4]}});
      assign midTerm1[5] = ((vid_in >> 5) & {12{shiftControl[5]}});
      assign midTerm1[6] = ((vid_in >> 6) & {12{shiftControl[6]}});
      assign midTerm1[7] = ((vid_in >> 7) & {12{shiftControl[7]}});
      assign midTerm1[8] = ((vid_in >> 8) & {12{shiftControl[8]}});
      assign midTerm1[9] = ((vid_in >> 9) & {12{shiftControl[9]}});
      assign midTerm1[10] = ((vid_in >> 10) & {12{shiftControl[10]}});
      assign midTerm1[11] = ((vid_in >> 11) & {12{shiftControl[11]}});



endmodule // stc
