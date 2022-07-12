create_clock -name clk -period 9.1 [get_ports clk]

set_false_path -from [get_ports rst_n] -to [get_clocks clk]
set_input_delay -min 1 -clock [get_clocks clk] [get_ports {message_byte[*] message_valid state}]
set_input_delay -max 2 -clock [get_clocks clk] [get_ports {message_byte[*] message_valid state}]
set_output_delay -min 1 -clock [get_clocks clk] [get_ports {digest_ready digest[*]}]
set_output_delay -max 2 -clock [get_clocks clk] [get_ports {digest_ready digest[*]}]
