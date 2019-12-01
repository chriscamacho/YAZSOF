module dvi
(
  input clk_25mhz,
  output [3:0] gpdi_dp,
  output [3:0] gpdi_dn,
  input [7:0] vidData,
  input [8:0] vidAdrs,
  input vidWE
);
    parameter C_ddr = 1'b1; // 0:SDR 1:DDR

    // clock generator
    wire  clk_125MHz;
    clks    clock_instance
    (
      .clkin(clk_25mhz),
      .clk125(clk_125MHz)
    );

    wire clk_pixel, clk_shift;
    assign clk_pixel = clk_25mhz;
    assign clk_shift = clk_125MHz;

    // VGA signal generator
    wire [7:0] vga_r, vga_g, vga_b;
    wire vga_hsync, vga_vsync, vga_blank;

    vga
    #(

    )
    vga_instance
    (
      .clk_pixel(clk_pixel),
      .clk_pixel_ena(1'b1),
      .test_picture(1'b0), // enable test picture generation
      .vga_r(vga_r),
      .vga_g(vga_g),
      .vga_b(vga_b),
      .red_byte(red),
      .green_byte(green),
      .blue_byte(blue),
      .vga_hsync(vga_hsync),
      .vga_vsync(vga_vsync),
      .vga_blank(vga_blank), // in not active area (not vblank!)
      .beam_x(scanx),
      .beam_y(scany)
    );

    reg [7:0] red;
    reg [7:0] green;
    reg [7:0] blue;


    // VGA to digital video converter
    wire [1:0] tmds[3:0];
    vga2dvid
    #(
      .C_ddr(C_ddr),
      .C_shift_clock_synchronizer(1'b1)
    )
    vga2dvid_instance
    (
      .clk_pixel(clk_pixel),
      .clk_shift(clk_shift),
      .in_red(vga_r),
      .in_green(vga_g),
      .in_blue(vga_b),
      .in_hsync(vga_hsync),
      .in_vsync(vga_vsync),
      .in_blank(vga_blank),
      .out_clock(tmds[3]),
      .out_red(tmds[2]),
      .out_green(tmds[1]),
      .out_blue(tmds[0])
    );

    // output TMDS SDR/DDR data to fake differential lanes
    fake_differential
    #(
      .C_ddr(C_ddr)
    )
    fake_differential_instance
    (
      .clk_shift(clk_shift),
      .in_clock(tmds[3]),
      .in_red(tmds[2]),
      .in_green(tmds[1]),
      .in_blue(tmds[0]),
      .out_p(gpdi_dp),
      .out_n(gpdi_dn)
    );

    charrom cri(
        .clk(clk_pixel),
        .address_in(chrAdr),
        .chardata_out(char_data)
    );

    videoram vri
    (
      .clk(clk_25mhz),
      .beamAdrs(bAdrs),
      .beamData(bData),
      .inAdrs(vidAdrs),
      .inData(vidData),
      .we(vidWE)
    );

    // rgb colour output to lcd
    wire [7:0] red;
    wire [7:0] blue;
    wire [7:0] green;

    // beam address ie which character the scan
    // points to in video memory
    wire [8:0] bAdrs;
    // its character value
    wire [7:0] bData;

    // lookup the character
    wire [9:0] chrAdr;
    // to find its bit pattern
    wire [7:0] char_data;

    // 32 real pixels for each 8 pixels
    assign bAdrs =  (scanx>>5) + ((scany[8:5])*20);
    // the bit patterns start at ascii 32, each character
    // is 8 bytes, every 4th scan line move to next line of data
    assign chrAdr = ((bData-32)<<3) + scany[4:2];

    // scanx is actually 1clk ahead of real X position
    // triggering on negedge to be ready for actual X position
    wire [9:0] scanx;
    wire [8:0] scany;

    // skw looks up the right bit for the current pixel
    wire [2:0] skw;
    assign skw = ((scanx-1)>>2);

    always @(posedge clk_pixel) begin
        if (~vga_blank) begin

            if (char_data[skw]) begin
                red <= 255;
                green <= 255;
                blue <= 255;
            end else begin
                red <= 0;
                green <= 0;
                blue <= 0;
            end

        end else begin // you're supposed to output black outside of active area
            red <= 0;
            green <= 0;
            blue <= 0;
        end

    end

endmodule
