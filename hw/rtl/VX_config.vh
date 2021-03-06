`ifndef VX_CONFIG
`define VX_CONFIG

`include "VX_user_config.vh"

`ifndef NUM_CLUSTERS
`define NUM_CLUSTERS 1
`endif

`ifndef NUM_CORES
`define NUM_CORES 4
`endif

`ifndef NUM_WARPS
`define NUM_WARPS 4
`endif

`ifndef NUM_THREADS
`define NUM_THREADS 4
`endif

`ifndef NUM_BARRIERS
`define NUM_BARRIERS 4
`endif

`ifndef L2_ENABLE
`define L2_ENABLE (`NUM_CORES > 2)
`endif

`ifndef L3_ENABLE
`define L3_ENABLE (`NUM_CLUSTERS > 1)
`endif

`ifndef GLOBAL_BLOCK_SIZE
`define GLOBAL_BLOCK_SIZE 64
`endif

`ifndef L1_BLOCK_SIZE
`define L1_BLOCK_SIZE 16
`endif

`ifndef STARTUP_ADDR
`define STARTUP_ADDR 32'h80000000
`endif

`ifndef SHARED_MEM_BASE_ADDR
`define SHARED_MEM_BASE_ADDR 32'h6FFFF000
`endif

`ifndef IO_BUS_BASE_ADDR
`define IO_BUS_BASE_ADDR 32'hFF000000
`endif

`ifndef IO_BUS_ADDR_COUT
`define IO_BUS_ADDR_COUT 32'hFFFFFFFC
`endif

`ifndef FRAME_BUFFER_BASE_ADDR
`define FRAME_BUFFER_BASE_ADDR 32'hFF000000
`endif

`ifndef FRAME_BUFFER_WIDTH
`define FRAME_BUFFER_WIDTH 16'd1920
`endif

`ifndef FRAME_BUFFER_HEIGHT
`define FRAME_BUFFER_HEIGHT 16'd1080
`endif

`define FRAME_BUFFER_SIZE (FRAME_BUFFER_WIDTH * FRAME_BUFFER_HEIGHT)

`ifndef EXT_M_DISABLE
`define EXT_M_ENABLE
`endif

`ifndef EXT_F_DISABLE
`define EXT_F_ENABLE
`endif

// Device identification
`define VENDOR_ID           0
`define ARCHITECTURE_ID     0
`define IMPLEMENTATION_ID   0

///////////////////////////////////////////////////////////////////////////////

`ifndef LATENCY_IMUL
`define LATENCY_IMUL 3
`endif

`ifndef LATENCY_FNONCOMP
`define LATENCY_FNONCOMP 1
`endif

`ifndef LATENCY_FADDMUL
`define LATENCY_FADDMUL 3
`endif

`ifndef LATENCY_FMADD
`define LATENCY_FMADD 4
`endif

`ifndef LATENCY_FDIV
`define LATENCY_FDIV 15
`endif

`ifndef LATENCY_FSQRT
`define LATENCY_FSQRT 10
`endif

`ifndef LATENCY_ITOF
`define LATENCY_ITOF 7
`endif

`ifndef LATENCY_FTOI
`define LATENCY_FTOI 3
`endif

`ifndef LATENCY_FDIVSQRT
`define LATENCY_FDIVSQRT 10
`endif

`ifndef LATENCY_FCONV
`define LATENCY_FCONV 3
`endif

// CSR Addresses //////////////////////////////////////////////////////////////

`define CSR_FFLAGS      12'h001
`define CSR_FRM         12'h002
`define CSR_FCSR        12'h003

`define CSR_LTID        12'h020
`define CSR_LWID        12'h021
`define CSR_GTID        12'h022
`define CSR_GWID        12'h023
`define CSR_GCID        12'h024
`define CSR_NT          12'h025
`define CSR_NW          12'h026
`define CSR_NC          12'h027

`define CSR_SATP        12'h180

`define CSR_PMPCFG0     12'h3A0
`define CSR_PMPADDR0    12'h3B0

`define CSR_MSTATUS     12'h300
`define CSR_MISA        12'h301
`define CSR_MEDELEG     12'h302
`define CSR_MIDELEG     12'h303
`define CSR_MIE         12'h304
`define CSR_MTVEC       12'h305

`define CSR_MEPC        12'h341

`define CSR_CYCLE       12'hC00
`define CSR_CYCLE_H     12'hC80
`define CSR_INSTRET     12'hC02
`define CSR_INSTRET_H   12'hC82

`define CSR_MVENDORID   12'hF11
`define CSR_MARCHID     12'hF12
`define CSR_MIMPID      12'hF13
`define CSR_MHARTID     12'hF14

// Pipeline Queues ////////////////////////////////////////////////////////////

// Size of instruction queue
`ifndef IBUF_SIZE
`define IBUF_SIZE 4
`endif

// Size of LSU Request Queue
`ifndef LSUQ_SIZE
`define LSUQ_SIZE 8
`endif

// Size of MUL Request Queue
`ifndef MULQ_SIZE
`define MULQ_SIZE 4
`endif

// Size of FPU Request Queue
`ifndef FPUQ_SIZE
`define FPUQ_SIZE 4
`endif

// Dcache Configurable Knobs //////////////////////////////////////////////////

// Size of cache in bytes
`ifndef DCACHE_SIZE
`define DCACHE_SIZE 8192
`endif

// Number of banks
`ifndef DNUM_BANKS
`define DNUM_BANKS `MIN(`NUM_THREADS, 4)
`endif

// Core Request Queue Size
`ifndef DCREQ_SIZE
`define DCREQ_SIZE 4
`endif

// Miss Reserv Queue Knob
`ifndef DMRVQ_SIZE
`define DMRVQ_SIZE `MAX(`LSUQ_SIZE, 4)
`endif

// Core Writeback Queue Size
`ifndef DCWBQ_SIZE
`define DCWBQ_SIZE 4
`endif

// DRAM Request Queue Size
`ifndef DDREQ_SIZE
`define DDREQ_SIZE 4
`endif

// DRAM Response Queue Size
`ifndef DDRFQ_SIZE
`define DDRFQ_SIZE 4
`endif

// Snoop Response Queue Size
`ifndef DSNPQ_SIZE
`define DSNPQ_SIZE 4
`endif

// Snoop Request Queue Size
`ifndef DSNRQ_SIZE
`define DSNRQ_SIZE 4
`endif

// Icache Configurable Knobs //////////////////////////////////////////////////

// Size of cache in bytes
`ifndef ICACHE_SIZE
`define ICACHE_SIZE 4096
`endif

// Core Request Queue Size
`ifndef ICREQ_SIZE
`define ICREQ_SIZE 4
`endif

// Miss Reserv Queue Knob
`ifndef IMRVQ_SIZE
`define IMRVQ_SIZE 4
`endif

// Core Writeback Queue Size
`ifndef ICWBQ_SIZE
`define ICWBQ_SIZE 4
`endif

// DRAM Request Queue Size
`ifndef IDREQ_SIZE
`define IDREQ_SIZE 4
`endif

// DRAM Response Queue Size
`ifndef IDRFQ_SIZE
`define IDRFQ_SIZE 4
`endif

// SM Configurable Knobs //////////////////////////////////////////////////////

// Size of cache in bytes
`ifndef SCACHE_SIZE
`define SCACHE_SIZE 4096
`endif

// Number of banks
`ifndef SNUM_BANKS
`define SNUM_BANKS `NUM_THREADS
`endif

// Core Request Queue Size
`ifndef SCREQ_SIZE
`define SCREQ_SIZE 4
`endif

// Core Writeback Queue Size
`ifndef SCWBQ_SIZE
`define SCWBQ_SIZE 4
`endif

// L2cache Configurable Knobs /////////////////////////////////////////////////

// Size of cache in bytes
`ifndef L2CACHE_SIZE
`define L2CACHE_SIZE 131072
`endif

// Number of banks
`ifndef L2NUM_BANKS
`define L2NUM_BANKS `MIN((`NUM_CORES * 2), 4)
`endif

// Core Request Queue Size
`ifndef L2CREQ_SIZE
`define L2CREQ_SIZE 4
`endif

// Miss Reserv Queue Knob
`ifndef L2MRVQ_SIZE
`define L2MRVQ_SIZE 8
`endif

// Core Writeback Queue Size
`ifndef L2CWBQ_SIZE
`define L2CWBQ_SIZE 4
`endif

// DRAM Request Queue Size
`ifndef L2DREQ_SIZE
`define L2DREQ_SIZE 4
`endif

// DRAM Response Queue Size
`ifndef L2DRFQ_SIZE
`define L2DRFQ_SIZE 4
`endif

// Snoop Request Queue Size
`ifndef L2SNRQ_SIZE
`define L2SNRQ_SIZE 4
`endif

// Snoop Response Queue Size
`ifndef L2SNPQ_SIZE
`define L2SNPQ_SIZE 4
`endif

// L3cache Configurable Knobs /////////////////////////////////////////////////

// Size of cache in bytes
`ifndef L3CACHE_SIZE
`define L3CACHE_SIZE 262144
`endif

// Number of banks
`ifndef L3NUM_BANKS
`define L3NUM_BANKS `MIN(`NUM_CLUSTERS, 4)
`endif

// Core Request Queue Size
`ifndef L3CREQ_SIZE
`define L3CREQ_SIZE 4
`endif

// Miss Reserv Queue Knob
`ifndef L3MRVQ_SIZE
`define L3MRVQ_SIZE 8
`endif

// Core Writeback Queue Size
`ifndef L3CWBQ_SIZE
`define L3CWBQ_SIZE 4
`endif

// DRAM Request Queue Size
`ifndef L3DREQ_SIZE
`define L3DREQ_SIZE 4
`endif

// DRAM Response Queue Size
`ifndef L3DRFQ_SIZE
`define L3DRFQ_SIZE 4
`endif

// Snoop Request Queue Size
`ifndef L3SNRQ_SIZE
`define L3SNRQ_SIZE 4
`endif

// Snoop Response Queue Size
`ifndef L3SNPQ_SIZE
`define L3SNPQ_SIZE 4
`endif

`endif
