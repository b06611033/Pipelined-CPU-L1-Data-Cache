module dcache_sram               
(
    clk_i,
    rst_i,
    addr_i,
    tag_i,
    data_i,
    enable_i,
    write_i,
    tag_o,
    data_o,
    hit_o
);

// I/O Interface from/to controller
input              clk_i;
input              rst_i;
input    [3:0]     addr_i;         //set index
input    [24:0]    tag_i;          //tag for the data that needs to be written or read
input    [255:0]   data_i;         
input              enable_i;
input              write_i;

output reg   [24:0]    tag_o;
output reg  [255:0]   data_o;
output reg             hit_o;


// Memory
reg      [24:0]    tag [0:15][0:1];     //16 sets for tag in two way cache ([0:1] is for two way cache)
reg      [255:0]   data[0:15][0:1];     //16 sets for data in two way cache ([0:1] is for two way cache)

integer            i, j;

 
reg      LRU [0:15][0:1];        //2-way LRU bit




// Write Data      
// 1. Write hit
// 2. Read miss: Read from memory
always@(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        for (i=0;i<16;i=i+1) begin
            for (j=0;j<2;j=j+1) begin
                tag[i][j] <= 25'b0;
                data[i][j] <= 256'b0;
                LRU[i][j] <= 1'b0;
            end
        end
    end
    if (enable_i && write_i) begin       //if instruction is read write and it is either cache write or write hit, the cache needs to be written              
        // TODO: Handle your write of 2-way associative cache + LRU here
        if (tag[addr_i][0][22:0] == tag_i[22:0] && tag[addr_i][0][24]) begin   //write hit  
            data[addr_i][0] <= data_i;     
            tag[addr_i][0] <= tag_i;
            LRU[addr_i][0] <= 1'b1;
            LRU[addr_i][1] <= 1'b0;
            tag[addr_i][0][24] <= 1'b1;             //valid bit
        end
        else if (tag[addr_i][1][22:0] == tag_i[22:0] && tag[addr_i][1][24]) begin   //write hit
            data[addr_i][1] <= data_i; 
            tag[addr_i][1] <= tag_i;
            LRU[addr_i][0] <= 1'b0;
            LRU[addr_i][1] <= 1'b1;
            tag[addr_i][0][24] <= 1'b1;
        end
        else if (LRU[addr_i][0] == 0) begin      //read miss
            data[addr_i][0] <= data_i;     
            tag[addr_i][0] <= tag_i;
            LRU[addr_i][0] <= 1'b1;
            LRU[addr_i][1] <= 1'b0;
            tag[addr_i][0][24] <= 1'b1;
        end
        else if (LRU[addr_i][1] == 0) begin    //read miss
             data[addr_i][1] <= data_i; 
            tag[addr_i][1] <= tag_i;
            LRU[addr_i][0] <= 1'b0;
            LRU[addr_i][1] <= 1'b1;
            tag[addr_i][0][24] <= 1'b1;
        end

    end
end

// Read Data      
// TODO: tag_o=? data_o=? hit_o=?
always @(*) begin
    if (enable_i) begin
        if (tag[addr_i][0][22:0] == tag_i[22:0] && tag[addr_i][0][24]) begin        //read hit or write hit: same tag [22:0] and valid
            data_o <= data[addr_i][0];
            tag_o <= tag_i;
            hit_o <= 1'b1;
            LRU[addr_i][0] <= 1'b1;
            LRU[addr_i][1] <= 1'b0;
        end

        else if (tag[addr_i][1][22:0] == tag_i[22:0] && tag[addr_i][1][24] ) begin
            data_o <= data[addr_i][1];
            tag_o <= tag_i;
            hit_o <= 1'b1;
            LRU[addr_i][0] <= 1'b0;
            LRU[addr_i][1] <= 1'b1;
        end

        else begin                         // miss
            if (LRU[addr_i][0] && tag[addr_i][1][23] ) begin              //LRU0 = 1, the block going to be replaced is 1
                data_o <= data[addr_i][1];                               //read data for write back if dirty
                tag_o <= tag[addr_i][1];
                hit_o <= 1'b0; 
            end
            else if(LRU[addr_i][1] && tag[addr_i][0][23]) begin   //does mot need to set LRU bit
                data_o <= data[addr_i][0];                     //because ot will be set when data is written into cache
                tag_o <= tag[addr_i][0]; 
                hit_o <= 1'b0;
            end
            else begin
                data_o <= data[addr_i][0];           //if both LRU = 0, default is write to 0
                tag_o <= tag[addr_i][0]; 
                hit_o <= 1'b0;
            end
        end      
    end

    else begin              //not read write instructions
        data_o <= 256'b0;
        tag_o <= 23'b0;
        hit_o <= 1'b0;
    end
    
end



endmodule
