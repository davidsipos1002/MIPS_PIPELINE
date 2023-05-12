module execute(read_data1, read_data2, ext_imm, func, sa, 
alu_src, alu_op, alu_result);

input logic [15:0]read_data1;
input logic [15:0]read_data2;
input logic [15:0]ext_imm;
input logic [2:0]func;
input logic sa;
input logic alu_src;
input logic [2:0]alu_op;
output logic [15:0]alu_result;

logic [3:0]alu_control;
logic [15:0]alu_operand;
logic [31:0]product;
logic [15:0]result;

/*
ALU control
ALU FUNCTION CODES
   --ADD 000 
   --SUB 001
   --SLL 010 
   --SRL 011 
   --AND 100 
   --OR 101 
   --XOR 110 
   --MUL 111
*/

always_comb
begin
    case (alu_op)
        3'b000: alu_control = func;
        3'b001: alu_control = 3'b000;
        3'b010: alu_control = 3'b001;
        3'b011: alu_control = 3'b100;
        3'b100: alu_control = 3'b101;
        default alu_control = 3'b000;
    endcase
end

always_comb
begin
    if(alu_src)
        alu_operand = ext_imm;
    else
        alu_operand = read_data2;
end

assign product = read_data1 * alu_operand;

always_comb
begin
    case (alu_control)
        3'b000: result = read_data1 + alu_operand;
        3'b001: result = read_data1 - alu_operand;
        3'b010:
            if(sa)
                result = {read_data1[14:0], 1'b0};
             else
                result = read_data1;
        3'b011:
            if(sa)
                result = {1'b0, read_data1[15:1]};
            else
                result = read_data1;
       3'b100: result = read_data1 & alu_operand;
       3'b101: result = read_data1 | alu_operand;
       3'b110: result = read_data1 ^ alu_operand;
       3'b111: result = product[15:0];
       default result = 16'h0000;
     endcase
end

assign alu_result = result;
endmodule