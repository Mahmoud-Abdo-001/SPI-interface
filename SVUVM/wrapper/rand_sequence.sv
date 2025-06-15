class rand_sequence extends uvm_sequence #(wrapper_seq_item);
  `uvm_object_utils(rand_sequence)

  function new(string name = "rand_sequence");
    super.new(name);
  endfunction

  // task body();
  //   wrapper_seq_item tr;
  //   bit [1:0] pattern = 2'b00;

  //   repeat (10000) begin
  //     tr = wrapper_seq_item::type_id::create("tr");

  //     // Randomize lower 8 bits (bits 7:0)
  //     assert(tr.randomize() with {
  //       data_in[7:0] inside {[0:255]};
  //       start == 1;
  //     });
  //     // Set upper 2 bits in rotating pattern
  //     tr.data_in[9:8] = pattern;
      
  //     start_item(tr);
  //     finish_item(tr);
  //     pattern = pattern + 1;
  //   end
  // endtask

//   task body();
//   wrapper_seq_item tr;

//   //==================== write operations ===========================
//   // First pattern: alternate between 2'b00 and 2'b01   
//   repeat (5000) begin
//     foreach (int i [0:1]) begin
//       tr = wrapper_seq_item::type_id::create("tr");

//       assert(tr.randomize() with {
//         data_in[7:0] inside {[0:255]};
//         start == 1;
//       });

//       tr.data_in[9:8] = i;  // i will be 0, then 1
//       start_item(tr);
//       finish_item(tr);
//     end
//   end


//   //====================== read operations ========================
//   // Second pattern: alternate between 2'b10 and 2'b11
//   repeat (5000) begin
//     foreach (int i [2:3]) begin
//       tr = wrapper_seq_item::type_id::create("tr");

//       assert(tr.randomize() with {
//         data_in[7:0] inside {[0:255]};
//         start == 1;
//       });

//       tr.data_in[9:8] = i;  // i will be 2, then 3 (i.e., 2'b10 and 2'b11)
//       start_item(tr);
//       finish_item(tr);
//     end
//   end
// endtask


task body();
  wrapper_seq_item tr;

  // First pattern: alternate between 2'b00 and 2'b01
  repeat (15000) begin
    for (int i = 0; i <= 1; i++) begin
      tr = wrapper_seq_item::type_id::create("tr");

      assert(tr.randomize() with {
        data_in[7:0] inside {[0:255]};
        start == 1;
      });

      tr.data_in[9:8] = i[1:0];  // i = 0 or 1
      start_item(tr);
      finish_item(tr);
    end
  end

  // Second pattern: alternate between 2'b10 and 2'b11
  repeat (10000) begin
    for (int i = 2; i <= 3; i++) begin
      tr = wrapper_seq_item::type_id::create("tr");

      assert(tr.randomize() with {
        data_in[7:0] inside {[0:255]};
        start == 1;
      });

      tr.data_in[9:8] = i[1:0];  // i = 2 or 3 → 2'b10 or 2'b11
      start_item(tr);
      finish_item(tr);
    end
  end
endtask


endclass
