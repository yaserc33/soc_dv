class i2c_transaction extends uvm_sequence_item;     
  
  bit [7:0] addr;          // addr[7:1]+ W/R[0]   byte comming  from wb 
  bit [7:0] din;           // data                byte comming  from wb
  rand bit [7:0] dout;     // data                byte going    to wb from the slave 


// Enable automation of the packet's fields
        `uvm_object_utils_begin(i2c_transaction)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(din, UVM_ALL_ON)
        `uvm_field_int(dout, UVM_ALL_ON)
        `uvm_object_utils_end



  function new (string name = "i2c_transaction");
    super.new(name);
  endfunction : new



  //function void post_randomize();
  
  
  //endfunction :post_randomize




endclass : i2c_transaction