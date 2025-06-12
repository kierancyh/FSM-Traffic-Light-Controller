# FSM Traffic Light Controller
FSM-based UK-style Pedestrian Traffic Light Controller in .Verilog

## FSM Overview
The controller implements 5 traffic states using a Mealy-style FSM:
- **S0:** Red (30s)
- **S1:** Red & Amber (3s)
- **S2:** Green (30s)
- **S3:** Amber (3s)
- **S4:** Pedestrian Green (30s)

### FSM State Diagram
`State Transitions for Normal and Pedestrian Mode`

![FSM Diagram](FSM%20State%20Diagram.png)


## Modules 

### Source
**Traffic_Light.v** – Main FSM module utilising Mealy Logic with State Registers and counter for time control

### Testbench
**tb_Traffic_Light.v** – Stimulates  FSM with clock, reset and button inputs. Observes `traffic_light` and `pedestrian_light` outputs

## Tools Used:
**Xilinx Nexys4 DDR** – FPGA implementation                                                                                           
**Vivado 2024.2** – Simulation, Synthesis and Testbenching      

## Testbench & Simulation

This project includes a behavioral testbench:
- Simulates `cross_button` presses
- Monitors FSM state transitions
- Verifies correct timing and output logic

Transition Observations:
- `Red → Red/Amber → Green → Amber → Pedestrian Green`
- Proper reversion to normal states after pedestrian cycle ends

## Quick Start Guide
Follow these steps to clone, simulate and synthesize the project

### 1. Clone the Repository
git clone https://github.com/kierancyh/FSM-Traffic-Light-Controller.git

### 2. Open in Vivado
**1. Launch Vivado 2024.2**    

**2. Create a New RTL Project**                                                       
- Name your project
- Select "Do not specify sources at this time"
                                 
**3. After project setup**                                                        
- Go to Add Sources
- Add `Traffic_Light.v` from the src/ folder
- Add `tb_Traffic_Light.v` from the testbench/ folder
                                 
**4. Set `Traffic_Light.v` as the Top Module**

### 3. Run Behavioral Simulation
**1. In the Flow Navigator, go to** 

Simulation → Run Simulation → Run Behavioral Simulation    

**2. Use the waveform viewer to inspect key signals such as**                        
- `traffic_light` and `pedestrian_light` outputs
- Internal FSM transitions
- Timer behaviour for state durations

## Folder Structure
```plaintext
Traffic-Light-Controller/
├── README.md                         # Project overview and simulation guide
├── LICENSE                           # MIT License 
├── FSM State Diagram.png             # FSM diagram image
├── src/
│   └── Traffic_Light.v               # FSM implementation
├── testbench/
│   └── tb_Traffic_Light.v            # Simulation testbench
```

## License
This project is released under the MIT License
