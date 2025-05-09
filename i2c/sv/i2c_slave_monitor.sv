class i2c_slave_monitor extends uvm_monitor;

  
  virtual i2c_if vif;

  // slave Id
  int slave_id;

  // This port is used to connect the monitor to the scoreboard
  uvm_analysis_port #(i2c_transaction) item_collected_port;

//declare a transaction
  i2c_transaction tr_collect;



  `uvm_component_utils_begin(i2c_slave_monitor)
  `uvm_field_int(slave_id, UVM_ALL_ON)
  `uvm_component_utils_end


  function new (string name, uvm_component parent);
    super.new(name, parent);
  item_collected_port = new("item_collected_port", this);
  endfunction : new


  
  function void build_phase(uvm_phase phase);
    if (!i2c_vif_config::get(this, get_full_name(),"vif", vif))
      `uvm_error(get_type_name(),{"virtual interface must be set for: ",get_full_name(),".vif"})
  endfunction: build_phase




  virtual task run_phase(uvm_phase phase);

    forever begin 
    tr_collect = i2c_transaction::type_id::create("tr_collect");

    collect();

    `uvm_info(get_type_name(), $sformatf("🧬🧬transaction collected :\n%s",tr_collect.sprint()), UVM_LOW)
   // item_collected_port.write(tr_collect);
     end
  endtask : run_phase




//this task should rebuild the transaction from the interface 
task collect();

//start condtion
@(negedge vif.sda iff  vif.scl);  

//read hedear byte (7bit addr + w/r bit)
foreach (tr_collect.addr[i]) begin
  @(posedge vif.scl);
  tr_collect.addr[i] =vif.sda;
end 
@(posedge vif.scl); //skip ack bit 

//read data byte 
if (!tr_collect.addr[0]) begin // master write 
    foreach (tr_collect.din[i]) begin
      @(posedge vif.scl);
      tr_collect.din[i] =vif.sda;
    end 
end else begin 
    foreach (tr_collect.dout[i]) begin
      @(posedge vif.scl);
      tr_collect.dout[i] =vif.sda;
    end 
end
@(posedge vif.scl); //skip ack bit 

endtask:collect


endclass : i2c_slave_monitor
