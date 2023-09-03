// `begin_keywords "1800-2017";
`default_nettype none

module synchronous_fifo
    #(
        parameter int G_WIDTH /*verilator public*/ = 8,
        parameter int G_DEPTH = 4
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

    logic [G_DEPTH : 0] r_addr_wr;
    logic [G_DEPTH : 0] r_addr_rd;

    logic [G_DEPTH : 0] r_fill_level;
    //verible urges to declare unpacked dimension in big-endian format
    //and declare any [0 : N-1] ranges as [N]
    logic [G_WIDTH -1 : 0] mem [2**G_DEPTH];

    always_ff @(posedge i_clk_wr) begin : wr_domain
        if(i_rst_wr) begin
            r_addr_wr <= '0;
        end else begin
            if(i_wr && !o_full) begin
                mem[r_addr_wr[G_DEPTH -1 : 0]] <= i_data;
                r_addr_wr <= r_addr_wr + 1;
            end
        end
    end

    always_ff @(posedge i_clk_rd) begin : rd_domain
        if(i_rst_rd) begin
            r_addr_rd <= '0;
            f_rd_done <= 1'b0;
        end else begin
            f_rd_done <= 1'b0;
            if(i_rd && !o_empty) begin
                o_data <= mem[r_addr_rd[G_DEPTH -1 : 0]];
                r_addr_rd <= r_addr_rd + 1;
                f_rd_done <= 1'b1;

            end
        end
    end

    assign o_overflow = (o_full && i_wr) ? 1'b1 : 1'b0;
    assign o_underflow = (o_empty && i_rd) ? 1'b1 : 1'b0;
    // always_comb begin : manage_over_under_flow
    //     o_overflow = 1'b0;
    //     if(o_full && i_wr)
    //         o_overflow = 1'b1;

    //     o_underflow = 1'b0;
    //     if(o_empty && i_rd)
    //         o_underflow = 1'b1;
    // end

    assign r_fill_level = r_addr_wr - r_addr_rd;
    assign o_empty = (r_fill_level == 0) ? 1'b1 : 1'b0;
    assign o_full = (r_fill_level == 2**G_DEPTH) ? 1'b1 : 1'b0;
    // always_comb begin : manage_full_empty
    //     r_fill_level = r_addr_wr - r_addr_rd;
    //     if(r_fill_level == 0)
    //         o_empty = 1'b1;
    //     else
    //         o_empty = 1'b0;

    //     if(r_fill_level == 2**G_DEPTH)
    //         o_full = 1'b1;
    //     else
    //         o_full = 1'b0;
    // end


                        /*          ######################      */
                        /*          Assertions && Coverage      */
                        /*          ######################      */
    // check conditions after reset
    assert_reset_wr : assert property(@(posedge i_clk_wr) $rose(i_rst_wr) |=> r_addr_wr ==0);
    assert_reset_rd : assert property(@(posedge i_clk_rd) $rose(i_rst_rd) |=> r_addr_rd ==0);

    //check fifo full and empty 
    check_full : assert property (@(posedge i_clk_rd) r_fill_level == 2**G_DEPTH |-> o_full == 1'b1);
    check_empty : assert property(@(posedge i_clk_rd) r_fill_level == 0 |-> o_empty == 1'b1);

    //check that data are not pushed in FIFO when they shouldn't
    check_push_overflow : assert property (@(posedge i_clk_wr) (i_wr && o_full && !i_rd) |=> $stable(r_addr_wr));
    //check that data are not removed from FIFO when they shouldn't
    check_pop_underflow : assert property (@(posedge i_clk_rd) (i_rd && o_empty && !i_wr) |=> $stable(r_addr_rd));

    // check that data are pushed when they should 
    check_push : assert property (@(posedge i_clk_wr) (i_wr && !o_full) |=> !($stable(r_addr_wr)));
    // check that data are removed from FIFO when they should
    check_pop : assert property (@(posedge i_clk_rd) (i_rd && !o_empty) |=> !($stable(r_addr_rd)));
endmodule : synchronous_fifo
