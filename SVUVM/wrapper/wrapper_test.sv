class wrapper_test extends uvm_test;
`uvm_component_utils(wrapper_test);

wrapper_environment env;

wrapper_config_obj w_cfg;
virtual wrapper_if ram_vif;
// ram_rst_seq rst_ram;
rand_sequence rand_seq;

    function new(string name="wrapper_test",uvm_component parent = null);
        super.new(name,parent);
    endfunction //new()

        // build both environmnet, Sequences and configuration objects 
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env  = wrapper_environment::type_id::create("env", this);
            w_cfg = wrapper_config_obj::type_id::create("w_cfg");

            // sequences 
            rand_seq = rand_sequence::type_id::create("rand_seq", this);

            //getting the real interface and assign it to the virtual one in the configuration object
            if (!uvm_config_db #(virtual wrapper_if)::get(this,"","wrapperV", w_cfg.wif))
                `uvm_fatal("build_phase", "test unable");

            // setting the entire object to be visible by all under the ram_test umbrella
            uvm_config_db #(wrapper_config_obj)::set(this,"*","CFG", w_cfg);
        endfunction


        // run phase
        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            phase.raise_objection(this); // incerement static var.
            // main sequence
            `uvm_info("run_phase", "main random sequences asserted", UVM_MEDIUM)
                rand_seq.start(env.w_agt.sqr);
            `uvm_info("run_phase", "main random sequence dasserted", UVM_LOW)
            phase.drop_objection(this); // decrement static var.
        endtask
endclass //ram_test 