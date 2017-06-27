
#=============================================================================#
#                              Configuration                                  #
#=============================================================================#

set DESIGN_NAME       "openMSP430"

set NETLIST_FILES    [list "core/gate/verilog/$DESIGN_NAME.gate.v"]

set LIBRARY_FILES    [list "core/gate/verilog/CORE65GPSVT_tmax.v"]



#=============================================================================#
#                           Read Design & Technology files                    #
#=============================================================================#

# Rules to be ignored
set_rules B7  ignore    ;# undriven module output pin
set_rules B8  ignore    ;# unconnected module input pin
set_rules B9  ignore    ;# undriven module internal net
set_rules B10 ignore    ;# unconnected module internal net
set_rules N20 ignore    ;# underspecified UDP
set_rules N21 ignore    ;# unsupported UDP entry
set_rules N23 ignore    ;# inconsistent UDP


# Reset TMAX
reset_all
build -force
read_netlist -delete

set_netlist -sequential_modeling

# Read gate level netlist

# Read library files
foreach lib_file $LIBRARY_FILES {
    read_netlist $lib_file
}

foreach design_file $NETLIST_FILES {
    read_netlist $design_file
}



# Remove unused net connections
remove_net_connection -all

# Build the model

run_build_model omsp_multiplier_DW02_mult_0



#=============================================================================#
#                                    Run DRC                                  #
#=============================================================================#

# Allow ATPG to use nonscan cell values loaded by the last shift.
#set_drc -load_nonscan_cells

# Report settings
report_settings drc

# Run DRC

run_drc

#=============================================================================#
#                               Fault Simulation                              #
#=============================================================================#



add_faults -all
set_patterns -internal
set_atpg -merge high
run_atpg 

write_patterns mul_patter.stil -internal -format stil



quit
