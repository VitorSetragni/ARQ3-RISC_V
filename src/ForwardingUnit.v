module ForwardingUnit (
    input  [4:0] idex_rs1,
    input  [4:0] idex_rs2,
    input  [4:0] exmem_rd,
    input  [4:0] memwb_rd,

    input  [6:0] idex_op,
    input  [6:0] exmem_op,
    input  [6:0] memwb_op,

    output reg [1:0] forwardA,
    output reg [1:0] forwardB
);

    localparam NO_FORWARD  = 2'b00;
    localparam FROM_MEM    = 2'b01;
    localparam FROM_WB_ALU = 2'b10;
    localparam FROM_WB_LD  = 2'b11;

    localparam LW    = 7'b000_0011;
    localparam SW    = 7'b010_0011;
    localparam BEQ   = 7'b110_0011;
    localparam ALUop = 7'b001_0011;

    reg uses_rs1;
    reg uses_rs2;

    initial begin
        forwardA = NO_FORWARD;
        forwardB = NO_FORWARD;
    end

    always @(*) begin
        forwardA = NO_FORWARD;
        forwardB = NO_FORWARD;

        uses_rs1 = (idex_op == LW) || (idex_op == SW) ||
                   (idex_op == BEQ) || (idex_op == ALUop);
        uses_rs2 = (idex_op == SW) || (idex_op == BEQ);

        // Prioridade maior para EX/MEM, pois é o resultado mais recente.
        // Apenas operações de ALU podem ser encaminhadas a partir de MEM;
        // para lw, o dado ainda não está disponível nesse ponto do ciclo.
        if (uses_rs1) begin
            if ((exmem_op == ALUop) && (exmem_rd != 5'd0) && (exmem_rd == idex_rs1)) begin
                forwardA = FROM_MEM;
            end
            else if ((memwb_op == ALUop) && (memwb_rd != 5'd0) && (memwb_rd == idex_rs1)) begin
                forwardA = FROM_WB_ALU;
            end
            else if ((memwb_op == LW) && (memwb_rd != 5'd0) && (memwb_rd == idex_rs1)) begin
                forwardA = FROM_WB_LD;
            end
        end

        if (uses_rs2) begin
            if ((exmem_op == ALUop) && (exmem_rd != 5'd0) && (exmem_rd == idex_rs2)) begin
                forwardB = FROM_MEM;
            end
            else if ((memwb_op == ALUop) && (memwb_rd != 5'd0) && (memwb_rd == idex_rs2)) begin
                forwardB = FROM_WB_ALU;
            end
            else if ((memwb_op == LW) && (memwb_rd != 5'd0) && (memwb_rd == idex_rs2)) begin
                forwardB = FROM_WB_LD;
            end
        end
    end

endmodule
