module dcache
(
    // System clock, reset and stall
    clk_i, 
    rst_i,
    
    // to Data Memory interface        
    mem_data_i,               //input from memory to cache
    mem_ack_i,     
    mem_data_o, 
    mem_addr_o,     
    mem_enable_o, 
    mem_write_o, 
    
    // to CPU interface    
    cpu_data_i, 
    cpu_addr_i,     
    cpu_MemRead_i, 
    cpu_MemWrite_i, 
    cpu_data_o, 
    cpu_stall_o
);
//
// System clock, start
//
input                 clk_i; 
input                 rst_i;

//
// to Data_Memory interface        
//
input    [255:0]      mem_data_i; 
input                 mem_ack_i; 
    
output   [255:0]      mem_data_o; 
output   [31:0]       mem_addr_o;     
output                mem_enable_o; 
output                mem_write_o; 
    
//    
// to CPU interface            
//    
input    [31:0]       cpu_data_i; 
input    [31:0]       cpu_addr_i;     
input                 cpu_MemRead_i; 
input                 cpu_MemWrite_i; 

output   [31:0]       cpu_data_o; 
output                cpu_stall_o; 

//
// to SRAM interface
//
wire    [3:0]         cache_sram_index;         //for the 16 rows cache
wire                  cache_sram_enable;
wire    [24:0]        cache_sram_tag;
wire    [255:0]       cache_sram_data;
wire                  cache_sram_write;
wire    [24:0]        sram_cache_tag;         //output
wire    [255:0]       sram_cache_data;        //output
wire                  sram_cache_hit;         //output


// cache
wire                  sram_valid;
wire                  sram_dirty;

// controller
parameter             STATE_IDLE         = 3'h0,
                      STATE_READMISS     = 3'h1,
                      STATE_READMISSOK   = 3'h2,
                      STATE_WRITEBACK    = 3'h3,
                      STATE_MISS         = 3'h4;
reg     [2:0]         state;
reg                   mem_enable;
reg                   mem_write;
reg                   cache_write;
wire                  cache_dirty;
reg                   write_back;

// regs & wires
wire    [4:0]         cpu_offset;
wire    [3:0]         cpu_index;
wire    [22:0]        cpu_tag;
wire    [255:0]       r_hit_data;                  //read hit data
wire    [21:0]        sram_tag;
wire                  hit;
reg     [255:0]       w_hit_data;
wire                  write_hit;
wire                  cpu_req;
reg     [31:0]        cpu_data;

// to CPU interface
assign    cpu_req     = cpu_MemRead_i | cpu_MemWrite_i;
assign    cpu_tag     = cpu_addr_i[31:9];      //without 5 bits offset and 4 bits index
assign    cpu_index   = cpu_addr_i[8:5];
assign    cpu_offset  = cpu_addr_i[4:0];        //5 bits offset
assign    cpu_stall_o = ~hit & cpu_req;
assign    cpu_data_o  = cpu_data; 

// to SRAM interface
assign    sram_valid = sram_cache_tag[24];            //valid bit
assign    sram_dirty = sram_cache_tag[23];            //dirty bit    
assign    sram_tag   = sram_cache_tag[22:0];
assign    cache_sram_index  = cpu_index;              //address input in dcache_sram module
assign    cache_sram_enable = cpu_req;                   //if there is read write instuctions, enable_i = 1
assign    cache_sram_write  = cache_write | write_hit;    //if cache_write = 1 or write_hit =1, then cache will be written
assign    cache_sram_tag    = {1'b1, cache_dirty, cpu_tag};    //1'b1 valid bit   
assign    cache_sram_data   = (hit) ? w_hit_data : mem_data_i;     

// to Data_Memory interface
assign    mem_enable_o = mem_enable;
assign    mem_addr_o   = (write_back) ? {sram_tag, cpu_index, 5'b0} : {cpu_tag, cpu_index, 5'b0}; //if write back = 1, write into memory by sram tag
assign    mem_data_o   = sram_cache_data;                                                        
assign    mem_write_o  = mem_write;

assign    write_hit    = hit & cpu_MemWrite_i;
assign    cache_dirty  = write_hit;          //because of write back policy, the cache is dirty when a write hit occurs

// TODO: add your code here!  (r_hit_data=...?)
assign hit = (cpu_tag == sram_tag && sram_valid)? 1'b1 : 1'b0;     // is hit if cache tag = cpu tag and valid bit =1
assign r_hit_data = sram_cache_data;

// read data :  256-bit to 32-bit                               //cpu data gen
always@(cpu_offset or r_hit_data) begin
    // TODO: add your code here! (cpu_data=...?)            //memory reads in 256 bit (32 bytes) of data at a time
    cpu_data = r_hit_data[cpu_offset*8 +: 32];              // = [cpu_offset*8 + 31 : cpu_offset*8]  (*8 because 1 byte = 8 bits)
end                                                         //need to find the 32 bits needed among the 256 bit block


// write data :  32-bit to 256-bit
always@(cpu_offset or r_hit_data or cpu_data_i) begin           //w hit data gen
    // TODO: add your code here! (w_hit_data=...?)
    w_hit_data =  r_hit_data;      //replace a 32 bit portion of r_hit_data with cpu_data_i
    w_hit_data[cpu_offset*8 +: 32] = cpu_data_i;
end


// controller 
always@(posedge clk_i or posedge rst_i) begin
    if(rst_i) begin
        state       <= STATE_IDLE;
        mem_enable  <= 1'b0;
        mem_write   <= 1'b0;
        cache_write <= 1'b0; 
        write_back  <= 1'b0;
    end
    else begin
        case(state)        
            STATE_IDLE: begin
                if(cpu_req && !hit) begin      // wait for request
                    state <= STATE_MISS;
                end
                else begin
                    state <= STATE_IDLE;
                end
            end
            STATE_MISS: begin
                if(sram_dirty) begin          // write back if dirty (the block will be replaced, so need to write back if dirty)
                    // TODO: add your code here! 
                    mem_enable <= 1'b1;
                    mem_write <= 1'b1;
					write_back <= 1'b1;
                    state <= STATE_WRITEBACK;
                end
                else begin                    // write allocate: write miss = read miss + write hit; read miss = read miss + read hit
                    // TODO: add your code here!
                    mem_enable <= 1'b1;     //not dirty -> no write back needed, only needs to enable access to memory
                    state <= STATE_READMISS;
                end
            end
            STATE_READMISS: begin
                if(mem_ack_i) begin            // wait for data memory acknowledge
                    // TODO: add your code here! 
                    mem_enable <= 1'b0;
                    cache_write <= 1'b1;
                    state <= STATE_READMISSOK;
                end
                else begin
                    state <= STATE_READMISS;
                end
            end
            STATE_READMISSOK: begin            // wait for data memory acknowledge
                // TODO: add your code here!
                mem_write <= 1'b0;
				write_back <= 1'b0; 
                cache_write <= 1'b0;
                state <= STATE_IDLE;
            end
            STATE_WRITEBACK: begin
                if(mem_ack_i) begin            // wait for data memory acknowledge
                    // TODO: add your code here! 
                    mem_write <= 1'b0;     //already written,so disable write into memory
					write_back <= 1'b0;
                    state <= STATE_READMISS;
                end
                else begin
                    state <= STATE_WRITEBACK;
                end
            end
        endcase
    end
end

//
// SRAM (cache memory part)
//
dcache_sram dcache_sram
(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .addr_i     (cache_sram_index),
    .tag_i      (cache_sram_tag),
    .data_i     (cache_sram_data),
    .enable_i   (cache_sram_enable),
    .write_i    (cache_sram_write),
    .tag_o      (sram_cache_tag),
    .data_o     (sram_cache_data),
    .hit_o      (hit)                        //hit wire that connects to hit_o in dcache_sram
);

endmodule
