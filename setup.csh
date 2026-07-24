

export NGSPICE_HOME=$PWD/verilator
export VERILATOR_HOME=$PWD/ngspice

unset VERILATOR_ROOT
export PATH=${VERILATOR_HOME}/installation/bin:$PATH
export PATH=${NGSPICE_HOME}/installation/bin:$PATH

source ~/venv/bin/activate
