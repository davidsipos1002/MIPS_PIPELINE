module forwarding_unit(id_ex_rs, id_ex_rt, ex_mem_reg_write,
ex_mem_rd, ex_mem_mem_write, mem_wb_reg_write, mem_wb_rd, mem_wb_mem_to_reg, 
if_id_branch, if_id_rs, if_id_rt, forward_a, 
forward_b, forward_mem, forward_branch_a, forward_branch_b);

input logic [2:0]id_ex_rs;
input logic [2:0]id_ex_rt;
input logic ex_mem_reg_write;
input logic [2:0]ex_mem_rd;
input logic ex_mem_mem_write;
input logic mem_wb_reg_write;
input logic [2:0]mem_wb_rd;
input logic mem_wb_mem_to_reg;
input logic if_id_branch;
input logic [2:0]if_id_rs;
input logic [2:0]if_id_rt;
output logic [1:0]forward_a;
output logic [1:0]forward_b;
output logic forward_mem;
output logic forward_branch_a;
output logic forward_branch_b;

//forward for ALU
always_comb
begin
    if(ex_mem_reg_write && ex_mem_rd == id_ex_rs)
        forward_a = 2'b01;
    else if(mem_wb_reg_write && mem_wb_rd == id_ex_rs)
        forward_a = 2'b10;
    else
        forward_a = 2'b00;
        
    if(ex_mem_reg_write && ex_mem_rd == id_ex_rt)
        forward_b = 2'b01;
    else if(mem_wb_reg_write && mem_wb_rd == id_ex_rt)
        forward_b = 2'b10;
    else
        forward_b = 2'b00;
end

//forward for MEM
always_comb
begin
    if(mem_wb_mem_to_reg && ex_mem_mem_write &&
        mem_wb_rd == ex_mem_rd)
        forward_mem = 1'b1;
    else
        forward_mem = 1'b0; 
end

//forward for BRANCH
always_comb
begin
    if(if_id_branch && ex_mem_reg_write)
    begin
        if(ex_mem_rd == if_id_rs)
            forward_branch_a = 1'b1;
        else
            forward_branch_a = 1'b0;
            
       if(ex_mem_rd == if_id_rt)
            forward_branch_b = 1'b1;
       else
            forward_branch_b = 1'b0;
    end
    else
    begin
        forward_branch_a = 1'b0;
        forward_branch_b = 1'b0;
    end
end

endmodule