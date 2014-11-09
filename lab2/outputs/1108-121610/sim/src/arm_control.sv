
`include "arm_defines.vh"
`include "internal_defines.vh"

module arm_control(
	input [31:0] inst,
	input reg_we,
	input [31:0]cpsr_out,
	//output logic exc_en,
	output logic rd_we,
	output logic pc_we,
	output logic cpsr_we,
	output logic rn_sel,	//1:dcd_rn; 0:dcd_mul_rn
	output logic [1:0] rd_sel, 	//2:BL, R_LR; 1:dcd_rd; 0:dcd_mul_rd
	output logic [1:0] rd_data_sel,	//2: LD, mem_data; 1:alu_result; 0: BL, pc + 4, lr	
	output logic [1:0] pc_in_sel,	//2: pc; 1:pc + 4; 0: branch addr
	output logic halted,
	output is_imm,
	output logic [3:0] mem_write_en,
	output logic ld_byte_or_word,	//1: byte; 0: word
	output logic alu_or_mac,	//1: alu; 0: mac
	output up_down,			//for LD/ST, calculate mem_addr by add or sub op2
	output mac_sel, 		//MUL/MULA
	output is_for_store,
	output is_alu_for_mem_addr
);

logic exc_en;

assign is_for_store = (inst[27:26] == 2'b01) && (inst[20] == 0);
// assign is_imm = (inst[25] == 1'b0) ? 1 : 0;
/*
 * Data Processing Instruction, when inst[25] == 1, operand2 is immediate.
 * But Single Data Transfer Instruction, when inst[25] == 0, operand2 is
 * immediate
 */
assign is_imm = ((~inst[26] & inst[25]) | (inst[26] & ~inst[25])) ? 1 : 0;
assign is_alu_for_mem_addr = (inst[27:26] == 2'b01) ? 1 : 0;
assign up_down = (inst[23]) ? 1 : 0;
assign mac_sel = (inst[21]) ? 1 : 0;

always_comb begin
	case (inst[31:28])
		 `COND_EQ: exc_en = cpsr_out[30] ? 1 : 0;
		 `COND_NE: exc_en = cpsr_out[30] ? 0 : 1;
	         `COND_GE: exc_en = (cpsr_out[31] == cpsr_out[28]) ? 1 : 0;
		 `COND_LT: exc_en = (cpsr_out[31] != cpsr_out[28]) ? 1 : 0;
		 `COND_GT: exc_en = (~cpsr_out[30] && (cpsr_out[31] == cpsr_out[28])) ? 1 : 0;
		 `COND_LE: exc_en = (cpsr_out[30] || (cpsr_out[31] != cpsr_out[28])) ? 1 : 0;
		 default: exc_en = 1;
	 endcase
end

always_comb begin
	if (!exc_en) begin
		rd_we = 1'b0;
		pc_we = 1'b1;
		cpsr_we = 1'b0;
		rn_sel = 1'bx;
		rd_sel = 'x;
		rd_data_sel = 'x;
		pc_in_sel = 1;
		halted = 1'b0;
		mem_write_en = 0;
		ld_byte_or_word = 1'bx;
		alu_or_mac = 1'bx;
	end else if (inst[27:24] == 4'hf) begin
		rd_we = 1'b0;
		pc_we = 1'b0;
		cpsr_we = 1'b0;
		rn_sel = 1'bx;
		rd_sel = 'x;
		rd_data_sel = 'x;
		pc_in_sel = 2;
		halted = 1'b1;
		mem_write_en = 0;
		ld_byte_or_word = 1'bx;
		alu_or_mac = 1'bx;
	end else if (inst[27:25] == 3'b101) begin
		pc_we = 1'b1;
		cpsr_we = 1'b0;
		rn_sel = 1'bx;
		pc_in_sel = 0;
		halted = 1'b0;
		mem_write_en = 0;
		ld_byte_or_word = 1'bx;
		alu_or_mac = 1'bx;
		if (inst[24] == 1'b0) begin	//B
			rd_we = 1'b0;
			rd_sel = 'x;
			rd_data_sel = 'x;
		end else begin
			rd_we = 1'b1;
			rd_sel = 2;
			rd_data_sel = '0;
		end
	end else if (inst[27:26] == 2'b01) begin
		pc_we = 1'b1;
		cpsr_we = 1'b0;
		rn_sel = 1'b1;
		rd_sel = 1;
		pc_in_sel = 1;
		halted = 1'b0;
		alu_or_mac = 1'b1;

		if (inst[20] == 1'b1) begin 	//LOAD
			rd_we = 1'b1;
			rd_data_sel = 2;
			mem_write_en = 0;
			ld_byte_or_word = (inst[22]) ? 1 : 0;
		end else begin			//STORE
			rd_we = 1'b0;
			rd_data_sel = 1;
			mem_write_en = 4'hf;
			ld_byte_or_word = 1'bx;
		end
	end else if ((inst[27:25] == 3'b000) && (inst[7:4] == 4'b1001)) begin //MUL
		rd_we = 1'b1;
		pc_we = 1'b1;
		cpsr_we = (inst[20] == 1'b1) ? 1 : 0;
		rn_sel = 1'b0;
		rd_sel = 0;
		rd_data_sel = 1;
		pc_in_sel = 1;
		halted = 1'b0;
		mem_write_en = 0;
		ld_byte_or_word = 1'bx;
		alu_or_mac = 1'b0;
	end else begin	//DATA PROCESSING
		rd_we = (reg_we) ? 1'b1 : 1'b0;
		// rd_we = 1'b1;
		pc_we = 1'b1;
		cpsr_we = (inst[20] == 1'b1) ? 1 : 0;
		rn_sel = 1'b1;
		rd_sel = 1;
		rd_data_sel = 1;
		pc_in_sel = 1;
		halted = 1'b0;
		mem_write_en = 0;
		ld_byte_or_word = 1'bx;
		alu_or_mac = 1'b1;
	end
end
endmodule
