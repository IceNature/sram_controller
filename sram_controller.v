`timescale 1ns / 1ps

module sram_controller(
    input clk,
    input rw,
    input en,
    input [18:0] address,
    input [15:0] data_in,
    output reg [15:0] data_out,
    output reg [18:0] sram_addr,
    inout [15:0] sram_data_inout,
    output reg sram_oe,
    output reg sram_ce,
    output reg sram_we,
    output reg sram_ub,
    output reg sram_lb,
    output read_finish,
    output write_finish
    );
    

    parameter IDLE=3'b000,
              ADDR=3'b001,
              BEGIN=3'b011,
              WAIT=3'b010,
              OPERATE=3'b110,
              END=3'b100;

    reg [2:0] status = 3'b000;
    reg [15:0] data_out_reg = 16'b0;

    assign read_finish = ((!rw && status == END) ? 1'b1 : 1'b0);
    assign write_finish = ((rw && status == END) ? 1'b1 : 1'b0);
    assign sram_data_inout = rw ? data_out_reg : 16'bz;

    always @(posedge clk) begin
        case (status)
            IDLE: begin
                if (en)
                    status <= ADDR;
                else
                    status <= IDLE;
            end
            ADDR: status <= BEGIN;
            BEGIN: status <= WAIT;
            WAIT: status <= OPERATE;
            OPERATE: status <= END;
            END: status <= IDLE;
            default: status <= IDLE;
        endcase
    end

    always @(posedge clk) begin
        case (status)
            ADDR: sram_addr <= address;
            END: sram_addr <= 19'b0;
            default: sram_addr <= sram_addr;
        endcase
    end

    always @(posedge clk) begin
        case (status)
        BEGIN: begin
            sram_ce <= 1'b0;
            sram_ub <= 1'b0;
            sram_lb <= 1'b0;
        end
        END: begin
            sram_ce <= 1'b1;
            sram_ub <= 1'b1;
            sram_lb <= 1'b1;
        end
        default: begin
            sram_ce <= sram_ce;
            sram_ub <= sram_ub;
            sram_lb <= sram_lb;
        end
        endcase
    end

    always @(posedge clk) begin
        if (rw && status == BEGIN)
            sram_we <= 1'b0;
        else if (status == END)
            sram_we <= 1'b1;
        else
            sram_we <= sram_we;
    end

    always @(posedge clk) begin
        if (!rw && status == BEGIN)
            sram_oe <= 1'b0;
        else if (status == END)
            sram_oe <= 1'b1;
        else
            sram_oe <= sram_oe;
    end

    always @(posedge clk) begin
        if (status == OPERATE)
            if (rw)
            begin
                data_out_reg <= data_in;
                data_out <= data_out;
            end
            else
            begin
                data_out_reg <= data_out_reg;
                data_out <= sram_data_inout;
            end
        else
        begin
            data_out_reg <= data_out_reg;
            data_out <= data_out;
        end
    end

endmodule
