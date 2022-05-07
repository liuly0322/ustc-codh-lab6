module control (
     input [31:0] ir,
     output [2:0] control_branch,
     output control_jal,
     output control_jalr,
     output control_mem_read,
     output control_mem_write,
     output [1:0] control_wb_reg_src,
     output [2:0] control_alu_op,
     output control_alu_src1,
     output control_alu_src2,
     output control_reg_write);

wire [6:0] opcd = ir[6:0];

wire is_load    = (opcd == 7'b0000011);
wire is_branch  = (opcd == 7'b1100011);
wire is_store   = (opcd == 7'b0100011);
wire is_jal     = (opcd == 7'b1101111);
wire is_jalr    = (opcd == 7'b1100111);
wire is_auipc   = (opcd == 7'b0010111);
wire is_arith   = (opcd == 7'b0110011);
wire is_arith_i = (opcd == 7'b0010011);

// control_branch 信号
// control_branch[2]: 当前是否是跳转指令
// control_branch[1]: ir[14]，用于区分使用 alu 的哪个标志位（a=b or a<b）
// control_branch[0]: ir[12]，用于区分功能相反的跳转指令，例如 beq 和 bne
assign control_branch     = {is_branch, ir[14], ir[12]};
assign control_jal        = is_jal;
assign control_jalr       = is_jalr;
assign control_mem_read   = is_load;
assign control_mem_write  = is_store;
assign control_alu_src1   = is_auipc;
assign control_alu_src2   = is_auipc | is_arith_i | is_load | is_store;
assign control_reg_write  = ~(is_branch | is_store);

// 写回寄存器的数据来源：
// 2'b00: 来源于 alu
// 2'b01: 来源于 mdr
// 2'b10: 来源于 pc+4
// 2'b11: 暂无
reg [1:0] wb_signal;
assign control_wb_reg_src = wb_signal;
always@(*) begin
    wb_signal = 0;                    // 默认 0, 用 alu 运算结果
    if (is_load) wb_signal = 2'b01;   // 使用 mdr
    else if (is_jal | is_jalr) begin 
        wb_signal = 2'b10;            // 用下一个 pc
    end
end

// 当前仅支持处理加减法
assign control_alu_op = ((is_arith & ir[30]) | is_branch)? 3'b0 : 3'b1;

endmodule
