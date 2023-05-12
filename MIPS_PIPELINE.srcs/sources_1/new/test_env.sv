module test_env(clk, btn, sw, led, an, cat, dp);

input logic clk;
input logic [4:0]btn;
input logic [15:0]sw;
output logic [15:0]led;
output logic [7:0]an;
output logic [6:0]cat;
output logic dp;

logic [4:0]btn_enable;
logic jump;
logic branch;
logic [15:0]instruction;
logic [15:0]pc;
logic [15:0]write_data;
logic reg_dest;
logic reg_write;
logic ext_op;
logic [15:0]read_data1;
logic [15:0]read_data2;
logic [15:0]ext_imm;
logic [2:0]func;
logic sa;
logic [2:0]alu_op;
logic alu_src;
logic mem_write;
logic mem_to_reg;
logic [15:0]read_data;
logic [2:0]rs;
logic [2:0]rt;
logic [2:0]rd;
logic [2:0]write_address;
logic [15:0]alu_result;
logic [1:0]forward_a;
logic [15:0]forward_a_mux;
logic [1:0]forward_b;
logic [15:0]forward_b_mux;
logic forward_mem;
logic [15:0]forward_mem_mux;
logic pc_write;
logic if_id_write;
logic control_zero;
logic forward_branch_a;
logic forward_branch_b;
logic [15:0]branch_a;
logic [15:0]branch_b;
logic [15:0]jump_address;
logic [15:0]branch_address;
logic pc_src;
logic [31:0]seven_seg;


struct
{
    logic [15:0]pc;
    logic [15:0]instruction;
}if_id;

struct
{
    logic reg_write;
    logic mem_to_reg;
    logic mem_write;
    logic reg_dest;
    logic alu_src;
    logic [2:0]alu_op;
    logic [2:0]func;
    logic sa;
    logic [2:0]rs;
    logic [2:0]rt;
    logic [2:0]rd;
    logic [15:0]read_data1;
    logic [15:0]read_data2;
    logic [15:0]ext_imm;
}id_ex;

struct
{
    logic mem_write;
    logic reg_write;
    logic mem_to_reg;
    logic [15:0]alu_result;
    logic [2:0]rd;
    logic [15:0]read_data2;
}ex_mem;

struct
{
    logic reg_write;
    logic mem_to_reg;
    logic [2:0]rd;
    logic [15:0]read_data;
    logic [15:0]alu_result;
}mem_wb;

mono_pulse (.clk(clk), .btn(btn), .enable(btn_enable));

//IF-begin

instruction_fetch(.clk(clk), .we(btn_enable[0]), .pc_write(pc_write), .reset(btn_enable[1]),
.branch_address(branch_address), .jump_address(jump_address), .jump(jump), .pc_src(pc_src),
.instruction(instruction), .pc_out(pc));

always_ff @(posedge clk or posedge btn_enable[1])
begin
    if(btn_enable[1])
     begin
        if_id.pc <= 16'b0;
        if_id.instruction <= 16'b0;
    end
    else if(if_id_write && btn_enable[0])
    begin
        if_id.pc <= pc;
        if_id.instruction <= instruction;
    end
end

//IF-end

//ID-begin

instruction_decode(.clk(clk), .instruction(if_id.instruction), .reg_write(mem_wb.reg_write),
.ext_op(ext_op), .write_address(mem_wb.rd), .write_data(write_data), .rs(rs), .rt(rt), .rd(rd),
.read_data1(read_data1), .read_data2(read_data2), .ext_imm(ext_imm), .func(func), .sa(sa));

control_unit(.opcode(if_id.instruction[15:13]), .reg_dest(reg_dest), .reg_write(reg_write), 
.ext_op(ext_op), .jump(jump), .branch(branch), .alu_op(alu_op), .alu_src(alu_src), 
.mem_write(mem_write), .mem_to_reg(mem_to_reg));

//branch && jump - begin
assign branch_address = pc + ext_imm;
assign jump_address = {3'b0, if_id.instruction[12:0]};

always_comb
begin
    if(forward_branch_a)
        branch_a = ex_mem.alu_result;
    else
        branch_a = read_data1;
        
    if(forward_branch_b)
        branch_b = ex_mem.alu_result;
    else
        branch_b = read_data2;
end

always_comb
begin
    if(branch && branch_a == branch_b)
        pc_src = 1'b1;
    else
        pc_src = 1'b0;
end
//branch && jump - end

always_ff @(posedge clk or posedge btn_enable[1])
begin
    if(btn_enable[1])
    begin
        id_ex.reg_write <= 'b0;
        id_ex.mem_to_reg <= 'b0;
        id_ex.mem_write <= 'b0;
        id_ex.reg_dest <= 'b0;
        id_ex.alu_src <= 'b0;
        id_ex.alu_op <= 3'b0;
        id_ex.func <= 3'b0;
        id_ex.sa <= 'b0;
        id_ex.rs <= 3'b0;
        id_ex.rt <= 3'b0;
        id_ex.rd <= 3'b0;
        id_ex.read_data1 <= 16'b0;
        id_ex.read_data2 <= 16'b0;
        id_ex.ext_imm <= 16'b0;
    end
    else if(btn_enable[0])
    begin
        if(!control_zero)
        begin
            id_ex.reg_write <= reg_write;
            id_ex.mem_to_reg <= mem_to_reg;
            id_ex.mem_write <= mem_write;
        end
        else
        begin
            id_ex.reg_write <= 1'b0;
            id_ex.mem_to_reg <= 1'b0;
            id_ex.mem_write <= 1'b0;
        end
        id_ex.reg_dest <= reg_dest;
        id_ex.alu_src <= alu_src;
        id_ex.alu_op <= alu_op;
        id_ex.func <= func;
        id_ex.sa <= sa;
        id_ex.rs <= rs;
        id_ex.rt <= rt;
        id_ex.rd <= rd;
        id_ex.read_data1 <= read_data1;
        id_ex.read_data2 <= read_data2;
        id_ex.ext_imm <= ext_imm;
    end
end

//ID-end

//EX-begin

always_comb
begin
    case(forward_a)
        2'b00: forward_a_mux = id_ex.read_data1;
        2'b01: forward_a_mux = ex_mem.alu_result;
        2'b10: forward_a_mux = write_data;
        default: forward_a_mux = id_ex.read_data1;
    endcase
    
    case(forward_b)
        2'b00: forward_b_mux = id_ex.read_data2;
        2'b01: forward_b_mux = ex_mem.alu_result;
        2'b10: forward_b_mux = write_data;
        default: forward_b_mux = id_ex.read_data2;
    endcase
end

execute(.read_data1(forward_a_mux), .read_data2(forward_b_mux),
.ext_imm(id_ex.ext_imm), .func(id_ex.func), .sa(id_ex.sa),
.alu_src(id_ex.alu_src), .alu_op(id_ex.alu_op), .alu_result(alu_result));

always_comb
begin
    if (id_ex.reg_dest)
        write_address = id_ex.rd;
    else
        write_address = id_ex.rt;
end

always_ff @(posedge clk or posedge btn_enable[1])
begin
    if(btn_enable[1])
    begin
        ex_mem.mem_write <= 1'b0;
        ex_mem.reg_write <= 1'b0;
        ex_mem.mem_to_reg <= 1'b0;
        ex_mem.alu_result <= 16'b0;
        ex_mem.rd <= 3'b0;
        ex_mem.read_data2 <= 16'b0;
    end
    else if(btn_enable[0])
    begin
        ex_mem.mem_write <= id_ex.mem_write;
        ex_mem.reg_write <= id_ex.reg_write;
        ex_mem.mem_to_reg <= id_ex.mem_to_reg;
        ex_mem.alu_result <= alu_result;
        ex_mem.rd <= write_address;
        ex_mem.read_data2 <= id_ex.read_data2;
    end
end

//EX-end

//MEM-begin

always_comb
begin
    if(forward_mem)
        forward_mem_mux = write_data;
    else
        forward_mem_mux = ex_mem.read_data2;
end

memory(.clk(clk), .mem_write(ex_mem.mem_write), .address(ex_mem.alu_result), 
.write_data(forward_mem_mux), .read_data(read_data));

always_ff @(posedge clk or posedge btn_enable[1])
begin
    if(btn_enable[1])
    begin
        mem_wb.reg_write <= 1'b0;
        mem_wb.mem_to_reg <= 1'b0;
        mem_wb.rd <= 3'b0;
        mem_wb.read_data <= 16'b0;
        mem_wb.alu_result <= 16'b0;
    end
    else if(btn_enable[0])
    begin
        mem_wb.reg_write <= ex_mem.reg_write;
        mem_wb.mem_to_reg <= ex_mem.mem_to_reg;
        mem_wb.rd <= ex_mem.rd;
        mem_wb.read_data <= read_data;
        mem_wb.alu_result <= ex_mem.alu_result;
    end
end

//MEM-end

//WB-begin

always_comb
begin
    if(mem_wb.mem_to_reg)
        write_data = mem_wb.read_data;
    else
        write_data = mem_wb.alu_result;
end

//WB-end

//FORWARDING UNIT
forwarding_unit(.id_ex_rs(id_ex.rs), .id_ex_rt(id_ex.rt),
.ex_mem_reg_write(ex_mem.reg_write), .ex_mem_rd(ex_mem.rd),
.ex_mem_mem_write(ex_mem.mem_write), .mem_wb_reg_write(mem_wb.reg_write),
 .mem_wb_rd(mem_wb.rd), .mem_wb_mem_to_reg(mem_wb.mem_to_reg),
 .if_id_branch(branch), .if_id_rs(rs), .if_id_rt(rt),
 .forward_a(forward_a), .forward_b(forward_b), .forward_mem(forward_mem),
 .forward_branch_a(forward_branch_a), .forward_branch_b(forward_branch_b));
 
 //HAZARD DETECTION UNIT
 hazard_detection_unit(.id_ex_mem_to_reg(id_ex.mem_to_reg),
 .if_id_mem_write(mem_write), .id_ex_rt(id_ex.rt), .if_id_mem_to_reg(mem_to_reg),
 .if_id_rs(rs), .if_id_rt(rt), .if_id_branch(branch), .id_ex_reg_write(id_ex.reg_write),
  .id_ex_rd(write_address), .pc_write(pc_write), .if_id_write(if_id_write),
 .control_zero(control_zero));

//DISPLAY-begin

always_comb
begin
    case (sw[2:0])
        3'b000: 
        begin
            seven_seg = {if_id.instruction, if_id.pc};
            led = 16'b0;
        end
        3'b001: 
        begin
            seven_seg = {forward_a_mux, forward_b_mux};
            led = {id_ex.rs, id_ex.rt, id_ex.rd, id_ex.reg_write, 
            forward_a, forward_b, id_ex.mem_to_reg, id_ex.alu_src};
        end
        3'b010:
        begin
            seven_seg = {ex_mem.alu_result, ex_mem.read_data2};
            led = {ex_mem.mem_write, ex_mem.reg_write, ex_mem.mem_to_reg,
                ex_mem.rd, 10'b0};
         end
         3'b011:
         begin
            seven_seg = {mem_wb.read_data, mem_wb.alu_result};
            led = {mem_wb.rd, mem_wb.reg_write, mem_wb.mem_to_reg, 11'b0};
         end
         3'b100:
         begin
            seven_seg = {id_ex.ext_imm, 16'b0};
            led = 16'b0;
         end
         default: 
         begin
            seven_seg = 32'b0;
            led = 16'b0;
         end
    endcase
 end 
seven_segment(.clk(clk), .data(seven_seg), .an(an), .cat(cat));
assign dp = 1'b1;

//DISPLAY-end
endmodule