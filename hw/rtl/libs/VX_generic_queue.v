`include "VX_platform.vh"

module VX_generic_queue #(
    parameter DATAW    = 1,
    parameter SIZE     = 2,
    parameter BUFFERED = 0,
    parameter ADDRW    = $clog2(SIZE),
    parameter SIZEW    = $clog2(SIZE+1),
    parameter FASTRAM  = 1
) ( 
    input  wire             clk,
    input  wire             reset,
    input  wire             push,
    input  wire             pop,        
    input  wire [DATAW-1:0] data_in,
    output wire [DATAW-1:0] data_out,
    output wire             empty,
    output wire             full,      
    output wire [SIZEW-1:0] size
); 
    `STATIC_ASSERT(`ISPOW2(SIZE), ("must be 0 or power of 2!"))
    
    if (SIZE == 1) begin

        reg [DATAW-1:0] head_r;
        reg size_r;

        always @(posedge clk) begin
            if (reset) begin
                head_r <= 0;
                size_r <= 0;                    
            end else begin
                if (push && !pop) begin
                    assert(!full);
                    size_r <= 1;
                end else if (pop && !push) begin
                    assert(!empty);
                    size_r <= 0;
                end
                if (push) begin 
                    head_r <= data_in;
                end
            end
        end        

        assign data_out = head_r;
        assign empty    = (size_r == 0);
        assign full     = (size_r != 0);
        assign size     = size_r;

    end else begin
        
        reg empty_r;
        reg full_r;
        reg [ADDRW-1:0] used_r;

        always @(posedge clk) begin
            if (reset) begin
                empty_r <= 1;                   
                full_r  <= 0;        
                used_r  <= 0;
            end else begin
                if (push) begin  
                    assert(!full);          
                    if (!pop) begin     
                        empty_r <= 0; 
                        if (used_r == ADDRW'(SIZE-1)) begin
                            full_r <= 1;
                        end                                                 
                        used_r <= used_r + ADDRW'(1);
                    end
                end
                if (pop) begin
                    assert(!empty);
                    if (!push) begin  
                        full_r <= 0;                          
                        if (used_r == ADDRW'(1)) begin
                            empty_r <= 1;  
                        end;                                                      
                        used_r <= used_r - ADDRW'(1);
                    end
                end
            end                   
        end

        if (0 == BUFFERED) begin          

            reg [ADDRW:0] rd_ptr_r;
            reg [ADDRW:0] wr_ptr_r;
        
            wire [ADDRW-1:0] rd_ptr_a = rd_ptr_r[ADDRW-1:0];
            wire [ADDRW-1:0] wr_ptr_a = wr_ptr_r[ADDRW-1:0];
            
            always @(posedge clk) begin
                if (reset) begin
                    rd_ptr_r <= 0;
                    wr_ptr_r <= 0;
                end else begin
                    if (push) begin           
                        wr_ptr_r <= wr_ptr_r + (ADDRW+1)'(1);
                    end
                    if (pop) begin
                        rd_ptr_r <= rd_ptr_r + (ADDRW+1)'(1);
                    end
                end                   
            end

            VX_dp_ram #(
                .DATAW(DATAW),
                .SIZE(SIZE),
                .BUFFERED(0),
                .RWCHECK(1),
                .FASTRAM(FASTRAM)
            ) dp_ram (
                .clk(clk),	
                .waddr(wr_ptr_a),                                
                .raddr(rd_ptr_a),
                .wren(push),
                .byteen(1'b1),
                .rden(pop),
                .din(data_in),
                .dout(data_out)
            );

        end else begin

            wire [DATAW-1:0] dout;
            reg [DATAW-1:0] din_r;
            reg [ADDRW-1:0] wr_ptr_r;
            reg [ADDRW-1:0] rd_ptr_r;
            reg [ADDRW-1:0] rd_ptr_n_r;
            reg             bypass_r;

            always @(posedge clk) begin
                if (reset) begin      
                    wr_ptr_r   <= 0;
                    rd_ptr_r   <= 0;
                    rd_ptr_n_r <= 1;
                end else begin
                    if (push) begin                 
                        wr_ptr_r <= wr_ptr_r + ADDRW'(1);
                    end
                    if (pop) begin
                        rd_ptr_r <= rd_ptr_n_r;                           
                        if (SIZE > 2) begin        
                            rd_ptr_n_r <= rd_ptr_r + ADDRW'(2);
                        end else begin // (SIZE == 2);
                            rd_ptr_n_r <= ~rd_ptr_n_r;                                
                        end
                    end
                end
            end

            always @(posedge clk) begin
                if (push && (empty_r || ((used_r == ADDRW'(1)) && pop))) begin
                    bypass_r <= 1;
                    din_r <= data_in;
                end else if (pop)
                    bypass_r <= 0;
            end

            VX_dp_ram #(
                .DATAW(DATAW),
                .SIZE(SIZE),
                .BUFFERED(1),
                .RWCHECK(0),
                .FASTRAM(FASTRAM)
            ) dp_ram (
                .clk(clk),	
                .waddr(wr_ptr_r),                                
                .raddr(rd_ptr_n_r),
                .wren(push),
                .byteen(1'b1),
                .rden(pop),
                .din(data_in),
                .dout(dout)
            ); 

            assign data_out = bypass_r ? din_r : dout;
        end
        
        assign empty = empty_r;
        assign full  = full_r;
        assign size  = {full_r, used_r};        
    end

endmodule
