import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer,RisingEdge,FallingEdge,ClockCycles,ReadWrite,ReadOnly
from cocotb.result import TestFailure
import random
from cocotb_coverage.coverage import CoverCross,CoverPoint,coverage_db

covered_number = []
g_width = int(cocotb.top.g_width)
g_depth = int(cocotb.top.g_depth)

full = False
empty = False
overflow = False
underflow = False
read_when_empty = False
write_when_full = False

# #Callback functions to capture the bin content showing
def notify_full():
	global full
	full = True

def notify_empty():
	global empty
	empty = True

def notify_overflow():
	global overflow
	overflow = True

def notify_underflow():
	global underflow
	underflow = True


# at_least = value is superfluous, just shows how you can determine the amount of times that
# a bin must be hit to considered covered
@CoverPoint("top.wr",xf = lambda x : x.i_wr.value, bins = [True,False], at_least=1)
@CoverPoint("top.rd",xf = lambda x : x.i_rd.value, bins = [True,False],at_least=1)
@CoverPoint("top.full",xf = lambda x : x.o_full.value,bins = [True,False],at_least=1)
@CoverPoint("top.empty",xf = lambda x : x.o_empty.value,bins = [True,False],at_least=1)
@CoverPoint("top.overflow",xf = lambda x : x.o_overflow.value,bins = [True,False],at_least=1)
@CoverPoint("top.underflow",xf = lambda x : x.o_underflow.value,bins = [True,False],at_least=1)
def number_cover(dut):
	pass

async def reset(dut,cycles=1):
	dut.i_rst_wr.value = 1
	dut.i_rst_rd.value = 1

	dut.i_wr.value = 0 
	dut.i_rd.value = 0
	dut.i_data.value = 0

	await ClockCycles(dut.i_clk_wr,cycles)
	await FallingEdge(dut.i_clk_wr)
	dut.i_rst_wr.value = 0
	dut.i_rst_rd.value = 0
	await RisingEdge(dut.i_clk_wr)
	dut._log.info("the core was reset")


#test the response when trying to push to a full fifo
@cocotb.test()
async def test_overflow(dut):
	"""Check the overflow condition"""

	cocotb.start_soon(Clock(dut.i_clk_wr, 10, units="ns").start())
	cocotb.start_soon(Clock(dut.i_clk_rd, 10, units="ns").start())
	await reset(dut,5)

	wr = 1
	rd = 0
	full = 0 
	empty = 0
	fifo = []
	fifo_rd = []

	data = random.randint(0,2**g_width-1)
	dut.i_wr.value = wr 
	dut.i_data.value = data
	dut.i_rd.value = rd 
	await RisingEdge(dut.i_clk_wr)
	while(full !=1):
		data = random.randint(0,2**g_width-1)
		dut.i_data.value = data
		fifo.append(int(dut.i_data.value))
		await RisingEdge(dut.i_clk_wr)
		full = dut.o_full.value

	for i in range(5):
		data = random.randint(0,2**g_width-1)
		await RisingEdge(dut.i_clk_wr)

	rd = 1
	dut.i_rd.value = rd
	dut.i_wr.value = 0 
	await RisingEdge(dut.i_clk_rd)
	while(empty != 1):
		await RisingEdge(dut.i_clk_rd)
		empty = dut.o_empty.value
		fifo_rd.append(int(dut.o_data.value))

	assert not (fifo_rd != fifo),"Wrong operation! Written to fifo {} and read back {}"\
	.format(fifo,fifo_rd)

#test the underflow condition
@cocotb.test()
async def test_underflow(dut):
	"""test the response when trying to get from an empty fifo"""

	cocotb.start_soon(Clock(dut.i_clk_wr, 10, units="ns").start())
	cocotb.start_soon(Clock(dut.i_clk_rd, 10, units="ns").start())
	await reset(dut,5)

	wr = 1 
	rd = 0 

	for i in range(2):
		data = random.randint(0,2**g_width-1)
		dut.i_wr.value = wr 
		dut.i_rd.value = rd 
		dut.i_data.value = data 

		await RisingEdge(dut.i_clk_wr)

	await RisingEdge(dut.i_clk_wr)
	wr = 0 
	rd = 1
	dut.i_wr.value = wr
	dut.i_rd.value = rd
	await RisingEdge(dut.i_clk_rd)
	for i in range(random.randint(3,10)):
		await RisingEdge(dut.i_clk_rd)

	assert not ((dut.r_addr_r != dut.r_addr_w) and dut.o_underflow !=1),\
	"Wrong operation! read address is {}, write address is {}, underflow is {}"\
	.format(dut.r_addr_r,dut.r_addr_w,dut.o_underflow)

