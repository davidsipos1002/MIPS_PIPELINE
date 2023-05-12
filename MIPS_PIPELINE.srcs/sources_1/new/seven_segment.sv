module seven_segment(clk, data, an, cat);

input clk;
input logic [31:0]data;
output logic [7:0]an;
output logic [6:0]cat;

logic [15:0]cnt;
logic [3:0]digit;

always_ff @(posedge clk)
begin
    cnt <= cnt + 1;
end

always_comb
begin
    case(cnt[15:13])
        3'b000: an = 8'b11111110;
        3'b001: an = 8'b11111101;
        3'b010: an = 8'b11111011;
        3'b011: an = 8'b11110111;
        3'b100: an = 8'b11101111;
        3'b101: an = 8'b11011111;
        3'b110: an = 8'b10111111;
        3'b111: an = 8'b01111111;
        default an = 8'b1111110;
    endcase
end

always_comb
begin
    case(cnt[15:13])
        3'b000: digit = data[3:0];
        3'b001: digit = data[7:4];
        3'b010: digit = data[11:8];
        3'b011: digit = data[15:12];
        3'b100: digit = data[19:16];
        3'b101: digit = data[23:20];
        3'b110: digit = data[27:24];
        3'b111: digit = data[31:28];
        default digit = 4'b0000;
    endcase
end

always_comb
begin
    case(digit)
        4'b0001: cat = 7'b1111001;
        4'b0010: cat = 7'b0100100;
        4'b0011: cat = 7'b0110000;
        4'b0100: cat = 7'b0011001;
        4'b0101: cat = 7'b0010010;
        4'b0110: cat = 7'b0000010;
        4'b0111: cat = 7'b1111000;
        4'b1000: cat = 7'b0000000;
        4'b1001: cat = 7'b0010000;
        4'b1010: cat = 7'b0001000;
        4'b1011: cat = 7'b0000011;
        4'b1100: cat = 7'b1000110;
        4'b1101: cat = 7'b0100001;
        4'b1110: cat = 7'b0000110;
        4'b1111: cat = 7'b0001110;
        default  cat = 7'b1000000;
    endcase
end
endmodule
