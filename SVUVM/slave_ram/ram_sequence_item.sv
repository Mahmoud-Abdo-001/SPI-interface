class ram_sequence_item extends uvm_sequence_item;
    bit rx_valid;
    bit [9:0] din;
    bit tx_valid;
    bit [7:0] dout;
    bit rst_n;

    // typedef enum {WRITE_ADDR, WRITE_DATA, READ_ADDR, READ_DATA} op_t;
    // rand op_t op;

    // rand bit [7:0] addr;
    // rand bit [7:0] data;

    // constraint op_distribution {
    //     // Favor write phases more than read
    //     op dist {
    //         WRITE_ADDR := 45,
    //         WRITE_DATA := 45,
    //         READ_ADDR  := 5,
    //         READ_DATA  := 5
    //     };
    // }

    // constraint encode_din {
    //     // Encodes the operation into din
    //     din[9:8] == (op == WRITE_ADDR) ? 2'b00 :
    //                 (op == WRITE_DATA) ? 2'b01 :
    //                 (op == READ_ADDR)  ? 2'b10 :
    //                 2'b11;
    //     din[7:0] == (op inside {WRITE_ADDR, READ_ADDR}) ? addr :
    //                 (op == WRITE_DATA) ? data : 8'd0;
    // }

    function new(string name = "ram_sequence_item");
        super.new(name);
    endfunction

    // `uvm_object_utils(ram_sequence_item)
    `uvm_object_utils_begin(ram_sequence_item)
        `uvm_field_int(rst_n , UVM_ALL_ON)
        `uvm_field_int(rx_valid , UVM_ALL_ON)
        `uvm_field_int(din , UVM_ALL_ON)
        `uvm_field_int(tx_valid , UVM_ALL_ON)
        `uvm_field_int(dout , UVM_ALL_ON)
    `uvm_object_utils_end


    // function string convert2string();
    //     return $sformatf(
    //         "%s rst_n = 0b%0b , rx_valid = 0b%0b , din = 0b%010b , dout = 0b%08b , tx_valid = 0b%0b",
    //         super.convert2string(), rst_n, rx_valid, din, dout, tx_valid
    //     );
    // endfunction


    // function string convert2string_stimulus();
    //     return $sformatf(
    //         "%s rst_n = 0b%0b , rx_valid = 0b%0b , din = 0b%010b",
    //         super.convert2string(), rst_n, rx_valid, din
    //     );
    // endfunction

endclass

