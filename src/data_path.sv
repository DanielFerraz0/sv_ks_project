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

    logic [4:0] branch_out;
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

    always @(posedge clk) begin // Registrador de instru??es

        if(ir_enable == 1'b1) begin
            instruction <= data_in;
        end
    
    end

    always @(instruction) begin // Decodificador

        case(instruction[15:8])

            8'b00000000: begin 
                decoded_instruction <= I_NOP;
            end
            8'b10000001: begin 
                decoded_instruction <= I_LOAD;
                c_addr <= instruction[6:5];
                mem_addr <= instruction[4:0];
            end
            8'b10000010: begin 
                decoded_instruction <= I_STORE;
                a_addr <= instruction[6:5];
                mem_addr <= instruction[4:0];
            end
            8'b10010001: begin 
                decoded_instruction <= I_MOVE;
                a_addr <= instruction[1:0];
                b_addr <= instruction[1:0];
                c_addr <= instruction[3:2];

            end
            8'b10100001: begin 
                decoded_instruction <= I_ADD;
                a_addr <= instruction[1:0];
                b_addr <= instruction[3:2];
                c_addr <= instruction[5:4]; 
            end
            8'b10100010: begin 
                decoded_instruction <= I_SUB;
                a_addr <= instruction[1:0];
                b_addr <= instruction[3:2];
                c_addr <= instruction[5:4];
            end
            8'b10100011: begin 
                decoded_instruction <= I_AND;
                a_addr <= instruction[1:0];
                b_addr <= instruction[3:2];
                c_addr <= instruction[5:4];
            end
            8'b10100100: begin 
                decoded_instruction <= I_OR;
                a_addr <= instruction[1:0];
                b_addr <= instruction[3:2];
                c_addr <= instruction[5:4];
            end
            8'b00000001: begin 
                decoded_instruction <= I_BRANCH;
                mem_addr <= instruction[4:0];
            end
            8'b00000010: begin 
                decoded_instruction <= I_BZERO;
                mem_addr <= instruction[4:0];
            end
            8'b00001011: begin 
                decoded_instruction <= I_BNZERO;
                mem_addr <= instruction[4:0];
            end
            8'b00000011: begin 
                decoded_instruction <= I_BNEG;
                mem_addr <= instruction[4:0];
            end
            8'b00001010: begin 
                decoded_instruction <= I_BNNEG;
                mem_addr <= instruction[4:0];
            end
            8'b11111111: begin 
                decoded_instruction <= I_HALT;
            end

        endcase

    end

    always @(posedge clk) begin // Banco de registradores

        if(rst_n == 1'b0) begin
            r0 = 15'b000000000000000;
            r1 = 15'b000000000000000;
            r2 = 15'b000000000000000;
            r3 = 15'b000000000000000;
        end

        case (a_addr)

            2'b00: begin
                bus_a <= r0;
            end
            2'b01: begin
                bus_a <= r1;
            end
            2'b10: begin
                bus_a <= r2;
            end
            2'b11: begin
                bus_a <= r3;
            end

        endcase

        data_out <= bus_a;

        case (b_addr)

            2'b00: begin
                bus_b <= r0;
            end
            2'b01: begin
                bus_b <= r1;
            end
            2'b10: begin
                bus_b <= r2;
            end
            2'b11: begin
                bus_b <= r3;
            end

        endcase

        if(write_reg_enable == 1'b1) begin

            case (c_addr)

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

    always @(operation, bus_a, bus_b) begin   // ULA

        case(operation)

            2'b00: begin
                ula_out <= bus_a | bus_b;
            end
            2'b01: begin
                ula_out <= bus_a + bus_b;
            end
            2'b10: begin
                ula_out <= bus_a - bus_b;
            end
            2'b11: begin
                ula_out <= bus_a & bus_b;
            end

        endcase
        
        if(ula_out[15:0]== 'b0)begin
            flag_zero <= 1'b1;
        end else begin
            flag_zero <= 1'b0;
        end

        if(ula_out[15]== 1'b1)begin
            flag_neg <= 1'b1;
        end else begin
            flag_neg <= 1'b0;
        end

        if(operation == 2'b01) begin // Adi??o

            if((bus_a[15] == 1'b1 && bus_b[15] == 1'b1) && ula_out[15] == 1'b0) begin
                flag_signed <= 'b1;
            end else if((bus_a[15]==1'b0 && bus_b[15]==1'b0) && ula_out[15] == 1'b1) begin
                flag_signed <= 1'b1;
            end else if ((bus_a[15] == 1'b0 && bus_b[15] == 1'b1) && (bus_a >= (~bus_b) - 1'b1)) begin
                flag_unsigned <= 1'b1;              
            end else if ((bus_a[15] == 1'b1 && bus_b[15] == 1'b0) && (bus_b >= (~bus_a) - 1'b1)) begin
                flag_unsigned <= 1'b1;
            end else if (bus_a[15] == 1'b1 && bus_b[15] == 1'b1) begin
                flag_unsigned <= 1'b1; 
            end   

        end else if (operation == 2'b10) begin // Subtra??o

            if((bus_a[15] == 1'b0 && bus_b[15] == 1'b1) && ula_out[15] == 1'b1) begin 
                flag_signed <= 1'b1;
            end else if ((bus_a[15] == 1'b1 && bus_b[15] == 1'b0) && ula_out[15] == 1'b0) begin  
                flag_signed <= 1'b1;
            end else if ((bus_a[15] == 1'b1 && bus_b[15] == 1'b1) && ((~bus_a) - 1'b1 <= (~bus_b)- 1'b1)) begin
                flag_unsigned <= 1'b1; 
            end else if (bus_a[15] == 1'b1 && bus_b[15] == 1'b0) begin
                flag_unsigned <= 1'b1;
            end
        end        
    end

    always @(c_sel, data_in, ula_out) begin // MUX C_SEL

        if(c_sel ==1'b1)begin
            bus_c <= data_in;
        end else begin
            bus_c <= ula_out;
        end

    end

    always @(posedge clk) begin // FLAG REG

        if(flags_reg_enable == 1'b1) begin
            zero_op <= flag_zero;
            neg_op <= flag_neg;
            signed_overflow <= flag_signed;
            unsigned_overflow <= flag_unsigned;
        end else begin
            zero_op <= 1'b0;
            neg_op <= 1'b0;
            signed_overflow <= 1'b0;
            unsigned_overflow <= 1'b0;
        end

    end

    always @(branch, mem_addr, program_counter) begin // MUX BRANCH

        if(branch == 1'b1) begin
            branch_out <= mem_addr;
        end else if (branch == 1'b0) begin
            branch_out <= program_counter + 1;
        end

    end

    always @(posedge clk) begin // PC

        if(pc_enable == 1'b1) begin
            program_counter <= branch_out;
        end else if(rst_n == 1'b0) begin
            program_counter <= 5'b00000;
        end

    end

    always @(addr_sel, mem_addr, program_counter) begin  // MUX ADDR_SEL
    
        if(addr_sel == 1'b1) begin
            ram_addr <= program_counter;
        end else if(addr_sel == 1'b0) begin
            ram_addr <= mem_addr;
        end

    end

endmodule : data_path