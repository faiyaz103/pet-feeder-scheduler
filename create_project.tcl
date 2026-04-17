# Vivado Project Creation Script for Automated Pet Feeding Scheduler
# Usage: Open Vivado Tcl Console, then: source create_project.tcl

# 1. Project Configuration
set project_name "pet_feeder_project"
set project_dir  "vivado_project"
set part_name     "xc7a35tcpg236-1" ;# Artix-7 XC7A35T on Basys 3

# 2. Create the project
# -force allows overwriting the directory if it already exists
create_project -force $project_name ./$project_dir -part $part_name

# 3. Add Source Files
# RTL Design Sources
add_files -fileset sources_1 [glob ./src/hdl/*.v]

# Simulation Sources
add_files -fileset sim_1 [glob ./src/sim/*.v]

# Constraints
add_files -fileset constrs_1 [glob ./src/constrs/*.xdc]

# 4. Set Top Module
set_property top pet_feeder_top [current_fileset]
update_compile_order -fileset sources_1

# 5. Simulation Settings
# Set the testbench as the top for simulation
set_property top tb_pet_feeder [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

puts "=========================================================="
puts "Project $project_name created successfully!"
puts "Device: $part_name"
puts "Top Module: pet_feeder_top"
puts "Testbench: tb_pet_feeder"
puts "=========================================================="
