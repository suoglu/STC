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

    //note that addition of midTerm will never overflow
    assign vid_out = midTerm2[0] + midTerm2[1] + midTerm2[2];

    //generation of midTerm2s
    // by adding midTerm1s in groups
    assign midTerm2[0] = midTerm1[0] + midTerm1[1] + midTerm1[2] + midTerm1[3];
    assign midTerm2[1] = midTerm1[4] + midTerm1[5] + midTerm1[6] + midTerm1[7];
    assign midTerm2[2] = midTerm1[8] + midTerm1[9] + midTerm1[10] + midTerm1[11];

    //generation of midTerm1s
    // by shifting by index and enabiling with shiftControl
    assign midTerm1[0] = ((vid_in) & {12{shiftControl[11]}});
    assign midTerm1[1] = ((vid_in >> 1) & {12{shiftControl[10]}});
    assign midTerm1[2] = ((vid_in >> 2) & {12{shiftControl[9]}});
    assign midTerm1[3] = ((vid_in >> 3) & {12{shiftControl[8]}});
    assign midTerm1[4] = ((vid_in >> 4) & {12{shiftControl[7]}});
    assign midTerm1[5] = ((vid_in >> 5) & {12{shiftControl[6]}});
    assign midTerm1[6] = ((vid_in >> 6) & {12{shiftControl[5]}});
    assign midTerm1[7] = ((vid_in >> 7) & {12{shiftControl[4]}});
    assign midTerm1[8] = ((vid_in >> 8) & {12{shiftControl[3]}});
    assign midTerm1[9] = ((vid_in >> 9) & {12{shiftControl[2]}});
    assign midTerm1[10] = ((vid_in >> 10) & {12{shiftControl[1]}});
    assign midTerm1[11] = ((vid_in >> 11) & {12{shiftControl[0]}});



    always@(posedge clk) //stc filter shift control data
      begin
        case (sampleCount)
          12'd0: shiftControl <= 12'b000000000000; //gain: 0
          12'd0: shiftControl <= 12'b000000000001; //gain: 488e-6
          12'd0: shiftControl <= 12'b000000000010; //gain: 977e-6
          12'd0: shiftControl <= 12'b000000000011; //gain: 1.46e-3
          12'd0: shiftControl <= 12'b000000000100; //gain: 1.95e-3
          12'd0: shiftControl <= 12'b000000000101; //gain: 2.44e-3
          12'd0: shiftControl <= 12'b000000000110; //gain: 2.93e-3
          12'd0: shiftControl <= 12'b000000000111; //gain: 3.42e-3
          12'd0: shiftControl <= 12'b000000001000; //gain: 3.91e-3
          12'd0: shiftControl <= 12'b000000001001; //gain: 4.39e-3
          12'd0: shiftControl <= 12'b000000001010; //gain: 4.88e-3
          12'd0: shiftControl <= 12'b000000001011; //gain: 5.47e-3
          12'd0: shiftControl <= 12'b000000001101; //gain: 6.35e-3
          12'd0: shiftControl <= 12'b000000001110; //gain: 6.84e-3
          12'd0: shiftControl <= 12'b000000001111; //gain: 7.32e-3
          12'd0: shiftControl <= 12'b000000010000; //gain: 7.81e-3
          12'd0: shiftControl <= 12'b000000010010; //gain: 8.79e-3
          12'd0: shiftControl <= 12'b000000010100; //gain: 9.77e-3
          12'd0: shiftControl <= 12'b000000010110; //gain: 10.7e-3
          12'd0: shiftControl <= 12'b000000011000; //gain: 11.7e-3
          12'd0: shiftControl <= 12'b000000011010; //gain: 12.7e-3
          12'd0: shiftControl <= 12'b000000011100; //gain: 13.7e-3
          12'd0: shiftControl <= 12'b000000011110; //gain: 14.6e-3
          12'd0: shiftControl <= 12'b000000100000; //gain: 15.6e-3
          12'd0: shiftControl <= 12'b000000100100; //gain: 17.6e-3
          12'd0: shiftControl <= 12'b000000101000; //gain: 19.5e-3
          12'd0: shiftControl <= 12'b000000101100; //gain: 21.5e-3
          12'd0: shiftControl <= 12'b000000110000; //gain: 23.4e-3
          12'd0: shiftControl <= 12'b000000110100; //gain: 25.4e-3
          12'd0: shiftControl <= 12'b000000111000; //gain: 27.3e-3
          12'd0: shiftControl <= 12'b000000111100; //gain: 29.3e-3
          12'd0: shiftControl <= 12'b000001000000; //gain: 31.2e-3
          12'd0: shiftControl <= 12'b000001001000; //gain: 35.2e-3
          12'd0: shiftControl <= 12'b000001010000; //gain: 39.1e-3
          12'd0: shiftControl <= 12'b000001011000; //gain: 43e-3
          12'd0: shiftControl <= 12'b000001100000; //gain: 46.9e-3
          12'd0: shiftControl <= 12'b000001101000; //gain: 50.8e-3
          12'd0: shiftControl <= 12'b000001110000; //gain: 54.7e-3
          12'd0: shiftControl <= 12'b000001111000; //gain: 58.6e-3
          12'd0: shiftControl <= 12'b000010000000; //gain: 62.5e-3
          12'd0: shiftControl <= 12'b000010010000; //gain: 70.3e-3
          12'd0: shiftControl <= 12'b000010100000; //gain: 78.1e-3
          12'd0: shiftControl <= 12'b000010110000; //gain: 85.8e-3
          12'd0: shiftControl <= 12'b000011000000; //gain: 93.7e-3
          12'd0: shiftControl <= 12'b000011010000; //gain: 102e-3
          12'd0: shiftControl <= 12'b000011100000; //gain: 109e-3
          12'd0: shiftControl <= 12'b000011110000; //gain: 117e-3
          12'd0: shiftControl <= 12'b000100000000; //gain: 125e-3
          12'd0: shiftControl <= 12'b000100100000; //gain: 141e-3
          12'd0: shiftControl <= 12'b000101000000; //gain: 156e-3
          12'd0: shiftControl <= 12'b000101100000; //gain: 172e-3
          12'd0: shiftControl <= 12'b000110000000; //gain: 187e-3
          12'd0: shiftControl <= 12'b000110100000; //gain: 203e-3
          12'd0: shiftControl <= 12'b000111000000; //gain: 219e-3
          12'd0: shiftControl <= 12'b000111100000; //gain: 234e-3
          12'd0: shiftControl <= 12'b001000000000; //gain: 250e-3
          12'd0: shiftControl <= 12'b001001000000; //gain: 281e-3
          12'd0: shiftControl <= 12'b001010000000; //gain: 312e-3
          12'd0: shiftControl <= 12'b001011000000; //gain: 344e-3
          12'd0: shiftControl <= 12'b001100000000; //gain: 375e-3
          12'd0: shiftControl <= 12'b001101000000; //gain: 406e-3
          12'd0: shiftControl <= 12'b001110000000; //gain: 438e-3
          12'd0: shiftControl <= 12'b001111000000; //gain: 469e-3
          12'd0: shiftControl <= 12'b010000000000; //gain: 500e-3
          12'd0: shiftControl <= 12'b010010000000; //gain: 562e-3
          12'd0: shiftControl <= 12'b010100000000; //gain: 625e-3
          12'd0: shiftControl <= 12'b010110000000; //gain: 688e-3
          12'd0: shiftControl <= 12'b011000000000; //gain: 750e-3
          12'd0: shiftControl <= 12'b011010000000; //gain: 812e-3
          12'd0: shiftControl <= 12'b011100000000; //gain: 875e-3
          12'd0: shiftControl <= 12'b011110000000; //gain: 938e-3
          12'd0: shiftControl <= 12'b100000000000; //gain: 1
        endcase
      end



endmodule // stc
