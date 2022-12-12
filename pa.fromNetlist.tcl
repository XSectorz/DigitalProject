
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name DigitalFinalProject -dir "D:/Xsectorz/ISE/DigitalFinalProject/planAhead_run_5" -part xc6slx9tqg144-3
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "D:/Xsectorz/ISE/DigitalFinalProject/vga_driver.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {D:/Xsectorz/ISE/DigitalFinalProject} }
set_property target_constrs_file "PinDriver.ucf" [current_fileset -constrset]
add_files [list {PinDriver.ucf}] -fileset [get_property constrset [current_run]]
link_design
