
module miter 
    #(
        parameter int G_WIDTH /*verilator public*/ = 8,
        parameter int G_DEPTH = 4
    )

    (
	    input logic i_clk_wr,    // clk write domain
	    input logic i_rst_wr,   //  synch. active high reset write domain
	    input logic i_clk_rd,    // clk read domain
	    input logic i_rst_rd,   //  synch. active high reset read domain

	    input logic ref_i_wr,      //   write enable
	    input logic ref_i_rd,      //   read enable
	    input logic [G_WIDTH -1 : 0] ref_i_data,   //    write data in

	    input logic uut_i_wr,
	    input logic uut_i_rd,
	    input logic [G_WIDTH -1 : 0] uut_i_data
	);
    wire [7 : 0] ref_o_data;
    wire ref_o_overflow;
    wire ref_o_underflow;
    wire ref_o_full;
    wire ref_o_empty;
    wire ref_f_rd_done;

    wire [7 : 0] uut_o_data;
    wire uut_o_overflow;
    wire uut_o_underflow;
    wire uut_o_full;
    wire uut_o_empty;
    wire uut_f_rd_done;

	reg f_past_valid;


	synchronous_fifo  ref
	(
		.mutsel(1'b0),
		.i_clk_wr  (i_clk_wr),
		.i_rst_wr  (i_rst_wr),
		.i_clk_rd  (i_clk_rd),
		.i_rst_rd  (i_rst_rd),
		.i_wr(ref_i_wr),
		.i_rd(ref_i_rd),
		.i_data(ref_i_data),
		.o_data(ref_o_data),
		.o_overflow(ref_o_overflow),
		.o_underflow(ref_o_underflow),
		.o_empty(ref_o_empty),
		.o_full(ref_o_full),
		.f_rd_done(ref_f_rd_done)
	);

	synchronous_fifo  uut
	(
		.mutsel(1'b1),
		.i_clk_wr  (i_clk_wr),
		.i_rst_wr  (i_rst_wr),
		.i_clk_rd  (i_clk_rd),
		.i_rst_rd  (i_rst_rd),
		.i_wr(uut_i_wr),
		.i_rd(uut_i_rd),
		.i_data(uut_i_data),
		.o_data(uut_o_data),
		.o_overflow(uut_o_overflow),
		.o_underflow(uut_o_underflow),
		.o_empty(uut_o_empty),
		.o_full(uut_o_full),
		.f_rd_done(uut_f_rd_done)
	);

	always @* begin
		assume_clk : assume(i_clk_wr == i_clk_rd);
		assume_rst : assume(i_rst_rd == i_rst_wr);
		assume_data : assume (ref_i_data == uut_i_data);
		assume_wr : assume (ref_i_wr == uut_i_wr);
		assume_rd : assume (ref_i_rd == uut_i_rd);
	end

	initial begin
		f_past_valid <= 1'b0;
		assume (i_rst_wr == 1'b1);	end
	
	always @(posedge i_clk_rd) begin
		f_past_valid <= 1'b1;
			if(!i_rst_rd) 
				if($past(f_past_valid) && f_past_valid && ref_f_rd_done && uut_f_rd_done)
					assert_data : assert (ref_o_data == uut_o_data);

				if(f_past_valid) begin
					assert_full : assert (ref_o_full == uut_o_full);
					asert_empty : assert (ref_o_empty == uut_o_empty);
					assert_overflow :assert (ref_o_overflow == uut_o_overflow);
					assert_underflow : assert (ref_o_underflow == uut_o_underflow);
				end
	end
endmodule
