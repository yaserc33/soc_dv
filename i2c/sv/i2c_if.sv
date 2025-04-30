interface i2c_if (input bit clk, input bit rst_n);
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import i2c_pkg::*;




//signals
wire scl;
wire sda;

logic sda_w;
assign sda = sda_w;





 bit [6:0] Slave_addr = 7'b1010_101 ; // this is the addr of this slave
 bit[7:0] header;

task  send_to_dut (i2c_transaction tr);



@(negedge sda & scl); //start condtion 


        read_header ();


        if ( Slave_addr == header[7:1] ) begin 

            @(negedge scl); // ------------------------
          $display("🥳🥳🥳🥳before pulling =  at $t" , $time);
          //   sda_w <=0;    //ack
        //     @(negedge scl); //-----------------------
        //     sda_w <= 'z;


        //   if (header[0] == 1'b0) //  0:R  1:W  from slave POV
        //     read_byte();    
        //   else 
        //     //write_byte(tr.dout); 
        end

endtask :send_to_dut





task read_header();

foreach (header[i]) begin
  @(posedge scl);
  header[i] =sda;
end 

$display("🥳🥳🥳🥳heder = %b at $t", header , $time);
 endtask : read_header







// task read_byte ();  

//         repeat(8)  // stalling for 8 cycle  
//         @(posedge scl); 
          
//         @(negedge scl); // ------------------------
//         sda_w <=0;    //ack
//         @(negedge scl); //-----------------------
//         sda_w <= 'z;



// endtask :read_byte








// task write_byte (bit [7:0] dout);  

// foreach (dout[i]) begin

//   @(negedge scl);
//   sda_w <= dout[7 - i];  // send MSB first
//   @(negedge scl);
// end 
//  sda_w <= 'z;  


// endtask :write_byte







endinterface : i2c_if

