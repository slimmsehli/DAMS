
module top;

reg clk;
reg reset;
reg d;
wire q1, q2;

always #1ns clk = ~clk;

dlatch dlatch1(
  .clk(clk),
  .reset(reset),
  .d(d),
  .q(q1)
);

dlatch dlatch2(
  .clk(clk),
  .reset(reset),
  .d(q1),
  .q(q2)
);


initial begin
    $display($time, " [INFO] - Simulation started");
    $dumpfile("sim.vcd");
    $dumpvars(0, top); 
    reset = 1;
    clk = 0;
    d = 0;
    #2ns reset = 0;
    repeat (10) begin 
        @(negedge clk);
        d = bit'($urandom);
    end
    $finish;
end

final begin
    $display($time, " [INFO] - Simulation finished");
end

endmodule