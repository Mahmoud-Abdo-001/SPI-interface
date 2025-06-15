class wrapper_config_obj extends uvm_object;
    `uvm_object_utils(wrapper_config_obj)

    virtual wrapper_if wif;

    //constructor 
    function new(string name ="wrapper_config_obj");
        super.new(name);
    endfunction

endclass