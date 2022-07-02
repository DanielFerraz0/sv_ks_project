//control unit
module control_unit
    import k_and_s_pkg::*;
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

    typedef enum logic [3:0] {
        FETCH,
        DECODE,
        ADD,
        SUB,
        AND,
        OR,
        BZERO,
        BNEG,
        EXEC,
        LOAD,
        MOVE,
        STORE,
        BRANCH,
        PC,
        NOP,
        HALT
    } state_t;

    state_t state;

    initial begin
        state <= FETCH;
    end

    always @(posedge clk) begin

        if(rst_n == 0) begin
            state <= FETCH;
        end

        case(state)

            FETCH: begin
                ram_write_enable <= 1'b0;
                addr_sel_s <= 1'b1;
                c_sel_s <= 1'b0;
                ir_enable_s <= 1'b1;
                flags_reg_enable_s <= 1'b0;
                pc_enable_s <= 1'b0;
                write_reg_enable_s <= 1'b0;
                halt <= 1'b0;
                state <= DECODE;
            end

            DECODE: begin
            
                case(decoded_instruction)

                    I_BRANCH: begin
                        state <= BRANCH;
                    end
                    I_BNEG: begin
                        state <= BNEG;
                    end
                    I_BZERO: begin
                        state <= BZERO;
                    end
                    I_BNNEG: begin
                        state <= BNNEG;
                    end
                    I_BNZERO: begin
                        state <= BNZERO;
                    end
                    I_ADD: begin
                        state <= ADD;
                    end
                    I_SUB: begin
                        state <= SUB;
                    end
                    I_AND: begin
                        state <= AND;
                    end
                    I_OR: begin
                        state <= OR;
                    end
                    I_MOVE: begin
                        state <= MOVE;
                    end
                    I_LOAD: begin
                        state <= LOAD;
                    end
                    I_STORE: begin
                        state <= STORE;
                    end
                    I_NOP: begin
                        state <= NOP;
                    end
                    I_HALT: begin
                        state <= HALT;
                    end

                endcase

            end

            ADD: begin
                operation <= 2'b01;
                state <= EXEC;
            end

            SUB: begin
                operation <= 2'b10;
                state <= EXEC;
            end

            AND: begin
                operation <= 2'b11;
                state <= EXEC;
            end

            OR: begin
                operation <= 2'b00;
                state <= EXEC;
            end

            BZERO: begin

            end

            BNEG: begin

            end

            EXEC: begin

            end

            LOAD: begin

            end

            MOVE: begin

            end

            STORE: begin

            end

            BRANCH: begin
                state <= FETCH;
            end

            PC: begin

            end

            NOP: begin

            end

            HALT: begin

            end

        endcase

    end

endmodule : control_unit
