## Overview

This document outlines all the necessary steps to utilize the **RMX100 design on ZeBuS5** to use within a **Digital Twin system**. The process involves both hardware and software preparation, and performance evaluation for this SW on the actual HW.

### Main Steps:

## 1. Compile the Design Build

Compile the processor core and its surrounding environment onto the ZeBu Server5.

### Steps:

1. **Set up the ZeBu settings:**

bash


source /u/regress/INFRA_HOME/bin/zLicense.sh


source /u/regress/INFRA_HOME/sourceme.sh

2. **Set up the grid settings:**

source /global/lsf/cells/us01_zebutrain/conf/profile.lsf


module load lsf/us01_zebutrain

3. **Set up the ZeBu environment:**

source [build/scripts/zebu_scripts/setup_zebu.sh](build/scripts/zebu_scripts/setup_zebu.sh)

4. **Run arczebu.makefile to start compiling using zCui tool:**

cd build


make -f arczebu.makefile clean_all


make -f arczebu.makefile&

## 2. Compile software applications

Develop and compile software applications targeted for the bare-mmetal RMX100 processor.

### Steps:

1. **Creating folder(s) to have inside the C/C++ and the resulting executable:**
   create these folders anywhere you want, only pass the path to ccac command as shown in next step

2. **Compiling the written C/C++ using ccac cross compiler dedicated for ARC processors:**

ccac -tcf=[build/tool_config/arc.tcf](build/tool_config/arc.tcf) path to C/C++ Application -o path to where executable (.out) will be located


## 3. Run the compiled software

Run the compiled software applications on the bare-metal processor core emulated on the ZeBu Server5 hardware.

## Steps:

1. **Set up the ZeBu settings:**

bash


source /u/regress/INFRA_HOME/bin/zLicense.sh


source /u/regress/INFRA_HOME/sourceme.sh

2. **Set up the grid settings:**

source /global/lsf/cells/us01_zebutrain/conf/profile.lsf


module load lsf/us01_zebutrain

3. **Set up the ZeBu environment:**

source [build/scripts/zebu_scripts/setup_zebu.sh](build/scripts/zebu_scripts/setup_zebu.sh)

4. **Request access to ZeBu server5:**

cd build


rems --zebu.work zcui.work/zebu.work/ --host_os RH8 --timeout=7000& --wait

5. **Run in ZeBu server terminal:**

zebu_mdb your_app.out --xargs '--postconnect "command source init_mem.cmd"'

zebu_mdb your_app.out -w --xargs '--postconnect "command source init_mem.cmd"' ##if it is needed to generate .ztdb waveforms for power calculation


## 4. Estimate performance and power

Measure and analyze the performance and power consumption of the software applications running on the hardware.

### 4.1 Performance Estimation

Measure the number of clock cycles taken by the Processor to execute this running SW application onto it onto the actual hardware (ZeBu server5).
This Measurment is based on reading the mcycle register in csr (control status register) which stores the number of clock cycles taken by processor from the starting of execution.

 ## Steps:

1. **Add this assembly code in the C/C++ code that you run and want to calculate its performance :**
/* defining the rdtime() macro */

#define rdtime() ({unsigned long __tmp; \


__asm__ volatile ("csrr %0, mcycle" \


: "=r" (__tmp) /*output : register */ \


: /*input : none */ \


:/*clobbers:none */); \

__tmp; })
2. **Calculating the number of clock cycles taken by section of code:**

Begin_Time = rdtime();


....

The code you want to calculate its performance

....


End_Time = rdtime();



Elapsed_Time = End_Time - Begin_Time;


### 4.2 Post-Emulation Power Estimation

Measure the average power taken by the Processor to execute this running SW application onto it onto the actual hardware (ZeBu server5).

 ## Steps:

⚠️ Due to size limitations, the `Post_Emulation_Power` folder is **not included** in this repository.


You can download the full folder from OneDrive:"https://synopsys-my.sharepoint.com/:f:/p/rashour/EstVzZ4OH-BDt2HIPsrOoxcBXDWQpmRK861PeTOuZokeKQ?e=PgvDt2"


Download it into the following path relative to the repo root:"RMX100_ZS5_added_axi_slave/zebu_ifx_mini_rattle_6649a592_20250509/"


1. **Need some PD data for this RMX100 Processor from IP team :**
This data includes the PAR netlist, mapping file, SDC constraints, SPEF file and Libraies used.
This data can be found in [Post_Emulation_Power/data.](Post_Emulation_Power/data.)
The libraries can't be accessed by us in Egypt, so The first step in power_calculation which depends on it is done by some one else who have access to and the sessions saved and used after that in next steps in power_calculation, These sessions are in [Post_Emulation_Power/empower_trial/archipelago.sess/wsh_session.wddb](Post_Emulation_Power/empower_trial/archipelago.sess/wsh_session.wddb) and [Post_Emulation_Power/empower_trial/archipelago.sess/wsh_session.wcdb](Post_Emulation_Power/empower_trial/archipelago.sess/wsh_session.wcdb)
2. **Compiling RMX_100 Processor again with zCui version compatible with empower tool:**
The zCui version used before to compile RMX_100 Processor was "S-2021.09-T-20240508", This info can be found in [build/zcui.work/zebu.work/zTopBuild.log](build/zcui.work/zebu.work/zTopBuild.log)
This version is not compatible with empower tool used "empower/2025.06".
The RMX_100 need to be compiled again with one of supported version by empower tool, so it is compiled using this supported version "S-2021.09-2".
The compiled RMX_100 using this version "S-2021.09-2" and used in power calculation is found in [Post_Emulation_Power/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/zebu.work](Post_Emulation_Power/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/zebu.work) and the version is defined in [Post_Emulation_Power/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/zebu.work/zTopBuild.log](Post_Emulation_Power/zebu_ifx_mini_rattle_6649a592_20250509/build/zcui.work/zebu.work/zTopBuild.log)
3. **Running The power calculation steps:**
Using this data from PD team and this RMX_100 Processor compiled using compatible version with empower tool, The power calculation can be calculated going through some steps.
This steps are defined in [Post_Emulation_Power/empower_trial/steps](Post_Emulation_Power/empower_trial/steps)
There is a demo illustrating these steps to compute the power for specific SW Application (PID) can be accessed from this link "https://synopsys-my.sharepoint.com/:f:/p/rashour/Et863WXddyhFut6N49DtJzgB0rnAIP3HCj5IIeFPNrCfdQ?tdid=2f0e8268-c675-4a8d-8ad3-315558d3d806".

## 5. Run PID application as an example, estimating its performance and power
To demonstrate the whole working, There is example for SW application (PID) in [PID_Example](PID_Example)
There is the PID.cc code added to it the assembly code to calculate its performance, PID.out compiled using ccac cross compiler, PID_WV.log which is the result of running it on ZeBu terminal and this log contains the number of clock cycles taken to execute it.
The waveform ZTDB for running it to be used in power calculation and finally the power calculation outputs are in [Post_Emulation_Power](Post_Emulation_Power) (Power calculation is done for PID Example).



