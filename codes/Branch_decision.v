module Branch_decision 
(
  branch_inst_in, 
  comparison_in,
  decision_out
);

input branch_inst_in;
input comparison_in;
output reg decision_out;

always @(branch_inst_in or comparison_in) begin
    if (branch_inst_in && comparison_in) begin
        decision_out = 1'b1;                        //1 if branch is taken
    end
    else begin
         decision_out = 1'b0;
    end
end

endmodule
