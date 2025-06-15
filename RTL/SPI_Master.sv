///////////////////////////////////////////
// AUTHOR : Mahmoud Abdo
// Module : SPI_Master.sv
// Description : Optimized SPI Master (10-bit write / 8-bit read)
// Date : June 2025
///////////////////////////////////////////////////////
module SPI_Master (
    input  logic clk,
    input  logic rst_n,
    output logic sclk,

    // Interface to User/Controller
    input  logic start,          
    input  logic [9:0] data_in,  
    output logic [7:0] data_out, 
    output logic busy,          
    output logic done,          

    // Interface to SPI Slave
    output logic MOSI,
    output logic ss_n,
    input  logic MISO,
    input  logic valid_MISO,
    input  logic sready
);

    typedef enum logic [2:0] {
        IDLE, WAIT_SREADY, ASSERT_SS,
        SEND_MOSI, RECV_MISO, FINISH
    } state_t;

    state_t cs, ns;

    // Internal signals
    logic [9:0] mosi_shift_reg;
    logic [7:0] miso_shift_reg;
    logic [3:0] bit_cnt;
    logic       is_read;
    logic       start_edge;

    // Clock is forwarded as sclk
    assign sclk = clk;

    // Rising edge detector for start signal
    logic start_d;
    always_ff @(posedge clk or negedge rst_n)
        if (!rst_n)
            start_d <= 0;
        else
            start_d <= start;
    assign start_edge = start & ~start_d;

    // FSM state register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cs <= IDLE;
        else
            cs <= ns;
    end

    // FSM next state logic
    always_comb begin
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
                    ns = (is_read ? RECV_MISO : FINISH);

            RECV_MISO:
                if (bit_cnt == 0 && valid_MISO)
                    ns = FINISH;

            FINISH:
                ns = IDLE;

            default:
                ns = IDLE;
        endcase
    end

    // Outputs and registers update
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ss_n           <= 1;
            MOSI           <= 0;
            bit_cnt        <= 0;
            mosi_shift_reg <= 0;
            miso_shift_reg <= 0;
            data_out       <= 0;
            is_read        <= 0;
            busy           <= 0;
            done           <= 0;
        end else begin
            done <= 0; // Default, pulse for 1 cycle only

            case (cs)
                IDLE: begin
                    ss_n <= 1;
                    busy <= 0;
                    if (start_edge) begin
                        mosi_shift_reg <= data_in;
                        is_read <= (data_in[9:8] == 2'b11);
                    end
                end

                WAIT_SREADY: begin
                    ss_n <= 1;
                    busy <= 1;
                end

                ASSERT_SS: begin
                    ss_n <= 0;
                    bit_cnt <= 9; // For 10-bit transfer
                    busy <= 1;
                end

                SEND_MOSI: begin
                    MOSI <= mosi_shift_reg[9];
                    mosi_shift_reg <= mosi_shift_reg << 1;
                    if (bit_cnt != 0)
                        bit_cnt <= bit_cnt - 1;
                    else if (is_read)
                        bit_cnt <= 7; // For 8-bit read
                end

                RECV_MISO: begin
                    if (valid_MISO) begin
                        miso_shift_reg <= {miso_shift_reg[6:0], MISO};
                        if (bit_cnt != 0)
                            bit_cnt <= bit_cnt - 1;
                        else
                            data_out <= {miso_shift_reg[6:0], MISO}; // Final bit
                    end
                end

                FINISH: begin
                    ss_n <= 1;
                    busy <= 0;
                    done <= 1;
                end
            endcase
        end
    end

endmodule





