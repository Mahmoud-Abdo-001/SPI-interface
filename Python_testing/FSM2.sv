///////////////////////////////////////////////////////
// AUTHOR   : Mahmoud Abdo
// MODULE   : FSM2
// FUNCTION : SPI Slave FSM
// DATE     : June 2025
///////////////////////////////////////////////////////

module FSM2 (
    input        clk,
    input        rst_n,
    input        ss_n,
    input        MOSI,
    input        tx_valid,
    input  [7:0] tx_data,
    output reg   sready,
    output reg   rx_valid,
    output reg [9:0] rx_data,
    output reg   valid_MISO,
    output reg   MISO
);

    // State encoding
    parameter IDLE = 3'd0,
              CHK_CMD = 3'd1,
              WRITE = 3'd2,
              READ_ADDR = 3'd3,
              READ_DATA = 3'd4;

    reg [2:0] cs, ns;
    reg read_flag, read_done;
    reg [9:0] mosi_cap;
    reg [3:0] counter_rx;
    reg [2:0] counter_tx;
    reg [7:0] tx_data_reg;
    reg rx_ready;

    //==================== State Register ====================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cs <= IDLE;
        else
            cs <= ns;
    end

    //==================== Next-State Logic ====================
    always @(*) begin
        ns = cs;
        case (cs)
            IDLE:
                if (~ss_n)
                    ns = CHK_CMD;
            CHK_CMD:
                if (!ss_n) begin
                    if (!MOSI)
                        ns = WRITE;
                    else if (read_flag)
                        ns = READ_DATA;
                    else
                        ns = READ_ADDR;
                end
            WRITE:
                if (ss_n)
                    ns = IDLE;
            READ_ADDR:
                if (ss_n)
                    ns = IDLE;
            READ_DATA:
                if (ss_n)
                    ns = IDLE;
            default:
                ns = IDLE;
        endcase
    end

    //==================== RX Capture and Control ====================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sready      <= 1'b1;
            rx_valid    <= 1'b0;
            rx_data     <= 10'd0;
            mosi_cap    <= 10'd0;
            counter_rx  <= 4'd9;
            read_flag   <= 1'b0;
            read_done   <= 1'b0;
            rx_ready    <= 1'b0;
        end else begin
            sready <= ss_n | (cs == IDLE);

            rx_valid <= rx_ready;
            if (rx_ready)
                rx_data <= mosi_cap;

            rx_ready <= 1'b0; // default

            if (~ss_n) begin
                case (cs)
                    CHK_CMD: begin
                        mosi_cap[9] <= MOSI;
                        counter_rx <= 4'd8;
                    end

                    WRITE: begin
                        mosi_cap[counter_rx] <= MOSI;
                        if (counter_rx == 0) begin
                            rx_ready <= 1'b1;
                            counter_rx <= 4'd9;
                        end else begin
                            counter_rx <= counter_rx - 1;
                        end
                    end

                    READ_ADDR: begin
                        mosi_cap[counter_rx] <= MOSI;
                        if (counter_rx == 0) begin
                            rx_ready <= 1'b1;
                            counter_rx <= 4'd9;
                            read_flag <= 1'b1;
                            read_done <= 1'b0;
                        end else begin
                            counter_rx <= counter_rx - 1;
                        end
                    end

                    READ_DATA: begin
                        if (!read_done) begin
                            mosi_cap[counter_rx] <= MOSI;
                            if (counter_rx == 0) begin
                                rx_ready <= 1'b1;
                                counter_rx <= 4'd9;
                                read_flag <= 1'b0;
                                read_done <= 1'b1;
                            end else begin
                                counter_rx <= counter_rx - 1;
                            end
                        end
                    end

                    default: ;
                endcase
            end else begin
                counter_rx <= 4'd9;
                read_done <= 1'b0;
            end
        end
    end

    //==================== TX (MISO Handling) ====================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_MISO  <= 1'b0;
            tx_data_reg <= 8'd0;
            counter_tx  <= 3'd7;
            MISO        <= 1'b0;
        end else begin
            if (tx_valid && !valid_MISO && ~ss_n) begin
                tx_data_reg <= tx_data;
                counter_tx  <= 3'd7;
                MISO        <= tx_data[7];
                valid_MISO  <= 1'b1;
            end else if (valid_MISO) begin
                MISO        <= tx_data_reg[6];
                tx_data_reg <= {tx_data_reg[6:0], 1'b0};  // left shift
                if (counter_tx == 0)
                    valid_MISO <= 1'b0;
                else
                    counter_tx <= counter_tx - 1;
            end else begin
                MISO <= 1'b0;
            end
        end
    end

endmodule
