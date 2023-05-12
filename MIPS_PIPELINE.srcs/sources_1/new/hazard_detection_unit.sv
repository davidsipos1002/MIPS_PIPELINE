module hazard_detection_unit(id_ex_mem_to_reg, if_id_mem_write, id_ex_rt,
if_id_mem_to_reg, if_id_rs, if_id_rt, if_id_branch, id_ex_reg_write, id_ex_rd,
pc_write, if_id_write, control_zero);

input logic id_ex_mem_to_reg;
input logic if_id_mem_write;
input logic [2:0]id_ex_rt;
input logic if_id_mem_to_reg;
input logic [2:0]if_id_rs;
input logic [2:0]if_id_rt;
input logic if_id_branch;
input logic id_ex_reg_write;
input logic [2:0]id_ex_rd;
output logic pc_write;
output logic if_id_write;
output logic control_zero;

//detect stall for lw
always_comb
begin
    if((id_ex_mem_to_reg && (
        ((if_id_mem_write || if_id_mem_to_reg) && id_ex_rt == if_id_rs) ||
        (!if_id_mem_to_reg && (id_ex_rt == if_id_rs || id_ex_rt == if_id_rt)))) ||
        (if_id_branch && id_ex_reg_write && (id_ex_rd == if_id_rs || id_ex_rd == if_id_rt)))
    begin
        pc_write = 1'b0;
        if_id_write = 1'b0;
        control_zero = 1'b1;
    end
    else
    begin
        pc_write = 1'b1;
        if_id_write = 1'b1;
        control_zero = 1'b0;
    end
end
endmodule