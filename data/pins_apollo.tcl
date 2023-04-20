#
# synth
# 

set_global_assignment -name VERILOG_MACRO "SYNTHESIS"

# 
# Clock
#
set_location_assignment PIN_G26 -to clk
set_instance_assignment -name IO_STANDARD "1.2V" -to clk 

