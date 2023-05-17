#============================================================
# pinout
#============================================================
#clk
set_location_assignment PIN_G26 -to clk
set_instance_assignment -name IO_STANDARD "1.2V" -to clk
# rst_sys_in
set_location_assignment PIN_W54 -to rst_sys_in
set_instance_assignment -name IO_STANDARD "1.2V" -to rst_sys_in
# uart
#set_location_assignment PIN_F32 -to uart_tx
#set_instance_assignment -name IO_STANDARD "1.2V" -to uart_tx
#set_location_assignment PIN_K29 -to uart_rx
#set_instance_assignment -name IO_STANDARD "1.2V" -to uart_rx

#============================================================
# accelerator on JP1 daughter board (with the directions bits)
#============================================================
#clk
# TODO: clk divisor 
set_location_assignment PIN_DB49 -to clk_i
set_instance_assignment -name IO_STANDARD "1.2V" -to clk_i
set_location_assignment PIN_CY46 -to io_clk_i 
set_instance_assignment -name IO_STANDARD "1.2V" -to io_clk_i
#CBL
set_location_assignment PIN_DB15 -to CBL0
set_instance_assignment -name IO_STANDARD "1.2V" -to CBL0
set_location_assignment PIN_CE52 -to io_CBL0
set_instance_assignment -name IO_STANDARD "1.2V" -to io_CBL0
#CBLEN
set_location_assignment PIN_CV11 -to CBLEN0
set_instance_assignment -name IO_STANDARD "1.2V" -to CBLEN0
set_location_assignment PIN_CE56 -to io_CBLEN0
set_instance_assignment -name IO_STANDARD "1.2V" -to io_CBLEN0
#CSL
set_location_assignment PIN_DA4 -to CSL0
set_instance_assignment -name IO_STANDARD "1.2V" -to CSL0
set_location_assignment PIN_CF49 -to io_CSL0
set_instance_assignment -name IO_STANDARD "1.2V" -to io_CSL0
#CWL
set_location_assignment PIN_CU4 -to CWL0
set_instance_assignment -name IO_STANDARD "1.2V" -to CWL0
set_location_assignment PIN_CE54 -to io_CWL0
#instructions
set_location_assignment PIN_CU8 -to instructions_in[0]
set_instance_assignment -name IO_STANDARD "1.2V" -to instructions_in[0]
set_location_assignment PIN_CL56 -to io_instructions_in[0]
set_instance_assignment -name IO_STANDARD "1.2V" -to io_instructions_in[0]
set_location_assignment PIN_CV15 -to instructions_in[1]
set_instance_assignment -name IO_STANDARD "1.2V" -to instructions_in[1]
set_location_assignment PIN_CK47 -to io_instructions_in[1]
set_instance_assignment -name IO_STANDARD "1.2V" -to io_instructions_in[1]
#adr_full_col
set_location_assignment PIN_DV12 -to adr_full_col[0]
set_instance_assignment -name IO_STANDARD "1.2V" -to adr_full_col[0]
set_location_assignment PIN_DC10 -to adr_full_col[1]
set_instance_assignment -name IO_STANDARD "1.2V" -to adr_full_col[1]
set_location_assignment PIN_CM25 -to adr_full_col[2]
set_instance_assignment -name IO_STANDARD "1.2V" -to adr_full_col[2]
set_location_assignment PIN_CU14 -to adr_full_col[3]
set_instance_assignment -name IO_STANDARD "1.2V" -to adr_full_col[3]
set_location_assignment PIN_DB5 -to adr_full_col[4]
set_instance_assignment -name IO_STANDARD "1.2V" -to adr_full_col[4]
# adr_full_col io pins 
set_location_assignment PIN_CE48 -to io_adr_full_col[0]
set_instance_assignment -name IO_STANDARD "1.2V" -to io_adr_full_col[0]
set_location_assignment PIN_CL46 -to io_adr_full_col[1]
set_instance_assignment -name IO_STANDARD "1.2V" -to io_adr_full_col[1]
set_location_assignment PIN_CE40 -to io_adr_full_col[2]
set_instance_assignment -name IO_STANDARD "1.2V" -to io_adr_full_col[2]
set_location_assignment PIN_CE46 -to io_adr_full_col[3]
set_instance_assignment -name IO_STANDARD "1.2V" -to io_adr_full_col[3]
set_location_assignment PIN_CF53 -to io_adr_full_col[4]
set_instance_assignment -name IO_STANDARD "1.2V" -to io_adr_full_col[4]

#adr_full_row
set_location_assignment PIN_DB7 -to adr_full_row[0]
set_instance_assignment -name IO_STANDARD "1.2V" -to adr_full_row[0]
set_location_assignment PIN_CV1 -to adr_full_row[1]
set_instance_assignment -name IO_STANDARD "1.2V" -to adr_full_row[1]
set_location_assignment PIN_CV5 -to adr_full_row[2]
set_instance_assignment -name IO_STANDARD "1.2V" -to adr_full_row[2]
set_location_assignment PIN_CH5 -to adr_full_row[3]
set_instance_assignment -name IO_STANDARD "1.2V" -to adr_full_row[3]
set_location_assignment PIN_CM3 -to adr_full_row[4]
set_instance_assignment -name IO_STANDARD "1.2V" -to adr_full_row[4]
# adr_full_row io pins
set_location_assignment PIN_CF57 -to io_adr_full_row[0]
set_instance_assignment -name IO_STANDARD "1.2V" -to io_adr_full_row[0]
set_location_assignment PIN_CF55 -to io_adr_full_row[1]
set_instance_assignment -name IO_STANDARD "1.2V" -to io_adr_full_row[1]
set_location_assignment PIN_CK53 -to io_adr_full_row[2]
set_instance_assignment -name IO_STANDARD "1.2V" -to io_adr_full_row[2]
set_location_assignment PIN_CY57 -to io_adr_full_row[3]
set_instance_assignment -name IO_STANDARD "1.2V" -to io_adr_full_row[3]
set_location_assignment PIN_CY53 -to io_adr_full_row[4]
set_instance_assignment -name IO_STANDARD "1.2V" -to io_adr_full_row[4]

#DATA_out
set_location_assignment PIN_CM7 -to DATA_out[0]
set_instance_assignment -name IO_STANDARD "1.2V" -to DATA_out[0]
set_location_assignment PIN_CH3 -to DATA_out[1]
set_instance_assignment -name IO_STANDARD "1.2V" -to DATA_out[1]
set_location_assignment PIN_CM5 -to DATA_out[2]
set_instance_assignment -name IO_STANDARD "1.2V" -to DATA_out[2]
set_location_assignment PIN_CH7 -to DATA_out[3]
set_instance_assignment -name IO_STANDARD "1.2V" -to DATA_out[3]
#DATA_out io pins
set_location_assignment PIN_CY55 -to io_DATA_out[0]
set_instance_assignment -name IO_STANDARD "1.2V" -to io_DATA_out[0]
set_location_assignment PIN_CT53 -to io_DATA_out[1]
set_instance_assignment -name IO_STANDARD "1.2V" -to io_DATA_out[1]
set_location_assignment PIN_DA50 -to io_DATA_out[2]
set_instance_assignment -name IO_STANDARD "1.2V" -to io_DATA_out[2]
set_location_assignment PIN_DA48 -to io_DATA_out[3]
set_instance_assignment -name IO_STANDARD "1.2V" -to io_DATA_out[3]

#============================================================
# define SYNTHESIS macro
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
