class spi_slave_base_seq extends uvm_sequence #(spi_transaction);
  `uvm_object_utils(spi_slave_base_seq)

  function new(string name = "spi_slave_base_seq");
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
endclass
//IN PHASE 1: DO NOT raise objections for slave sequences because master will control transaction 

class spi_slave_response_seq extends spi_slave_base_seq;
    `uvm_object_utils(spi_slave_response_seq)

    function new(string name = "spi_slave_response_seq");
        super.new(name);
    endfunction
spi_transaction req;
    virtual task body();
        `uvm_info(get_type_name(), "Executing SPI Slave Response Sequence", UVM_LOW)

        // Create a transaction
        
        req = spi_transaction::type_id::create("req");

        start_item(req);

        //random response data
       req.data_out = 8'b10101010;  

        finish_item(req);
`uvm_info(get_type_name(), $sformatf("Slave recevied data: %h", req.data_in), UVM_MEDIUM)
        `uvm_info(get_type_name(), $sformatf("Slave responded with data: %h", req.data_out), UVM_MEDIUM)
    endtask
endclass

class spi_slave_write_seq extends spi_slave_base_seq;
    `uvm_object_utils(spi_slave_write_seq)
   
    function new(string name = "spi_slave_write_seq");
        super.new(name);
    endfunction
     spi_transaction req;
    virtual task body();
        
        `uvm_info(get_type_name(), "Executing SPI Slave write Sequence", UVM_LOW)

        
         
      // send data back to master 
            req = spi_transaction::type_id::create("req");
            start_item(req);
       if (!req.randomize() with { req.data_in == 8'h2B; }) begin
            `uvm_error(get_type_name(), "Randomization failed")
        end
        `uvm_do(req)
         

            `uvm_info(get_type_name(), $sformatf("Slave received data: %h", req.data_in), UVM_MEDIUM)
        
    endtask
endclass