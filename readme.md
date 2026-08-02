
# Mixed-Signal Simulation Wrapper

This repository is ro provide a small workflow for running mixed signal simulation that combines both analog spice netlists and digital verilog modules.
it is intended as a lightweight wrapper around ngspice for analog transient analysis and Verilator for digital simulation


## What this repo contains
- [setup_ngspice.csh](setup_ngspice.csh), [setup_verilator.csh](setup_verilator.csh), and [setup.csh](setup.csh) - setup scripts for installing and configuring the required tools.
- [tests](tests) - test directory ment to for simulators tests in ngspice and verilator.
- [src](src) - main simulation wrapper source code  

## Quick start

1. Install the toolchains:
- using both script you need to install verilator binary and ngspice shared library 
   ```bash
   ./setup_ngspice.sh
   ./setup_verilator.sh
   ```

2. Load the environment:
-  this will set the simulators paths and also the shared libarary path for ngspice use
   ```bash
   source setup.csh
   ```

3. Run the simulator tests
- run analog simulation and the verilator simulation tests to make sure installation went correct :
   ```bash
   make -C tests ng
   make -C tests verilator
   ```
3. compile and run the top dams wrapper 
   ```bash
   cd src 
   make comp
   make run
   ```
## Notes

- The analog example uses ngspice binary and write simulation signals to sim_ana.raw.
- The digital example uses Verilator and writes a VCD file named sim_dig.vcd.
- There is a python script that converts the raw fiel from ngspice to vcd format (was not able to dump vcd from ngspice, let me know if you have any idea) 

## Repository layout

```text
DAMS/
├── setup.csh
├── setup_ngspice.csh
├── setup_verilator.csh
├── tests/
│   ├── analog/
│   ├── digital/
│   ├── Makefile
│   └── raw2vcd.py
├── src
│   ├── Makefile
│   └── core 
└── readme.md
```
