


comp:
	rm -rf dams
	g++ -std=c++17 \
	${PWD}/core/main.cpp ${PWD}/core/cli_parser.cpp ${PWD}/core/simcore.cpp -o dams

run:
	./dams -n ../tests/analog/top.cir -t 5e-8

comp1:
	g++ -O2 -o main main.cpp -lngspice -lpthread \
	-I/home/slim/DAMS/ngspice/installation_shared/share/ngspice/include \
	-L/home/slim/DAMS/ngspice/installation_shared/lib

run1:
	#time ./main ../tests/analog/top.cir 5e-8
	./main -t 5e-8 -r sim.raw -l sim.log ../tests/analog/top.cir


diff:
	time ./main ../tests/analog/top.cir 10e-8
	time ngspice -b ../tests/analog/top.cir
	hyperfine --warmup 3 --runs 10 \
	'./main ../tests/analog/top.cir 10e-8' \
	'ngspice -b ../tests/analog/top.cir'

clean:
	rm -f main sim.raw *.log