
# PlanAhead Launch Script for Post-Synthesis pin planning, created by Project Navigator

create_project -name DigitalFinalProject -dir "D:/Xsectorz/ISE/DigitalFinalProject/planAhead_run_2" -part xc6slx9tqg144-3
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "D:/Xsectorz/ISE/DigitalFinalProject/VGADriver.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {D:/Xsectorz/ISE/DigitalFinalProject} }
set_param project.pinAheadLayout  yes
set_property target_constrs_file "VGADriver.ucf" [current_fileset -constrset]
add_files [list {VGADriver.ucf}] -fileset [get_property constrset [current_run]]
link_design
