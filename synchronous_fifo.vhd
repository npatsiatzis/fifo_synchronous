--Dual clock FIFO for communicating data between two syncrhonous clock domains,
--the write and read domain.

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
	--signal w_empty_int : std_ulogic;
	--signal w_full_int : std_ulogic;

	signal r_fill : unsigned(g_depth downto 0);
	signal r_addr_w : unsigned(g_depth downto 0);
	alias  w_addr_w : unsigned(g_depth -1 downto 0) is r_addr_w(g_depth-1 downto 0);
	signal r_addr_r : unsigned(g_depth downto 0);
	alias w_addr_r : unsigned(g_depth-1 downto 0) is r_addr_r(g_depth-1 downto 0);

	type fifo_mem is array(0 to 2**g_depth-1) of std_ulogic_vector(g_width -1 downto 0);
	signal mem : fifo_mem;
begin

	--FIFO write domain
	fifo_write : process(i_clk_wr)
	begin
		if(rising_edge(i_clk_wr)) then
			if(i_rst_wr = '1') then
				r_addr_w <= (others => '0');
			else
				if(i_wr = '1' and o_full = '0') then
					mem(to_integer(w_addr_w)) <= i_data;
					r_addr_w <= r_addr_w + 1;
				end if;
			end if;
		end if;
	end process; -- fifo_write

	--FIFO read domain
	fifo_read : process(i_clk_rd)
	begin
		if(rising_edge(i_clk_rd)) then
			if(i_rst_rd = '1') then
				r_addr_r <= (others => '0');
			else
				if(i_rd = '1' and  o_empty = '0')then
					o_data <= mem(to_integer(w_addr_r));
					r_addr_r <= r_addr_r +1;
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