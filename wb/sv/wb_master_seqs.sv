
class wb_base_seq extends uvm_sequence #(wb_transaction);

  // Required macro for sequences automation
  `uvm_object_utils(wb_base_seq)

  string phase_name;
  uvm_phase phaseh;
  wb_transaction tr;

  // Constructor
  function new(string name = "wb_base_seq");
    super.new(name);
    tr = wb_transaction::type_id::create("tr");

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

endclass : wb_base_seq



//####################################################################################
// I2c  sequences 
//#####################################################################################


//------------------------------------------------------------------------------
// SEQUENCE: set the mode of i2c core to 400khz (Fast mode)
//------------------------------------------------------------------------------

class i2c_400k_seq extends wb_base_seq;

  function new(string name = get_type_name());
    super.new(name);
  endfunction

  `uvm_object_utils(i2c_400k_seq)

  virtual task body();
    `uvm_info(get_type_name(), "Executing sequence", UVM_LOW)


#60 //waiting to WB reset to finish  

//  prescale the SCL clock
    `uvm_do_with(req,
                 { op_type == wb_write ; 
                   addr == 32'h40; //Clock Prescale register lo-byte 
                   din == 8'b0011_0001;  // (100M)/ (5*400K) -1 = 8'd49  ==> 0011_0001
                   valid_sb == 0;  //indicate to scoreboard that this is configuration command
                 })

    `uvm_do_with(req,
                 { op_type == wb_write ; 
                   addr == 32'h41; //Clock Prescale register HI-byte 
                   din == 8'b0000_0000;  // (100M)/ (5*400K) -1 = 16'd0049  ==> 00000_0000_0011_0001
                   valid_sb == 0;  //indicate to scoreboard that this is configuration command
                 })

    //enable i2c control register
    `uvm_do_with(req,
                 { op_type == wb_write ; 
                   addr == 32'h42; //i2c control register (ctr)
                   din == 8'b1000_0000;  //7:en i2c   6: en inte
                   valid_sb == 0;  ///indicate to scoreboard that this is configuration command
                 })


  endtask : body

endclass : i2c_400k_seq










//------------------------------------------------------------------------------
// SEQUENCE: i2c_write_byte_seq  this sequence write a single byte to test the intgration of wb & i2c 
//------------------------------------------------------------------------------

class i2c_write_byte_seq extends wb_base_seq;

  function new(string name = get_type_name());
    super.new(name);
  endfunction

  `uvm_object_utils(i2c_write_byte_seq)

  bit [6:0] slave_addr =7'b1010101 ;
  int count_polling = 0;

  virtual task body();
    `uvm_info(get_type_name(), "Executing sequence", UVM_LOW)


 // sendign heaeder byte 
     `uvm_do_with(req,
                 { op_type == wb_write ; 
                   addr == 32'h43; //i2c transmit register
                   din == {slave_addr,1'b0}; // 7-1: slave addr [1010101], 0: write
                   valid_sb == 0;  //indicate to scoreboard that this is configuration command
                 })
      `uvm_do_with(req,
                 { op_type == wb_write ; 
                   addr == 32'h44; //i2c command register
                   din == 8'b1001_0000; //sta & wr
                   valid_sb == 0;  //indicate to scoreboard that this is configuration command
                 })


/////////////
//polling for ACK && TIP 
////////////              
  
  // this  additional polling transaction is "necessary" to bypass the initial dout value of 8'b0000_0000
     `uvm_do_with(req,
                 { op_type == wb_read ; 
                   addr == 32'h44; //i2c status register
                   valid_sb == 0;  //indicate to scoreboard that this is configuration command
                 })
  count_polling =0;

  while(1) begin :polling
    count_polling++;
      `uvm_do_with(req,
                 { op_type == wb_read ; 
                   addr == 32'h44; //i2c status register
                   valid_sb == 0;  //indicate to scoreboard that this is configuration command
                 })

  if (!req.dout[7] && !req.dout[1]) begin // check for ACK && TIP both bits should be de-asserted
   break; // i2c finish transmiting 
  end
  else if (count_polling > 1_000_000) 
    `uvm_fatal (get_type_name(), "WB took too long to poll I2C");
  end 



 
// sending dumy data byte
       `uvm_do_with(req,
                 { op_type == wb_write ; 
                   addr == 32'h43; //i2c transmit register
                   din == 8'b1101_1101; // dumy data :DD
                   valid_sb == 0;  //indicate that it's a read sequence
                 })
      `uvm_do_with(req,
                 { op_type == wb_write ; 
                   addr == 32'h44; //i2c command register
                   din == 8'b0101_0000; //STO & WR
                   valid_sb == 0;  //indicate that it's a read sequence
                 })





//////////////////
//polling for STOP
/////////////////
   // this  additional polling transaction is "necessary" to bypass the initial dout value of 8'b0000_0000
     `uvm_do_with(req,
                 { op_type == wb_read ; 
                   addr == 32'h44; //i2c status register
                   valid_sb == 0;  //indicate to scoreboard that this is configuration command
                 })
  count_polling =0;

  while(1) begin 
    count_polling++;
      `uvm_do_with(req,
                 { op_type == wb_read ; 
                   addr == 32'h44; //i2c status register
                   valid_sb == 0;  //indicate to scoreboard that this is configuration command
                 })

  if (!req.dout[6]) begin // check for STOP &&  should be de-asserted
   break; // i2c finish transmiting 
  end
  else if (count_polling > 1_000_000) 
    `uvm_fatal (get_type_name(), "WB took too long to poll I2C");
  end 


    



  endtask : body



endclass : i2c_write_byte_seq



class i2c_read_byte_seq extends wb_base_seq;

  function new(string name = get_type_name());
    super.new(name);
  endfunction

  `uvm_object_utils(i2c_read_byte_seq)

  bit [6:0] slave_addr =7'b1010101 ;
  int count_polling = 0;

  virtual task body();
    `uvm_info(get_type_name(), "Executing sequence", UVM_LOW)


 // sendign heaeder byte 
     `uvm_do_with(req,
                 { op_type == wb_write ; 
                   addr == 32'h43; //i2c transmit register
                   din == {slave_addr,1'b1}; // 7-1: slave addr [1010101], 0: write
                   valid_sb == 0;  //indicate to scoreboard that this is configuration command
                 })
      `uvm_do_with(req,
                 { op_type == wb_write ; 
                   addr == 32'h44; //i2c command register
                   din == 8'b1001_0000; //sta & wr
                   valid_sb == 0;  //indicate to scoreboard that this is configuration command
                 })


/////////////
//polling for ACK && TIP 
////////////              
  
  // this  additional polling transaction is "necessary" to bypass the initial dout value of 8'b0000_0000
     `uvm_do_with(req,
                 { op_type == wb_read ; 
                   addr == 32'h44; //i2c status register
                   valid_sb == 0;  //indicate to scoreboard that this is configuration command
                 })
  count_polling =0;

  while(1) begin :polling
    count_polling++;
      `uvm_do_with(req,
                 { op_type == wb_read ; 
                   addr == 32'h44; //i2c status register
                   valid_sb == 0;  //indicate to scoreboard that this is configuration command
                 })

  if (!req.dout[7] && !req.dout[1]) begin // check for ACK && TIP both bits should be de-asserted
   break; // i2c finish transmiting 
  end
  else if (count_polling > 1_000_000) 
    `uvm_fatal (get_type_name(), "WB took too long to poll I2C");
  end 



 
      `uvm_do_with(req,
                 { op_type == wb_write ; 
                   addr == 32'h44; //i2c command register
                   din == 8'b0110_0000; //STO & RD
                   valid_sb == 0;  //indicate that it's a read sequence
                 })





//////////////////
//polling for STOP
/////////////////
   // this  additional polling transaction is "necessary" to bypass the initial dout value of 8'b0000_0000
     `uvm_do_with(req,
                 { op_type == wb_read ; 
                   addr == 32'h44; //i2c status register
                   valid_sb == 0;  //indicate to scoreboard that this is configuration command
                 })
  count_polling =0;

  while(1) begin 
    count_polling++;
      `uvm_do_with(req,
                 { op_type == wb_read ; 
                   addr == 32'h44; //i2c status register
                   valid_sb == 0;  //indicate to scoreboard that this is configuration command
                 })


  if (!req.dout[6] ) begin // check for STOP &&  should be de-asserted
   //$display("🥶 finsih");
  break; // i2c finish transmiting 
  end
  else if (count_polling > 1_000_000) 
    `uvm_fatal (get_type_name(), "WB took too long to poll I2C");
  end 


     `uvm_do_with(req,
    { op_type == wb_read ; 
                   addr == 32'h43; //i2c reciver register
                   din == 0; //i2c reciver register
                   valid_sb == 0;  //indicate to scoreboard that this is configuration command
                 })
    



  endtask : body



endclass : i2c_read_byte_seq






//####################################################################################
// SPI  sequences 
//#####################################################################################


//------------------------------------------------------------------------------
// SEQUENCE: wb_write_spi1_seq -  write byte to spi1 peripheral (addr 2 spi data register) then dumy read from data reg to empty the read fifo of the spi
//------------------------------------------------------------------------------

class wb_write_spi1_seq extends wb_base_seq ;

  function new(string name = get_type_name());
    super.new(name);
  endfunction

  `uvm_object_utils(wb_write_spi1_seq)

  virtual task body();
    `uvm_info(get_type_name(), "Executing sequence", UVM_LOW)

    
    
    `uvm_do_with(req,
                 { op_type == wb_write ; // we =1
                   addr == 0; // enable spi by setting the control register 
                   din==8'b01110000;  // 7:disable inta 6:en spi 5:reserved 4:set spi as master 3:S_polarity 2: S_phase  [1:0]: sclk=clk/2
                   valid_sb==0;// indecate write sequnnace

                   })


       
    `uvm_do_with(req,
                 { op_type == wb_write ; 
                   addr == 4;        //manually control CS singal through  register 4
                   din==8'b0000001;  // [0]:  1 to clear Cs     0 to set cs
                   valid_sb==0;// indecate write sequnnace

                   })
   
   
   
    `uvm_do_with(req,
                 { op_type == wb_write ; // write a random data to data register 
                   addr == 2;
                   valid_sb==1;// indecate write sequnnace

                   }
                )

      #160;      //stalling until spi send out the byte serially on mosi   
          
    `uvm_do_with(req,
                 { op_type == wb_write ; 
                   addr == 4; //manually control CS singal through  register 4
                   din==8'b0000000;  // [0]:  1 to clear Cs     0 to set cs
                   valid_sb==0;// indecate write sequnnace

                   })




    `uvm_do_with(req,
                 { op_type == wb_read ;
                   addr == 2;
                   valid_sb==0;// indecate write sequnnace
                   } //sending read requist to data reg to empty the garbge from read fifo
                )
   
   

//    `uvm_info(get_type_name(), $sformatf("wb WRITE ADDRESS:%0d  DATA:%h", req.addr, req.din), UVM_MEDIUM)

  endtask : body


endclass : wb_write_spi1_seq

//------------------------------------------------------------------------------
// SEQUENCE: wb_write_spi1_seq -  write byte to spi1 peripheral (addr 2 spi data register) then dumy read from data reg to empty the read fifo of the spi
//------------------------------------------------------------------------------



class wb_write_spi2_seq extends wb_base_seq;

  function new(string name = get_type_name());
    super.new(name);
  endfunction

  `uvm_object_utils(wb_write_spi2_seq)

  virtual task body();
    `uvm_info(get_type_name(), "Executing sequence", UVM_LOW)

    `uvm_do_with(req,
                 { op_type == wb_write;
                   addr == 16'h10; //SPI_2 control register base
                   din == 8'b01110000; // 7:disable inta 6:en spi 5:reserved 4:set spi as master 3:S_polarity 2: S_phase  [1:0]: sclk=clk/2
                   valid_sb == 0; //indecate write sequnnace
                 })

    `uvm_do_with(req,
                 { op_type == wb_write;
                   addr == 16'h14; //SPI_2 CS control register
                   din == 8'b00000001; // [0]:  1 to clear Cs     0 to set cs
                   valid_sb == 0; //indecate write sequnnace
                 })

    `uvm_do_with(req,
                 { op_type == wb_write;
                   addr == 16'h12; //SPI_2 data register
                   din == 8'b00011111; //dummy data 
                   valid_sb == 1; //indecate write sequnnace
                 })

    #160;

    `uvm_do_with(req,
                 { op_type == wb_write;
                   addr == 16'h14; //SPI_2 CS control register
                   din == 8'b00000000; // [0]:  1 to clear Cs     0 to set cs
                   valid_sb == 0; //indecate write sequnnace
                 })

    `uvm_do_with(req,
                 { op_type == wb_read;
                   addr == 16'h12; 
                   valid_sb == 0; //indecate write sequnnace
                 })

  endtask : body

endclass : wb_write_spi2_seq




//------------------------------------------------------------------------------
// SEQUENCE: wb_read_spi1_seq -  sendying  a dumy write then  send read byte read from spi1 peripheral (addr 3)
//------------------------------------------------------------------------------
class wb_read_spi1_seq extends wb_base_seq;

      function new(string name = get_type_name());
        super.new(name);
      endfunction

      `uvm_object_utils(wb_read_spi1_seq)

      virtual task body();
        `uvm_info(get_type_name(), "Executing sequence", UVM_LOW)

        `uvm_do_with(req,
                    { op_type == wb_write ; // we =1
                      addr == 0; // enable spi by setting the control register 
                      din==8'b01110000;  // 7:disable inta 6:en spi 5:reserved 4:set spi as master 3:S_polarity 2: S_phase  [1:0]: sclk=clk/2
                     valid_sb==0;// indecate read sequnnace
                      })



        `uvm_do_with(req,
                    { op_type == wb_write ; 
                      addr == 4;        //manually control CS singal through  register 4
                      din==8'b0000001;  // [0]:  1 to clear Cs     0 to set cs
                      valid_sb==0;// indecate read sequnnace
                      })



            `uvm_do_with(req,
                    { op_type == wb_write ; // damy write to data register 
                      addr == 2;
                      din==8'b000000;
                      valid_sb==0;// indecate read sequnnace
                      })

        #160;  //stalling until spi send out the byte serially on mosi   

        `uvm_do_with(req, 
                    { op_type == wb_write ; 
                      addr == 4; //manually control CS singal through  register 4
                      din==8'b0000000;  // [0]:  1 to clear Cs     0 to set cs
                      valid_sb==0;// indecate read sequnnace
                      })




        `uvm_do_with(req,
                    { op_type == wb_read ;
                      addr == 2;
                      din==8'b00000111;
                      valid_sb==1;// indecate read sequnnace
                      } //read requist to collect the data from spi read fifo
    )


  endtask : body


endclass : wb_read_spi1_seq



//------------------------------------------------------------------------------
// SEQUENCE: wb_read_spi1_seq -  sendying  a dumy write then  send read byte read from spi1 peripheral (addr 3)
//------------------------------------------------------------------------------

class wb_read_spi2_seq extends wb_base_seq;

  function new(string name = get_type_name());
    super.new(name);
  endfunction

  `uvm_object_utils(wb_read_spi2_seq)

  virtual task body();
    `uvm_info(get_type_name(), "Executing sequence", UVM_LOW)

    //enable SPI control register
    `uvm_do_with(req,
                 { op_type == wb_write ; 
                   addr == 16; //SPI_2 control register
                   din == 8'b01110000;  //7:disable inta 6:en spi 5:reserved 4:set spi as master 3:S_polarity 2: S_phase  [1:0]: sclk=clk/2
                   valid_sb == 0;  //indicate that it's a read sequence
                 })

    //control CS signal
    `uvm_do_with(req,
                 { op_type == wb_write ; 
                   addr == 20;  //SPI_2 Chip Select register
                   din == 8'b0000001;  //[0]:  1 to clear Cs     0 to set cs
                   valid_sb == 0; //indicate read sequence
                 })

    //to clear FIFO
    `uvm_do_with(req,
                 { op_type == wb_write ; 
                   addr == 18; //SPI_2 data register
                   din == 8'b000000;
                   valid_sb == 0; //indicate read sequence
                 })

    #160; 

    //disable CS signal
    `uvm_do_with(req,
                 { op_type == wb_write ; 
                   addr == 20;  //SPI_2 Chip Select register
                   din == 8'b0000000;  // [0]:  1 to clear Cs     0 to set cs
                   valid_sb == 0;  //indicate read sequence
                 })

    //read data from SPI_2 data register
    `uvm_do_with(req,
                 { op_type == wb_read ;
                   addr == 18;  // SPI_2 data register
                   valid_sb == 1; //indicate read sequence
                 })
  endtask : body

endclass : wb_read_spi2_seq



