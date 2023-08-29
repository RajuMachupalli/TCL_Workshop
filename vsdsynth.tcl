#! /bin/env tclsh
#------------------------------------------------------------------
#-------- Check whether vsdsynth usage is correct or not -----------
#-------------------------------------------------------------------
set enable_prelayout_timing 1
set working_dir [exec pwd]
set vsd_array_length [llength [split [lindex $argv 0] .]]
set input [lindex [split [lindex $argv 0] .] $vsd_array_length-1]

if {![regexp {^csv} $input] || $argc!=1} {
	puts "Error in usage"
	puts "Usage: ./vsdsynth <.csv>"
	puts "where <.csv> file has below inputs"
	exit
} else {
	#-----------------------------------------------------------
	#----- Step 1: creating format[1] from input .csv file -----
	#-----------------------------------------------------------
	set filename [lindex $argv 0]
	puts "\n Info: file name $filename"
	package require csv
	package require struct::matrix
	struct::matrix m
	set f [open $filename]
	csv::read2matrix $f m , auto
	close $f
	m link my_arr
	set num_of_rows [m rows]
	set i 0
	while {$i < $num_of_rows} {
		
		if {$i==0} {
			set [string map {" " ""} $my_arr(0,$i)] $my_arr(1,$i)
			puts "\nInfo: Setting $my_arr(0,$i) as $my_arr(1,$i)"
		} else {
			set [string map {" " ""} $my_arr(0,$i)] [file normalize $my_arr(1,$i)]
			puts "\nInfo: Setting $my_arr(0,$i) as $my_arr(1,$i)"
		}
		set i [expr {$i+1}]
	}
}

puts "\nInfo: Below are the variables and their values generated from .csv file"
puts "\n DesignName = $DesignName"
puts "\n OutputDrectory = $OutputDirectory"
puts "\n NetlistDirectory = $NetlistDirectory"
puts "\n EarlyLibraryPath = $EarlyLibraryPath"
puts "\n LateLibraryPath = $LateLibraryPath"
puts "\n ContraintsFile = $ConstraintsFile"

#-----------------------------------------------------------------------------------------------
#----- Below script checks if directoris and files mentions in csv file exist or not------------
#-----------------------------------------------------------------------------------------------

if {![file isdirectory $OutputDirectory]} { 
	puts "\nInfo: can not find $OutputDirectory, creating new directory $OutputDirectory"
	file mkdir $OutputDirectory
} else {
	puts "\nInfo: Output direectory found in the path $OutputDirectory"
}

if {![file isdirectory $NetlistDirectory]} {
	puts "\nInfo: can not find $NetlistDirectory"
	exit
} else {
	puts "\nInfo: Netlist directory found in the path $NetlistDirectory"
}

if {![file exists $EarlyLibraryPath]} {
	puts "\nInfo: can not find the file $EarlyLibraryPath"
	exit
} else {
	puts "\nInfo: Early library path file found at $EarlyLibraryPath"
}

if {![file exists $LateLibraryPath]} {
	puts "\nInfo: can not find the file $LateLibraryPath"
	exit
} else {
	puts "\nInfo: Late Librarypath file found at  $LateLibraryPath"
}

if {![file exists $ConstraintsFile]} {
	puts "\nInfo: can not find the $ConstraintsFile"
	exit
} else {
	puts "\nInfo: Constraints file found at $ConstraintsFile"
}

#----------------------------------------------------------------------------------
#--------------Creating SDC file from constraints csv file-------------------------
#----------------------------------------------------------------------------------

#--- Open the csv file and find number of rows and colums
puts "Info: Dumping SDC constraints for design $DesignName"
struct::matrix constraints
set f [open $ConstraintsFile]
csv::read2matrix $f constraints , auto
close $f
set number_of_rows [constraints rows]
puts "Number of rows = $number_of_rows"
set number_of_colums [constraints columns]
puts "Number of columns = $number_of_colums"

# ----------- Identify starting row of CLOCKS, INPUTS and OUTPUTS------------------
set clock_start [lindex [lindex [constraints search all CLOCKS] 0] 1]
set clock_start_colum [lindex [lindex [constraints search all CLOCKS] 0] 0]
puts "Clock pins starts at row $clock_start"

set input_ports_start [lindex [lindex [constraints search all INPUTS] 0] 1]
puts "Input ports starts at row $input_ports_start"

set output_ports_start [lindex [lindex [constraints search all OUTPUTS] 0] 1]
puts "Output ports starts at row $output_ports_start"

#--------------------------------------------------------------------------------
#------------ Create clock constraints ------------------------------------------
#--------------------------------------------------------------------------------
set frequency_start [lindex [lindex [constraints search rect $clock_start_colum $clock_start [expr {$number_of_colums-1}] [expr {$input_ports_start-1}] frequency] 0] 0]
set duty_cycle_start [lindex [lindex [constraints search rect $clock_start_colum $clock_start [expr {$number_of_colums-1}] [expr {$input_ports_start-1}] duty_cycle] 0] 0]
set clock_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_colum $clock_start [expr {$number_of_colums-1}] [expr {$input_ports_start-1}] early_rise_delay] 0] 0]
set clock_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_colum $clock_start [expr {$number_of_colums-1}] [expr {$input_ports_start-1}] early_fall_delay] 0] 0]
set clock_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_colum $clock_start [expr {$number_of_colums-1}] [expr {$input_ports_start-1}] late_rise_delay] 0] 0]
set clock_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_colum $clock_start [expr {$number_of_colums-1}] [expr {$input_ports_start-1}] late_fall_delay] 0] 0]
set clock_early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_colum $clock_start [expr {$number_of_colums-1}] [expr {$input_ports_start-1}] early_rise_slew] 0] 0]
set clock_early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_colum $clock_start [expr {$number_of_colums-1}] [expr {$input_ports_start-1}] early_fall_slew] 0] 0]
set clock_late_rise_slew_start [lindex [lindex [constraints search rect $clock_start_colum $clock_start [expr {$number_of_colums-1}] [expr {$input_ports_start-1}] late_rise_slew] 0] 0]
set clock_late_fall_slew_start [lindex [lindex [constraints search rect $clock_start_colum $clock_start [expr {$number_of_colums-1}] [expr {$input_ports_start-1}] late_fall_slew] 0] 0]

set sdc_file [open $OutputDirectory/$DesignName.sdc "w"]
#-----Clocks iteration-----
set i [expr {$clock_start+1}]
set end_of_ports [expr {$input_ports_start-1}]
puts "Info: working on clock constraints"
while {$i<$end_of_ports} {
	puts -nonewline $sdc_file "\ncreate_clock -name [constraints get cell 0 $i] -period [constraints get cell $frequency_start $i] -waveform \{0 [expr {[constraints get cell $frequency_start $i]*[constraints get cell $duty_cycle_start $i]/100}]\} \[get_ports [constraints get cell 0 $i]\]"
	#
	puts -nonewline $sdc_file "\nset_clock_transition -rise -min [constraints get cell $clock_early_rise_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_transition -fall -min [constraints get cell $clock_early_fall_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_transition -rise -max [constraints get cell $clock_late_rise_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_transition -fall -max [constraints get cell $clock_late_fall_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_latency -source -early -rise [constraints get cell $clock_early_rise_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_latency -source -early -fall [constraints get cell $clock_early_fall_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_latency -source -late -rise [constraints get cell $clock_late_rise_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_latency -source -late -fall [constraints get cell $clock_late_fall_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
	set i [expr {$i+1}]
}

#------------------------------------------------------------------------------
#------------ Creating inputs constraints -------------------------------------
#------------------------------------------------------------------------------

set input_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_colum $input_ports_start [expr {$number_of_colums-1}] [expr {$output_ports_start-1}] early_rise_delay] 0] 0]
set input_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_colum $input_ports_start [expr {$number_of_colums-1}] [expr {$output_ports_start-1}] early_fall_delay] 0] 0]
set input_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_colum $input_ports_start [expr {$number_of_colums-1}] [expr {$output_ports_start-1}] late_rise_delay] 0] 0]
set input_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_colum $input_ports_start [expr {$number_of_colums-1}] [expr {$output_ports_start-1}] late_fall_delay] 0] 0]
set input_early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_colum $input_ports_start [expr {$number_of_colums-1}] [expr {$output_ports_start-1}] early_rise_slew] 0] 0]
set input_early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_colum $input_ports_start [expr {$number_of_colums-1}] [expr {$output_ports_start-1}] early_fall_slew] 0] 0]
set input_late_rise_slew_start [lindex [lindex [constraints search rect $clock_start_colum $input_ports_start [expr {$number_of_colums-1}] [expr {$output_ports_start-1}] late_rise_slew] 0] 0]
set input_late_fall_slew_start [lindex [lindex [constraints search rect $clock_start_colum $input_ports_start [expr {$number_of_colums-1}] [expr {$output_ports_start-1}] late_fall_slew] 0] 0]
set related_clock [lindex [lindex [constraints search rect $clock_start_colum $input_ports_start [expr {$number_of_colums-1}] [expr {$output_ports_start-1}] clocks] 0] 0]

#-----------Iterating through input ports -------------------------------------
set i [expr {$input_ports_start+1}]
set end_of_ports [expr {$output_ports_start-1}]
puts "Info: working on input ports constarints"
while {$i<$end_of_ports} {
	#
	set netlist [glob -dir $NetlistDirectory *.v]
	set tmp_file [open /tmp/1/ "w"]
	foreach f $netlist {
		#
		set fd [open $f]
		puts "Info: reading file $f"
		while {[gets $fd line]!=-1} {
			#
			set pattern1 " [constraints get cell 0 $i];"
			if {[regexp -all -- $pattern1 $line]} {
				#
				puts "$pattern1 found and matching line in verilog file \"$f\" is \"$line\""
				set pattern2 [lindex [split $line ";"] 0]
				if {[regexp -all {input} [lindex [split $pattern2 "\S+"] 0]]} {
					set s1 "[lindex [split $pattern2 "\S+"] 0] [lindex [split $pattern2 "\S+"] 1] [lindex [split $pattern2 "\S+"] 2]"
					puts "printing first 3 elements of pattern2 as \"$s1\" using space delimitor"
					puts -nonewline $tmp_file "\n[regsub -all {\s+} $s1 " "]"
				}
			}
		}
		close $fd
	}
	close $tmp_file
	#-------------- count number of string to decide sinle bit or multi-bit port -----
	set tmp_file [open /tmp/1 r]
	set tmp2_file [open /tmp/2 w]
	puts -nonewline $tmp2_file "[join [lsort -unique [split [read $tmp_file] \n]] \n]"
	close $tmp_file
	close $tmp2_file
	set tmp2_file [open /tmp/2 r]
	set count [llength [read $tmp2_file]]
	puts "Info: counting number of elements in tmp2_file:  $count"
	if {$count > 2} {
		set inp_ports [concat [constraints get cell 0 $i]*]
		puts "Info:[constraints get cell 0 $i] is a multi-bit port"
	} else {
		set inp_ports [constraints get cell 0 $i]
		puts "Info: [constraints get cell 0 $i] is a single bit port"
	}
	#
	puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min  -rise -source_latency_included [constraints get cell $input_early_rise_delay_start $i] \[get_ports $inp_ports\]"
	puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min  -fall -source_latency_included [constraints get cell $input_early_fall_delay_start $i] \[get_ports $inp_ports\]"
	puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max  -rise -source_latency_included [constraints get cell $input_late_rise_delay_start $i] \[get_ports $inp_ports\]"
	puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max  -fall -source_latency_included [constraints get cell $input_late_fall_delay_start $i] \[get_ports $inp_ports\]"
	puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -min  -rise -source_latency_included [constraints get cell $input_early_rise_slew_start $i] \[get_ports $inp_ports\]"
        puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -min  -fall -source_latency_included [constraints get cell $input_early_fall_slew_start $i] \[get_ports $inp_ports\]"
	puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -max  -rise -source_latency_included [constraints get cell $input_late_rise_slew_start $i] \[get_ports $inp_ports\]"
	puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -max  -fall -source_latency_included [constraints get cell $input_late_fall_slew_start $i] \[get_ports $inp_ports\]"

	close $tmp2_file
	set i [expr {$i+1}]
}

#----------------------------------------------------------------------------------------------
#--------------------Creating Output delay and load constrainst -------------------------------
#----------------------------------------------------------------------------------------------
set output_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_colum $output_ports_start [expr {$number_of_colums-1}] [expr {$number_of_rows-1}] early_rise_delay] 0] 0]
set output_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_colum $output_ports_start [expr {$number_of_colums-1}] [expr {$number_of_rows-1}] early_fall_delay] 0] 0]
set output_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_colum $output_ports_start [expr {$number_of_colums-1}] [expr {$number_of_rows-1}] late_rise_delay] 0] 0]
set output_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_colum $output_ports_start [expr {$number_of_colums-1}] [expr {$number_of_rows-1}] late_fall_delay] 0] 0]
set output_load_start [lindex [lindex [constraints search rect $clock_start_colum $output_ports_start [expr {$number_of_colums-1}] [expr {$number_of_rows-1}] load] 0] 0]
set related_clock [lindex [lindex [constraints search rect $clock_start_colum $output_ports_start [expr {$number_of_colums-1}] [expr {$number_of_rows-1}] clocks] 0] 0]

#-----------Iterating through output ports -------------------------------------
set i [expr {$output_ports_start+1}]
set end_of_ports [expr {$number_of_rows}]
puts "Info: working on output ports constarints"
while {$i<$end_of_ports} {
        #
        set netlist [glob -dir $NetlistDirectory *.v]
        set tmp_file [open /tmp/1/ "w"]
        foreach f $netlist {
                #
                set fd [open $f]
                puts "Info: reading file $f"
                while {[gets $fd line]!=-1} {
                        #
                        set pattern1 " [constraints get cell 0 $i];"
                        if {[regexp -all -- $pattern1 $line]} {
                                #
                                puts "$pattern1 found and matching line in verilog file \"$f\" is \"$line\""
                                set pattern2 [lindex [split $line ";"] 0]
                                if {[regexp -all {output} [lindex [split $pattern2 "\S+"] 0]]} {
                                        set s1 "[lindex [split $pattern2 "\S+"] 0] [lindex [split $pattern2 "\S+"] 1] [lindex [split $pattern2 "\S+"] 2]"
                                        puts "printing first 3 elements of pattern2 as \"$s1\" using space delimitor"
                                        puts -nonewline $tmp_file "\n[regsub -all {\s+} $s1 " "]"
                                }
                        }
                }
                close $fd
        }
        close $tmp_file
        #-------------- count number of string to decide sinle bit or multi-bit port -----
	set tmp_file [open /tmp/1 r]
        set tmp2_file [open /tmp/2 w]
        puts -nonewline $tmp2_file "[join [lsort -unique [split [read $tmp_file] \n]] \n]"
        close $tmp_file
        close $tmp2_file
        set tmp2_file [open /tmp/2 r]
        set count [llength [read $tmp2_file]]
        puts "Info: counting number of elements in tmp2_file:  $count"
        if {$count > 2} {
                set op_ports [concat [constraints get cell 0 $i]*]
                puts "Info:[constraints get cell 0 $i] is a multi-bit port"
        } else {
                set op_ports [constraints get cell 0 $i]
                puts "Info: [constraints get cell 0 $i] is a single bit port"
        }
        #
        puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min  -rise -source_latency_included [constraints get cell $output_early_rise_delay_start $i] \[get_ports $op_ports\]"
        puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min  -fall -source_latency_included [constraints get cell $output_early_fall_delay_start $i] \[get_ports $op_ports\]"
        puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max  -rise -source_latency_included [constraints get cell $output_late_rise_delay_start $i] \[get_ports $op_ports\]"
        puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max  -fall -source_latency_included [constraints get cell $output_late_fall_delay_start $i] \[get_ports $op_ports\]"
        puts -nonewline $sdc_file "\nset_load [constraints get cell $output_load_start $i] \[get_ports $op_ports\]"
        close $tmp2_file
        set i [expr {$i+1}]
}

close $sdc_file

#-----------------------------------------------------------------------------------
#---------------- Hierarcy Check ---------------------------------------------------
#-----------------------------------------------------------------------------------
puts "\nInfo: Creating hierarchy check script to be used by Yosys"
set data "read_liberty -lib -ignore_miss_dir -setattr blackbox ${LateLibraryPath}"
set filename "$DesignName.hier.ys"
set fileId [open $OutputDirectory/$filename "w"]
puts -nonewline $fileId $data

set netlist [glob -dir $NetlistDirectory *.v]
foreach f $netlist {
	set data $f
	puts -nonewline $fileId "\nread_verilog $f"
}
puts -nonewline $fileId "\nhierarchy -check"
close $fileId

puts "\nInfo: Checking hierarchy....."
set my_err [catch {exec yosys -s $OutputDirectory/$DesignName.hier.ys >& $OutputDirectory/$DesignName.hierarchy_check.log} msg]
puts "err flag is $my_err"

if {$my_err} {
	set filename "$OutputDirectory/$DesignName.hierarchy_check.log"
	puts "log file name is $filename"
	set pattern {referenced in module}
	puts "pattern is $pattern"
	set count 0
	set fid [open $filename]
	while {[gets $fid line] != -1} {
		incr count [regexp -all -- $pattern $line]
		if {[regexp -all -- $pattern $line]} {
			puts "\nError: module [lindex $line 2] is not part of design $DesignName. Please correct RTL in path $NetlistDirectory"
			puts "\nInfo: Hierarchy check FAIL"
		}
	}
	close $fid
} else {
	puts "\nInfo: Hierarchy check PASS"
}
puts "\nInfo: Please find hierarchy check details in [file normalize $OutputDirectory/$DesignName.hierarchy_check.log] for more info"

#-----------------------------------------------------------------------------------
#---------------- Creating main syntheis script for yosys --------------------------
#-----------------------------------------------------------------------------------
puts "\nInfo: Creating synthesis  script to be used by Yosys"
set data "read_liberty -lib -ignore_miss_dir -setattr blackbox ${LateLibraryPath}"
set filename "$DesignName.ys"
set fileId [open $OutputDirectory/$filename "w"]
puts -nonewline $fileId $data

set netlist [glob -dir $NetlistDirectory *.v]
foreach f $netlist {
        set data $f
        puts -nonewline $fileId "\nread_verilog $f"
}
puts -nonewline $fileId "\nhierarchy -top $DesignName"
puts -nonewline $fileId "\nsynth -top $DesignName"
puts -nonewline $fileId "\nsplitnets -ports -format __\ndfflibmap -liberty ${LateLibraryPath}\nopt"
puts -nonewline $fileId "\nabc -liberty ${LateLibraryPath}"
puts -nonewline $fileId "\nflatten"
puts -nonewline $fileId "\nclean -purge\niopadmap -outpad BUFX2 A:Y -bits\nopt\nclean"
puts -nonewline $fileId "\nwrite_verilog $OutputDirectory/$DesignName.synth.v"
close $fileId
puts "\nInfo: Synthesis script created and can be accessed from path $OutputDirectory/$DesignName.ys"

#----------- Runing Synthesis ---------------
#
puts "\nInfo: Runing synthesis ....."

if {[catch {exec yosys -s $OutputDirectory/$DesignName.ys >& $OutputDirectory/$DesignName.synthesis.log} msg]} {
        puts "\nInfo: Synthesis FAIL. please refer to log $OutputDirectory/$DesignName.synthesis.log for errors"
} else {
        puts "\nInfo: Synthesis finished successfully"
}

#------------- Edit design.synthesis.v for further use ------------
#
set fileId [open /tmp/1 w]
puts -nonewline $fileId [exec grep -v -w "*" $OutputDirectory/$DesignName.synth.v]
close $fileId
set output [open $OutputDirectory/$DesignName.final.synth.v w]
set fid [open /tmp/1 r]
while {[gets $fid line] != -1} {
	puts -nonewline $output [string map {"\\" ""} $line]
	puts -nonewline $output "\n"
}
close $fid
close $output
puts "Final netlist is created at $OutputDirectory/$DesignName.final.synth.v for STA or PNR tools"

#--------------------------------------------------------------------------------------
#------- Static timing Analysis -------------------------------------------------------
#--------------------------------------------------------------------------------------

puts "\nInfo: Timing analysis started ....."
puts "\nInfo: Initializing number of threads, libraries, sdc, verilog netlist path ..."
source procs_raju/reopenStdout.proc
source procs_raju/set_num_threads.proc
reopenStdout $OutputDirectory/$DesignName.conf
set_multi_cpu_usage -localCpu 8
source procs_raju/read_lib.proc
read_lib -early $EarlyLibraryPath -late $LateLibraryPath
source ./procs_raju/read_verilog.proc
read_verilog $OutputDirectory/$DesignName.final.synth.v
source procs/read_sdc.proc
read_sdc $OutputDirectory/$DesignName.sdc
reopenStdout /dev/tty


#--- dumy spec file creation -----

if {$enable_prelayout_timing == 1} {
	puts "\nInfo: enable_prelayout_timing is $enable_prelayout_timing. Enabling zero-wire load parasitics"
	set spef_file [open $OutputDirectory/$DesignName.spef w]
puts $spef_file "*SPEF \"IEEE 1481-1998\" " 
puts $spef_file "*DESIGN \"$DesignName\" " 
puts $spef_file "*DATE \"Tue Sep 25 11:51:50 2012\" " 
puts $spef_file "*VENDOR \"TAU 2015 Contest\" " 
puts $spef_file "*PROGRAM \"Benchmark Parasitic Generator\" " 
puts $spef_file "*VERSION \"0.0\" " 
puts $spef_file "*DESIGN_FLOW \"NETLIST_TYPE_VERILOG\" " 
puts $spef_file "*DIVIDER / " 
puts $spef_file "*DELIMITER : " 
puts $spef_file "*BUS_DELIMITER [ ] " 
puts $spef_file "*T_UNIT 1 PS " 
puts $spef_file "*C_UNIT 1 FF " 
puts $spef_file "*R_UNIT 1 KOHM " 
puts $spef_file "*L_UNIT 1 UH " 
}
close $spef_file

set conf_file [open $OutputDirectory/$DesignName.conf a]
puts $conf_file "set_spef_fpath $OutputDirectory/$DesignName.spef"
puts $conf_file "init_timer "
puts $conf_file "report_timer "
puts $conf_file "report_wns "
puts $conf_file "report_worst_paths -numPaths 10000 "
close $conf_file

#--- pre-timing layout screen shot -----
set time_elapsed_in_us [time {exec OpenTimer < $OutputDirectory/$DesignName.conf >& $OutputDirectory/$DesignName.results}]
set time_elapsed_in_sec "[expr {[lindex $time_elapsed_in_us 0]/100000}]sec"
puts "\nInfo: STA finished in $time_elapsed_in_sec seconds"
puts "\nInfo: Refer to $OutputDirectory/$DesignName.results for warnings and errors"
set tcl_precision 3

#-----find worst output violation------#
set worst_RAT_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r]
set pattern {RAT}
while {[gets $report_file line] != -1} {
        if {[regexp $pattern $line]} {
        set worst_RAT_slack  "[expr {[lindex [join $line " "] 3]/1000}]ns"
        break
        } else {
        continue
        }
}
close $report_file

#-----find number of output violation------#
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
        incr count [regexp -all -- $pattern $line]
}
set Number_output_violations $count
close $report_file

#-----find worst setup violation------#
set worst_negative_setup_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r]
set pattern {Setup}
while {[gets $report_file line] != -1} {
        if {[regexp $pattern $line]} {
        set worst_negative_setup_slack "[expr {[lindex [join $line " "] 3]/1000}]ns"
        break
        } else {
        continue
        }
}
close $report_file


#-----find number of setup violation------#
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
        incr count [regexp -all -- $pattern $line]
}       
set Number_of_setup_violations $count
close $report_file

#-----find worst hold violation------#
set worst_negative_hold_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r]
set pattern {Hold}
while {[gets $report_file line] != -1} {
        if {[regexp $pattern $line]} {
        set worst_negative_hold_slack "[expr {[lindex [join $line " "] 3]/1000}]ns"
        break
        } else {
        continue
        }
}
close $report_file


#-----find number of hold violation------#
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
        incr count [regexp -all -- $pattern $line]
}
set Number_of_hold_violations $count
close $report_file

#-----find number of instance------#
set pattern {Num of gates}
set report_file [open $OutputDirectory/$DesignName.results r]
while {[gets $report_file line] != -1} {
        if {[regexp -all -- $pattern $line]} {
        set Instance_count [lindex [join $line " "] 4 ]
        break
        } else {
        continue
        }
}
close $report_file



puts "                      **** PRELAYOUT TIMING RESULTS ****                                                  "
set formatStr {%15s%15s%15s%15s%15s%15s%15s%15s%15s}

puts [format $formatStr "-----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]
puts [format $formatStr "Design Name" "Runtime" "Instance Count" "WNS setup" "FEP Setup" "WNS Hold" "FEP Hold" "WNS RAT" "FEP RAT"]
puts [format $formatStr "-----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]

foreach design_name $DesignName runtime $time_elapsed_in_sec instance_count $Instance_count wns_setup $worst_negative_setup_slack fep_setup $Number_of_setup_violations wns_hold $worst_negative_hold_slack fep_hold $Number_of_hold_violations wns_rat $worst_RAT_slack fep_rat $Number_output_violations {
        puts [format $formatStr $design_name $runtime $instance_count $wns_setup $fep_setup $wns_hold $fep_hold $wns_rat $fep_rat]
}

puts [format $formatStr "-----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]
puts "\n"

