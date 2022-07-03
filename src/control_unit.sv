//control unit
module control_unit
    import k_and_s_pkg::*;  // Pinos de entrada e saida do controle
    (
        input  logic                    rst_n,
        input  logic                    clk,
        output logic                    branch,
        output logic                    pc_enable,
        output logic                    ir_enable,
        output logic                    write_reg_enable,
        output logic                    addr_sel,
        output logic                    c_sel,
        output logic              [1:0] operation,
        output logic                    flags_reg_enable,
        input  decoded_instruction_type decoded_instruction,
        input  logic                    zero_op,
        input  logic                    neg_op,
        input  logic                    unsigned_overflow,
        input  logic                    signed_overflow,
        output logic                    ram_write_enable,
        output logic                    halt
    );

    typedef enum logic [3:0] {   // Estados da unidade de controle 
        FETCH,
        DECODE,
        BRANCH,
        EXEC,
        WB,
        LOAD,
        WB_LOAD,
        STORE,
        W_MEM,
        PC_EN
    } state_t;

    state_t state;

    initial begin
        state <= FETCH;  // Inicio da maquina de estados
    end

    always @(posedge clk) begin  //Loop da maquina

        if(rst_n == 0) begin
            state <= FETCH;
        end

        case(state) //Switch case do estado

            FETCH: begin
                addr_sel <= 1'b1;          // Seleciona o caminho do pc
                ir_enable <= 1'b1;         // Habilita o registrador de instruções
                ram_write_enable <= 1'b0;  // Trava  a memoria
                c_sel <= 1'b0;             // Seleciona o caminha da ula
                flags_reg_enable <= 1'b0;  // Desativa flags da ula
                pc_enable <= 1'b0;         // Desativa o pc
                branch <= 1'b0;            // Desativa o desvio
                write_reg_enable <= 1'b0;  // Desativa o banco de registradores
                halt <= 1'b0;              // Desativa o halt
                state <= DECODE;
            end

            DECODE: begin
                ir_enable <= 1'b0;
                case(decoded_instruction)
    
                    I_NOP: begin
                        state <= PC_EN;
                    end
                    I_LOAD: begin
                        state <= LOAD;
                    end
                    I_STORE: begin
                        state <= STORE;
                    end
                    I_MOVE: begin
                        operation <= 2'b00;
                        state <= EXEC;
                    end
                    I_ADD: begin
                        operation <= 2'b01;
                        state <= EXEC;
                    end
                    I_SUB: begin
                        operation <= 2'b10;
                        state <= EXEC;
                    end
                    I_AND: begin
                        operation <= 2'b11;
                        state <= EXEC;
                    end
                    I_OR: begin
                        operation <= 2'b00;
                        state <= EXEC;
                    end
                    I_BRANCH: begin
                        state <= BRANCH;
                    end
                    I_BZERO: begin
                        if (zero_op == 1'b1) begin
                            state <= BRANCH;
                        end else begin
                            state <= PC_EN;
                        end
                    end
                    I_BNZERO: begin
                        if (zero_op == 1'b0) begin
                            state <= BRANCH;
                        end else begin
                            state <= PC_EN;
                        end
                    end
                    I_BNEG: begin
                        if (neg_op == 1'b1) begin
                            state <= BRANCH;
                        end else begin
                            state <= PC_EN;
                        end
                    end
                    I_BNNEG: begin
                        if (neg_op == 1'b0) begin
                            state <= BRANCH;
                        end else begin
                            state <= PC_EN;
                        end 
                    end
                    I_HALT: begin
                        halt <= 1'b1;
                    end
                endcase
            end

            BRANCH: begin
                branch <=1'b1;
                state <= PC_EN;
            end

            EXEC: begin
                if(decoded_instruction == I_MOVE) begin
                    flags_reg_enable <= 1'b0;
                end else begin
                    flags_reg_enable <= 1'b1;
                end
                state <= WB;
            end

            WB: begin
                c_sel <= 1'b0;
                write_reg_enable <= 1'b1;
                state <= PC_EN;
            end

            LOAD: begin
                addr_sel <= 1'b0;  
                state <= WB_LOAD;
            end

            WB_LOAD: begin
                c_sel <= 1'b1;
                write_reg_enable <= 1'b1;
                state <= PC_EN;
            end

            STORE: begin
                addr_sel <= 1'b0;
                state <= W_MEM;
            end

            W_MEM: begin
                ram_write_enable <= 1'b1;
                state <= PC_EN;
            end

            PC_EN: begin
                pc_enable <= 1'b1;
                addr_sel <= 1'b1;
                state <= FETCH;
            end

        endcase

    end

endmodule : control_unit
