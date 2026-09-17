module synchronizer (
    input  logic clk,
    input  logic rst_n,
    input  logic async_in,
    output logic sync_out
);
    logic stage1;

    dff u_stage1 (.clk(clk), .rst_n(rst_n), .d(async_in), .q(stage1));
    dff u_stage2 (.clk(clk), .rst_n(rst_n), .d(stage1),   .q(sync_out));
endmodule
