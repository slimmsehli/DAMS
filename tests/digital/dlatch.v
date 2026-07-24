

module dlatch(
  input clk,
  input reset,
  input d,
  output reg q
    );
  always @(posedge clk or posedge reset)
    if (reset)
      q <= 0;
    else if (clk)
      q <= d;
endmodule