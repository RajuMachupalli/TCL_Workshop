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



