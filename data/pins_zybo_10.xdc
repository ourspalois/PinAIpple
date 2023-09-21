## clock signal 
set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports {clk}]
create_clock -add -name sys_clk_pin -period 8 -waveform {0 4} [get_ports {clk}]

## rst signal
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports {rst_sys_in}] 

## uart
set_property -dict {PACKAGE_PIN Y17 IOSTANDARD LVCMOS33} [get_ports {uart_rx}]
set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports {uart_tx}]

#gp_i 
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33} [get_ports {gp_i[0]}]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports {gp_i[1]}]
set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33} [get_ports {gp_i[2]}]
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS33} [get_ports {gp_i[3]}]

#gp_o
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports {gp_o[0]}]
set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS33} [get_ports {gp_o[1]}]
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33} [get_ports {gp_o[2]}]
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports {gp_o[3]}]

#-----------------------------------------------------------------------------
# Pins of accel
#-----------------------------------------------------------------------------

## clk
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports {clk_i}]

## io dir
#set_property -dict {PACKAGE_PIN Y14 IOSTANDARD LVCMOS33} [get_ports {io_out}]
#set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS33} [get_ports {io_in}]

## instr
set_property -dict {PACKAGE_PIN V18 IOSTANDARD LVCMOS33} [get_ports {instructions_in[0]}]
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports {instructions_in[1]}]

## CBL
set_property -dict {PACKAGE_PIN T17 IOSTANDARD LVCMOS33} [get_ports {CBL0}]

## CBLEN
set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports {CBLEN0}]

## CSL
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS33} [get_ports {CSL0}]

## CWL
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports {CWL0}]

## address col 
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports {adr_full_col_in[0]}]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {adr_full_col_in[1]}]
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS33} [get_ports {adr_full_col_in[2]}]
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports {adr_full_col_in[3]}]
set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33} [get_ports {adr_full_col_in[4]}]

## address row
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {adr_full_row_in[0]}]
set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS33} [get_ports {adr_full_row_in[1]}]
set_property -dict {PACKAGE_PIN Y14 IOSTANDARD LVCMOS33} [get_ports {adr_full_row_in[2]}]
set_property -dict {PACKAGE_PIN T12 IOSTANDARD LVCMOS33} [get_ports {adr_full_row_in[3]}]
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports {adr_full_row_in[4]}]

## result 
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports {DATA_out[0]}]
set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS33} [get_ports {DATA_out[1]}]
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports {DATA_out[2]}]
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {DATA_out[3]}]