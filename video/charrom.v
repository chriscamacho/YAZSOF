
module charrom(
    input clk,
    input [9:0] address_in,
    output reg [7:0] chardata_out
    );

    reg [7:0] rom[0:1023];

    initial begin
        $readmemh("video/8x8rom.mem", rom);
    end

    always @(posedge clk) begin
        chardata_out <= rom[address_in];
    end

endmodule
