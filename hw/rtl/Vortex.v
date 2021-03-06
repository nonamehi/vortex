`include "VX_define.vh"

module Vortex (
    `SCOPE_IO_Vortex

    // Clock
    input  wire                             clk,
    input  wire                             reset,

    // DRAM request
    output wire                             dram_req_valid,
    output wire                             dram_req_rw,    
    output wire [`VX_DRAM_BYTEEN_WIDTH-1:0] dram_req_byteen,    
    output wire [`VX_DRAM_ADDR_WIDTH-1:0]   dram_req_addr,
    output wire [`VX_DRAM_LINE_WIDTH-1:0]   dram_req_data,
    output wire [`VX_DRAM_TAG_WIDTH-1:0]    dram_req_tag,
    input  wire                             dram_req_ready,

    // DRAM response    
    input wire                              dram_rsp_valid,        
    input wire [`VX_DRAM_LINE_WIDTH-1:0]    dram_rsp_data,
    input wire [`VX_DRAM_TAG_WIDTH-1:0]     dram_rsp_tag,
    output wire                             dram_rsp_ready,

    // Snoop request
    input wire                              snp_req_valid,
    input wire [`VX_DRAM_ADDR_WIDTH-1:0]    snp_req_addr,
    input wire                              snp_req_invalidate,
    input wire [`VX_SNP_TAG_WIDTH-1:0]      snp_req_tag,
    output wire                             snp_req_ready, 

    // Snoop response
    output wire                             snp_rsp_valid,
    output wire [`VX_SNP_TAG_WIDTH-1:0]     snp_rsp_tag,
    input wire                              snp_rsp_ready,     

    // I/O request
    output wire [`NUM_THREADS-1:0]          io_req_valid,
    output wire                             io_req_rw,  
    output wire [`NUM_THREADS-1:0][3:0]     io_req_byteen,  
    output wire [`NUM_THREADS-1:0][29:0]    io_req_addr,
    output wire [`NUM_THREADS-1:0][31:0]    io_req_data,    
    output wire [`VX_CORE_TAG_WIDTH-1:0]    io_req_tag,    
    input wire                              io_req_ready,

    // I/O response
    input wire                              io_rsp_valid,
    input wire [31:0]                       io_rsp_data,
    input wire [`VX_CORE_TAG_WIDTH-1:0]     io_rsp_tag,
    output wire                             io_rsp_ready,

    // CSR I/O Request
    input  wire                             csr_io_req_valid,
    input  wire [`VX_CSR_ID_WIDTH-1:0]      csr_io_req_coreid,
    input  wire [11:0]                      csr_io_req_addr,
    input  wire                             csr_io_req_rw,
    input  wire [31:0]                      csr_io_req_data,
    output wire                             csr_io_req_ready,

    // CSR I/O Response
    output wire                             csr_io_rsp_valid,
    output wire [31:0]                      csr_io_rsp_data,
    input wire                              csr_io_rsp_ready,

    // Status
    output wire                             busy, 
    output wire                             ebreak
);
    if (`NUM_CLUSTERS == 1) begin

        VX_cluster #(
            .CLUSTER_ID(0)
        ) cluster (
            `SCOPE_BIND_Vortex_cluster(0)

            .clk                (clk),
            .reset              (reset),
            
            .dram_req_valid     (dram_req_valid),
            .dram_req_rw        (dram_req_rw),
            .dram_req_byteen    (dram_req_byteen),
            .dram_req_addr      (dram_req_addr),
            .dram_req_data      (dram_req_data),
            .dram_req_tag       (dram_req_tag),
            .dram_req_ready     (dram_req_ready),

            .dram_rsp_valid     (dram_rsp_valid),            
            .dram_rsp_data      (dram_rsp_data),
            .dram_rsp_tag       (dram_rsp_tag),
            .dram_rsp_ready     (dram_rsp_ready),

            .snp_req_valid      (snp_req_valid),
            .snp_req_addr       (snp_req_addr),
            .snp_req_invalidate (snp_req_invalidate),
            .snp_req_tag        (snp_req_tag),
            .snp_req_ready      (snp_req_ready),

            .snp_rsp_valid      (snp_rsp_valid),
            .snp_rsp_tag        (snp_rsp_tag),
            .snp_rsp_ready      (snp_rsp_ready),

            .io_req_valid       (io_req_valid),
            .io_req_rw          (io_req_rw),
            .io_req_byteen      (io_req_byteen),
            .io_req_addr        (io_req_addr),
            .io_req_data        (io_req_data),
            .io_req_tag         (io_req_tag),
            .io_req_ready       (io_req_ready),

            .io_rsp_valid       (io_rsp_valid),            
            .io_rsp_data        (io_rsp_data),
            .io_rsp_tag         (io_rsp_tag),
            .io_rsp_ready       (io_rsp_ready),

            .csr_io_req_valid   (csr_io_req_valid),
            .csr_io_req_coreid  (csr_io_req_coreid),
            .csr_io_req_rw      (csr_io_req_rw),
            .csr_io_req_addr    (csr_io_req_addr),
            .csr_io_req_data    (csr_io_req_data),
            .csr_io_req_ready   (csr_io_req_ready),

            .csr_io_rsp_valid   (csr_io_rsp_valid),            
            .csr_io_rsp_data    (csr_io_rsp_data),
            .csr_io_rsp_ready   (csr_io_rsp_ready),

            .busy               (busy),
            .ebreak             (ebreak)
        );

    end else begin

        wire [`NUM_CLUSTERS-1:0]                         per_cluster_dram_req_valid;
        wire [`NUM_CLUSTERS-1:0]                         per_cluster_dram_req_rw;        
        wire [`NUM_CLUSTERS-1:0][`L2DRAM_BYTEEN_WIDTH-1:0] per_cluster_dram_req_byteen;   
        wire [`NUM_CLUSTERS-1:0][`L2DRAM_ADDR_WIDTH-1:0] per_cluster_dram_req_addr;
        wire [`NUM_CLUSTERS-1:0][`L2DRAM_LINE_WIDTH-1:0] per_cluster_dram_req_data;
        wire [`NUM_CLUSTERS-1:0][`L2DRAM_TAG_WIDTH-1:0]  per_cluster_dram_req_tag;
        wire                                             cluster_dram_req_ready;
  
        wire [`NUM_CLUSTERS-1:0]                         per_cluster_dram_rsp_valid;        
        wire [`NUM_CLUSTERS-1:0][`L2DRAM_LINE_WIDTH-1:0] per_cluster_dram_rsp_data;
        wire [`NUM_CLUSTERS-1:0][`L2DRAM_TAG_WIDTH-1:0]  per_cluster_dram_rsp_tag; 
        wire [`NUM_CLUSTERS-1:0]                         per_cluster_dram_rsp_ready;

        wire [`NUM_CLUSTERS-1:0]                         per_cluster_snp_req_valid;
        wire [`NUM_CLUSTERS-1:0][`L2DRAM_ADDR_WIDTH-1:0] per_cluster_snp_req_addr;
        wire [`NUM_CLUSTERS-1:0]                         per_cluster_snp_req_invalidate;
        wire [`NUM_CLUSTERS-1:0][`L2SNP_TAG_WIDTH-1:0]   per_cluster_snp_req_tag;
        wire [`NUM_CLUSTERS-1:0]                         per_cluster_snp_req_ready;

        wire [`NUM_CLUSTERS-1:0]                         per_cluster_snp_rsp_valid;
        wire [`NUM_CLUSTERS-1:0][`L2SNP_TAG_WIDTH-1:0]   per_cluster_snp_rsp_tag;
        wire [`NUM_CLUSTERS-1:0]                         per_cluster_snp_rsp_ready;

        wire [`NUM_CLUSTERS-1:0][`NUM_THREADS-1:0]       per_cluster_io_req_valid;
        wire [`NUM_CLUSTERS-1:0]                         per_cluster_io_req_rw;
        wire [`NUM_CLUSTERS-1:0][`NUM_THREADS-1:0][3:0]  per_cluster_io_req_byteen;
        wire [`NUM_CLUSTERS-1:0][`NUM_THREADS-1:0][29:0] per_cluster_io_req_addr;
        wire [`NUM_CLUSTERS-1:0][`NUM_THREADS-1:0][31:0] per_cluster_io_req_data;        
        wire [`NUM_CLUSTERS-1:0][`L2CORE_TAG_WIDTH-1:0]  per_cluster_io_req_tag;
        wire [`NUM_CLUSTERS-1:0]                         per_cluster_io_req_ready;

        wire [`NUM_CLUSTERS-1:0]                         per_cluster_io_rsp_valid;
        wire [`NUM_CLUSTERS-1:0][`L2CORE_TAG_WIDTH-1:0]  per_cluster_io_rsp_tag;
        wire [`NUM_CLUSTERS-1:0][31:0]                   per_cluster_io_rsp_data;
        wire [`NUM_CLUSTERS-1:0]                         per_cluster_io_rsp_ready;

        wire [`NUM_CLUSTERS-1:0]                         per_cluster_csr_io_req_valid;
        wire [`NUM_CLUSTERS-1:0][11:0]                   per_cluster_csr_io_req_addr;
        wire [`NUM_CLUSTERS-1:0]                         per_cluster_csr_io_req_rw;
        wire [`NUM_CLUSTERS-1:0][31:0]                   per_cluster_csr_io_req_data;
        wire [`NUM_CLUSTERS-1:0]                         per_cluster_csr_io_req_ready;

        wire [`NUM_CLUSTERS-1:0]                         per_cluster_csr_io_rsp_valid;
        wire [`NUM_CLUSTERS-1:0][31:0]                   per_cluster_csr_io_rsp_data;
        wire [`NUM_CLUSTERS-1:0]                         per_cluster_csr_io_rsp_ready;

        wire [`NUM_CLUSTERS-1:0]                         per_cluster_busy;
        wire [`NUM_CLUSTERS-1:0]                         per_cluster_ebreak;

        wire [`CLOG2(`NUM_CLUSTERS)-1:0] csr_io_request_id = `CLOG2(`NUM_CLUSTERS)'(csr_io_req_coreid >> `CLOG2(`NUM_CLUSTERS));
        wire [`NC_BITS-1:0] per_cluster_csr_io_req_coreid = `NC_BITS'(csr_io_req_coreid);

        for (genvar i = 0; i < `NUM_CLUSTERS; i++) begin        
            VX_cluster #(
                .CLUSTER_ID(i)
            ) cluster (
                `SCOPE_BIND_Vortex_cluster(i)

                .clk                (clk),
                .reset              (reset),

                .dram_req_valid     (per_cluster_dram_req_valid [i]),
                .dram_req_rw        (per_cluster_dram_req_rw    [i]),
                .dram_req_byteen    (per_cluster_dram_req_byteen[i]),
                .dram_req_addr      (per_cluster_dram_req_addr  [i]),
                .dram_req_data      (per_cluster_dram_req_data  [i]),
                .dram_req_tag       (per_cluster_dram_req_tag   [i]), 
                .dram_req_ready     (cluster_dram_req_ready),

                .dram_rsp_valid     (per_cluster_dram_rsp_valid [i]),                
                .dram_rsp_data      (per_cluster_dram_rsp_data  [i]),
                .dram_rsp_tag       (per_cluster_dram_rsp_tag   [i]),
                .dram_rsp_ready     (per_cluster_dram_rsp_ready [i]),

                .snp_req_valid      (per_cluster_snp_req_valid  [i]),
                .snp_req_addr       (per_cluster_snp_req_addr   [i]),
                .snp_req_invalidate (per_cluster_snp_req_invalidate[i]),
                .snp_req_tag        (per_cluster_snp_req_tag    [i]),
                .snp_req_ready      (per_cluster_snp_req_ready  [i]),

                .snp_rsp_valid      (per_cluster_snp_rsp_valid  [i]),
                .snp_rsp_tag        (per_cluster_snp_rsp_tag    [i]),
                .snp_rsp_ready      (per_cluster_snp_rsp_ready  [i]),

                .io_req_valid       (per_cluster_io_req_valid   [i]),
                .io_req_rw          (per_cluster_io_req_rw      [i]),
                .io_req_byteen      (per_cluster_io_req_byteen  [i]),
                .io_req_addr        (per_cluster_io_req_addr    [i]),
                .io_req_data        (per_cluster_io_req_data    [i]),                
                .io_req_tag         (per_cluster_io_req_tag     [i]),
                .io_req_ready       (per_cluster_io_req_ready   [i]),

                .io_rsp_valid       (per_cluster_io_rsp_valid   [i]),            
                .io_rsp_data        (per_cluster_io_rsp_data    [i]),
                .io_rsp_tag         (per_cluster_io_rsp_tag     [i]),
                .io_rsp_ready       (per_cluster_io_rsp_ready   [i]),

                .csr_io_req_valid   (per_cluster_csr_io_req_valid[i]),
                .csr_io_req_coreid  (per_cluster_csr_io_req_coreid),
                .csr_io_req_rw      (per_cluster_csr_io_req_rw  [i]),
                .csr_io_req_addr    (per_cluster_csr_io_req_addr[i]),
                .csr_io_req_data    (per_cluster_csr_io_req_data[i]),
                .csr_io_req_ready   (per_cluster_csr_io_req_ready[i]),

                .csr_io_rsp_valid   (per_cluster_csr_io_rsp_valid[i]),            
                .csr_io_rsp_data    (per_cluster_csr_io_rsp_data[i]),
                .csr_io_rsp_ready   (per_cluster_csr_io_rsp_ready[i]),

                .busy               (per_cluster_busy           [i]),
                .ebreak             (per_cluster_ebreak         [i])
            );
        end

        VX_io_arb #(
            .NUM_REQUESTS  (`NUM_CLUSTERS),
            .WORD_SIZE     (4),
            .TAG_IN_WIDTH  (`L2CORE_TAG_WIDTH),
            .TAG_OUT_WIDTH (`L3CORE_TAG_WIDTH)
        ) io_arb (
            .clk                    (clk),
            .reset                  (reset),

            // input requests
            .io_req_valid_in        (per_cluster_io_req_valid),
            .io_req_rw_in           (per_cluster_io_req_rw),
            .io_req_byteen_in       (per_cluster_io_req_byteen),
            .io_req_addr_in         (per_cluster_io_req_addr),
            .io_req_data_in         (per_cluster_io_req_data),  
            .io_req_tag_in          (per_cluster_io_req_tag),  
            .io_req_ready_in        (per_cluster_io_req_ready),

            // input responses
            .io_rsp_valid_in        (per_cluster_io_rsp_valid),
            .io_rsp_data_in         (per_cluster_io_rsp_data),
            .io_rsp_tag_in          (per_cluster_io_rsp_tag),
            .io_rsp_ready_in        (per_cluster_io_rsp_ready),

            // output request
            .io_req_valid_out       (io_req_valid),
            .io_req_rw_out          (io_req_rw),        
            .io_req_byteen_out      (io_req_byteen),        
            .io_req_addr_out        (io_req_addr),
            .io_req_data_out        (io_req_data),
            .io_req_tag_out         (io_req_tag),
            .io_req_ready_out       (io_req_ready),
            
            // output response
            .io_rsp_valid_out       (io_rsp_valid),
            .io_rsp_tag_out         (io_rsp_tag),
            .io_rsp_data_out        (io_rsp_data),
            .io_rsp_ready_out       (io_rsp_ready)
        );

        VX_csr_io_arb #(
            .NUM_REQUESTS (`NUM_CLUSTERS)
        ) csr_io_arb (
            .clk                    (clk),
            .reset                  (reset),

            .request_id             (csr_io_request_id),

            // input requests
            .csr_io_req_valid_in    (csr_io_req_valid),    
            .csr_io_req_addr_in     (csr_io_req_addr),
            .csr_io_req_rw_in       (csr_io_req_rw),
            .csr_io_req_data_in     (csr_io_req_data),
            .csr_io_req_ready_in    (csr_io_req_ready),

            // input responses
            .csr_io_rsp_valid_in    (per_cluster_csr_io_rsp_valid),
            .csr_io_rsp_data_in     (per_cluster_csr_io_rsp_data),
            .csr_io_rsp_ready_in    (per_cluster_csr_io_rsp_ready),

            // output request
            .csr_io_req_valid_out   (per_cluster_csr_io_req_valid),
            .csr_io_req_addr_out    (per_cluster_csr_io_req_addr),            
            .csr_io_req_rw_out      (per_cluster_csr_io_req_rw),
            .csr_io_req_data_out    (per_cluster_csr_io_req_data),  
            .csr_io_req_ready_out   (per_cluster_csr_io_req_ready),            
            
            // output response
            .csr_io_rsp_valid_out   (csr_io_rsp_valid),
            .csr_io_rsp_data_out    (csr_io_rsp_data),
            .csr_io_rsp_ready_out   (csr_io_rsp_ready)
        );

        assign busy   = (| per_cluster_busy);
        assign ebreak = (| per_cluster_ebreak);

        // L3 Cache ///////////////////////////////////////////////////////////

        wire [`L3NUM_REQUESTS-1:0]                           cluster_dram_rsp_valid;        
        wire [`L3NUM_REQUESTS-1:0][`L2DRAM_LINE_WIDTH-1:0]   cluster_dram_rsp_data;
        wire [`L3NUM_REQUESTS-1:0][`L2DRAM_TAG_WIDTH-1:0]    cluster_dram_rsp_tag;
        wire                                                 cluster_dram_rsp_ready;    

        wire                                                 snp_fwd_rsp_valid;
        wire [`L3DRAM_ADDR_WIDTH-1:0]                        snp_fwd_rsp_addr;
        wire                                                 snp_fwd_rsp_invalidate;
        wire [`L3SNP_TAG_WIDTH-1:0]                          snp_fwd_rsp_tag;
        wire                                                 snp_fwd_rsp_ready;

        reg [`L3NUM_REQUESTS-1:0] cluster_dram_rsp_ready_other;

        always @(*) begin
            cluster_dram_rsp_ready_other = {`L3NUM_REQUESTS{1'b1}};
            for (integer i = 0; i < `L3NUM_REQUESTS; i++) begin
                for (integer j = 0; j < `L3NUM_REQUESTS; j++) begin
                    if (i != j)
                        cluster_dram_rsp_ready_other[i] &= (per_cluster_dram_rsp_ready [j] | !cluster_dram_rsp_valid [j]);
                end
            end
        end

        for (genvar i = 0; i < `L3NUM_REQUESTS; i++) begin     
            // Core Response
            assign per_cluster_dram_rsp_valid [i] = cluster_dram_rsp_valid [i] & cluster_dram_rsp_ready_other [i];
            assign per_cluster_dram_rsp_data  [i] = cluster_dram_rsp_data [i];
            assign per_cluster_dram_rsp_tag   [i] = cluster_dram_rsp_tag [i];
        end
        assign cluster_dram_rsp_ready = & (per_cluster_dram_rsp_ready | ~cluster_dram_rsp_valid);

        VX_snp_forwarder #(
            .CACHE_ID           (`L3CACHE_ID),            
            .NUM_REQUESTS       (`NUM_CLUSTERS), 
            .SRC_ADDR_WIDTH     (`L3DRAM_ADDR_WIDTH), 
            .DST_ADDR_WIDTH     (`L2DRAM_ADDR_WIDTH),             
            .SNP_TAG_WIDTH      (`L3SNP_TAG_WIDTH),
            .SNRQ_SIZE          (`L3SNRQ_SIZE)
        ) snp_forwarder (
            .clk                (clk),
            .reset              (reset),

            .snp_req_valid      (snp_req_valid),
            .snp_req_addr       (snp_req_addr),
            .snp_req_invalidate (snp_req_invalidate),
            .snp_req_tag        (snp_req_tag),
            .snp_req_ready      (snp_req_ready),

            .snp_rsp_valid      (snp_fwd_rsp_valid),       
            .snp_rsp_addr       (snp_fwd_rsp_addr),
            .snp_rsp_invalidate (snp_fwd_rsp_invalidate),
            .snp_rsp_tag        (snp_fwd_rsp_tag),
            .snp_rsp_ready      (snp_fwd_rsp_ready),   

            .snp_fwdout_valid   (per_cluster_snp_req_valid),
            .snp_fwdout_addr    (per_cluster_snp_req_addr),
            .snp_fwdout_invalidate(per_cluster_snp_req_invalidate),
            .snp_fwdout_tag     (per_cluster_snp_req_tag),
            .snp_fwdout_ready   (per_cluster_snp_req_ready),

            .snp_fwdin_valid    (per_cluster_snp_rsp_valid),
            .snp_fwdin_tag      (per_cluster_snp_rsp_tag),
            .snp_fwdin_ready    (per_cluster_snp_rsp_ready)      
        );

        VX_cache #(
            .CACHE_ID           (`L3CACHE_ID),
            .CACHE_SIZE         (`L3CACHE_SIZE),
            .BANK_LINE_SIZE     (`L3BANK_LINE_SIZE),
            .NUM_BANKS          (`L3NUM_BANKS),
            .WORD_SIZE          (`L3WORD_SIZE),
            .NUM_REQUESTS       (`L3NUM_REQUESTS),
            .CREQ_SIZE          (`L3CREQ_SIZE),
            .MRVQ_SIZE          (`L3MRVQ_SIZE),
            .DRFQ_SIZE          (`L3DRFQ_SIZE),
            .SNRQ_SIZE          (`L3SNRQ_SIZE),
            .CWBQ_SIZE          (`L3CWBQ_SIZE),
            .DREQ_SIZE          (`L3DREQ_SIZE),
            .SNPQ_SIZE          (`L3SNPQ_SIZE),
            .DRAM_ENABLE        (1),
            .FLUSH_ENABLE       (1), 
            .WRITE_ENABLE       (1),
            .CORE_TAG_WIDTH     (`L2DRAM_TAG_WIDTH),
            .CORE_TAG_ID_BITS   (0),
            .DRAM_TAG_WIDTH     (`L3DRAM_TAG_WIDTH),
            .SNP_TAG_WIDTH      (`L3SNP_TAG_WIDTH)
        ) l3cache (
            `SCOPE_BIND_Vortex_l3cache

            .clk                (clk),
            .reset              (reset),

            // Core request    
            .core_req_valid     (per_cluster_dram_req_valid),
            .core_req_rw        (per_cluster_dram_req_rw),
            .core_req_byteen    (per_cluster_dram_req_byteen),
            .core_req_addr      (per_cluster_dram_req_addr),
            .core_req_data      (per_cluster_dram_req_data),
            .core_req_tag       (per_cluster_dram_req_tag),
            .core_req_ready     (cluster_dram_req_ready),

            // Core response
            .core_rsp_valid     (cluster_dram_rsp_valid),
            .core_rsp_data      (cluster_dram_rsp_data),
            .core_rsp_tag       (cluster_dram_rsp_tag),              
            .core_rsp_ready     (cluster_dram_rsp_ready),

            // DRAM request
            .dram_req_valid     (dram_req_valid),
            .dram_req_rw        (dram_req_rw),
            .dram_req_byteen    (dram_req_byteen),
            .dram_req_addr      (dram_req_addr),
            .dram_req_data      (dram_req_data),
            .dram_req_tag       (dram_req_tag),
            .dram_req_ready     (dram_req_ready),

            // DRAM response
            .dram_rsp_valid     (dram_rsp_valid),            
            .dram_rsp_data      (dram_rsp_data),
            .dram_rsp_tag       (dram_rsp_tag),
            .dram_rsp_ready     (dram_rsp_ready),

            // Snoop request
            .snp_req_valid      (snp_fwd_rsp_valid),
            .snp_req_addr       (snp_fwd_rsp_addr),
            .snp_req_invalidate (snp_fwd_rsp_invalidate),
            .snp_req_tag        (snp_fwd_rsp_tag),
            .snp_req_ready      (snp_fwd_rsp_ready),

            // Snoop response
            .snp_rsp_valid      (snp_rsp_valid),
            .snp_rsp_tag        (snp_rsp_tag),
            .snp_rsp_ready      (snp_rsp_ready),

            // Miss status
            `UNUSED_PIN (miss_vec)
        );
    end

    `SCOPE_ASSIGN (reset, reset);

    `SCOPE_ASSIGN (dram_req_fire,  dram_req_valid && dram_req_ready);
    `SCOPE_ASSIGN (dram_req_addr,  `TO_FULL_ADDR(dram_req_addr));
    `SCOPE_ASSIGN (dram_req_rw,    dram_req_rw);
    `SCOPE_ASSIGN (dram_req_byteen,dram_req_byteen);
    `SCOPE_ASSIGN (dram_req_data,  dram_req_data);
    `SCOPE_ASSIGN (dram_req_tag,   dram_req_tag);

    `SCOPE_ASSIGN (dram_rsp_fire,  dram_rsp_valid && dram_rsp_ready);
    `SCOPE_ASSIGN (dram_rsp_data,  dram_rsp_data);
    `SCOPE_ASSIGN (dram_rsp_tag,   dram_rsp_tag);

    `SCOPE_ASSIGN (snp_req_fire,  snp_req_valid && snp_req_ready);
    `SCOPE_ASSIGN (snp_req_addr,  `TO_FULL_ADDR(snp_req_addr));
    `SCOPE_ASSIGN (snp_req_invalidate, snp_req_invalidate);
    `SCOPE_ASSIGN (snp_req_tag,   snp_req_tag);

    `SCOPE_ASSIGN (snp_rsp_fire,  snp_rsp_valid && snp_rsp_ready);
    `SCOPE_ASSIGN (snp_rsp_tag,   snp_rsp_tag);

    `SCOPE_ASSIGN (snp_rsp_fire,  snp_rsp_valid && snp_rsp_ready);
    `SCOPE_ASSIGN (snp_rsp_tag,   snp_rsp_tag);

    `SCOPE_ASSIGN (busy, busy);

`ifdef DBG_PRINT_DRAM
    always @(posedge clk) begin
        if (dram_req_valid && dram_req_ready) begin
            if (dram_req_rw)
                $display("%t: DRAM Wr Req: addr=%0h, tag=%0h, byteen=%0h data=%0h", $time, `TO_FULL_ADDR(dram_req_addr), dram_req_tag, dram_req_byteen, dram_req_data);
            else
                $display("%t: DRAM Rd Req: addr=%0h, tag=%0h, byteen=%0h", $time, `TO_FULL_ADDR(dram_req_addr), dram_req_tag, dram_req_byteen);
        end
        if (dram_rsp_valid && dram_rsp_ready) begin
            $display("%t: DRAM Rsp: tag=%0h, data=%0h", $time, dram_rsp_tag, dram_rsp_data);
        end
    end
`endif


`ifndef NDEBUG
    always @(posedge clk) begin
        $fflush(); // flush stdout buffer
    end
`endif

endmodule