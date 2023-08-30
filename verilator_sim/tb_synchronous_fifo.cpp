// Verilator Example
#include <stdlib.h>
#include <iostream>
#include <cstdlib>
#include <memory>
#include <set>
#include <deque>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include <verilated_cov.h>
#include "Vsynchronous_fifo.h"
#include "Vsynchronous_fifo_synchronous_fifo.h"   //to get parameter values, after they've been made visible in SV


#define MAX_SIM_TIME 300
#define VERIF_START_TIME 7
vluint64_t sim_time = 0;
vluint64_t posedge_cnt = 0;

// input interface transaction item class
class InTx {
    private:
    public:
        uint32_t i_wr;
        uint32_t i_rd;
        uint32_t i_data;
};


// output interface transaction item class
class OutTx {
    public:
        uint32_t o_data;
};

//in domain Coverage
class InCoverage{
    private:
        std::set <uint32_t> in_cvg;
    
    public:
        void write_coverage(InTx *tx){
            // std::tuple<uint32_t,uint32_t> t;
            // t = std::make_tuple(tx->A,tx->B);
            // in_cvg.insert(t);
            in_cvg.insert(tx->i_data);
        }

        bool is_covered(uint32_t A){
            // std::tuple<uint32_t,uint32_t> t;
            // t = std::make_tuple(A,B);            
            // return in_cvg.find(t) == in_cvg.end();
            return in_cvg.find(A) == in_cvg.end();
        }
};

//out domain Coverage
class OutCoverage {
    private:
        std::set <uint32_t> coverage;
        int cvg_size = 0;

    public:
        void write_coverage(OutTx* tx){
            coverage.insert(tx->o_data); 
            cvg_size++;
        }

        bool is_full_coverage(){
            return cvg_size == (1 << (Vsynchronous_fifo_synchronous_fifo::G_WIDTH));
            // return coverage.size() == (1 << (Vsynchronous_fifo_synchronous_fifo::G_WIDTH));
        }
};


// ALU scoreboard
class Scb {
    private:
        std::deque<InTx*> in_q;
        
    public:
        // Input interface monitor port
        void writeIn(InTx *tx){
            // Push the received transaction item into a queue for later
            in_q.push_back(tx);
        }

        // Output interface monitor port
        void writeOut(OutTx* tx){
            // We should never get any data from the output interface
            // before an input gets driven to the input interface
            if(in_q.empty()){
                std::cout <<"Fatal Error in AluScb: empty InTx queue" << std::endl;
                exit(1);
            }

            // Grab the transaction item from the front of the input item queue
            InTx* in;
            in = in_q.front();
            in_q.pop_front();

            if(in->i_data!= tx->o_data){
                std::cout << "Test Failure!" << std::endl;
                std::cout << "Expected : " <<  in->i_data << std::endl;
                std::cout << "Got : " << tx->o_data << std::endl;
                exit(1);
            } else {
                std::cout << "Test PASS!" << std::endl;
                std::cout << "Expected : " <<  in->i_data << std::endl;
                std::cout << "Got : " << tx->o_data << std::endl; 
            }

            // As the transaction items were allocated on the heap, it's important
            // to free the memory after they have been used
            delete in;    //input monitor transaction
            delete tx;    //output monitor transaction
        }
};

// interface driver
class InDrv {
    private:
        // Vsynchronous_fifo *dut;
        std::shared_ptr<Vsynchronous_fifo> dut;
    public:
        InDrv(std::shared_ptr<Vsynchronous_fifo> dut){
            this->dut = dut;
        }

        void drive(InTx *tx){
            // we always start with in_valid set to 0, and set it to
            // 1 later only if necessary
            // dut->i_valid = 0;

            // Don't drive anything if a transaction item doesn't exist
            if(tx != NULL){
                dut->i_data = tx->i_data;
                dut->i_wr = tx->i_wr;
                dut->i_rd = tx->i_rd;
                // Release the memory by deleting the tx item
                // after it has been consumed
                delete tx;
            }
        }
};

// input interface monitor
class InMon {
    private:
        // Vsynchronous_fifo *dut;
        std::shared_ptr<Vsynchronous_fifo> dut;
        // Scb *scb;
        std::shared_ptr<Scb>  scb;
        // InCoverage *cvg;
        std::shared_ptr<InCoverage> cvg;
    public:
        InMon(std::shared_ptr<Vsynchronous_fifo> dut, std::shared_ptr<Scb>  scb, std::shared_ptr<InCoverage> cvg){
            this->dut = dut;
            this->scb = scb;
            this->cvg = cvg;
        }

        void monitor(){
            if(dut->i_wr == 1 && dut->o_full == 0){
                InTx *tx = new InTx();
                tx->i_data = dut->i_data;
                // then pass the transaction item to the scoreboard
                scb->writeIn(tx);
                cvg->write_coverage(tx);
            }
        }
};

// ALU output interface monitor
class OutMon {
    private:
        // Vsynchronous_fifo *dut;
        std::shared_ptr<Vsynchronous_fifo> dut;
        // Scb *scb;
        std::shared_ptr<Scb> scb;
        // OutCoverage *cvg;
        std::shared_ptr<OutCoverage> cvg;
    public:
        OutMon(std::shared_ptr<Vsynchronous_fifo> dut, std::shared_ptr<Scb> scb, std::shared_ptr<OutCoverage> cvg){
            this->dut = dut;
            this->scb = scb;
            this->cvg = cvg;
        }

        void monitor(){
            if(dut->f_rd_done == 1){
                
                OutTx *tx = new OutTx();
                tx->o_data = dut->o_data;

                // then pass the transaction item to the scoreboard
                scb->writeOut(tx);
                cvg->write_coverage(tx);
            }
        }
};

//sequence (transaction generator)
// coverage-driven random transaction generator
// This will allocate memory for an InTx
// transaction item, randomise the data, until it gets
// input values that have yet to be covered and
// return a pointer to the transaction item object
class Sequence{
    private:
        InTx* in;
        // InCoverage *cvg;
        std::shared_ptr<InCoverage> cvg;
    public:
        Sequence(std::shared_ptr<InCoverage> cvg){
            this->cvg = cvg;
        }

        InTx* genTx(){
            in = new InTx();
            // std::shared_ptr<InTx> in(new InTx());
            if(rand()%5 == 0){
                in->i_data = rand() % (1 << Vsynchronous_fifo_synchronous_fifo::G_WIDTH);  
                in->i_wr = rand() % 2;
                in->i_rd = rand() % 2;  

                while(cvg->is_covered(in->i_data) == false){
                    in->i_data = rand() % (1 << Vsynchronous_fifo_synchronous_fifo::G_WIDTH);   
                }
                return in;
            } else {
                return NULL;
            }
        }
};


void dut_reset (std::shared_ptr<Vsynchronous_fifo> dut, vluint64_t &sim_time){
    dut->i_rst_wr = 0;
    dut->i_rst_rd = 0;
    if(sim_time >= 3 && sim_time < VERIF_START_TIME -1){
        dut->i_rst_wr = 1;
        dut->i_rst_rd = 1;
    }
}

int main(int argc, char** argv, char** env) {
    srand (time(NULL));
    Verilated::commandArgs(argc, argv);
    // Vsynchronous_fifo *dut = new Vsynchronous_fifo;

    std::shared_ptr<VerilatedContext> contextp{new VerilatedContext};
    std::shared_ptr<Vsynchronous_fifo> dut(new Vsynchronous_fifo{contextp.get(), "TOP"});

    // std::shared_ptr<Vsynchronous_fifo> dut(new Vsynchronous_fifo);

    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    InTx   *tx;

    // Here we create the driver, scoreboard, input and output monitor and coverage blocks
    std::unique_ptr<InDrv> drv(new InDrv(dut));
    std::shared_ptr<Scb> scb(new Scb());
    std::shared_ptr<InCoverage> inCoverage(new InCoverage());
    std::shared_ptr<OutCoverage> outCoverage(new OutCoverage());
    std::unique_ptr<InMon> inMon(new InMon(dut,scb,inCoverage));
    std::unique_ptr<OutMon> outMon(new OutMon(dut,scb,outCoverage));
    std::unique_ptr<Sequence> sequence(new Sequence(inCoverage));

    while (outCoverage->is_full_coverage() == false) {
        // 0-> all 0s
        // 1 -> all 1s
        // 2 -> all random
        Verilated::randReset(2); 
        dut_reset(dut, sim_time);
        dut->i_clk_wr ^= 1;
        dut->i_clk_rd ^= 1;
        dut->eval();

        m_trace->dump(sim_time);
        sim_time++;

        // Do all the driving/monitoring on a positive edge
        if (dut->i_clk_wr == 1){

            if (sim_time >= VERIF_START_TIME) {
                // Generate a randomised transaction item 
                // tx = rndInTx(inCoverage);
                tx = sequence->genTx();


                // Pass the generated transaction item in the driver
                //to convert it to pin wiggles
                //operation similar to than of a connection between
                //a sequencer and a driver in a UVM tb
                drv->drive(tx);


                // Monitor the input interface
                // also writes recovered transaction to
                // input coverage and scoreboard
                inMon->monitor();

                // Monitor the output interface
                // also writes recovered result (out transaction) to
                // output coverage and scoreboard 
                outMon->monitor();
            }
        }
    }

    VerilatedCov::write();
    m_trace->close();  
    exit(EXIT_SUCCESS);
}
