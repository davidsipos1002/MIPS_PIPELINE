module instruction_fetch(clk, we, pc_write, reset, branch_address, 
jump_address, jump, pc_src, instruction, pc_out);

input logic clk;
input logic we;
input logic pc_write;
input logic reset;
input logic [15:0]branch_address;
input logic [15:0]jump_address;
input logic jump;
input logic pc_src;
output logic [15:0]instruction;
output logic [15:0]pc_out;

logic [0:65535] instruction_memory[15:0];
logic [15:0]pc;
logic [15:0]pc1;
logic [15:0]next_address;
logic [15:0]mux;

initial
    $readmemh("instruction_memory.mem", instruction_memory, 0);
    
always_ff @(posedge clk or posedge reset)
begin
    if(reset)
        pc <= 16'h0000;
    else
    begin
        if(pc_write && we)
            pc <= next_address;
    end
end

always_comb
begin
    case (pc_src)
        1'b0: mux = pc1;
        1'b1: mux = branch_address;
        default mux = pc1;
    endcase
end

always_comb
begin
    case (jump)
        1'b0: next_address = mux;
        1'b1: next_address = jump_address;
        default next_address = mux;
    endcase;
end

assign pc1 = pc + 1;
assign pc_out = pc1;
assign instruction = instruction_memory[pc];
endmodule