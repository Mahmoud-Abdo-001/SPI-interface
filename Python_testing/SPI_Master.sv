///////////////////////////////////////////////////////
// AUTHOR   : Mahmoud Abdo
// MODULE   : SPI_Master
// FUNCTION : Optimized SPI Master (10-bit write / 8-bit read)
// DATE     : June 2025
///////////////////////////////////////////////////////

module SPI_Master (
    input  wire        clk,
    input  wire        rst_n,
    output wire        sclk,

    // Interface to User/Controller
    input  wire        start,
    input  wire [9:0]  data_in,
    output reg  [7:0]  data_out,
    output reg         busy,
    output reg         done,

    // Interface to SPI Slave
    output reg         MOSI,
    output reg         ss_n,
    input  wire        MISO,
    input  wire        valid_MISO,
    input  wire        sready
);

    // State encoding
    localparam IDLE         = 3'd0;
    localparam WAIT_SREADY  = 3'd1;
    localparam ASSERT_SS    = 3'd2;
    localparam SEND_MOSI    = 3'd3;
    localparam RECV_MISO    = 3'd4;
    localparam FINISH       = 3'd5;

    reg [2:0] cs, ns;

    // Internal registers
    reg [9:0] mosi_shift_reg;
    reg [7:0] miso_shift_reg;
    reg [3:0] bit_cnt;
    reg       is_read;
    reg       start_d;
    wire      start_edge;

    assign sclk = clk;
    assign start_edge = start & ~start_d;

    // Rising edge detection
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            start_d <= 1'b0;
        else
            start_d <= start;
    end

    // FSM state register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cs <= IDLE;
        else
            cs <= ns;
    end

    // FSM next state logic
    always @(*) begin
        ns = cs;
        case (cs)
            IDLE:
                if (start_edge)
                    ns = WAIT_SREADY;
            WAIT_SREADY:
                if (sready)
                    ns = ASSERT_SS;
            ASSERT_SS:
                ns = SEND_MOSI;
            SEND_MOSI:
                if (bit_cnt == 0)
                    ns = is_read ? RECV_MISO : FINISH;
            RECV_MISO:
                if (bit_cnt == 0 && valid_MISO)
                    ns = FINISH;
            FINISH:
                ns = IDLE;
            default:
                ns = IDLE;
        endcase
    end

    // Sequential logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ss_n           <= 1'b1;
            MOSI           <= 1'b0;
            bit_cnt        <= 4'd0;
            mosi_shift_reg <= 10'd0;
            miso_shift_reg <= 8'd0;
            data_out       <= 8'd0;
            is_read        <= 1'b0;
            busy           <= 1'b0;
            done           <= 1'b0;
        end else begin
            done <= 1'b0; // default, 1-cycle pulse

            case (cs)
                IDLE: begin
                    ss_n <= 1'b1;
                    busy <= 1'b0;
                    if (start_edge) begin
                        mosi_shift_reg <= data_in;
                        if (data_in[9:8] == 2'b11)
                            is_read <= 1'b1;
                        else
                            is_read <= 1'b0;
                    end
                end

                WAIT_SREADY: begin
                    ss_n <= 1'b1;
                    busy <= 1'b1;
                end

                ASSERT_SS: begin
                    ss_n <= 1'b0;
                    bit_cnt <= 4'd9;
                    busy <= 1'b1;
                end

                SEND_MOSI: begin
                    MOSI <= mosi_shift_reg[9];
                    mosi_shift_reg <= {mosi_shift_reg[8:0], 1'b0}; // shift left
                    if (bit_cnt != 0)
                        bit_cnt <= bit_cnt - 1;
                    else if (is_read)
                        bit_cnt <= 4'd7;
                end

                RECV_MISO: begin
                    if (valid_MISO) begin
                        miso_shift_reg <= {miso_shift_reg[6:0], MISO};
                        if (bit_cnt != 0)
                            bit_cnt <= bit_cnt - 1;
                        else
                            data_out <= {miso_shift_reg[6:0], MISO};
                    end
                end

                FINISH: begin
                    ss_n <= 1'b1;
                    busy <= 1'b0;
                    done <= 1'b1;
                end
            endcase
        end
    end

endmodule
