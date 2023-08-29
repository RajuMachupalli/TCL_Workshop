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

2. ### Check file/directory validity ###
  Check the files or directory in .csv are valid? if any file does not exist then the program produce error, if no directory then creates an empty directory.
  
  ![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/b47e2d9a-7a09-45e5-8afe-f92dd197db98)

3. ### Identify INPUT, OUTPUT and CLOCKs in constraints csv file ###
  The designs constarinst are provided in the .csv file, it is very easy is add or modify at .csv. But, the **Yosys** tool take the constraints in .sdc format, so we need to extract the data from .csv file and write an .sdc file. Example constraints.csv is shown below, CLOCK, INPU, OUTPUT are the words used to identify the respective constrainst. 

  ![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/f464048c-7603-47ea-8f05-bbcc46588b74)

  In the following script, we identify the CLOCK, INPUT, OUTPUT words in .csv file and used as reference to access respective ports.  

  ![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/6facee43-41df-43c0-aee3-38bc4794758b)

  An example code snippet for creating input constraints is shown in following two figures, first figure set the port's constrainst parameters and read from .csv file. in the second figure the the ports are identified as single-bit or multi-bit port so that a * is added to the contsrainst. Similar script except refence and constraint format id changed for CLOCK and OUTPUT ports constrainst. refer vsdsynth.tcl for full details.
    
  ![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/8f66bfd2-f18d-4d70-96ee-58a4cd34b99d)

  ![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/82fa2c46-2631-4f92-8e13-ba51aca8938d)

  Sript creates an output .sdc constraints file as shown below to use for **Yosys** tool. refer .sdc file in output directory.

  ![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/a4b06310-e146-4a8a-92e8-4252d6366bee)

4.  ### Set design hierarchy ###
   Set the design file hierarchy before run the sysnthesis.
  ![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/beb75d1f-f9d8-402e-8f9a-073ebf32c857)

5. ### Run synthesis ###
  To run **Yosys** tool for synthesis. create a $DesignName.ys file with scripts as shown in figure, refer tool for details. Run the synthesis in UNIX shell using follwing command
  > exec yosys -s $OutputDirectory/$DesignName.ys >& $OutputDirectory/$DesignName.synthesis.log
  The synthesis log output si stored in .synthesis.log file and synthesized netlist file is written in .synth.v in output directory.

  ![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/0d406188-d6dc-446d-9a95-95eae40fbab8)

## Create constraints for timing analysis ##
1. ### Modify netlist ###
The netlist produced by **Yosys** has "/" mark at ports connect which is not needed for **OpenTimer** as shown in the below figure, so will remove the "/" in the netlist file by folowing script.
> while {[gets $fid line] != -1} {
>        puts -nonewline $output [string map {"\\" ""} $line]
>        puts -nonewline $output "\n"
> }

![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/9bd49ea2-844a-4211-83db-b1b0a811ab6e)

2. ### Create constraints ###
   Instead of continue writing the vsdsynth.tcl script, we created a procs, which will help to create a functions in TCL and call as needed. we created a read_sdc.proc to read the existing .sdc file and generate modified constarint file. The following figure shows the difference representing same constraints file. For **OpenTimer** the bus ports are expanded and all constarints for a port is written in single line. we need to write the script to get and generate the modified .timing file. **OpenTimer** takes .timing file as constarint file.
   ![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/cab6d82d-7b7f-4e23-baa8-478d05d07738)
 
 Below code snippet shows the scropt in procs to convert clock constarinst, similar logic is extended for the ports. refet */procs_raju/read_sdc.proc* for full details. 
 ![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/1930f072-053d-4ca4-9374-f4cffed7b3d2)

At the end of sdc convertion, we have to expend the multi-bit ports, the multi-bit ports are identified based on "*" at the end of the port in original constrainst. Code snippet is shown below.
![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/ead21920-15fa-4473-9d82-d70b81c37b9a)

3. ### Create dumy .spef file ###
   The **OpenTimer** tool need .spef for timing analysis. Rightnow, we are creating a dumy .spef file with manual values, it can be replaced with the data later.

   ![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/9fd098a7-0762-4e2d-a5e3-395cfa899343)
## Run Timing analysis ##
While writing procs for sdc convertion, a configuration file is created for **OpenTimer**, the .conf file contains paths for all modified netlist, constarints as shown below:

![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/00bf2dc1-ee64-4089-a28b-ab395edcd7f4)

Finally run the, **OpenTimer** with the command
> exec OpenTimer < $OutputDirectory/$DesignName.conf >& $OutputDirectory/$DesignName.results


## Display results ##
The final sript to dispaly the results are codded as below, the parameter value is extracted from file $OutputDirectory/$DesignName.results generated by **OpenTime**

![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/cc19e70f-27f4-4bc1-b9a8-f9762dbf2eca)


Final Output is:

![image](https://github.com/RajuMachupalli/TCL_Workshop/assets/52839597/25a35a13-8fe8-4e3b-9ee8-7c70c81245d3)



# Support #
Thanks to [VSD Systems](https://www.vlsisystemdesign.com/about-us/) and Kunal Ghosh for the couse materials.
Specials thanks to all the contributors of Opensource softwares like **Yosys**, **OpenTimer**, **Linux**
