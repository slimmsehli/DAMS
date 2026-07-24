
clean:
	rm -rf sim*

ng:
	ngspice -b analog/top.cir -r sim.raw 2>&1 | tee sim.log

ng_wave:
	#head -c 100 sim.raw | xxd
	python3 raw2vcd.py sim.raw sim.vcd 
	gtkwave sim.vcd

verilator:
	verilator --timing --binary --trace -Mdir simdir_verilator -o simv \
	digital/dlatch.v digital/top.v --top-module top
	cd simdir_verilator ;\
	./simv

verilator_wave:
	gtkwave simdir_verilator/sim.vcd