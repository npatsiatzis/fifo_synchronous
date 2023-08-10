from cocotb_test.simulator import run
import pytest
import os

vhdl_compile_args = "--std=08"
sim_args = "--wave=wave.ghw"


tests_dir = os.path.abspath(os.path.dirname(__file__)) #gives the path to the test(current) directory in which this test.py file is placed
rtl_dir = tests_dir                                    #path to hdl folder where .vhdd files are placed


                                   
#run tests with generic values for length
@pytest.mark.parametrize("g_width", [str(i) for i in [4,9,4]])
@pytest.mark.parametrize("g_depth", [str(i) for i in range(4,9,1)])
def test_fifo(g_width,g_depth):

    module = "testbench"
    toplevel = "synchronous_fifo"   
    vhdl_sources = [
        os.path.join(rtl_dir, "../rtl/VHDL/synchronous_fifo.vhd"),
        ]

    parameter = {}
    parameter['g_width'] = g_width
    parameter['g_depth'] = g_depth

    extra_env = {f'PARAM_{k}': str(v) for k, v in parameter.items()}

    run(
        python_search=[tests_dir],                         #where to search for all the python test files
        vhdl_sources=vhdl_sources,
        toplevel=toplevel,
        module=module,

        vhdl_compile_args=[vhdl_compile_args],
        toplevel_lang="vhdl",
        parameters=parameter,                              #parameter dictionary
        extra_env=extra_env,
        sim_build="sim_build/"
        + "_".join(("{}={}".format(*i) for i in parameter.items())),
    )
