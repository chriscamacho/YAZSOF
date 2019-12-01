module videoram
(
  input clk,
  input [8:0] beamAdrs,
  output [7:0] beamData,
  input we,
  input [8:0] inAdrs,
  input [7:0] inData
);

reg [7:0] vidData[0:511];

// for testing pattern of various chars...
initial begin
    $readmemh("video/video.mem", vidData);
end

assign beamData = vidData[beamAdrs];

always @(posedge clk) begin
    if (we) vidData[inAdrs] <= inData;
end

endmodule
