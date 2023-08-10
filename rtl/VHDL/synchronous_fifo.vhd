--Dual clock FIFO for communicating data between two syncrhonous clock domains,
--the write and read domain.

--The FIFO operation rests upon 2 ready/valid handshakes, 1 for the write "domain" 
-- and 1 for the read "domain". Each of the handshakes consist of a Control Path 
--(trivial FSM) and a Data Path (performs the actions (push/pop) on the buffer).

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity synchronous_fifo is
	generic (
			g_width : natural :=8;
			g_depth : natural :=4);
	port (
			i_clk_wr : in std_ulogic;
			i_rst_wr : in std_ulogic;
			i_data : in std_ulogic_vector(g_width -1 downto 0);
			i_wr : in std_ulogic;

			i_clk_rd : in std_ulogic;
			i_rst_rd : in std_ulogic;
			i_rd : in std_ulogic;

			o_data : out std_ulogic_vector(g_width -1 downto 0);
			o_overflow : out std_ulogic;
			o_underflow : out std_ulogic;
			o_full : out std_ulogic;
			o_empty : out std_ulogic
		);
end synchronous_fifo;

architecture arch of synchronous_fifo is
	constant ADDR_DEPTH :natural := natural(ceil(log2(real(g_depth))));	--parameter of log2 is real valued

	signal r_fill : unsigned(g_depth downto 0);
	signal r_addr_w : unsigned(g_depth downto 0);
	alias  w_addr_w : unsigned(g_depth -1 downto 0) is r_addr_w(g_depth-1 downto 0);
	signal r_addr_r : unsigned(g_depth downto 0);
	alias w_addr_r : unsigned(g_depth-1 downto 0) is r_addr_r(g_depth-1 downto 0);

	type fifo_mem is array(0 to 2**g_depth-1) of std_ulogic_vector(g_width -1 downto 0);
	signal mem : fifo_mem :=(others => (others => '0'));

	--signals used in verification
	signal f_wr_done, f_rd_done : std_ulogic;
	signal f_data : std_ulogic_vector(g_width -1 downto 0);
begin

	veirification_util : process(i_clk_wr,i_rst_wr) is
	begin
		if(rising_edge(i_clk_wr)) then
			if(i_rst_wr = '1') then
				f_data <= (others => '0');
			else
				f_data <= i_data;
			end if;
		end if;
	end process; -- veirification_util

	--FIFO write domain

	--FIFO write ready/valid handshake, also called the push/full handshake
	--data flow control signals:
	--i_wr/valid <-> !o_full/ready

	--Write domain handhsake Control Path
	--2 data flow control signals (ready/valid) make up 4 possible states for the connection
	--Trivial FSM with 3 states collapsed in 1 (00,01,10) and the other state (11)
	--being the state where the transaction occurs.
	fifo_write : process(i_clk_wr)
	begin
		if(rising_edge(i_clk_wr)) then
			f_wr_done <= '0';

			if(i_rst_wr = '1') then
				r_addr_w <= (others => '0');
				f_wr_done <= '0';
			else
				if(i_wr = '1' and o_full = '0') then
					mem(to_integer(w_addr_w)) <= i_data;
					r_addr_w <= r_addr_w + 1;
					f_wr_done <= '1';
				end if;
			end if;
		end if;
	end process; -- fifo_write

	--FIFO read domain

	--FIFO read ready/valid handshake, also called the pop/empty handshake
	--data flow control signals:
	--i_rd/valid <-> !o_empty/ready

	--Read domain Control Path
	--FSM strucure analogous to the one in the Write domain
	fifo_read : process(i_clk_rd)
	begin
		if(rising_edge(i_clk_rd)) then
			f_rd_done <= '0';

			if(i_rst_rd = '1') then
				o_data <= (others => '0');
				r_addr_r <= (others => '0');
				f_rd_done <= '0';
			else
				if(i_rd = '1' and  o_empty = '0')then
					o_data <= mem(to_integer(w_addr_r));
					r_addr_r <= r_addr_r +1;
					f_rd_done <= '1';
				end if;
			end if;
		end if;
	end process; -- fifo_read

	--fifo oveflow/underflow detection
	overflow_underflow : process(all)
	begin
		if(o_full and i_wr) then
			o_overflow <= '1';
		else
			o_overflow <= '0';
		end if;
		if(o_empty and i_rd) then
			o_underflow <= '1';
		else
			o_underflow <= '0';
		end if;
	end process; -- overflow_underflow

	control_flow : process(all) 
	begin
		r_fill <= r_addr_w - r_addr_r;
		if(r_fill = 0) then
			o_empty <= '1';
		else
			o_empty <= '0';	
		end if;

		if(r_fill = 2**g_depth) then
			o_full <= '1';
		else
			o_full <= '0';
		end if;
	end process; -- control_flow
end arch;