////////////////////////////////////////
// option
////////////////////////////////////////



############Saving run Output to a Log File/##########
-l sim.log





############select test###########

+UVM_TESTNAME=wb_write_test
//+UVM_TESTNAME=wb_all_address_test



##############debug#################

##+UVM_CONFIG_DB_TRACE
##+UVM_OBJECTION_TRACE




############verbosity level###########
//+UVM_VERBOSITY=UVM_LOW
+UVM_VERBOSITY=UVM_HIGH
// +UVM_VERBOSITY=UVM_FULL



############ gui#############
//-gui
//+access+rwc



// default timescale
-timescale 1ns/1ns

