

export NGSPICE_HOME=$PWD/ngspice
export VERILATOR_HOME=$PWD/verilator

export PATH=${VERILATOR_HOME}/installation/bin:$PATH
export PATH=${NGSPICE_HOME}/installation/bin:$PATH

source ~/venv/bin/activate

export LD_LIBRARY_PATH=$PWD/ngspice/installation_shared/lib/