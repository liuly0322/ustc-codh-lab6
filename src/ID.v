
module ID(
        input clk,
        input predict_IF,
        input          stall_ID,
        input          flush_ID,
        input  [4: 0]  reg_addr_debug,
        output [31: 0] reg_data_debug,
        input          ctrl_reg_write_MEM,
        input [4: 0]   reg_wb_addr_MEM,
        input [31: 0]  reg_wb_data,
        input [31: 0]  pc_IF,
        input [31: 0]  pc_4_IF,
        input [31: 0]  ir_IF,
        output load_use_hazard,
        output reg [31: 0] pc_ID,
        output reg [31: 0] pc_4_ID,
        output reg [4: 0]  rs1_ID,
        output reg [4: 0]  rs2_ID,
        output reg [31: 0] rd1_ID,
        output reg [31: 0] rd2_ID,
        output reg [4: 0]  reg_wb_addr_ID,
        output reg [31: 0] imm_ID,
        output reg [2:0] funct3_ID,
        output reg predict_ID,
        output reg ctrl_branch_ID,
        output reg ctrl_jal_ID,
        output reg ctrl_jalr_ID,
        output reg ctrl_mem_r_ID,
        output reg ctrl_mem_w_ID,
        output reg [1:0] ctrl_wb_reg_src_ID,
        output reg [3:0] ctrl_alu_op_ID,
        output reg ctrl_alu_src1_ID,
        output reg ctrl_alu_src2_ID,
        output reg ctrl_reg_write_ID
    );

    wire [2:0]  funct3;
    wire [31:0] imm_ext;
    wire control_branch;
    wire control_jal, control_jalr;
    wire control_mem_read;
    wire control_mem_write;
    wire [1:0]  control_wb_reg_src;
    wire [3:0]  control_alu_op;
    wire control_alu_src1;
    wire control_alu_src2;
    wire control_reg_write;
    wire is_compressed = pc_IF[1] || (ir_IF[1:0] != 2'b11);
    wire [15:0] ir_compressed = pc_IF[1]? ir_IF[31:16]: ir_IF[15:0];
    wire [31:0]	ir_dec;
    wire [31:0] ir = is_compressed? ir_dec: ir_IF;

    decompression u_decompression(
                      .IF_Instr_16 		( ir_compressed ),
                      .IF_Dec_32   		( ir_dec   		)
                  );

    control control_unit (.ir(ir),.funct3(funct3), .control_branch(control_branch), .control_jal(control_jal), .control_jalr(control_jalr), .control_mem_read(control_mem_read),
                          .control_mem_write(control_mem_write), .control_wb_reg_src(control_wb_reg_src), .control_alu_op(control_alu_op),
                          .control_alu_src1(control_alu_src1), .control_alu_src2(control_alu_src2), .control_reg_write(control_reg_write));

    // 寄存器及相关端口
    wire [4:0]  rs2  = ir[24:20];
    wire [4:0]  rs1  = ir[19:15];
    wire [31:0] rd1, rd2;
    register_file register (.clk(clk), .ra0(rs1), .ra1(rs2), .wa(reg_wb_addr_MEM),
                            .rd0(rd1), .rd1(rd2), .wd(reg_wb_data), .we(ctrl_reg_write_MEM),
                            .ra_debug(reg_addr_debug), .rd_debug(reg_data_debug));

    // 立即数拓展
    imm_extend imm_extend_unit (.ir(ir), .im_ext(imm_ext));

    // 是否有 load 指令相关，交给 hazard 模块处理（产生一个周期气泡）
    assign load_use_hazard = ctrl_mem_r_ID && (reg_wb_addr_ID == rs2 || reg_wb_addr_ID == rs1);

    always @(posedge clk) begin
        if (flush_ID) begin
            pc_ID   <= 0;
            pc_4_ID <= 0;
            rs1_ID  <= 0;
            rs2_ID  <= 0;
            rd1_ID  <= 0;
            rd2_ID  <= 0;
            imm_ID  <= 0;
            funct3_ID       <= 0;
            reg_wb_addr_ID  <= 0;
            predict_ID      <= 0;
            ctrl_branch_ID  <= 0;
            ctrl_jal_ID     <= 0;
            ctrl_jalr_ID    <= 0;
            ctrl_mem_r_ID   <= 0;
            ctrl_mem_w_ID   <= 0;
            ctrl_wb_reg_src_ID <= 0;
            ctrl_alu_op_ID     <= 0;
            ctrl_alu_src1_ID   <= 0;
            ctrl_alu_src2_ID   <= 0;
            ctrl_reg_write_ID  <= 0;
        end
        else if (!stall_ID) begin
            pc_ID   <=  pc_IF;
            pc_4_ID <=  pc_4_IF;
            rs1_ID  <=  rs1;
            rs2_ID  <=  rs2;
            rd1_ID  <=  rd1;
            rd2_ID  <=  rd2;
            imm_ID  <=  imm_ext;
            funct3_ID       <=  funct3;
            reg_wb_addr_ID  <=  ir[11:7];
            predict_ID      <=  predict_IF;
            ctrl_branch_ID  <=  control_branch;
            ctrl_jal_ID     <=  control_jal;
            ctrl_jalr_ID    <=  control_jalr;
            ctrl_mem_r_ID   <=  control_mem_read;
            ctrl_mem_w_ID   <=  control_mem_write;
            ctrl_wb_reg_src_ID <=  control_wb_reg_src;
            ctrl_alu_op_ID     <=  control_alu_op;
            ctrl_alu_src1_ID   <=  control_alu_src1;
            ctrl_alu_src2_ID   <=  control_alu_src2;
            ctrl_reg_write_ID  <=  control_reg_write;
        end
    end

endmodule
