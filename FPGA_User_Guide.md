# Pet Feeder FPGA Project - User Guide

This document provides step-by-step instructions on how to build, deploy, and operate the **Automated Pet Feeding Scheduler** on a Basys 3 FPGA.

## 1. Prerequisites
- **Xilinx Vivado Design Suite** (2019.1 or newer recommended).
- **Basys 3 FPGA Board** (Artix-7 XC7A35T).
- **Micro-USB Cable** for programming and power.

---

## 2. Project Setup in Vivado

I have provided an automation script to simplify the setup process.

1.  Launch **Vivado**.
2.  In the bottom window, locate the **Tcl Console**.
3.  Navigate to the project root directory:
    ```tcl
    cd {E:/CSE-2K20/4-2/Sessional Course/Digital System Design Laboratory (CSE-4224)/Project/petfeeder}
    ```
4.  Run the creation script:
    ```tcl
    source create_project.tcl
    ```
5.  Vivado will generate the project structure and add all source files.

---

## 3. Building the Project

1.  In the **Flow Navigator** (left sidebar), click **Generate Bitstream**.
2.  If prompted to run Synthesis and Implementation first, click **Yes**.
3.  Wait for the process to complete. A "Bitstream Generation Completed" dialog will appear.

---

## 4. Programming the FPGA

1.  Connect your **Basys 3** board to your PC via Micro-USB.
2.  Ensure the power switch (top left) is set to **ON**.
3.  In Vivado, click **Open Hardware Manager** -> **Open Target** -> **Auto Connect**.
4.  Click **Program Device**. Select the `.bit` file generated in the `vivado_project` folder.
5.  Click **Program**.

---

## 5. Operating Instructions

Once programmed, the system will start tracking time from `00:00:00`.

### Controls
| Control | Function |
| :--- | :--- |
| **Switch 0** | Enable 08:00 AM Feeding slot |
| **Switch 1** | Enable 12:00 PM Feeding slot |
| **Switch 2** | Enable 05:00 PM (17:00) Feeding slot |
| **Switch 3** | Enable 09:00 PM (21:00) Feeding slot |
| **Button Center** | **Manual Override**: Immediate 10-second feeding |
| **Button Upper** | **System Reset**: Clears time and FSM state |

### Indicators
- **7-Segment Display**:
    - **IDLE Mode**: Displays current time as `HH.MM`.
    - **FEEDING Mode**: Displays the word **"FEED"**.
- **LED 0**: Lights up when the system is in `FEEDING` mode.
- **LED 15**: Acts as the `motor_en` signal (Simulates the feeder motor motor being active).

---

## 6. Technical Verification Summary

The implementation has been verified for correctness against the DSD Report:
- **Clock Divider**: Precisely derives 1Hz from 100MHz for accurate real-time tracking.
- **FSM Reliability**: Uses a Moore machine architecture ensuring glitch-free output to the motor driver.
- **State Protection**: Includes a logic-gate mechanism to prevent multiple triggers within the same minute.
- **Active-Low Mapping**: Correctly mapped to Basys 3 hardware specifications for segments and anodes.
