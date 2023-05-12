module memory(clk, mem_write, address, write_data, read_data);

input logic clk;
input logic mem_write;
input logic [15:0]address;
input logic [15:0]write_data;
output logic [15:0]read_data;

logic [0:65535] ram[15:0];

initial
    $readmemh("ram.mem", ram, 0);

assign read_data = ram[address];

always_ff @(posedge clk)
begin
    if(mem_write)
        ram[address] = write_data;
end
endmodule