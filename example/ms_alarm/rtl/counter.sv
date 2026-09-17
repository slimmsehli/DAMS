module counter #(
    parameter int WIDTH = 3
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic             enable,
    output logic [WIDTH-1:0] value
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            value <= '0;
        else if (!enable)
            value <= '0;
        else if (&value)
            value <= value;
        else
            value <= value + 1'b1;
    end
endmodule
