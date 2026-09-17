module debounce_filter #(
    parameter int COUNT_WIDTH = 3
) (
    input  logic clk,
    input  logic rst_n,
    input  logic noisy_in,
    output logic stable_high
);
    logic [COUNT_WIDTH-1:0] high_count;

    counter #(.WIDTH(COUNT_WIDTH)) u_counter (
        .clk    (clk),
        .rst_n  (rst_n),
        .enable (noisy_in),
        .value  (high_count)
    );

    comparator #(.WIDTH(COUNT_WIDTH)) u_comparator (
        .value (high_count),
        .match (stable_high)
    );
endmodule
