from cocotb.triggers import Timer, RisingEdge
from cocotb_coverage import crv
from cocotb.clock import Clock
from cocotb.queue import QueueEmpty, QueueFull, Queue
from cocotb_coverage.coverage import CoverCross,CoverPoint,coverage_db
from pyuvm import *
import random
import cocotb
import pyuvm
from utils import FifoBfm
from cocotb_coverage.coverage import CoverCross,CoverPoint,coverage_db


g_width = int(cocotb.top.g_width)
g_depth = int(cocotb.top.g_depth)
covered_values = []


covered_cross = []
# #Callback functions to capture the bin content showing
full_cross = False
def notify():
    global full_cross
    full_cross = True

# at_least = value is superfluous, just shows how you can determine the amount of times that
# a bin must be hit to considered covered
@CoverPoint("top.data",xf = lambda x : x, bins = list(range(2**g_width)), at_least=1)
def number_cover(dut):
    pass

class crv_inputs(crv.Randomized):
    def __init__(self,wr,rd,data):
        crv.Randomized.__init__(self)
        self.wr = wr
        self.rd = rd 
        self.data = data
        self.add_rand("wr",list(range(2)))
        self.add_rand("rd",list(range(2)))
        self.add_rand("data",list(range(2**g_width)))

# Sequence classes
class SeqItem(uvm_sequence_item):

    def __init__(self, name, wr,rd,data):
        super().__init__(name)
        self.i_crv = crv_inputs(wr,rd,data)

    def randomize_operands(self):
        self.i_crv.randomize()


class RandomSeq(uvm_sequence):
    async def body(self):
        while full_cross != True:
        # while len(covered_values) != 2**g_width:
            data_tr = SeqItem("data_tr", None, None,None)
            await self.start_item(data_tr)
            data_tr.randomize_operands()
            # while(data_tr.i_crv.data in covered_values):
            #     data_tr.randomize_operands()
            # covered_values.append(data_tr.i_crv.data)

            await self.finish_item(data_tr)


# class ReadSeq(uvm_sequence):
#     async def body(self):

#         #read enough to cause underflow
#         for i in range(2**g_depth+100):
#             data_tr = SeqItem("data_tr",0,1,0)
#             await self.start_item(data_tr)
#             await self.finish_item(data_tr)

class TestAllSeq(uvm_sequence):

    async def body(self):
        seqr = ConfigDB().get(None, "", "SEQR")
        random = RandomSeq("random")
        # read = ReadSeq("read_seq")
        await random.start(seqr)
        # await read.start(seqr)


class Driver(uvm_driver):

    def build_phase(self):
        self.ap = uvm_analysis_port("ap", self)

    def start_of_simulation_phase(self):
        self.bfm = FifoBfm()

    async def launch_tb(self):
        await self.bfm.reset()
        self.bfm.start_bfm()

    async def run_phase(self):
        await self.launch_tb()
        while True:
            data = await self.seq_item_port.get_next_item()
            await self.bfm.send_data((data.i_crv.wr, data.i_crv.rd,data.i_crv.data))
            await RisingEdge(self.bfm.dut.i_clk_wr)
            if(data.i_crv.rd == 1 and self.bfm.dut.o_empty.value == 0):
                result = await self.bfm.get_result()
                self.ap.write(result)
                data.result = result

                if(int(result) not in covered_values):
                    covered_values.append(int(result))
                number_cover(int(result))
                coverage_db["top.data"].add_threshold_callback(notify, 100)

            self.seq_item_port.item_done()


class Coverage(uvm_subscriber):

    def end_of_elaboration_phase(self):
        self.cvg = set()

    def write(self, data):
        # (wr, rd, i_data) = data
        number_cover(int(data))
        if((int(data)) not in self.cvg):
            self.cvg.add(int(data))

    def report_phase(self):
        try:
            disable_errors = ConfigDB().get(
                self, "", "DISABLE_COVERAGE_ERRORS")
        except UVMConfigItemNotFound:
            disable_errors = False
        if not disable_errors:
            if len(set(covered_values) - self.cvg) > 0:
                self.logger.error(
                    f"Functional coverage error. Missed: {set(covered_values)-self.cvg}")   
                assert False
            else:
                self.logger.info("Covered all input space")
                assert True


class Scoreboard(uvm_component):
    # def __init__(self,name,parent):
    #     super().__init__(name,parent)
    #     # self.result = 0
    #     # self.q = Queue(maxsize=2**g_depth)

    def build_phase(self):
        self.data_fifo = uvm_tlm_analysis_fifo("data_fifo", self)
        self.result_fifo = uvm_tlm_analysis_fifo("result_fifo", self)
        self.data_get_port = uvm_get_port("data_get_port", self)
        self.result_get_port = uvm_get_port("result_get_port", self)
        self.data_export = self.data_fifo.analysis_export
        self.result_export = self.result_fifo.analysis_export

    def connect_phase(self):
        self.data_get_port.connect(self.data_fifo.get_export)
        self.result_get_port.connect(self.result_fifo.get_export)

    def check_phase(self):
        passed = True

        try:
            self.errors = ConfigDB().get(self, "", "CREATE_ERRORS")
        except UVMConfigItemNotFound:
            self.errors = False
        while self.result_get_port.can_get():
            _, actual_result = self.result_get_port.try_get()
            data_success, data = self.data_get_port.try_get()

            if not data_success:
                self.logger.critical(f"result {actual_result} had no command")
            else:
                if int(data) == int(actual_result):
                    self.logger.info("PASSED")
                    print("i_tx_data is {}, rx_data is {}".format(int(data),int(actual_result)))
                else:
                    self.logger.error("FAILED")
                    print("i_tx_data is {}, rx_data is {}".format(int(data),int(actual_result)))
                    passed = False
        assert passed


        #     (wr,rd,i_data) = data 
        #     (result,overflow,underflow) = actual_result

        #     prev_result = self.result

        #     if (rd == 1 and self.q.full() != True):
        #         try:
        #             self.result = self.q.get_nowait()
        #         except QueueEmpty:
        #             assert not (underflow !=1),"Wrong Behavior!"

        #     if(wr == 1):
        #         try:
        #             self.q.put_nowait(i_data)
        #         except QueueFull:
        #             assert not (overflow != 1),"Wrong Behavior!"

        #     if (rd == 1 and self.q.full() == True):
        #         self.result = self.q.get_nowait()

        #     assert not (int(prev_result) != int(result)),"Wrong Behavior!"
 
        # assert passed


class Monitor(uvm_component):
    def __init__(self, name, parent, method_name):
        super().__init__(name, parent)
        self.method_name = method_name

    def build_phase(self):
        self.ap = uvm_analysis_port("ap", self)
        self.bfm = FifoBfm()
        self.get_method = getattr(self.bfm, self.method_name)

    async def run_phase(self):
        while True:
            datum = await self.get_method()
            self.logger.debug(f"MONITORED {datum}")
            self.ap.write(datum)


class Env(uvm_env):

    def build_phase(self):
        self.seqr = uvm_sequencer("seqr", self)
        ConfigDB().set(None, "*", "SEQR", self.seqr)
        self.driver = Driver.create("driver", self)
        self.data_mon = Monitor("data_mon", self, "get_data")
        self.coverage = Coverage("coverage", self)
        self.scoreboard = Scoreboard("scoreboard", self)

    def connect_phase(self):
        self.driver.seq_item_port.connect(self.seqr.seq_item_export)
        self.data_mon.ap.connect(self.scoreboard.data_export)
        self.data_mon.ap.connect(self.coverage.analysis_export)
        self.driver.ap.connect(self.scoreboard.result_export)


@pyuvm.test()
class Test(uvm_test):
    """Test synchronous FIFO with random values"""
    """Constrained random test generation for wr,rd,data"""
    """Test generation ends when all data values are written and read to/from memory at least once"""
    def build_phase(self):
        self.env = Env("env", self)

    def end_of_elaboration_phase(self):
        self.test_all = TestAllSeq.create("test_all")

    async def run_phase(self):
        self.raise_objection()
        cocotb.start_soon(Clock(cocotb.top.i_clk_wr, 10, units="ns").start())
        cocotb.start_soon(Clock(cocotb.top.i_clk_rd, 10, units="ns").start())
        await self.test_all.start()

        coverage_db.report_coverage(cocotb.log.info,bins=True)
        coverage_db.export_to_xml(filename="coverage.xml")
        self.drop_objection()
