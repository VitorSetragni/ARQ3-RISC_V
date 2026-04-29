module HazardDetectionUnit (
    input [4:0] idex_rs1,
    input [4:0] idex_rs2,
    input [4:0] exmem_rd,

    input [6:0] idex_op,
    input [6:0] exmem_op,

    output reg stall
);

    localparam LW    = 7'b000_0011;
    localparam SW    = 7'b010_0011;
    localparam BEQ   = 7'b110_0011;
    localparam ALUop = 7'b001_0011;

    reg uses_rs1;
    reg uses_rs2;

    initial begin
        stall = 1'b0;
    end

    always @(*) begin
        stall = 1'b0;

        uses_rs1 = (idex_op == LW) || (idex_op == SW) ||
                   (idex_op == BEQ) || (idex_op == ALUop);
        uses_rs2 = (idex_op == SW) || (idex_op == BEQ);

        // Load-use hazard neste pipeline didático:
        // quando a instrução em EX/MEM é um lw, o valor carregado só fica
        // disponível no estágio WB. Se a instrução em ID/EX já precisa desse
        // registrador como rs1 ou rs2, ela deve ficar parada por um ciclo para
        // receber o dado via forwarding de WB no ciclo seguinte.
        if ((exmem_op == LW) && (exmem_rd != 5'd0)) begin
            if ((uses_rs1 && (idex_rs1 == exmem_rd)) ||
                (uses_rs2 && (idex_rs2 == exmem_rd))) begin
                stall = 1'b1;
            end
        end
    end

endmodule
