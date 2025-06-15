///////////////////////////////////////////
// AUTHER : Mahmoud Abdo
// Module : ram.sv
//
// Description : Slave Memery 
// Date : june 2025
///////////////////////////////////////////////////////
module ram (
    input  logic clk,
    input  logic rst_n,

    input  logic rx_valid,
    input  logic [9:0] din, 

    output logic [7:0] dout,
    output logic tx_valid
);

    // Memory array
    logic [7:0] mem [255:0];
    // Address registers
    logic [7:0] w_addr, r_addr;

    always@(posedge clk or negedge rst_n) begin
	tx_valid <= '0;
	dout <= '0;
			
        if (!rst_n) begin
            tx_valid <= '0;
            dout <= '0;
            w_addr <= '0;
            r_addr <= '0;
        end else if (rx_valid) begin
            case (din[9:8])
                2'b00: begin // Write command (set address)
                    w_addr <= din[7:0];
                    tx_valid <= 1'b0;
                end
                2'b01: begin // Write data
                    mem[w_addr] <= din[7:0]; 
                    tx_valid <= 1'b0;
                end
                2'b10: begin // Read command (set read address)
                    r_addr <= din[7:0];
                    tx_valid <= 1'b0;
                end
                2'b11: begin // Read data
                    dout <= mem[r_addr];
                    tx_valid <= 1'b1;
                end
				default : begin
					tx_valid <= '0;
					dout <= '0;
				end
            endcase
        end
    end
endmodule
