module data_path
import k_and_s_pkg::*;
(
    input  logic                    rst_n,
    input  logic                    clk,
    input  logic                    branch,
    input  logic                    pc_enable,
    input  logic                    ir_enable,
    input  logic                    addr_sel,
    input  logic                    c_sel,
    input  logic              [1:0] operation,
    input  logic                    write_reg_enable,
    input  logic                    flags_reg_enable,
    output decoded_instruction_type decoded_instruction,
    output logic                    zero_op,
    output logic                    neg_op,
    output logic                    unsigned_overflow,
    output logic                    signed_overflow,
    output logic              [4:0] ram_addr,
    output logic             [15:0] data_out,
    input  logic             [15:0] data_in

);
    logic [4:0] program_counter;
    logic [4:0] mem_addr;
    logic [15:0] instruction;

    logic [1:0] a_addr;
    logic [1:0] b_addr;
    logic [1:0] c_addr;

    logic [15:0] r0;
    logic [15:0] r1;
    logic [15:0] r2;
    logic [15:0] r3;

    logic [15:0] bus_a;
    logic [15:0] bus_b;
    logic [15:0] bus_c;
    logic [15:0] ula_out;

    logic flag_zero;
    logic flag_neg;
    logic flag_unsigned;
    logic flag_signed;

    always @(posedge clk) begin // Registrador de instruções

        if(ir_enable == 1'b1) begin
            instruction <= data_in;
        end
    
    end

    always @(instruction) begin // Decodificador

        case(instruction[15:8])
        
            8'b000000000 : begin 
                decoded_instruction <= I_NOP;
            end
            8'b100000010 : begin 
                decoded_instruction <= I_LOAD;
                c_addr <= instruction[6:5];
                mem_addr <= instruction[4:0];
            end
            8'b100000100 : begin 
                decoded_instruction <= I_STORE;
                a_addr <= instruction[6:5];
                mem_addr <= instruction[4:0];
            end
            8'b100100010 : begin 
                decoded_instruction <= I_MOVE;
                a_addr <= instruction[1:0];
                b_addr <= instruction[1:0];
                c_addr <= instruction[3:2];

            end
            8'b101000010 : begin 
                decoded_instruction <= I_ADD;
                a_addr <= instruction[1:0];
                b_addr <= instruction[3:2];
                c_addr <= instruction[5:4]; 
            end
            8'b101000100 : begin 
                decoded_instruction <= I_SUB;
                a_addr <= instruction[1:0];
                b_addr <= instruction[3:2];
                c_addr <= instruction[5:4];
            end
            8'b101000110 : begin 
                decoded_instruction <= I_AND;
                a_addr <= instruction[1:0];
                b_addr <= instruction[3:2];
                c_addr <= instruction[5:4];
            end
            8'b101001000 : begin 
                decoded_instruction <= I_OR;
                a_addr <= instruction[1:0];
                b_addr <= instruction[3:2];
                c_addr <= instruction[5:4];
            end
            8'b000000010 : begin 
                decoded_instruction <= I_BRANCH;
                mem_addr <= instruction[4:0];
            end
            8'b000000100 : begin 
                decoded_instruction <= I_BZERO;
                mem_addr <= instruction[4:0];
            end
            8'b000010110 : begin 
                decoded_instruction <= I_BNZERO;
                mem_addr <= instruction[4:0];
            end
            8'b000000110 : begin 
                decoded_instruction <= I_BNEG;
                mem_addr <= instruction[4:0];
            end
            8'b000010100 : begin 
                decoded_instruction <= I_BNNEG;
                mem_addr <= instruction[4:0];
            end
            8'b111111111 : begin 
                decoded_instruction <= I_HALT;
            end
        endcase
    end

    always @(posedge clk) begin // Banco de registradores

        case (a_addr) begin

            2'b00: begin
                r0 <= bus_a;
            end
            2'b01: begin
                r1 <= bus_a;
            end
            2'b10: begin
                r2 <= bus_a;
            end
            2'b11: begin
                r3 <= bus_a;
            end

        endcase

        data_out <= bus_a;

        case (b_addr) begin

            2'b00: begin
                r0 <= bus_b;
            end
            2'b01: begin
                r1 <= bus_b;
            end
            2'b10: begin
                r2 <= bus_b;
            end
            2'b11: begin
                r3 <= bus_b;
            end

        endcase

        if(write_reg_enable == 1'b1) begin

            case (c_addr) begin

                2'b00: begin
                    r0 <= bus_c;
                end
                2'b01: begin
                    r1 <= bus_c;
                end
                2'b10: begin
                    r2 <= bus_c;
                end
                2'b11: begin
                    r3 <= bus_c;
                end

            endcase

        end

    end

endmodule : data_path
