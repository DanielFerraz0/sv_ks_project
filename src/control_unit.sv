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
        BRANCH,
        EXEC,
        WB,
        LOAD,
        WB_LOAD,
        STORE,
        W_MEM
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
                ram_write_enable <= 1b'0;
                addr_sel_s <= 1b'1;
                c_sel_s <= 1b'0;
                ir_enable_s <= 1b'1;
                flags_reg_enable_s <= 1b'0;
                pc_enable_s <= 1b'0;
                write_reg_enable_s <= 1b'0;
                halt <= 1b'0;
                state <= DECODE;
            end

            DECODE: begin
            
                case(decoded_instruction)

                    I_BRANCH: begin
                        state <= BRANCH;
                    end
                    I_BNEG: begin
                        state <= BRANCH;
                    end
                    I_BZERO: begin
                        state <= BRANCH;
                    end
                    I_ADD: begin
                        state <= EXEC;
                    end
                    I_SUB: begin
                        state <= EXEC;
                    end
                    I_AND: begin
                        state <= EXEC;
                    end
                    I_OR: begin
                        state <= EXEC;
                    end
                    I_MOVE: begin
                        state <= EXEC;
                    end
                    I_LOAD: begin
                        state <= LOAD;
                    end
                    I_STORE: begin
                        state <= STORE;
                    end
                endcase
            end

            BRANCH: begin
                state <= FETCH;
            end

            EXEC: begin
                state <= WB;
            end

            WB: begin
                state <= FETCH;
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

        endcase

    end

endmodule : control_unit
