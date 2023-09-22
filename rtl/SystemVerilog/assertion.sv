module assertion
    #(
        parameter int G_DEPTH /*verilator public*/= 10
    )

    (
        input logic [G_DEPTH : 0] r_addr_wr,
        input logic [G_DEPTH : 0] r_addr_rd,
        input logic [G_DEPTH : 0] r_fill_level,

        input logic i_clk_wr,    // clk write domain
        input logic i_rst_wr,   //  synch. active high reset write domain
        input logic i_wr,      //   write enable

        input logic i_clk_rd,    // clk read domain
        input logic i_rst_rd,   //  synch. active high reset read domain
        input logic i_rd,      //   read enable

        input logic o_overflow,
        input logic o_underflow,
        input logic o_full,
        input logic o_empty
    );


    // check conditions after reset
    assert_reset_wr : assert property(@(posedge i_clk_wr) disable iff(i_rst_wr) $rose(i_rst_wr) |=> r_addr_wr ==0)
        else $warning("Test Failure! ASSERTION FAILED!");
    assert_reset_rd : assert property(@(posedge i_clk_rd) disable iff(i_rst_rd) $rose(i_rst_rd) |=> r_addr_rd ==0)
        else $warning("Test Failure! ASSERTION FAILED!");

    //check fifo full and empty 
    check_full : assert property (@(posedge i_clk_rd) disable iff(i_rst_rd) r_fill_level == 2**G_DEPTH |-> o_full == 1'b1)
        else $warning("Test Failure! ASSERTION FAILED!");
    check_full_negative : assert property (@(posedge i_clk_wr) disable iff(i_rst_wr) !(r_fill_level == 2**G_DEPTH) |-> !o_full)
        else $warning("Test Failure! ASSERTION FAILED!");
    check_empty : assert property(@(posedge i_clk_rd) disable iff(i_rst_rd) r_fill_level == 0 |-> o_empty == 1'b1)
        else $warning("Test Failure! ASSERTION FAILED!");
    check_empty_negative : assert property (@(posedge i_clk_rd) disable iff(i_rst_rd) !(r_fill_level == 0) |-> !o_empty)
        else $warning("Test Failure! ASSERTION FAILED!");
    check_full_empty : assert property (@(posedge i_clk_wr) disable iff(i_rst_wr) o_empty |-> !o_full)
        else $warning("Test Failure! ASSERTION FAILED!");
    check_empty_full : assert property (@(posedge i_clk_wr) disable iff(i_rst_wr) o_full |-> !o_empty)
        else $warning("Test Failure! ASSERTION FAILED!");

    //check that data are not pushed in FIFO when they shouldn't
    check_push_overflow : assert property (@(posedge i_clk_wr) disable iff(i_rst_wr) (i_wr && o_full && !i_rd) |=> $stable(r_addr_wr))
        else $warning("Test Failure! ASSERTION FAILED!");
    //check that data are not removed from FIFO when they shouldn't
    check_pop_underflow : assert property (@(posedge i_clk_rd) disable iff(i_rst_rd) (i_rd && o_empty && !i_wr) |=> $stable(r_addr_rd))
        else $warning("Test Failure! ASSERTION FAILED!");

    // check that data are pushed when they should 
    check_push : assert property (@(posedge i_clk_wr) disable iff(i_rst_wr) (i_wr && !o_full) |=> !($stable(r_addr_wr)))
        else $warning("Test Failure! ASSERTION FAILED!");
    // check that data are removed from FIFO when they should
    check_pop : assert property (@(posedge i_clk_rd) disable iff(i_rst_rd) (i_rd && !o_empty) |=> !($stable(r_addr_rd)))
        else $warning("Test Failure! ASSERTION FAILED!");

    check_w_addr : assert property (@(posedge i_clk_wr) disable iff(i_rst_wr) i_wr && !o_full |=> r_addr_wr == ($past(r_addr_wr) + 1) % 2**(G_DEPTH+1))
        else $warning("Test Failure! ASSERTION FAILED!");
    check_r_addr : assert property (@(posedge i_clk_rd) disable iff(i_rst_rd) i_rd && !o_empty |=> r_addr_rd == ($past(r_addr_rd) + 1) % 2**(G_DEPTH+1))
    else $warning("Test Failure! ASSERTION FAILED!");        
    
    check_overflow : assert property (@(posedge i_clk_wr) disable iff(i_rst_wr) o_full && i_wr |-> o_overflow)
        else $warning("Test Failure! ASSERTION FAILED!");
    check_overflow_negative : assert property (@(posedge i_clk_wr) disable iff(i_rst_wr) !o_full |-> !o_overflow)
        else $warning("Test Failure! ASSERTION FAILED!");
    check_underflow : assert property (@(posedge i_clk_rd) disable iff(i_rst_rd) o_empty && i_rd |-> o_underflow)
        else $warning("Test Failure! ASSERTION FAILED!");
    check_underflow_negative : assert property (@(posedge i_clk_rd) disable iff(i_rst_rd) !o_empty |-> !o_underflow)
        else $warning("Test Failure! ASSERTION FAILED!");

    // check assignments 
    check_overflow_correctness : assert property (@(posedge i_clk_wr) disable iff(i_rst_wr) o_overflow == (i_wr & o_full))
        else $warning("Test Failure! ASSERTION FAILED!");
    check_underflow_correctness : assert property (@(posedge i_clk_rd) disable iff(i_rst_rd) o_underflow == (i_rd & o_empty))
        else $warning("Test Failure! ASSERTION FAILED!");
    check_rfill_correctness : assert property (@(posedge i_clk_wr) disable iff(i_rst_wr) r_fill_level == (r_addr_wr - r_addr_rd))
        else $warning("Test Failure! ASSERTION FAILED!");
    check_full_correctness : assert property (@(posedge i_clk_wr) disable iff(i_rst_wr) o_full == (r_fill_level == 2**G_DEPTH))
        else $warning("Test Failure! ASSERTION FAILED!");
    check_empty_correctness : assert property (@(posedge i_clk_rd) disable iff(i_rst_rd) o_empty == (r_fill_level == 0))
        else $warning("Test Failure! ASSERTION FAILED!");

endmodule
