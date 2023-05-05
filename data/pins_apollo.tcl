#============================================================
# synth
#============================================================

set_global_assignment -name VERILOG_MACRO "SYNTHESIS"

#============================================================
# Clock
#============================================================
set_location_assignment PIN_G26 -to clk
set_instance_assignment -name IO_STANDARD "1.2V" -to clk 


#============================================================
# VID Assignments
#============================================================
set_global_assignment -name USE_PWRMGT_SCL SDM_IO0
set_global_assignment -name USE_PWRMGT_SDA SDM_IO12
set_global_assignment -name VID_OPERATION_MODE "PMBUS MASTER"
set_global_assignment -name PWRMGT_BUS_SPEED_MODE "400 KHZ"
set_global_assignment -name PWRMGT_SLAVE_DEVICE_TYPE OTHER
set_global_assignment -name PWRMGT_SLAVE_DEVICE0_ADDRESS 4F
set_global_assignment -name PWRMGT_PAGE_COMMAND_ENABLE ON


#============================================================
# Configuration scheme/pin
#============================================================
set_global_assignment -name ACTIVE_SERIAL_CLOCK AS_FREQ_125MHZ
set_global_assignment -name USE_CONF_DONE SDM_IO16
set_global_assignment -name USE_HPS_COLD_RESET SDM_IO13
set_global_assignment -name DEVICE_INITIALIZATION_CLOCK OSC_CLK_1_125MHZ
set_global_assignment -name PWRMGT_VOLTAGE_OUTPUT_FORMAT "LINEAR FORMAT"
set_global_assignment -name PWRMGT_LINEAR_FORMAT_N "-12"
