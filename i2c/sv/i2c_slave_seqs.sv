
class slave_base_seq extends uvm_sequence #(i2c_transaction);

  // Required macro for sequences automation
  `uvm_object_utils(slave_base_seq)

  string phase_name;
  uvm_phase phaseh;

  // Constructor
  function new(string name = "slave_base_seq");
    super.new(name);
  endfunction


  task pre_body();
    uvm_phase phase;
`ifdef UVM_VERSION_1_2
    // in UVM1.2, get starting phase from method
    phase = get_starting_phase();
`else
    phase = starting_phase;
`endif
    if (phase != null) begin
      phase.raise_objection(this, get_type_name());
      `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
    end
  endtask : pre_body


  task post_body();
    uvm_phase phase;
`ifdef UVM_VERSION_1_2
    // in UVM1.2, get starting phase from method
    phase = get_starting_phase();
`else
    phase = starting_phase;
`endif
    if (phase != null) begin
      phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
    end
  endtask : post_body

endclass : slave_base_seq





//------------------------------------------------------------------------------
// SEQUENCE: this sequence will make the uvc act as i2c slave to rsponse to i2c master  
//------------------------------------------------------------------------------
class i2c_slave_seq extends slave_base_seq;

  function new(string name = get_type_name());
    super.new(name);
  endfunction

  `uvm_object_utils(i2c_slave_seq)

  virtual task body();
    `uvm_info(get_type_name(), "Executing sequence", UVM_LOW)
    `uvm_do(req)
    `uvm_info(get_type_name(), $sformatf("i2c slave tr ::  dout(dumy data to be sent to master 'if needed'): %h", req.dout), UVM_MEDIUM)

  endtask : body


endclass : i2c_slave_seq

