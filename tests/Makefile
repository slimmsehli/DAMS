
clean:
	rm -rf sim*

ng:
	ngspice -b analog/top.cir -r sim.raw 2>&1 | tee sim.log
	python3 raw2vcd.py sim.raw sim.vcd
	rm -rf sim.raw

verilator:
	verilator --timing --binary --trace -Mdir simdir_verilator -o simv \
	digital/dlatch.v digital/top.v --top-module top
	cd simdir_verilator ;\
	./simv

wave:
	gtkwave sim.vcd &
