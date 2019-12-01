module ram( input   clk,
            input   [15:0] addr,
            input   we,
            input   [7:0] data_in,
            input   [6:0] btn_in,
            output  [7:0] data_out,
            output  [7:0] ledo,
            output  ftdi_rxd_o,
            input   ftdi_txd_o,
            output  [3:0] gpdi_dp_o,
            output  [3:0] gpdi_dn_o
        );

    parameter n = 4;

    reg [7:0] r_led;
    assign ledo = r_led;

    reg [7:0] reg_array [2**n-1:0];

    initial $readmemh("ram.mem", reg_array);


    // uart is a memory mapped device so it is in the memory module
    wire [7:0] tx_out;
    wire [7:0] rx_in;
    wire send;

    reg [7:0] to_send;
    reg sent; initial sent = 1;

    uart uart1(
        .clk                (clk),
        .rx                 (ftdi_txd_o),
        .tx                 (ftdi_rxd_o),
        .transmit           (send),
        .tx_byte            (tx_out),
        .received           (rx_got),
        .rx_byte            (rx_in),
        .is_transmitting    (transmitting),
        .recv_error         (rx_error),
        .rst                (uart_reset)
    );

    reg uart_reset;

    dvi dvi1(
        .clk_25mhz(clk),
        .gpdi_dp(gpdi_dp_o),
        .gpdi_dn(gpdi_dn_o),
        .vidData(vidData),
        .vidAdrs(vidAdrs),
        .vidWE(vidWE)
    );

    //wire [7:0] vidData;
    //wire [8:0] vidAdrs;
    reg vidWE;
    reg [7:0] tx_out;
    reg send;
    reg [8:0] vidAdrs;
    reg [7:0] vidData;

    reg [7:0] data_out;

    reg [7:0] rxBuff [0:15];
    reg [3:0] rxTop=0;
    wire [7:0] rx_in;
    reg [7:0] rx_out;
    wire rx_got;
    wire rx_error;
    wire transmitting;


    always @(posedge clk) begin

        // ffff led address (can be read)
        // fffe uart send byte (write only)
        // fffd ptr top rx ring buffer
        // fffc hardware buttons (read only)
        // ffe0 -> ffef rx buffer
        // fd00 -> feff video ram each line 20x15

        vidWE <=0;
        if (we == 1) begin
            if (addr[15]) begin
                if (addr == 16'hffff) begin
                    r_led <= data_in;
                end
                if (addr == 16'hfffe) begin
                    to_send <= data_in;
                    tx_out <= data_in;
                    send <= 1;
                    sent <= 0;
                end
                if (addr >= 16'hfd00 && addr <= 16'hfeff) begin
                    vidWE <= 1;
                    vidAdrs <= addr-16'hfd00;
                    vidData <= data_in;
                end
            end else begin
                reg_array[addr] <= data_in;
            end
        end else begin
            if (addr[15]) begin
                if (addr == 16'hffff ) begin
                    data_out <= r_led;          // state of the led's
                end
                if (addr == 16'hfffe ) begin
                    data_out <= transmitting;  // read back of tx gives transmition status
                end
                if (addr == 16'hfffc ) begin
                    data_out <= btn_in & 8'b00111111;   // hardware buttons
                end

                if (addr == 16'hfffd ) begin
                    data_out <= rxTop;
                end

                //ffe0 -> ffef
                if (addr >= 16'hffe0 && addr <= 16'hffef) begin
                    data_out <= rxBuff[addr[3:0]];
                end
            // assume everything below 0x8000 is ram!
            end else begin
                data_out <= reg_array[addr];
            end
        end

        if (!sent) begin
            if (!transmitting) begin
                sent <= 1;
                send <= 1;
                tx_out <= to_send;
            end
        end

        if (transmitting) begin
            send <= 0;
        end

        if (rx_got && !rx_error) begin
            rxBuff[rxTop] <= rx_in;
            rxTop = rxTop + 1;
        end

        if (rx_error) begin
            uart_reset <= 1;
        end

        if (uart_reset) begin
            uart_reset <= 0;
        end

    end

endmodule
