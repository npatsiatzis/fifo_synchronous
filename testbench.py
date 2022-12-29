import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge,FallingEdge,ClockCycles
from cocotb.queue import QueueEmpty, QueueFull, Queue
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

fifo = []
fifo_rd = []

# #Callback functions to capture the bin content showing
full_cross = False
def notify():
	global full_cross
	full_cross = True

# at_least = value is superfluous, just shows how you can determine the amount of times that
# a bin must be hit to considered covered
@CoverPoint("top.data",xf = lambda x : x.i_data.value, bins = list(range(2**g_width)), at_least=1)
@CoverPoint("top.wr",xf = lambda x : x.i_wr.value, bins = [True,False], at_least=1)
@CoverPoint("top.rd",xf = lambda x : x.i_rd.value, bins = [True,False],at_least=1)
@CoverPoint("top.full",xf = lambda x : x.o_full.value,bins = [True,False],at_least=1)
@CoverPoint("top.empty",xf = lambda x : x.o_empty.value,bins = [True,False],at_least=1)
@CoverPoint("top.overflow",xf = lambda x : x.o_overflow.value,bins = [True,False],at_least=1)
@CoverPoint("top.underflow",xf = lambda x : x.o_underflow.value,bins = [True,False],at_least=1)
@CoverCross("top.cross", items = ["top.wr","top.data"], at_least=1)
def number_cover(dut):
	covered_number.append((dut.i_wr.value,dut.i_data.value))

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


#test the response whe doing random reads/writes with random data
#then read back the resulting contents of the fifo and
#compare them against the expected ones
@cocotb.test()
async def test_behavior(dut):

	cocotb.start_soon(Clock(dut.i_clk_wr, 5, units="ns").start())
	cocotb.start_soon(Clock(dut.i_clk_rd, 5, units="ns").start())
	await reset(dut,5)

	rd_data = 0 

	q = Queue(maxsize=2**g_depth)	
	data = random.randint(0,2**g_width-1)
	wr = random.randint(0,1)
	rd = random.randint(0,1)

	# for i in range(2**g_width):
	while full_cross != True:
		while((wr,data) in covered_number):
			data = random.randint(0,2**g_width-1)
			wr = random.randint(0,1)
			rd = random.randint(0,1)

		dut.i_wr.value = wr 
		dut.i_rd.value = rd 
		dut.i_data.value = data

		await FallingEdge(dut.i_clk_wr)
		await RisingEdge(dut.i_clk_wr)
		
		#these statements execute the same way
		#as we expect our fifo to execute
		if (rd == 1 and q.full() != True):
			try:
				rd_data = q.get_nowait()
			except QueueEmpty:
				pass

		if(wr == 1):
			try:
				q.put_nowait(data)
			except QueueFull:
				pass

		if (rd == 1 and q.full() == True):
			rd_data = q.get_nowait()

		number_cover(dut)
		coverage_db["top.cross"].add_threshold_callback(notify, 100)

	dut.i_wr.value =0
	dut.i_rd.value =1
	await RisingEdge(dut.i_clk_rd)
	while True:
		try:
			rd_data = q.get_nowait()
			fifo.append(rd_data)
			await RisingEdge(dut.i_clk_rd)
			fifo_rd.append(int(dut.o_data.value))
		except QueueEmpty:
			break

	print("fifo is {}".format(fifo))
	print("fifo bfm is {}".format(fifo_rd))
	assert not (fifo_rd != fifo),"Wrong behavior!"
	coverage_db.report_coverage(cocotb.log.info,bins=True)
	coverage_db.export_to_xml(filename="coverage.xml") 
#test the response when trying to push to a full fifo
@cocotb.test()
async def test_overflow(dut):
	"""Check the overflow condition"""

	cocotb.start_soon(Clock(dut.i_clk_wr, 5, units="ns").start())
	cocotb.start_soon(Clock(dut.i_clk_rd, 5, units="ns").start())
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

	assert not (fifo_rd != fifo),"Wrong behavior! Written to fifo {} and read back {}"\
	.format(fifo,fifo_rd)

#test the underflow condition
@cocotb.test()
async def test_underflow(dut):
	"""test the response when trying to get from an empty fifo"""

	cocotb.start_soon(Clock(dut.i_clk_wr, 5, units="ns").start())
	cocotb.start_soon(Clock(dut.i_clk_rd, 5, units="ns").start())
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
	"Wrong behavior! read address is {}, write address is {}, underflow is {}"\
	.format(dut.r_addr_r,dut.r_addr_w,dut.o_underflow)

