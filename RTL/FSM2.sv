///////////////////////////////////////////
// AUTHER : Mahmoud Abdo
// Module : FSM2.sv
//
// Description : SPI Slave Fsm 
// Date : june 2025
///////////////////////////////////////////////////////
module FSM2 (
    input  logic        clk, rst_n,
    input  logic        ss_n,
    input  logic        MOSI,
    input  logic        tx_valid,
    input  logic [7:0]  tx_data,
    output logic        sready,
    output logic        rx_valid,
    output logic [9:0]  rx_data,
    output logic        valid_MISO,
    output logic        MISO
);

    typedef enum logic [2:0] {
        IDLE, CHK_CMD, WRITE, READ_ADDR, READ_DATA
    } state_t;

    state_t cs, ns;
    logic read_flag, read_done;
    logic [9:0] mosi_cap;
    logic [3:0] counter_rx;
    logic [2:0] counter_tx;
    logic [7:0] tx_data_reg;
    logic rx_ready;

    //==================== State Register ====================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cs <= IDLE;
        else
            cs <= ns;
    end

    //==================== Next-State Logic ====================
    always_comb begin
        ns = cs;
        unique case (cs)
            IDLE:      ns = (~ss_n) ? CHK_CMD : IDLE;
            CHK_CMD:   ns = (!ss_n) ? ((!MOSI) ? WRITE : (read_flag ? READ_DATA : READ_ADDR)) : CHK_CMD;
            WRITE:     ns = (ss_n) ? IDLE : WRITE;
            READ_ADDR: ns = (ss_n) ? IDLE : READ_ADDR;
            READ_DATA: ns = (ss_n) ? IDLE : READ_DATA;
            default:   ns = IDLE;
        endcase
    end

    //==================== RX Capture and Control ====================
    always_ff @(posedge clk or negedge rst_n) begin
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
            sready <= (ss_n | (cs == IDLE));  // High if idle or deselected

            rx_valid <= rx_ready;
            if (rx_ready)
                rx_data <= mosi_cap;

            rx_ready <= 1'b0; // default

            if (~ss_n) begin
                unique case (cs)
                    CHK_CMD: begin
                        mosi_cap[9] <= MOSI;
                        counter_rx  <= 4'd8;
                    end

                    WRITE: begin
                        mosi_cap[counter_rx] <= MOSI;
                        if (counter_rx == 0) begin
                            rx_ready   <= 1'b1;
                            counter_rx <= 4'd9;
                        end else begin
                            counter_rx <= counter_rx - 1;
                        end
                    end

                    READ_ADDR: begin
                        mosi_cap[counter_rx] <= MOSI;
                        if (counter_rx == 0) begin
                            rx_ready   <= 1'b1;
                            counter_rx <= 4'd9;
                            read_flag  <= 1'b1;
                            read_done  <= 1'b0;
                        end else begin
                            counter_rx <= counter_rx - 1;
                        end
                    end

                    READ_DATA: begin
                        if (!read_done) begin
                            mosi_cap[counter_rx] <= MOSI;
                            if (counter_rx == 0) begin
                                rx_ready   <= 1'b1;
                                counter_rx <= 4'd9;
                                read_flag  <= 1'b0;
                                read_done  <= 1'b1;
                            end else begin
                                counter_rx <= counter_rx - 1;
                            end
                        end
                    end

                    default: ; // safe default
                endcase
            end else begin
                counter_rx <= 4'd9;
                read_done  <= 1'b0; // reset on deselect
            end
        end
    end

    //==================== TX (MISO Handling) ====================
    always_ff @(posedge clk or negedge rst_n) begin
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
                tx_data_reg <= tx_data_reg << 1;
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
