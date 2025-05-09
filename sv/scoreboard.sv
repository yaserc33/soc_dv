class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)



  ////////////////declaring the analysis port//////////////////
  `uvm_analysis_imp_decl(_wb)
  `uvm_analysis_imp_decl(_i2c)
  `uvm_analysis_imp_decl(_spi)


    uvm_analysis_imp_wb#(wb_transaction, scoreboard) 
    uvm_analysis_imp_spi#(i2c_transaction, scoreboard) 
    uvm_analysis_imp_spi#(spi_transaction, scoreboard) 
  
////////////////////////////////////////////////////////////////////

    // Counters for analysis
    int total_packets_received=0;
    int total_matched_packets=0;
    int total_wrong_packets=0;
    int total_spi_transactions=0;
    int total_wb_transactions=0; 
    int err;



    // Scoreboard Data Structures
    spi_transaction spi_queue[$];  
    wb_transaction wb_queue[$];   



    function new(string name= "scoreboard" , uvm_component parent);
        super.new(name,  parent);

    wb_imp=new("wb_imp", this);
    i2c_imp=new("i2c_imp", this);
    spi_imp=new("spi_imp", this);


    endfunction :new



     // Transaction Capturing - SPI
    function void write_spi(spi_transaction t);
        `uvm_info("SCOREBOARD", $sformatf("Received SPI Transaction: %s", t.sprint()), UVM_MEDIUM)
        spi_queue.push_back(t);
          total_spi_transactions++;
        total_packets_received++;
        compare_transactions();
    endfunction

    // Transaction Capturing - WB
    function void write_wb(wb_transaction t);
       
        // Ignore WB dummy writes or reads
        if (t.valid_sb == 1'b1) begin
        //     `uvm_info("SCOREBOARD", "Ignoring WB Dummy Write for Read Transaction", UVM_LOW)
        //     return;
        // end
        // else begin 
        `uvm_info("SCOREBOARD", $sformatf("Received WB Transaction: %s", t.sprint()), UVM_MEDIUM)
        wb_queue.push_back(t);
                  
             total_wb_transactions++;
        total_packets_received++;
        compare_transactions();
        end 
    endfunction

    // Compare Transactions
    function void compare_transactions();
        if (spi_queue.size() > 0 && wb_queue.size() > 0) begin
            spi_transaction spi_pkt = spi_queue.pop_front();
            wb_transaction wb_pkt = wb_queue.pop_front();
            if (wb_pkt.op_type==wb_write)begin 
            if (spi_pkt.data_in == wb_pkt.dout) begin
                `uvm_info("SCOREBOARD", $sformatf("MATCH: SPI = %h, WB = %h", spi_pkt.data_in, wb_pkt.dout), UVM_HIGH)
                total_matched_packets++;
            end
            end  
            else if  (wb_pkt.op_type==wb_read)begin 
            if (spi_pkt.data_out == wb_pkt.din) begin
                `uvm_info("SCOREBOARD", $sformatf("MATCH: SPI = %h, WB = %h", spi_pkt.data_in, wb_pkt.dout), UVM_HIGH)
                total_matched_packets++;
            end
            end 
            else begin
                `uvm_error("SCOREBOARD", $sformatf("MISMATCH: SPI = %h, WB = %h", spi_pkt.data_in, wb_pkt.dout))
                total_wrong_packets++;
               
            end
        end
    endfunction
    








     function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(),"printing report",UVM_NONE)

    $display("\n****************** TEST REPORT ******************\n");



   $display("Packets Summary:\n");
   $display( "   - Total WB Packets Received:  %d", total_wb_transactions);
   $display( "   - Total SPI Packets Received: %d",total_spi_transactions);
   $display( "   - Total I2C Packets Received: %d", 0/*total_i2c_transactions*/);
   $display( "   - Total UART Packets Received:%d", 0 /*to be handeled*/);
   $display( "   - Total Packets Received: %d", total_packets_received);
   $display( "   - Total Matched Packets:  %d", total_matched_packets);
   $display( "   - Number of Mismatches:   %d\n",err);
      

  if (err ) begin
      $display("\n==================================================\n",
      "                   TEST FAILED ❌\n",
      "==================================================\n");
  end else begin
      $display("\n==================================================\n",
      "                    TEST PASS ✅\n",
      "==================================================\n");

  end

    $display("\n****************** END OF REPORT ******************\n");

endfunction : report_phase

endclass :scoreboard

    