module mono_pulse(clk, btn, enable);

input logic clk;
input logic [4:0]btn;
output logic [4:0]enable;

logic [15:0]cnt;
logic en;
logic [4:0]q1;
logic [4:0]q2;
logic [4:0]q3;

always_ff @(posedge clk)
begin
    cnt <= cnt + 1;
end

always_comb
begin
    if (cnt == 16'hFFFF) 
    begin
        en = 'b1;
    end else 
    begin
        en = 'b0;
    end
end

always_ff @(posedge clk)
begin
    if(en) 
    begin
        q1 <= btn;
    end
end


always_ff @(posedge clk)
begin
    q2 <= q1;
    q3 <= q2;
end

assign enable = q2 & ~q3;
endmodule