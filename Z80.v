
module Z80(input clk_25mhz,
            output ftdi_rxd,
            input ftdi_txd,
            input [0:6] btn,
            output [7:0] led,
            output [3:0] gpdi_dp,
            output [3:0] gpdi_dn
            );

    // z80 pins
    wire nMREQ;
    wire nIORQ;
    wire nRD;
    wire nWR;

    wire [15:0] A;
    reg [7:0] D /* synthesis keep */;

    wire [7:0] RamData; // Data writer from the RAM module
    wire [7:0] CpuData;
    //assign CpuData = nRD==0 ? D[7:0] : {nIORQ,nRD,nWR}==3'b011 ? 8'h80 : {8{1'bz}};

    wire RamWE;
    assign RamWE = nIORQ==1 && nRD==1 && nWR==0;

    wire nHi;
    assign nHi = 1;

    reg nRESET;
    // when we first start hold restart for 8 clocks
    reg [4:0] rstCount = 0;



    always @(posedge clk_25mhz)
    begin
        if (rstCount<8) begin
            rstCount <= rstCount + 1;
            nRESET <= 1'b0;
        end else begin
            nRESET <= 1'b1;
        end

        if (! btn[0]) begin
            rstCount <= 0;
        end
    end

    always @(*) // always_comb
    begin
        case ({nIORQ,nRD,nWR})
            // -------------------------------- Memory read --------------------------------
            3'b101: D[7:0] = RamData;
            // -------------------------------- Memory write -------------------------------
            3'b110: D[7:0] = CpuData;
            /*
            // ---------------------------------- IO write ---------------------------------
            3'b010: D[7:0] = CpuData;
            // ---------------------------------- IO read ----------------------------------
            3'b001: D[7:0] = {7'b0000000, uart_busy};
            // IO read *** Interrupts test ***
            // This value will be pushed on the data bus on an IORQ access which
            // means that:
            // In IM0: this is the opcode of an instruction to execute, set it to 0xFF
            // In IM2: this is a vector, set it to 0x80 (to correspond to a test program Hello World)
            3'b011: D[7:0] = 8'h80;
            */

        default:
            D[7:0] = {8{1'bz}};
        endcase
    end


    tv80n z80 (
        .clk        (clk_25mhz),
        .reset_n    (nRESET),
        .iorq_n     (nIORQ),
        .mreq_n     (nMREQ),
        .rd_n       (nRD),
        .wr_n       (nWR),
        .A          (A),
        .do         (CpuData),
        .di         (D),
        .int_n      (nHi),
        .busrq_n    (nHi),
        .nmi_n      (nHi),
        .wait_n     (nHi)
  );

    ram #( .n(12))   memory(
        .addr       (A),
        .clk        (clk_25mhz),
        .we         (RamWE),
        .data_in    (CpuData),
        .btn_in     (btn),
        .data_out   (RamData) ,
        .ledo       (led),
        .ftdi_txd_o (ftdi_txd),
        .ftdi_rxd_o (ftdi_rxd),
        .gpdi_dn_o  (gpdi_dn),
        .gpdi_dp_o  (gpdi_dp)
    );

endmodule
