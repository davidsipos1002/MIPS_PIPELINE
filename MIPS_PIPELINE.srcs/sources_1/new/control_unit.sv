module control_unit(opcode, reg_dest, reg_write, ext_op, jump, branch,
alu_op, alu_src, mem_write, mem_to_reg);

input logic [2:0]opcode;
output logic reg_dest;
output logic reg_write;
output logic ext_op;
output logic jump;
output logic branch;
output logic [2:0]alu_op;
output logic alu_src;
output logic mem_write;
output logic mem_to_reg;

always_comb
begin
    reg_dest = 1'b0;
    reg_write = 1'b0;
    ext_op = 1'b0;
    jump = 1'b0;
    branch = 1'b0;
    alu_src = 1'b0;
    alu_op = 3'b000;
    mem_write = 1'b0;
    mem_to_reg = 1'b0;
    
/*
    --ALU FUNCTION CODES
    --ADD 000 
    --SUB 001
    --SLL 010 
    --SRL 011 
    --AND 100 
    --OR 101 
    --XOR 110 
    --MUL 111
*/
    case (opcode)
        //R-type
        3'b000: 
        begin
            reg_dest = 1'b1; 
            reg_write = 1'b1;
        end
        //I-type
        //addi
        3'b001:
        begin
            reg_write = 1'b1;
            alu_src = 1'b1;
            alu_op = 3'b001; //force add
        end
        //lw
        3'b010:
        begin
            reg_write = 1'b1;
            alu_src = 1'b1;
            alu_op = 3'b001;
            mem_to_reg = 1'b1; //force add
        end
        //sw
        3'b011:
        begin
            alu_src = 1'b1;
            alu_op = 3'b001; //force add
            mem_write = 1'b1;
        end
        //beq
        3'b100:
        begin
            branch = 1'b1;
            alu_op = 3'b010; //force sub
        end
        //andi
        3'b101:
        begin
            reg_write = 1'b1;
            alu_src = 1'b1;
            alu_op = 3'b011; //force and
        end
        //ori
        3'b110:
        begin
            reg_write = 1'b1;
            alu_src = 1'b1;
            alu_op = 3'b100; //force or
        end
        //J-type
        //jump
        3'b111: jump = 1'b1;
    endcase
end

endmodule