puts "Info: start testing"

do wave.do

add wave -position end sim:/soc_top_tb/DUT/*
add wave -position end sim:/soc_top_tb/DUT/core_1/*
add wave -position end sim:/soc_top_tb/DUT/core_1/register_file/*
add wave -position end sim:/soc_top_tb/DUT/core_1/register_file/reg_array

run -all

exit
