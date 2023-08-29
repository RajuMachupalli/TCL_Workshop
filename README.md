# TCL_Workshop
> Learning TCL scripting through UI design
>
## Steps
We will design a user interface for synthesis and timing analysis in the workshop. The synthesis tool is **YOSYS**, and **OpenTimer** for timing analysis. The user interface takes a .csv file containing the directory info of design, constraints, and output. The design process is divided into four parts:
1. Create a UNIX command with the .csv file as input argument.
2. Generate design constarints for **YOSYS** tool, and Synthesize the design.
3. Reformat the constraints file for **OpenTimer** tool, and run timing analysis.
4. Dispaly the output from **OpenTimer** on command line.

   Basic knowledge of TCL scripting is necessary to understand the document, we are not expalining the each command here. The document provides an overview of steps necessary to create an UI in tools automation.
   The synthesis/timing analysis requires design files, constarints, and library. It is very hard to provide each file as commond argument, instead we can privde the path to file directory and ask the tool to extarct the necessary information. In this workshop the necessary files directories are provided in an .csv file, as shown in the below figure
    ![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/bc89e6a1-cb72-448d-8afb-7219fb8858fd)

   
## UNIX command creation ##
create a ***vsdsynth*** file with help of vim, and add the text as follows. The first line *#!/bin/tcsh -f* make the file as shell command. **echo " "** command to display the text. **set** will assign the *my_work_dir* variable to the current working directory. 

![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/89c7cee0-ee46-4b21-a9bc-56f0cf55af2d)

Change the vsdsynth files permission to available as a command, The below figure shows how the permission changes make it a command and output.

![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/7a0ad8d1-88e4-4ba9-b111-db3255d0c3a0)

## Create Design constrainst for Yosys ##
1. ### Create variables ###
  The inputs for tool is in .csv file, we need to create a variable that points to the files or directories. Read the first column of .csv and create variable name without space, assign second column data as value to the variables. 
  ![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/fc3f0713-4892-4e68-b4e8-0426fefa8f41)


2. ### Check files/directory validity ###
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

4.  ### Set design hierarchy ###
  ![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/beb75d1f-f9d8-402e-8f9a-073ebf32c857)

5. ### Run Yosys tool for synthesis ###
  ![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/0d406188-d6dc-446d-9a95-95eae40fbab8)
  

6. 

7.  

8.  ### Create timing file for OpenTimer ###
  First, eliminate [] in .sdc file so that we can index the lines in sdc file. 
  >puts -nonewline $tmp_file [string map {"\[" "" "\]" ""} [read $sdc]]

  identify the clocks, and write the clock name, period and duty cycle (duty cycle is the % of clock off)
  >
>

6.  


