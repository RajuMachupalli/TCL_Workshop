# TCL_Workshop
> Learning TCL scripting through UI design
>
## Steps
We will design a user interface for synthesis and timing analysis in the workshop. The synthesis tool is **YOSYS**, and **OpenTimer** for timing analysis. The user interface takes a .csv file containing the directory info of design, constraints, and output. The design process is divided into four parts:
1. Create a UNIX command with the .csv file as input argument.
2. Convert the inputs to format [1] & SDC, and feed them to **YOSYS** tool.
3. Convert format [1] files to format [2] and feed to **OpenTimer** tool.
4. The outputs from **OpenTimer** are format and display.

## UNIX command creation
create a vsdsynth file with help of vim, and add the text as follows to popout at the run time. the first line *#!/bin/tcsh -f* make the file as shell command. **echo " "** command to display the text. **set** will assign the *my_work_dir* variable to the current working directory. 

![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/89c7cee0-ee46-4b21-a9bc-56f0cf55af2d)

Change the vsdsynth files permission to available as a command, The below figure shows how the permission changes make it a command and output.

![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/7a0ad8d1-88e4-4ba9-b111-db3255d0c3a0)

## Convert inputs
1. ### Create variables###
  Create a variable that points to the files present in the input .csv file. Read the first column of .csv and create variable name without space, assign column as value to variable.
  ![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/fc3f0713-4892-4e68-b4e8-0426fefa8f41)


2. ### Check files/directory existance###
  Check the files or directory existance in at the location, if no file exit the program  produce error, if no directory then create an empty directory.
  
  ![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/b47e2d9a-7a09-45e5-8afe-f92dd197db98)

3. ### Identify INPUT, OUTPUT and CLOCKs in csv file ###
  find clock, inpu and output ports starting row in .csv file
  ![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/6facee43-41df-43c0-aee3-38bc4794758b)

  Create clock constraints
  
  ![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/9f4eabb4-dffd-4e7f-b0cf-fabfc8c357a7)

  Create input constraints
  
  ![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/8f66bfd2-f18d-4d70-96ee-58a4cd34b99d)

  ![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/82fa2c46-2631-4f92-8e13-ba51aca8938d)

  similarly create output constarinst.

4.  ### Set the SDC constraints ###

5.  ### Create timing file for OpenTimer ###
  First, eliminate [] in .sdc file so that we can index the lines in sdc file. 
  >puts -nonewline $tmp_file [string map {"\[" "" "\]" ""} [read $sdc]]

  identify the clocks, and write the clock name, period and duty cycle (duty cycle is the % of clock off)
  >
>

6.  


