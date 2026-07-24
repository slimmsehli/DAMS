
clean:
	rm -rf sim*

ng:
	ngspice -b analog/top.cir -r sim.raw 2>&1 | tee sim.log

wave:
	head -c 100 sim.raw | xxd
	python3 raw2vcd.py sim.raw sim.vcd 
	gtkwave sim.vcd
