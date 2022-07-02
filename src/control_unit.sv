//control unit
module control_unit
    import k_and_s_pkg::*;              // pinos de entrada e saida do controle
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

    typedef enum logic [3:0] {                  //estados da unidade de controle 
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
        state <= FETCH;                 // inicio da maquina de estados
    end

    always @(posedge clk) begin             //loop da maquina

        if(rst_n == 0) begin
            state <= FETCH;
        end

        case(state)             //switch case do estado

            FETCH: begin
                ram_write_enable <= 1'b0;  // trava  a memoria
                addr_sel <= 1'b1;           // seleciona o caminho do pc
                c_sel <= 1'b0;              // seleciona o caminha da ula
                ir_enable <= 1'b1;             //habilita o registrador de instruções
                flags_reg_enable <= 1'b0;       //desativa flags da ula
                pc_enable <= 1'b0;          //desativa o pc
                write_reg_enable <= 1'b0;   // desativa o banco de registradores
                halt <= 1'b0;       
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
                        operation <= 2'b00;   // na operação or
                        flags_reg_enable <= 1'b0; // nao aparece na ula
                        c_sel <= 1'b0; // resposta da ula
                        ir_enable <=1'b0; // nega instrução
                        state <= WB ;
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
                        if (zero_op = 1'b1) begin
                            state <= BRANCH;
                        end else begin
                            state <= PC_EN;
                        end
                    end
                    I_BNZERO: begin
                        state <= BRANCH;
                    end
                    I_BNEG: begin
                        if (neg_op = 1'b1) begin
                            state <= BRANCH;
                        end else begin
                            state <= PC_EN;
                        end
                    end
                    I_BNNEG: begin
                        state <= BRANCH;
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
                c_sel <= 1'b0;
                ir_enable <= 1'b0;
                flags_reg_enable <= 1'b1;
                write_reg_enable <= 1'b1;
                state <= WB;
            end

            WB: begin
            if(decoded_instruction <= I_MOVE)begin
                state <= FETCH;
                end
                c_sel <= 1'b0;
                state <= PC_EN;
            end

            LOAD: begin
                state <= WB_LOAD;
            end

            WB_LOAD: begin
                state <= FETCH;
            end

            STORE: begin
                state <= W_MEM;
            end

            WB_MEM: begin
                state <= FETCH;
            end

            PC_EN: begin
                pc_enable <= 1'b1;
                addr_sel <= 1'b0;
                state <= FETCH;
            end

        endcase

    end

endmodule : control_unit
