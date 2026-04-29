module BranchUnit (
    input  [31:0] pc_ex,
    input  [31:0] rs1_value,
    input  [31:0] rs2_value,
    input  [31:0] instruction,

    output reg        branch_taken,
    output reg [31:0] branch_target
);

    localparam BEQ = 7'b110_0011;

    wire [6:0] opcode;
    assign opcode = instruction[6:0];

    // Immediate tipo B do RISC-V:
    // imm[12|10:5|4:1|11|0] = instruction[31|30:25|11:8|7|0]
    // O bit 0 sempre vale zero porque o desvio é alinhado em 2 bytes.
    wire [31:0] branch_imm;
    assign branch_imm = {
        {20{instruction[31]}},
        instruction[7],
        instruction[30:25],
        instruction[11:8],
        1'b0
    };

    always @(*) begin
        branch_taken  = 1'b0;
        branch_target = pc_ex + 32'd4;

        // BEQ: branch é decidido no estágio EX comparando os operandos já
        // corrigidos por forwarding. Se os registradores forem iguais, o PC
        // deve receber PC_EX + imediato tipo B, e os estágios jovens são
        // descartados pelo flush no processador principal.
        if (opcode == BEQ) begin
            if (rs1_value == rs2_value) begin
                branch_taken  = 1'b1;
                branch_target = pc_ex + branch_imm;
            end
        end
    end

endmodule
