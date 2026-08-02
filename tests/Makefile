
clean:
	rm -rf sim*

ng:
	rm -rf simdir_ngspice ; mkdir simdir_ngspice; cd simdir_ngspice ; \
	ngspice -b ../analog/top.cir -r sim_ana.raw 2>&1 | tee sim_ana.log ; \
	python3 ../raw2vcd.py sim_ana.raw sim_ana.vcd ; \
	rm -rf sim_ana.raw

verilator:
	verilator --timing --binary --trace -Mdir simdir_verilator -o simd \
	digital/dlatch.v digital/top.v --top-module top
	cd simdir_verilator ;\
	./simd

