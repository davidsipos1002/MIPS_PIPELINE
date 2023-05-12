module instruction_decode(clk, instruction, reg_write, ext_op, write_address, write_data,
 rs, rt, rd, read_data1, read_data2, ext_imm, func, sa);

input logic clk;
input logic [15:0]instruction;
input logic [2:0]write_address;
input logic [15:0]write_data;
input logic reg_write;
input logic ext_op;
output logic [2:0]rs;
output logic [2:0]rt;
output logic [2:0]rd;
output logic [15:0]read_data1;
output logic [15:0]read_data2;
output logic [15:0]ext_imm;
output logic [2:0] func;
output logic sa;

logic [0:7] register_file[15:0];
logic [2:0]read_address1;
logic [2:0]read_address2;

initial
    $readmemh("register_file.mem", register_file, 0);

assign read_address1 = instruction[12:10];
assign read_address2 = instruction[9:7];
assign rs = read_address1;
assign rt = read_address2;
assign rd = instruction[6:4];

always_comb
begin
    ext_imm[6:0] = instruction[6:0];
    if(ext_op)
        ext_imm[15:7] = ~9'b0;
    else
        ext_imm[15:7] = 9'b0;
end

assign read_data1 = register_file[read_address1];
assign read_data2 = register_file[read_address2];

always_ff @(negedge clk)
begin
    if(reg_write)
        register_file[write_address] = write_data;
end

assign sa = instruction[3];
assign func = instruction[2:0];
endmodule