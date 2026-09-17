module alarm_latch (
    input  logic clk,
    input  logic rst_n,
    input  logic set,
    output logic alarm
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            alarm <= 1'b0;
        else if (set)
            alarm <= 1'b1;
    end
endmodule
