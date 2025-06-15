module SPI_Slave_tb() ;
logic clk,rst_n,ss_n;
logic MISO , MOSI ,valid_MISO ;
logic sready;

SPI_Slave DUT(.clk(clk),.ss_n(ss_n),.rst_n(rst_n),.MISO(MISO),.MOSI(MOSI),.valid_MISO(valid_MISO));


initial begin
    clk = 0;
    forever begin
       #1 clk =!clk;
    end
end
    // Main Test Sequence
    initial begin
        rst_n = 0;
        ss_n = 1;
		MOSI = 0;
        repeat(10)@(negedge clk);
        rst_n = 1;
        
		
        @(negedge clk);
        for(int j = 0 ; j < 1000 ; j++)begin
            // @(negedge clk);
            writ_add_data();    
        end

        @(negedge clk);
        ss_n = 1;

        for(int x = 0 ; x < 50 ; x++)begin
            // @(negedge clk);
            read_add_data();    
        end

        #100;
        $finish;
    end

reg [7:0] w_vector;
reg [7:0] r_vector;

//-------------------------
task writ_add_data ();
// w_vector =8'b01010101;
w_vector = $random;

    @(negedge clk);
    ss_n = 0;
    @(negedge clk);  // write address
    MOSI = '0;
    @(negedge clk);
    MOSI = '0;
    for(int i = 0 ; i < 8 ; i++)begin
        @(negedge clk);
        MOSI = w_vector[7-i];
    end


    @(negedge clk);
    ss_n = 1;
    repeat(40)@(clk);
	
    @(negedge clk);
    ss_n = 0;
    @(negedge clk);  // write data in the previous address
    MOSI = 0;
    @(negedge clk);
    MOSI = 1;
    for(int l = 0 ; l < 8 ; l++)begin
        @(negedge clk);
        MOSI = w_vector[7-l];
    end

    @(negedge clk);
    ss_n = 1;
    repeat(40)@(clk);
endtask //writ_data

//--------------------------------

task read_add_data ();
	// r_vector = 8'b01010101;
    r_vector = $random;
    @(negedge clk);
    ss_n = 0;

    @(negedge clk);  // read address
    MOSI = 1;
    @(negedge clk);
    MOSI ='0;
    for(int i = 0 ; i < 8 ; i++)begin
        @(negedge clk);
        MOSI = r_vector[7-i];
    end


    @(negedge clk);
    ss_n = 1;
	repeat(40)@(clk);

    @(negedge clk);
    ss_n = 0;

    // @(negedge clk);  // read address
    // MOSI = 1;
    @(negedge clk);  // read data from the previous address
    MOSI = 1;
    @(negedge clk);
    MOSI = 1;
    for(int l = 0 ; l < 8 ; l++)begin
        @(negedge clk);
        MOSI = r_vector[7-l];
    end

    @(negedge clk);
    ss_n = 1;
    repeat(2)@(clk);

endtask //writ_data
endmodule