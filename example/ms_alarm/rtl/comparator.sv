module comparator #(
    parameter int WIDTH = 3
) (
    input  logic [WIDTH-1:0] value,
    output logic             match
);
    assign match = &value;
endmodule
