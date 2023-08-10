-- Dual clock FIFO for communicating data between two syncrhonous clock domains,
-- the write and read domain.

-- The FIFO operation rests upon 2 ready/valid handshakes, 1 for the write "domain"
-- and 1 for the read "domain". Each of the handshakes consist of a Control Path
-- (trivial FSM) and a Data Path (performs the actions (push/pop) on the buffer).

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	use ieee.math_real.all;

entity SYNCHRONOUS_FIFO is
	generic (
		G_WIDTH : natural := 8;
		G_DEPTH : natural := 4
	);
	port (
		I_CLK_WR    : in    std_ulogic;
		I_RST_WR    : in    std_ulogic;
		I_DATA      : in    std_ulogic_vector(G_WIDTH - 1 downto 0);
		I_WR        : in    std_ulogic;

		I_CLK_RD    : in    std_ulogic;
		I_RST_RD    : in    std_ulogic;
		I_RD        : in    std_ulogic;

		O_DATA      : out   std_ulogic_vector(G_WIDTH - 1 downto 0);
		O_OVERFLOW  : out   std_ulogic;
		O_UNDERFLOW : out   std_ulogic;
		O_FULL      : out   std_ulogic;
		O_EMPTY     : out   std_ulogic
	);
end entity SYNCHRONOUS_FIFO;

architecture ARCH of SYNCHRONOUS_FIFO is

	type fifo_mem is array(0 to 2 ** G_DEPTH - 1) of std_ulogic_vector(G_WIDTH - 1 downto 0);

	constant addr_depth : natural := natural(ceil(log2(real(G_DEPTH))));	-- parameter of log2 is real valued

	signal r_fill       : unsigned(G_DEPTH downto 0);
	signal r_addr_w     : unsigned(G_DEPTH downto 0);
	alias  w_addr_w     : unsigned(G_DEPTH - 1 downto 0) is r_addr_w(G_DEPTH - 1 downto 0);
	signal r_addr_r     : unsigned(G_DEPTH downto 0);
	alias  w_addr_r     : unsigned(G_DEPTH - 1 downto 0) is r_addr_r(G_DEPTH - 1 downto 0);

	signal mem          : fifo_mem;

	-- signals used in verification
	signal f_wr_done    : std_ulogic;
	signal f_rd_done    : std_ulogic;
	signal f_data       : std_ulogic_vector(G_WIDTH - 1 downto 0);

begin

	VERIFICATION_UTIL : process (I_CLK_WR, I_RST_WR) is
	begin

		if (rising_edge(I_CLK_WR)) then
			if (I_RST_WR = '1') then
				f_data <= (others => '0');
			else
				f_data <= I_DATA;
			end if;
		end if;

	end process VERIFICATION_UTIL;

	-- FIFO write domain

	-- FIFO write ready/valid handshake, also called the push/full handshake
	-- data flow control signals:
	-- I_WR/valid <-> !O_FULL/ready

	-- Write domain handhsake Control Path
	-- 2 data flow control signals (ready/valid) make up 4 possible states for the connection
	-- Trivial FSM with 3 states collapsed in 1 (00,01,10) and the other state (11)
	-- being the state where the transaction occurs.
	FIFO_WRITE : process (I_CLK_WR) is
	begin

		if (rising_edge(I_CLK_WR)) then
			f_wr_done <= '0';

			if (I_RST_WR = '1') then
				r_addr_w  <= (others => '0');
				f_wr_done <= '0';
			else
				if (I_WR = '1' and O_FULL = '0') then
					mem(to_integer(w_addr_w)) <= I_DATA;

					r_addr_w  <= r_addr_w + 1;
					f_wr_done <= '1';
				end if;
			end if;
		end if;

	end process FIFO_WRITE;

	-- FIFO read domain

	-- FIFO read ready/valid handshake, also called the pop/empty handshake
	-- data flow control signals:
	-- I_RD/valid <-> !O_EMPTY/ready

	-- Read domain Control Path
	-- FSM strucure analogous to the one in the Write domain
	FIFO_READ : process (I_CLK_RD) is
	begin

		if (rising_edge(I_CLK_RD)) then
			f_rd_done <= '0';

			if (I_RST_RD = '1') then
				O_DATA    <= (others => '0');
				r_addr_r  <= (others => '0');
				f_rd_done <= '0';
			else
				if (I_RD = '1' and  O_EMPTY = '0') then
					O_DATA    <= mem(to_integer(w_addr_r));
					r_addr_r  <= r_addr_r + 1;
					f_rd_done <= '1';
				end if;
			end if;
		end if;

	end process FIFO_READ;

	-- fifo oveflow/underflow detection
	OVERFLOW_UNDERFLOW : process (all) is
	begin

		if (O_FULL and I_WR) then
			O_OVERFLOW <= '1';
		else
			O_OVERFLOW <= '0';
		end if;

		if (O_EMPTY and I_RD) then
			O_UNDERFLOW <= '1';
		else
			O_UNDERFLOW <= '0';
		end if;

	end process OVERFLOW_UNDERFLOW;

	CONTROL_FLOW : process (all) is
	begin

		r_fill <= r_addr_w - r_addr_r;

		if (r_fill = 0) then
			O_EMPTY <= '1';
		else
			O_EMPTY <= '0';
		end if;

		if (r_fill = 2 ** G_DEPTH) then
			O_FULL <= '1';
		else
			O_FULL <= '0';
		end if;

	end process CONTROL_FLOW;

end architecture ARCH;