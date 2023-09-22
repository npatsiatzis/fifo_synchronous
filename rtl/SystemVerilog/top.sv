`include "assertion.sv"
module top
    #(
        parameter int G_WIDTH /*verilator public*/ = 8,
        parameter int G_DEPTH /*verilator public*/= 10
    )

    (
    input logic i_clk_wr,    // clk write domain
    input logic i_rst_wr,   //  synch. active high reset write domain
    input logic i_wr,      //   write enable
    input logic [G_WIDTH -1 : 0] i_data,   //    write data in

    input logic i_clk_rd,    // clk read domain
    input logic i_rst_rd,   //  synch. active high reset read domain
    input logic i_rd,      //   read enable

    output logic [G_WIDTH -1 : 0] o_data,
    output logic o_overflow,
    output logic o_underflow,
    output logic o_full,
    output logic o_empty,
    output logic f_rd_done
    );

    synchronous_fifo #(.G_WIDTH(G_WIDTH),.G_DEPTH(G_DEPTH)) DUT 
    (
    	.i_clk_wr,
    	.i_rst_wr,
    	.i_wr,
    	.i_data,
    	.i_clk_rd,
    	.i_rst_rd,
    	.i_rd,
        .o_data,
        .o_underflow,
        .o_overflow,
        .o_full,
        .o_empty,
        .f_rd_done
	);

    // Note: Verilator only ssupports bind to a target module name, NOT to an instance path.
	bind synchronous_fifo assertion #(.G_DEPTH(G_DEPTH)) inst
    (
        .r_addr_wr(DUT.r_addr_wr),
        .r_addr_rd(DUT.r_addr_rd),
        .r_fill_level(DUT.r_fill_level),
    	.i_clk_wr,
    	.i_rst_wr,
    	.i_wr,
    	.i_clk_rd,
    	.i_rst_rd,
    	.i_rd,
        .o_underflow,
        .o_overflow,
        .o_full,
        .o_empty
	);
endmodule
