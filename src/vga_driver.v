module vga_driver (input clk,                  // 系统 50MHz 时钟
                       input rstn,             // 系统复位
                       output [3:0] VGA_R, // VGA 红色分量
                       output [3:0] VGA_G, // VGA 绿色分量
                       output [3:0] VGA_B, // VGA 蓝色分量
                       output VGA_HS,          // VGA 行同步信号
                       output VGA_VS,          // VGA 场同步信号
                       // VGA bus
                       output [9:0] vga_addr,  // VGA 访问存储器地址
                       input [31:0] vga_data); // VGA 存储器数据

    // 分辨率为640*480时行时序各个参数定义
    parameter       C_H_SYNC_PULSE   = 96,
                    C_H_BACK_PORCH   = 48,
                    C_H_ACTIVE_TIME  = 640,
                    C_H_LINE_PERIOD  = 800;

    // 分辨率为640*480时场时序各个参数定义
    parameter       C_V_SYNC_PULSE   = 2,
                    C_V_BACK_PORCH   = 33,
                    C_V_ACTIVE_TIME  = 480,
                    C_V_FRAME_PERIOD = 525;

    parameter       C_BLACK_MARGIN_WIDTH = (C_H_ACTIVE_TIME - C_V_ACTIVE_TIME) / 2;
    parameter       C_BLOCK_SIZE         = 30;

    reg [11:0]      R_h_cnt;        // 行时序计数器
    reg [11:0]      R_v_cnt;        // 列时序计数器

    wire            W_active_flag;  // 激活标志，当这个信号为1时RGB的数据可以显示在屏幕上

    //////////////////////////////////////////////////////////////////
    // 功能：产生行时序
    //////////////////////////////////////////////////////////////////
    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            R_h_cnt <= 12'd0;
        else if (R_h_cnt == C_H_LINE_PERIOD - 1'b1)
            R_h_cnt <= 12'd0;
        else
            R_h_cnt <= R_h_cnt + 1'b1;
    end

    assign VGA_HS = (R_h_cnt < C_H_SYNC_PULSE) ? 1'b0 : 1'b1;

    //////////////////////////////////////////////////////////////////
    // 功能：产生场时序
    //////////////////////////////////////////////////////////////////
    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            R_v_cnt <= 12'd0;
        else if (R_v_cnt == C_V_FRAME_PERIOD - 1'b1)
            R_v_cnt <= 12'd0;
        else if (R_h_cnt == C_H_LINE_PERIOD - 1'b1)
            R_v_cnt <= R_v_cnt + 1'b1;
        else
            R_v_cnt <= R_v_cnt;
    end

    assign VGA_VS = (R_v_cnt < C_V_SYNC_PULSE) ? 1'b0 : 1'b1;

    assign W_active_flag = (R_h_cnt >= (C_H_SYNC_PULSE + C_H_BACK_PORCH))  &&
           (R_h_cnt <= (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_H_ACTIVE_TIME))  &&
           (R_v_cnt >= (C_V_SYNC_PULSE + C_V_BACK_PORCH))  &&
           (R_v_cnt <= (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_V_ACTIVE_TIME));

    //////////////////////////////////////////////////////////////////
    // 功能：显示方格
    //////////////////////////////////////////////////////////////////
    wire is_black = (R_h_cnt < (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_BLACK_MARGIN_WIDTH) ||
                     R_h_cnt >= (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_BLACK_MARGIN_WIDTH + C_BLOCK_SIZE * 16));
    reg[3:0] x_index, y_index;
    assign vga_addr = 10'h040 + {4'b0, x_index, 2'b0};
    always @(posedge clk) begin
        if (rstn && W_active_flag) begin
            if (R_h_cnt < (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_BLACK_MARGIN_WIDTH + C_BLOCK_SIZE)) begin
                x_index <= 0;
            end
            else if (R_h_cnt < (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_BLACK_MARGIN_WIDTH + C_BLOCK_SIZE * 2)) begin
                x_index <= 1;
            end
            else if (R_h_cnt < (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_BLACK_MARGIN_WIDTH + C_BLOCK_SIZE * 3)) begin
                x_index <= 2;
            end
            else if (R_h_cnt < (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_BLACK_MARGIN_WIDTH + C_BLOCK_SIZE * 4)) begin
                x_index <= 3;
            end
            else if (R_h_cnt < (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_BLACK_MARGIN_WIDTH + C_BLOCK_SIZE * 5)) begin
                x_index <= 4;
            end
            else if (R_h_cnt < (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_BLACK_MARGIN_WIDTH + C_BLOCK_SIZE * 6)) begin
                x_index <= 5;
            end
            else if (R_h_cnt < (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_BLACK_MARGIN_WIDTH + C_BLOCK_SIZE * 7)) begin
                x_index <= 6;
            end
            else if (R_h_cnt < (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_BLACK_MARGIN_WIDTH + C_BLOCK_SIZE * 8)) begin
                x_index <= 7;
            end
            else if (R_h_cnt < (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_BLACK_MARGIN_WIDTH + C_BLOCK_SIZE * 9)) begin
                x_index <= 8;
            end
            else if (R_h_cnt < (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_BLACK_MARGIN_WIDTH + C_BLOCK_SIZE * 10)) begin
                x_index <= 9;
            end
            else if (R_h_cnt < (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_BLACK_MARGIN_WIDTH + C_BLOCK_SIZE * 11)) begin
                x_index <= 10;
            end
            else if (R_h_cnt < (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_BLACK_MARGIN_WIDTH + C_BLOCK_SIZE * 12)) begin
                x_index <= 11;
            end
            else if (R_h_cnt < (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_BLACK_MARGIN_WIDTH + C_BLOCK_SIZE * 13)) begin
                x_index <= 12;
            end
            else if (R_h_cnt < (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_BLACK_MARGIN_WIDTH + C_BLOCK_SIZE * 14)) begin
                x_index <= 13;
            end
            else if (R_h_cnt < (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_BLACK_MARGIN_WIDTH + C_BLOCK_SIZE * 15)) begin
                x_index <= 14;
            end
            else begin
                x_index <= 15;
            end
            if (R_v_cnt < (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_BLOCK_SIZE)) begin
                y_index <= 0;
            end
            else if (R_v_cnt < (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_BLOCK_SIZE * 2)) begin
                y_index <= 1;
            end
            else if (R_v_cnt < (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_BLOCK_SIZE * 3)) begin
                y_index <= 2;
            end
            else if (R_v_cnt < (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_BLOCK_SIZE * 4)) begin
                y_index <= 3;
            end
            else if (R_v_cnt < (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_BLOCK_SIZE * 5)) begin
                y_index <= 4;
            end
            else if (R_v_cnt < (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_BLOCK_SIZE * 6)) begin
                y_index <= 5;
            end
            else if (R_v_cnt < (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_BLOCK_SIZE * 7)) begin
                y_index <= 6;
            end
            else if (R_v_cnt < (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_BLOCK_SIZE * 8)) begin
                y_index <= 7;
            end
            else if (R_v_cnt < (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_BLOCK_SIZE * 9)) begin
                y_index <= 8;
            end
            else if (R_v_cnt < (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_BLOCK_SIZE * 10)) begin
                y_index <= 9;
            end
            else if (R_v_cnt < (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_BLOCK_SIZE * 11)) begin
                y_index <= 10;
            end
            else if (R_v_cnt < (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_BLOCK_SIZE * 12)) begin
                y_index <= 11;
            end
            else if (R_v_cnt < (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_BLOCK_SIZE * 13)) begin
                y_index <= 12;
            end
            else if (R_v_cnt < (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_BLOCK_SIZE * 14)) begin
                y_index <= 13;
            end
            else if (R_v_cnt < (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_BLOCK_SIZE * 15)) begin
                y_index <= 14;
            end
            else begin
                y_index <= 15;
            end
        end
        else begin
            x_index <= 0;
            y_index <= 0;
        end
    end

    wire [15:0] data = vga_data[15:0];

    assign VGA_R = (W_active_flag && !is_black)? (data[y_index] == 0? 0: 4'b1111): 0;
    assign VGA_G = (W_active_flag && !is_black)? (data[y_index] == 0? 0: 4'b1111): 0;
    assign VGA_B = (W_active_flag && !is_black)? (data[y_index] == 0? 0: 4'b1111): 0;
endmodule
