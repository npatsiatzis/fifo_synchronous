from cocotb.triggers import Timer,RisingEdge,ClockCycles
from cocotb.queue import QueueEmpty, Queue
import cocotb
import enum
import random
from cocotb_coverage import crv 
from cocotb_coverage.coverage import CoverCross,CoverPoint,coverage_db
from pyuvm import utility_classes



class FifoBfm(metaclass=utility_classes.Singleton):
    def __init__(self):
        self.dut = cocotb.top
        self.driver_queue = Queue(maxsize=1)
        self.data_mon_queue = Queue(maxsize=0)
        self.result_mon_queue = Queue(maxsize=0)

    async def send_data(self, data):
        await self.driver_queue.put(data)

    async def get_data(self):
        data = await self.data_mon_queue.get()
        return data

    async def get_result(self):
        result = await self.result_mon_queue.get()
        return result

    async def reset(self):
        await RisingEdge(self.dut.i_clk_wr)
        self.dut.i_rst_wr.value = 1
        self.dut.i_rst_rd.value = 1
        self.dut.i_data.value = 0
        self.dut.i_wr.value = 0 
        self.dut.i_rd.value = 0
        await ClockCycles(self.dut.i_clk_wr,5)
        self.dut.i_rst_wr.value = 0
        self.dut.i_rst_rd.value = 0
        await RisingEdge(self.dut.i_clk_wr)


    async def driver_bfm(self):
        self.dut.i_wr.value = 0 
        self.dut.i_data.value = 0
        self.dut.i_rd.value = 0
        while True:
            await RisingEdge(self.dut.i_clk_wr)
            try:
                (wr,rd,data) = self.driver_queue.get_nowait()
                self.dut.i_wr.value = wr
                self.dut.i_data.value = data
                self.dut.i_rd.value = rd
            except QueueEmpty:
                pass

    async def data_mon_bfm(self):
        while True:
            await RisingEdge(self.dut.i_clk_wr)
            data_tuple = (self.dut.i_wr.value,self.dut.i_rd.value,self.dut.i_data.value)
            self.data_mon_queue.put_nowait(data_tuple)

    async def result_mon_bfm(self):
        while True:
            await RisingEdge(self.dut.i_clk_wr)
            self.result_mon_queue.put_nowait((self.dut.o_data.value,self.dut.o_overflow.value,self.dut.o_underflow.value))


    def start_bfm(self):
        cocotb.start_soon(self.driver_bfm())
        cocotb.start_soon(self.data_mon_bfm())
        cocotb.start_soon(self.result_mon_bfm())